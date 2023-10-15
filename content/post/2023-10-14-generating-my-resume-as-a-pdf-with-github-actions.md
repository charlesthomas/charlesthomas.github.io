---
title: "Generating My Resume as a PDF with Github Actions"
date: 2023-10-14T12:51:10-04:00
tags:
    - ci/cd
    - github actions
    - automation
---

For over ten years, I've been maintaining [my resume as a GitHub repo](https://github.com/charlesthomas/resume).
It's a simple Markdown file, but until yesterday every time I actually needed to submit it somewhere, I'd have to use [MacDown](https://macdown.uranusjr.com/) or something to render it as a PDF.
(As an aside, the fact that I even need to use something other than VS Code to do this is crazy. However, even though VS Code has [extensions](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles) that will render Markdown, VS Code [**can't print!**](https://stackoverflow.com/questions/36934247/how-to-print-a-file-from-vscode))

I started looking for a new job this week, and immediately stepped on all these rakes again.

{{< image src="memes/sideshow-bob-stepping-on-rake-static.png" alt="Sideshow Bob from The Simpsons stepping on a rake in an area full of rakes" >}}

This got me wondering if I could do this PDF generation via the CLI, and I pretty quickly found that [pandoc](https://pandoc.org/) can do this.
It wasn't long before I had hacked together a one-liner using a pre-existing Docker container:

```bash
docker run --rm -v $(pwd):/data:Z pandoc/latex:2.6 resume.md -o resume.pdf
```

When run from the root of my resume repo, this mounts the current working directory into a `pandoc` container and uses `pandoc` to render the resume to PDF.
Since the ouput file is in the same directory in the container, which is a volume mount to my resume repo, after the container exists the PDF persists on disk.

This was enough to generate the PDF, which I moved off to a different location on my laptop so that I could get to it easier when filling out the endless job posting forms as I was trolling for new gigs.

However, as part of my search I also started sending links to friends & former colleagues to see if they could help me out.
Since I was reaching out to all of them via text messages, I didn't want to have to text them a PDF.
Instead I sent them a link to the resume repo.

I wasn't sure who they would pass that link along to, but it got me thinking that it would be nice if someone needed an actual PDF they could find it from the link.
My first thought was to put it on Dropbox or my website or something and link to it in the resume Markdown.
Then it occurred to me that I could upload it as a GitHub Release Asset.

This was my aha! moment.
If I know how to render the Markdown into a PDF with command line tools, and I want to serve the PDF from the repo's Releases page, then why wouldn't I automate this?

I spent a couple hours messing with Github Actions, and I managed to do exactly that!
Now when you go to [github.com/charlesthomas/resume/releases/latest/download/Charles-Thomas-Resume.pdf](https://github.com/charlesthomas/resume/releases/latest/download/Charles-Thomas-Resume.pdf) you'll get a PDF of my resume that is an exact match to the Markdown, because it auto-updates every time I push a new version of my resume to the `main` branch!

I am not going to paste the entire GitHub Actions Workflow here, but I will go over the interesting parts. [You can see the whole thing in its most up-to-date form here.](https://github.com/charlesthomas/resume/blob/main/.github/workflows/publish-pdf.yaml)

First, I only wanted this to run when I pushed to the `main` branch:

```yaml
on:
  push:
    branches:
      - main
```

`pandoc` requires a couple of additional packages in order to work on the `ubuntu-latest` runners GitHub Actions provides:

```yaml
steps:
    ...
    - name: install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install --yes pandoc texlive-latex-base texlive-latex-recommended
```

Releases require git tags.
I messed around for a while trying to use [`svu`](https://github.com/caarlos0/svu) to use [Semantic Versioning](https://semver.org), but I ran into an issue where it wanted to always tag the version as `v0.0.1`, so I removed all the existing Semantic Version tags and switched to a date-based tagging system.

GitHub Actions allows you to generate and store new environment variables for use in later steps by appending to the `$GITHUB_ENV` file.
This `step` stores today's date in `YYYY-MM-DD` format as `$tag` in that file:

```yaml
      - name: generate tag
        run: |
          echo "tag=$(date +%F)" >> "$GITHUB_ENV"
```

I tried making and pushing the tag via raw `git` commands, but I immediately ran into issues with the global git config not being setup with a committer name or email address.
I found [this on StackOverflow](https://stackoverflow.com/a/64479344) which created and pushed the tag in a single step, and auto-populated this missing `git` config:

```yaml
      - name: push tag
        uses: actions/github-script@v6
        with:
          script: |
            const {tag} = process.env
            github.rest.git.createRef({
              owner: context.repo.owner,
              repo: context.repo.repo,
              ref: `refs/tags/${tag}`,
              sha: context.sha
            })
```

I'll call out here that I'm not 100% sure how `const {tag} = process.env` is working, but it does work.
My suspicion is that `$tag` being the name in the `$GITHUB_ENV` file **and** the name of the variable inside the github-script `script` block is not a coincidence, but I can't say for sure.
I'm sure I could confirm with a little trial-and-error, but it's working now and I don't want to break it just to see if I'm right.
`¯\_(ツ)_/¯`

The final interesting step in this Workflow is creating the Release, and uploading the PDF as a Release Asset. This is all done in a single step at the tail end of the Workflow using the [GitHub `gh` cli client](https://cli.github.com/), which is baked into all the public GitHub Actions runners:

```yaml
      - name: publish release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create $tag Charles-Thomas-Resume.pdf
```

Again, I don't know if the `GITHUB_TOKEN` piece is required, but it works.
I'll further add that I didn't do any kind of credential management to generate a new `GITHUB_TOKEN` to inject into this Workflow.
Since it's all GitHub, it appears to have Just Worked.

This is all fantastic!
There's only one final thing I wanted to solve at this point: I don't have a great understanding of how `pandoc` will render the PDF based on my Markdown changes.
I wanted a way to generate the PDF as a draft, so that I could see the exact output I'd get if I pushed to `main` without actually breaking the `latest` link above.

In order to accomplish this, I made a second Workflow that's slightly different.
You can see that [here](https://github.com/charlesthomas/resume/blob/main/.github/workflows/draft.yaml).
It's nearly identical to the other, but I'll call out the important differences.

First, it runs on a different branch called `draft`.
I won't leave this branch around, but whenever I need to preview a change, I can recreate the `draft` branch and push changes.

```yaml
on:
  push:
    branches:
      - draft
```

Second, I may end up pushing to this branch several times before getting it right. I didn't want to keep overwriting the same date-based tag, so the tags on this branch include hour, minute, and seconds:

```yaml
      - name: generate tag
        run: |
          echo "tag=$(date +%F-%H-%M-%S)-draft" >> "$GITHUB_ENV"
```

Not only that, but I don't actually want draft tags in the git history.
It turns out if you're making a draft GitHub Release, you don't need the tag.
By leaving the `push tag` step described above out of the draft Workflow, I still get a draft Release, but I don't leave any extra tags lying around to clean up later.

Finally, I **definitely** don't want someone trying to access the latest version of my resume to end up downloading one of these drafts.
The `gh` cli supports a `--draft` flag which will do all the things `gh release create` already does, but without changing what `latest` redirects to.
The release that gets created is flagged as a "Draft".

{{< image src="screenshots/github-draft-release.png" alt="screenshot of the GitHub Release page showing the special Draft label" >}}

```yaml
      - name: publish release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create --draft $tag Charles-Thomas-Resume.pdf
```

Once I have a copy I like, I can merge the `draft` branch into `main` and those changes will be published as a real release and update `latest`.

**UPDATE 2023-10-15**

The original closing paragraph mentioned needing manual cleanup after pushing to the `draft` branch:

> Currently there is some manual cleanup required to delete all the draft Releases and tags. In the future I may take the time to have the on main workflow clean those up for me every time I merge, but I’m not sure the effort is worth it at this time.

It turns out that cleaning this up is fairly simple.
This is because a Draft GitHub Release doesn't actually need a git tag.
By simply deleting the `push tag` step described above from the draft Workflow, I still get a Draft Release I can download the PDF from, but there are no lingering git tags to manually delete.

Also, via the `gh` cli you can list and delete releases. Appending a single line to the end of the main Workflow auto-cleans up all Draft Releases when you push to main:

```yaml
- name: publish release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create $tag Charles-Thomas-Resume.pdf
          gh release list --limit 999 | grep Draft | cut -f 1 | xargs gh release delete
```
