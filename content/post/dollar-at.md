---
title: "when alias isn't enough: $@"
date: 2022-11-20T11:52:06-05:00
tags:
  - hacks
  - bash
  - dotfiles
---
# Intro
---

I am a **huge** fan of bash aliases.
I want to move as quickly as I think, and when my whole day is spent hammering on a keyboard I want to do it with as little input as possible.

It's pretty common practice to do stuff like this in your `.bashrc` (or `.zshrc` or whatever):

```bash
alias d=docker
alias g=git
alias kc=kubectl
```

While those aliases served me in good stead, my needs evolved.

For each of the above examples, I have replaced my aliases with bash scripts instead.

## What is `$@`?

In a bash script, `$@` represents all of the command line arguments passed to a given command.

Take this command as an example:

```bash
./test a 2 D
```

It's probably common knowledge that inside `test.sh` `$1=a`, `$2=2`, and `$3=D`.

It might be less common to know that `$0=./test`.
This is good to know for writing help functions, because you can `echo $0` so that your usage example will match the way the user initiated your script.

At any rate, given the same example above, `$@=a 2 D`.
It's **all** of the args (excluding the script itself).

This means that you can write bash scripts to pass all of the arguments to your script _straight through to a different program_.

In effect, a script `~/bin/d` with the following contents is functionally the same as `alias d='docker'` in your `.bashrc`:

```bash
#!/bin/bash
docker $@
```

But what benefit is that?

**Because your script can do more than blindly fire all the args into a different program like an alias would, you can add extra logic.**

# `~/bin/d`
---

While I understand the distinction between images and containers, I often find myself in a situation where I'm trying to look at both at the same time, and I don't want to run two different commands to do it.

My `~/bin/d` script inspects the arguments passed to it before sending them to `docker`.
If `$1` is `ls`, instead of running `docker $@` my `~/bin/d` will do the following:

- `docker container ls -a`
- `docker image ls -a`

Now I can LIST ALL THE THINGS ![](/memes/allthethings.jpg) with one command.

Even more useful than that is `~/bin/d prune`.
I don't know why, but `docker image prune` seems backwards to me.
I **always** run `docker prune image` when the correct command is `docker image prune`.

To make matters worse, while `docker image prune` is a valid command `docker container prune` **is not**.

Like `ls` I often want to just purge everything; images _and containers_.

Since `~/bin/d` is its own script and not just an alias, I can make all of this work the way _I think it should_:

- `d prune image[s]`
  - run `docker image prune -af`
- `d prune container[s]`
  - run `docker container rm -f $(docker container ls -aq)`
- `d prune`
  - do both of the above

Here's the whole `~/bin/d` script:

```bash
#!/bin/bash
set -e

function list() {
    echo docker container ls -a
    docker container ls -a
    echo
    echo -----
    echo
    echo docker image ls -a
    docker image ls -a
}

function prune_containers() {
    containers=$(docker container ls -aq)
    if [[ "" != "${containers}" ]]; then
        docker container rm -f $containers
    fi
}

function prune_images() {
    docker image prune -af
}

function prune() {
    if [ -z $2 ]; then
        prune_containers
        prune_images
    elif [[ "${2}" =~ "container" ]]; then
        prune_containers
    elif [[ "${2}" =~ "image" ]]; then
        prune_images
    fi
}

if [[ "${1}" == "ls" ]]; then
    list
elif [[ "${1}" == "prune" ]]; then
    prune $2
else
    docker $@
fi
```

# `~/bin/g`
---

I probably run `git` more than any other program on my computer, and my most common `git` operation is `pull`.

I've tried several approaches to shortening `git pull`:

## one bash alias

```bash
alias g='git pull'
```

But for all other `git` operations _I had to type the entire three letters_ `g i t` _like a caveman_.

## bash and git aliases

`~/.bashrc`

```bash
alias g='git'
```

`~/.gitconfig`

```toml
[alias]
	g = pull
```

But I just can't get my fingers to type `g <SPACE> g`. Often I would only do one and end up seeing `git`'s help message cluttering up my screen.

## multiple bash aliases

```bash
alias g='git'
alias gg='git pull'
```

This is better, but I would still only `g` when I needed to `gg` ... `n00b`

The solution is a _very_ simple `~/bin/g`:

```bash
#!/bin/bash
set -e

if [ -z $1 ]; then
    git pull
else
    git $@
fi
```

If `g` has no arguments: `pull`. If it does have arguments: send them to `git`.

# `~/bin/kc`
---

This gets a little more complicated for several reasons:
1. This script modifies incoming args rather than replacing them whole-cloth
2. Because of #1, there's a debug flag to print the command rather than run it
3. It's not actually using `$@`; it's using `$#` instead

## What is `$#`?

`$#` is closely related to `$@`.
It's the length of `$@`.
Going back to the original example:

```bash
./test a 2 D
```

- `$@=a 2 D`
- `$#=3`
  - because there are 3 args in `$@`

If we add some more args:

```bash
./test a 2 D four five six
```

- `$@=a 2 D four five six`
- `$#=6`

I'm not going to go into detail on `shift` and `case`, but I will describe the script's behavior:

- `kc -d` will print the `kubectl` command instead of actually running it
- `kubectl describe` can be run with any of the following
  - `kc d`
  - `kc desc`
  - `kc describe`
- `kubectl delete` can be run with either of the following commands
  - `kc del`
  - `kc delete`
- `--timestamps` will be appended to `kc logs`

```bash
#!/bin/bash
set -e

debug=""
cmd=""

while [ $# -gt 0 ]; do
    case $1 in
      '-d')
        debug="echo "
        shift
        ;;
      'describe' | 'desc' | 'des' | 'd')
        cmd="${cmd}describe "
        shift
        ;;
      'delete' | 'del')
        cmd="${cmd}delete "
        shift
        ;;
      'logs')
        cmd="${cmd}logs --timestamps "
        shift
        ;;
      *)
        cmd="${cmd}${1} "
        shift
        ;;
    esac
done

${debug}kubectl $cmd
```

---
I have not made my dotfiles public in quite some time. I plan to in the near future since I'm actively blogging again. Hopefully [this dotfiles repo](https://github.com/charlesthomas/dotfiles) will start getting commits soon, and you can clone the repo instead of copy/pasting out of this post if you want to steal any of these scripts.
