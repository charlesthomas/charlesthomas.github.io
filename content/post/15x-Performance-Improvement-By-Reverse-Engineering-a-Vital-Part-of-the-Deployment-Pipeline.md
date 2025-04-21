---
title: "15x Performance Improvement by Reverse Engineering a Vital Part of the Deployment Pipeline"
date: 2025-04-21T19:13:17-04:00
categories:
    - portfolio
tags:
    - bash
    - go
    - ci/cd
    - jsonnet
    - work
---

There was about a month of overlap between when I started my new job, and when the person who knew the most about the company's CI/CD system left. In that time we had a series of meetings where he offloaded as much info as he could about how everything worked. At our last knowledge share, I had the presence of mind to ask two questions that turned out to be very important:

1. What work are you most proud of?
2. What part of the system needs the most improvement?

Having the answer to the first question told me what was safe to ignore, while I really dug in to understanding how to address the second.

The thing that needed the most attention is a bespoke system responsible for automatically promoting images through the various deployment phases using a combination of `go`, `bash`, and `jsonnet`. Over the course of the last year, I reverse-engineered and completely rewrote the entire system. The _fastest_ I ever saw the **old** system go was more than fifteen times slower than the _slowest_ I've observed the new version accomplish the same task.

This post _isn't_ about how the system works; it's about what I did to reverse engineer it, why I decided to rewrite it, and what I did to improve the performance. Because of this I will only be including the bare minimum of technical information in order to explain what I did and -- maybe more interestingly -- what I **didn't do** in the process.

# Summary

## What I Did

- Re-implemented the `jsonnet` pieces in `go`
- Created a secondary schema for faster data referencing & updating
- Added cacheing for results of expensive & repetitive operations

## What I Didn't Do

- Use a `go` library for `git`
- Import the ArgoCD `Application` schema
- Use goroutines

# Rewriting the `jsonnet`

It wasn't my intention to rewrite anything when I started studying the system. I was just seeking to understand how it worked. I had read the docs & the code, and figured out how to run everything locally without making any changes. I had never heard of [jsonnet](https://jsonnet.org/) before starting this job; I'm still not very comfortable with it, but after reviewing the code I had a hunch that at least some of the unintuitive behavior was coming from this part of the code base.

The first thing the system does is use a `bash` script to scrape some of our [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) `Applications` for their health & sync status. That data was fed into the `jsonnet` to filter out the unhealthy & unsynced `Applications`, and map the image digests for images in healthy `Applications` to the commit in the [config-as-code](https://octopus.com/blog/config-as-code-what-is-it-how-is-it-beneficial) repo that deploys them.

My hypothesis was that the `jsonnet` was being overly aggressive in considering images unhealthy. After struggling mightily to confirm this by adjusting the `jsonnet` directly, I wrote a separate `go` program that reimplemented what I thought the logic _should have been_. Since I had already figured out how to run everything locally, I started running the `jsonnet` and my `go` rewrite in parallel. Fairly quickly I started finding cases that proved I was correct, but it took a **very** long time to understand what the `jsonnet` was actually doing.

It's hard to explain what the actual bug was, except to say that "unhealthyness" could cascade through ArgoCD `Applications` and images such that images that should have been considered healthy were poisoned by a chain of other things being considered unhealthy due to their association with something else. It was so hard to conceptualize that I ended up building a feature into my `go` rewrite that would explain in plain English the chain of reasons for why an image wasn't being promoted.

> `A` is unhealthy because of `B`. `B` is unhealthy because of `C`. `C` is unhealthy because of `D`. `D` is unhealthy because its ArgoCD `status` is `syncing`.

# Deciding to Rewrite the `go`

At this point I felt like a had a really good grasp on images not promoting when ArgoCD was reporting them healthy, but we also had the opposite problem: images being promoted when they **weren't** healthy. This lead me to dig deeper into the system's `go` code.

Despite 2+ years of experience writing `go`, I struggled understanding this part of the code base, too. I thought I understood most, but definitely not all, of what it was doing; and I certainly didn't understand _why_ it was doing it. Since rewriting the `jsonnet` from scratch had already worked so well to help me understand that part of the code, I figured I'd do the same thing with the `go` code.

# Redesigning the Schema

A big part of the confusion for me was in the structure of the data in the config-as-code repo. The key information the system needs isn't much:
- image URL, versioned by digest
	- eg `docker.io/example/not-a-real-image@sha256:1234567890abcdef`
- upstream commit that generated that image
- commit that deployed it from the config-as-code repo

This info is stored across 4 `json` files; 3 of which are arrays of objects. A big part of the slowness in the `go` code was the same thing that made it hard to read: there were **a lot** of 
[O(N^2) loops](https://www.geeksforgeeks.org/what-does-big-on2-complexity-mean/)
in order to correlate one part of the data with another, due to the multiple arrays.

The first thing I did in rewriting the `go` code was restructure the schema as a series of objects keyed by the un-versioned image URL (`docker.io/example/not-a-real-image`). Once I had the new schema, I wrote conversion functions to translate from v1 to v2 and from v2 back to v1. This allowed me to make iterating over the data a lot easier to follow in the code, significantly reduced the run time, and preserved compatibility with the existing version of the system. Compatibility meant that I could continue the pattern of running the two versions of the code alongside each other to compare their output and ensure the rewrite was producing identical behavior to the original.

# Implementing the ArgoCD `Application` Schema From Scratch

The ArgoCD [`Application` CRD](https://github.com/argoproj/argo-cd/blob/master/manifests/crds/application-crd.yaml) is **enormous**, and we don't use that much of it; about a dozen properties. I was able to define a version of its schema that meets all of the needs of the promotion system in about 120 lines of `go` (including blank formatting lines and comments). Doing so reduced the memory required to hold all of the `Application` data by about 95%. This is due to the fact that `go`'s standard `encoding/json` discards all data that isn't defined in the `struct` you're `Unmarshal`ing into.

# Cacheing `git` Results

The system makes heavy use of a few `git` commands in order to ensure that it's always promoting from the **oldest** commit of the config-as-code repo that it can, that's still **newer** than what's been promoted before. Any one of these commands doesn't take all that long, but the old system was running the same ones multiple times with the same inputs. By adding in a cache of results, keyed by the inputs, the new system never has to run the same expensive command more than once.

# Shelling Out for `git`

The original system used a `git` library that had two big problems. First, it wasn’t a client for executing commands so much as it was an attempt to completely reimplement `git` from scratch. This made it **very** difficult to use, even for someone who’s been using `git` for nearly 15 years. It would have been substantially harder to figure out which `git` operations the original system was doing if it hadn't been for some comments left behind by whoever wrote it. The second problem is that it's incomplete. At least one of the "archaeology" commands I needed to run wasn't available via this library. So I needed a way to shell-out to `git` whether I used the library or not. I decided to leave it out. Not only is the resulting code easier to read, but it's also easier to understand what `git` operations are being run, because they're right there in the code; not obscured away by a reimplementation of the `git` internals.

# Not Using Goroutines

Aside from the frequent nested loops, the thing that made the old code hardest to read was its goroutines. One of the reasons I always struggle with JavaScript is the frequent use of nested anonymous functions. If they're more than a line or two, the code becomes unreadable very quickly. Goroutines can have the same problem, so when I first started rewriting everything I left them out, thinking that I could go back and add them later after I fully understood the flow.

As I've mentioned several times, I was constantly running the new and old implementations alongside each other, so that I could be sure the new version produced identical output. (This whole project started out as an exercise in confirming I understood the old system.) Once I started seeing how much faster the new version was, I realized it wasn't worth the complexity to go back and add them in.
