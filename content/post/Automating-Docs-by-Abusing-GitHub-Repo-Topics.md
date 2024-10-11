---
title: "Automating Docs by Abusing GitHub Repo Topics"
date: 2024-10-10T21:18:15-04:00
tags:
    - bash
    - ci/cd
    - github
    - homelab
    - jq
    - kubernetes
---
After [I got laid off last year](https://charlesthomas.dev/blog/automating-myself-out-of-a-job-2024-01-06/),
I built a home lab k3s cluster to keep my skills sharp while I was job hunting.
Initially I kept all the manifests in a mono repo, but I decided to break it up into micro services repos.
This solved several problems, but it created another:
I want to be able to link to it easily.

When I broke the mono repo apart, I did have the presence of mind to give each micro service repo a templated name: “homelab-<service>” (eg [homelab-metallb](https://github.com/charlesthomas/homelab-metallb)).
When I wanted to link to everything, [I linked to a GitHub search](https://github.com/search?q=owner%3Acharlesthomas+homelab&type=repositories).
This *technically* worked, but felt like a hack.

I knew the best option would be to build out [the original mono repo's](https://github.com/charlesthomas/homelab) `README` and link to each micro service repo there.
That way I could categorize everything, and generally have more control over the presentation.

I know myself well enough to know I'd never keep that up to date on my own, so for months I've been chewing on the problem of automating it.

Over the weekend it occurred to me that I could build a `category` field into the [🤖 Templatron](https://github.com/charlesthomas/templatron) template I use to flesh out new micro services: [homelab-template](https://github.com/charlesthomas/homelab-template).

There are already over 40 micro services running in my home lab, which meant that it was not going to be a small amount of work to update all of the existing repos to add a category.
I started hacking on a `bash` script that would use GitHub's cli tool `gh` to append the cathegory into each repo's `.homelab-template.yaml` config file.
While digging through the `gh --help` menus, I realized I could add topics to repos.

This gave me an idea: if I just gave all the home lab repos the `homelab` topic, I could link to the topic instead of the original search, and I'd be done.
Unfortunately, this had a couple problems. First, clicking a topic in the GitHub UI takes you to a list of **all** repos across all of GitHub that have that topic, so in order to link to only mine I'd have to use a search anyway.
Not only that, but this solution didn't address the presentation at all.

Repos can have multiple topics.
It eventually occurred to me that I could give every home lab micro service repo the `homelab` topic, and then also give another for categorization.
Since adding tags is supported by `gh` I could do this easily through a bash loop, and I wouldn't have to worry about updating their `.homelab-template.yaml` config.

One thing that's already in the homelab-template is a category for [homepage](https://gethomepage.dev). Anything in my with a web UI shows up in my `homepage`
 dashboard.
 I used those categories as a jumping off point.
 Additionally, I had tried to keep the `README` up to date manually at some point, and had categorized those things as well.
 What I found was that most things just needed a single category, but for Infrastructure stuff I wanted subcategories, like Storage, HTTP, Observability, etc.
 
 In an effort to make updating the topics for 40+ repos as simple as I could (and reduce the likelihood of typos), I threw together [this script](https://github.com/charlesthomas/steal-this-code/blob/main/bash/repo-topics.bash).
 It pulls all my repos with the `homelab` tag using `gh`, and prompts for a category.
 The categories I knew I wanted could be entered from a numbered menu, and if none of them applied I could manually enter whatever I wanted.
 Additionally if I chose the `Infrastructure` topic, it would prompt me for a subcategory.
 Then it would add the new topic to the repo: `homelab-category[-subcategory]`

Now that all the existing repos had both the `homelab` and `homelab-category` topics, I could [write another script](https://github.com/charlesthomas/homelab/blob/main/bin/generate_list.bash) that again uses `gh` to iterate over all repos with the `homelab` topic, and inject them into a markdown stub file based on the additional `homelab-category` topic.
Once all the stubs are generated (including one that's generated for infra with all its subcategories as individual stubs), they get sorted and dumped into the `README`

In order to make sure these are kept up to date, I [built a GitHub Action](https://github.com/charlesthomas/homelab/blob/main/.github/workflows/update-readme.yaml) to run the `README` updater script once per week.
I also [updated the script I use when creating a new homelab repo](https://github.com/charlesthomas/homelab-template/blob/main/bin/add-repo.bash#L19-L21) to add the `homelab` topic, and then prompt me for the `homelab-category` topic and add that, too.

One final piece: now that I know how easy GitHub makes it to add topics, I opened a [🤖 Templatron issue](https://github.com/charlesthomas/templatron/issues/83) to add an extra config to the `autoscan` feature so that it can save on GitHub API calls by searching for repos with a specific topic.
