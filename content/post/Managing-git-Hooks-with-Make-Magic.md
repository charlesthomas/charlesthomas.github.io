---
title: "Managing git Hooks with make Magic"
date: 2024-10-22T22:37:24-04:00
tags:
    - git
    - make
    - steal-this-code
---
`git` [hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
can be extremely useful, but only if you remember to install them.
Since `git` automatically excludes `.git/` from the commit history,
but hooks need to be installed in `.git/hooks`,
there's not an elegant way to keep them up to date across multiple checkouts.

If your repo has a `Makefile` already, this can be solved with
[a couple simple targets](https://github.com/charlesthomas/steal-this-code/tree/main/make/git-hooks/Makefile).

Explaining the file one line at a time:

1. `.PHONY: install-hooks` is telling `make` that running `make install-hooks` will not create
a file called `install-hooks`,
so that if a file does appear called `install-hooks` its date will be ignored,
and `make install-hooks` will always run.
2. `install-hooks: .git/hooks/some-hook .git/hooks/another-hook` declares
`.git/hooks/some-hook` and `.git/hooks/another-hook` as dependencies of `install-hooks`;
telling `make` that before `install-hooks` can be made,
`.git/hooks/some-hook` and `.git/hooks/another-hook` must be made first.
3. This line is blank because `make install-hooks` doesn't actually do anything.
Effectively it's just an alias to make the dependencies.
If you only have one `git` hook, then you could probably get away without the `install-hooks` target.
However, if you're copying this pattern across many repos it'll be easier to remember
"I just need to run `make install-hooks`" rather than having to remember which hooks are
used for which repos, in order to use the real make target, like `make .git/hooks/pre-commit`.
4. `.git/hooks/%:` is our first bit of `make` magic.
`%` is a special wild-card character.
Defining the target `.git/hooks/%` tells `make` how to make _any_ `.git/hooks/` target.
As you can see,
`.git/hooks/some-hook` doesn't have an explicit target defined in this `Makefile`.
It's being made by the `.git/hooks/%` target because it conforms to the wild-card pattern.
5. `    ln -s hooks/$* $@` contains two more bits of `make` magic.
`$*` is a variable containing whatever was matched in the `%` from the target.
`$@` is contains the entire target.

`make .git/hooks/some-hook`:
- `$*` value: `some-hook`
- `$@` value: `.git/hooks/some-hook`
- The full command that gets run: `ln -s hooks/some-hook .git/hooks/some-hook`

By using these special `make` variables, this pattern can be copied into any repo's `Makefile`
and the only thing that needs to be touched is the dependencies on line 2.
As you add or remove hooks, you can update line 2 again.
No matter what, because we created that `install-hooks` alias,
all you have to do if you find any of your hooks are missing **in any repo** is
`make install-hooks` and they'll be installed.
Because they're symbolic links to the `hooks/` directory,
you can keep your hooks in your repo without worrying about `.git/` being ignored.
