This repo hosts my blog at [charlesthomas.dev](https://charlesthomas.dev).

It's built by static site generator [hugo](https://gohugo.io), with the [blackburn](https://github.com/yoshiharuyamashita/blackburn) theme

---

# make commands

## `make`

- setup [git hooks](#git-hooks)
- build the site
- serve it locally on [localhost:1313](http://localhost:1313)

## `make build`

- install `hugo`
- update the theme
- sync down any missing [assets from S3](https://charlesthomas.dev/dynamic-img-src-with-hugo-shortcodes-2023-01-16/)

## `make post`

- prompt for the title of the new post
- create the markdown file in the correct place
- open VS Code to the new post file

## `make page`

- does the same thing as `make post`, but for a new page

## `make static-upload`

- install aws cli
- use aws cli to sync `/static/` to S3

# git hooks

currently the only hook is `etc/git-hooks/pre-push`

## pre-push

detect the current branch, and run `make static-upload` before pushing to origin
