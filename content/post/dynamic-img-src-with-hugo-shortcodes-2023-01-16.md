---
title: "Dynamic img src with Hugo Shortcodes"
date: 2023-01-16T12:51:20-05:00
tags:
  - meta
  - hugo
---

# Problems

This site is hosted via [GitHub Pages](https://pages.github.com/), which means it's just [a git repo](https://github.com/charlesthomas/charlesthomas.github.io) with some fanciness added.
Because of that, I knew from the start that I needed to find a way to host some static content (at least images) externally.

It wasn't that much of a hassle to get an S3 bucket setup to load the static content from.
I got that working so long ago that I lost all the links I referenced to do it.
However, sourcing all images from s3 creates new problems.

[`hugo`](https://gohugo.io/) is the tool I'm using to generate this site.
Like any decent static site generator should, it has a local mode where you can serve drafts as you write them and access the whole site via `localhost`.

It doesn't make sense to me to link static content to s3 when I'm still working on a draft.
I wanted to be able to just dump an image into the `static/` dir locally and then have it immediately accessible to play around with in the new draft.

Doing that works for fast feedback, but it also immediately introduces tech-debt:
- You have to remember to sync the new file to s3 before pushing to `origin/main`
- You have to remember to go change the image source to read from s3 instead of the local `static/` dir
- You have to remember either to be careful with `git add` or else you have to remember to delete the new local file from `static/` _after_ remembering to sync to s3

🤢 it's all too much!

# Solutions

I was able to find solutions to all of these problems, but the one that gave me the most trouble was `hugo` shortcodes.
Rather than dive right into all that, let's talk through the soltions in order from easiest to implement to most complicated:

## `.gitignore`

In order to address the problem of accidentally adding stuff from `static/` I just put `static/` in `.gitignore`.
Now I can dump whatever I want into `static/` locally and unless I explicitly `git add -f` it, it won't explode the size of the repo.

## `make static-download` and `make static-upload`

I realized early on that I don't blog enough to remember all the subtleties of how to invoke `hugo`, so I created [a `Makefile` for this site's repo](https://github.com/charlesthomas/charlesthomas.github.io/blob/main/Makefile).
I set it up so that the default target will build the static site and then serve it on `localhost`.

As part of the initial s3 work I also created `static-download` and `static-upload` targets, and then I updated the default target to always run `static-download` before `build` and `serve`.
This means that even a fresh checkout on a different computer will always have all of the content from `static/` locally for faster serving as I'm writing new content (assuming I have my aws creds configured correctly first).

## `.git/hooks/pre-push`

The `Makefile` will ensure that I always pull stuff from s3 when running locally, but I also needed to make sure I didn't have to remember to push new stuff to s3 when trying to publish a new post.
I wrote a pretty simple `git` pre-push hook that checks to see what branch I'm pushing.
If it's `main` then before `git` pushes the new content to `origin`, the hook runs `make static-upload` to sync `static/` up to s3.
This guarantees that all the static content is where it needs to be in s3 before GitHub ever receives the new version of the site to build & deploy.

I don't know if I was doing something wrong, or if `git` won't let you commit your hooks on purpose, but I couldn't figure out how to gracefully sync the hooks.
So I added an `install-hooks` target to my `Makefile` instead, which also runs as part of the default target to ensure I always have the hook ... which itself ensures I always upload new `static/` content to s3.

## `hugo` shortcodes

The final piece of the puzzle was figuring out how to automatically switch between local and s3 URLs when serving locally vs at `origin`.
`hugo` is a powerful and complex tool.
It seems like there are probably several ways to solve this, but I used [`hugo` shortcodes](https://gohugo.io/content-management/shortcodes/).

The one thing I still have to remember is to use the following shortcode to reference images:

```html
{{</* image src="..." alt="..." */>}}
```

Where `src`'s value is the local path of the file relative to the `static/` directory, and `alt`'s value is the alt-text I want.

By creating [`layouts/shortcodes/image.html` in this site's repo](https://github.com/charlesthomas/charlesthomas.github.io/blob/main/layouts/shortcodes/image.html) with the following content, images will automatically load from disk if the file is present and from the site's s3 bucket if it isn't:

```html
<!-- Get src param from shortcode -->
{{ $src := $.Get "src"}}
{{ $image := .Page.Resources.GetMatch (.Get "src") }}
{{ $local := path.Join "static" $src }}
{{ $s3 := printf "https://s3.us-east-2.amazonaws.com/charlesthomas.dev/static/%s" $src }}


<!-- Get alt param from shortcode -->
{{ $alt := $.Get "alt"}}

{{- /* This shortcode create img tag with lazy loading
Params:
- "src" : relative path of image in directory "static/"
*/ -}}
{{- with .Get "src" }}
{{- $src := . }}
{{ if fileExists $local }}
<img class="img-fluid" src="{{ $src | absURL }}" alt="{{ $alt }}" loading="lazy" decoding="async">
{{ else }}
<img class="img-fluid" src="{{ $s3 }}" alt="{{ $alt }}" loading="lazy" decoding="async">
{{ end }}
{{- else }}
{{- errorf "missing value for param 'name': %s" .Position }}
{{- end }}
```

# Workflow

I've decided to create a new post with images.
For whatever reason I don't have my site's repo on the computer I've decided to write the post on.

I clone the repo.
At this point I have all the existing published text, but nothing in `static/` and no `git` hook.

I run `make post` to create a new post and start editing it.

As soon as I want to see the draft, which will be _very_ soon because I crave fast feedback when I'm writing, I run `make` to build the site and serve it on `localhost`.

This installs the `pre-push` hook, clones the site's theme submodule (not covered in this blog, but a nice touch I thought), downloads everything in the site's s3 bucket to `static/`, then builds the page and serves it.

As I need images for the post, I put them in `static/` locally and then reference them using the shortcode:

```html
{{</* image src="path_relative_to_static.jpg" alt="my sweet alt-text" */>}}
```

This makes them visible in my local copy immediately, even though they have not been uploaded to s3 yet.
This is because they exist on disk, so `hugo` is serving the `src` as `localhost:1313/path_relative_to_static.jpg`.

I finish the draft, and decide to commit it and push it to `origin/main`.

When I run `git push`, `git` runs the `.git/hooks/pre-push` script that was installed by the `Makefile` the first time I ran `make` to serve the local version.
`.git/hooks/pre-push` runs `make static-upload` and syncs everything in `static/` to s3.
_THEN_ `git` pushes the repo to `origin/main`.

GitHub receives the new code, which triggers a GitHub Action to build and deploy the new version of the site.

Since `static/` is in `.gitignore`, GitHub Actions **does not** have the `static/` files, which means `hugo` renders the image sources with the links to s3 instead of the local paths.

```html
{{</* image src="memes/awesome.png" alt="awesome" */>}}
```
{{< image src="memes/awesome.png" alt="awesome" >}}

# Thanks / References

- The code above is modified from [this tutorial](https://www.cloudhadoop.com/hugo-images/) that got me started
- In order to display an example use-case for the shortcode, I had to figure out how to escape it in this post, so that it didn't just get rendered as a broken image. [This page](https://liatas.com/posts/escaping-hugo-shortcodes/) showed me how to do that
