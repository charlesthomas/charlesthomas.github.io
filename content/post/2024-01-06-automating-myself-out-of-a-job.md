---
title: "Automating Myself Out of a Job"
date: 2024-01-06T14:39:28-05:00
categories:
    - portfolio
tags:
    - go
    - ci/cd
    - work
---

In October of 2023, for the first time since before I graduated college, I found myself without a job. 

We have lots of ways to describe what happened: laid off, let go, downsized; staff reduction, or its weirdly militaristic sibling **force reduction**; I told everyone except potential employers I got "shit-canned." But one phrase in particular, that America doesn't use but the UK does, feels the most fitting: I was made redundant. In particular, I was made redundant _by my own work_.

For the first ten years of my career, I said in every job interview that it was my career ambition to automate myself out of a job... But I never thought I'd actually do it!

Now, obviously the situation was more complicated than that. For starters I was laid off along with other employees. A thriving company in a healthy economy with low interest rates doesn't lay a bunch of folks off. On a smaller scale, creating automation and documentation aren't the only ways in which I made it easy for them to cull me from the herd. But I think I can make the case that the work I did made it possible for them to get rid of me.

# Documentation

When I joined, the company was at the tail end of transitioning onto a new deployment pipeline, that was based on a non-standard tool. As a result, there were lots of rough edges and failure conditions that weren't well understood by Engineering. Or by me. I created a wiki called "Why aren't my changes being deployed?" and populated it with everything I knew about how the system could fail. Once I understood the system myself, I started guiding people who asked for help to that doc, with the goal that it would become self-service and people weren't blocked by an under-resourced team. When the doc didn't solve the problem and issues were escalated to us, we discovered new failure conditions and I added them to the doc.

# Auditing

In those early days, the answer to "Why aren't my changes being deployed?" was often "because someone locked the resource." The CD tool we used could "lock" individual resources (or even entire clusters), so that it would not change them despite someone merging changes. This was really helpful during incidents, or for testing changes before committing them. However any resource could be locked, and "locks" were just a special metadata annotation. Plus there were multiple resources involved in rolling out even the simplest change (more on this later). This meant it wasn't always obvious that your deployment was blocked by a locked resource. And even if it was, there was no way of knowing why it was locked or who put the lock in place.

My next major project involved adding new functionality to an existing internal CLI tool; giving it the ability to lock and unlock resources, as well as list all locked resources in an environment. Crucially, in addition to the lock annotation, the tool applied additional annotations when locking a resource. Those annotations included _who locked the resource_ and _when_. Optionally, the user locking a resource could also include a _why_ by referencing a ticket number. Unlocking resources with the tool removed all of the extra annotations as well. Listing the locked resources showed not just the resource kind and name, but also the name of the locker, the timestamp, and the reason (if one was given).

# Performance

Even after we had documented every possible failure condition of the deployment pipeline, we still had a problem: it was slow. It was so slow, that by the time people realized something was wrong their patience had already worn thin. People didn't want to start stepping through a troubleshooting guide an hour after they thought their deployment had started rolling out.

The pipeline supported about 20 different environments. As a result, templating was heavily utilized; not just for the services being deployed, but also for the components of the pipeline itself. In the system we used, the templates were CRDs that were applied into the system and then rendered into other Kubernetes resources (deployments, statefulsets, etc) live in the environment. Before that could happen, several other templates had to be rendered first; also live in the environment.

The tool consisted of two different components, both of which ran on a 5 minute loop, and each with their own CRD. One component pulled things out of S3 and applied them into the cluster, and the other rendered the template resources into other resources. Every 5 minutes the S3 downloader would re-apply the config into the system. The template renderer ran on a separate 5 minute loop. The pipeline had to render 3 different sets of resources before it even knew which version of the application templates being deployed should be downloaded into the environment and then rendered. This meant that if you got really lucky, your deployment could theoretically roll out in as few as 10 minutes. If you got really unlucky, it could take upwards of 45 minutes **even if nothing was wrong**.

In addition to the 5 minute timeout loop, both the components in the pipeline utilized the Kubernetes watch API. When a custom resource of the CRD type the component provided was changed, the Kubernetes API would send an event to that component, which would cause it to reprocess that resource. IE it would either detect that the S3 resource changed and trigger it to be reapplied from S3, or the template component would detect that a template spec had changed and the template would be re-rendered. However because of the way the pipeline was designed, when the pipeline meta-templates changed (the templates that drove the pipeline itself), they weren't changing any of the resources being watched by the watch API.

Redesigning the pipeline wasn't a feasible option, but I was able to find a solution anyway. I was able to get a PR merged to the upstream CD tool so that templates could be rendered locally to disk, rather than only working in a live Kubernetes environment.

Once that was done, we were able to render the pipeline's meta-templates in CI rather than live in each environment. By rendering all the templates in advance and uploading their output to S3, instead of rendering them one at a time in the live environment, we reduced the number of times we had to wait on the 5 minute event loop timeout from at least 3 to exactly 1. It also changed the system so that when resources were changed by the pipeline, they were the actual resources that the CD components were actually watching through the Kubernetes watch API.

In other words, I reduced the deployment pipeline time from "at least 15 but upwards of 45 minutes" to "no more than 5 minutes after CI finishes."

# Testing

Adding local file output to the template renderer had the added benefit of enabling better local testing for our engineers. They could test locally with real data using the real template renderer, rather than using alternative tools that mimicked the functionality by duplicating the spec, but required test data in a different format.

# Troubleshooting

Before I started working there, someone had the idea to inject build metadata into the Kubernetes resources as part of CI. This metadata included the repo to which the resource belonged, as well as the branch & SHA of the repo the file was rendered from, and even the specific CI job number that did the rendering. Having this information was tremendously useful when trying to troubleshoot environmental issues. _If the data existed._ The trouble was that it was up to the individual teams to ensure that metadata got injected into each resource of a repo they controlled. How this worked and how to set it up correctly was either not well communicated or not well understood (probably both). As a result most _templates_ had the metadata, but _the resources those templates rendered_ did not. A big part of the point of that metadata was to be able to look at any resource in the cluster and map it back to the template that rendered it and / or the repo it lived in just by looking at the metadata. But if you only included that data in the template, then you had to already know where a resource came from in order to figure out where it came from. Not very useful.

To address this problem, I taught myself Go and used it to build a new tool to do the metadata injection. At that point in time, almost all of the tooling used in the deployment pipeline was off-the-shelf open-source software. This included the tool we were using to inject the metadata. By writing a new tool myself, I was able to inject the metadata into all of the resources being sent to S3 regardless of how it had been setup by the maintainers. This meant that when people were looking at resources they weren't familiar with, they actually had the metadata to track it back to the originating repo; functionality that had always been intended but rarely actually existed.

# Distribution

As mentioned, all of the pipeline tooling was off-the-shelf open-source software. In order to bypass the problem of dependency management, everything ran in containers triggered by `make` commands. This was a really clever solution, undermined by two major problems:
1. A lot of people hated having to use `make`
2. None of it could be used in a container without running into Docker-in-Docker complications

A huge part of the reason I chose to implement the metadata injection tool in Go was because I knew it would be a highly portable, entirely self-contained binary. Eventually it occurred to me that the majority of the pipeline tooling was similar. Almost all of the tools were standalone executables that could be run anywhere without installation processes or elevated privileges.

... long story short, I built a package manager. `please` (Program Location, Extraction, And Systematic Execution) is a Go CLI tool that replaced all of the Docker containers. Instead of something like `docker run mikefarah/yq` you could `please run yq`. If you didn't already have `yq` installed, `please` would install it on the fly before running it. Additionally it supported multiple versions of the same tool, so that if a user worked in different repos with different versions of the same tool they didn't have to worry about version conflicts. Eventually we even built support for Python and Node apps into `please` so that if you tried to do something like `please run yamllint` it would created a dedicated Python virtualenv for that `yamllint` version (if it didn't already exist). In addition to open source / external programs, `please` could also install the metadata injection tool previously detailed.

# Automation

Even after all this time and effort, we still had people getting tripped up by the deployment pipeline. Someone's CI job would cut a new version and then die silently and without notice before it could upload everything to S3. Someone else would make "just a minor change" to their resources and get the YAML indentation wrong without validating it. A very old service would need an urgent patch and no one noticed the apiVersion of the template CRD was deprecated.

About two years ago, I got the idea that I think ultimately lead to my downfall: `production-certifier`.

The idea behind `production-certifier` was simple: take every operational problem we could and shift it left into a CI failure.

If the Kubernetes manifests you're trying to rollout aren't actually in S3, fail CI.
If your resources don't match the spec, fail CI.
If your CI job itself is misconfigured, fail CI.

I've never done anything in my career that I'm as proud of as `production-certifier`. Effectively it's just a test framework and test suite. But it was designed to be fast, portable, and capable of providing actionable feedback; and it was all of those things.

While it was intended to run against a small number of application version changes at once, it utilized go routines to be as performant as possible. I witnessed it run 400 tests in less than 10 seconds.

All of the tests that made use of external tools used `please` to run them, and `production-certifier` itself was runnable via `please`. This meant that in addition to always running in the infrastructure-as-code repos that set the versions of all the micro-services in the application stack, it could also run in any individual application's CI with a single command invocation: `please run production-certifier`.

It was not possible to add a new test to `production-certifier` without creating documentation for that test. Its CI would detect that there was a new test without a corresponding markdown doc, and fail the build until you added one. That documentation explained what the test was doing, why the test was necessary, and what to do if the test failed. By default all of that information would be printed to the console. Additionally if `production-certifier` could find an open PR associated with the changes when running in CI, it would also add a comment on the PR with clickable links back to the documentation on what to do about each individual test failure.

In other words: **it did my job for me**, and it did it faster and more proactively than I could.
