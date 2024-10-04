---
title: "Lightning Fast Code Search in the Terminal"
date: 2023-11-08T13:58:51-05:00
tags:
  - bash
  - cli
  - hacks
  - productivity
---

For the better part of a decade, I’ve had a function in my `.bashrc` called `finf` (Find IN File), which chains `find` and `grep` together to search the contents of files. The other day I started playing around with a couple of tools I had never tried before and found a much better solution than `finf`, and I thought I’d share.

## Ripgrep

[Link](https://github.com/BurntSushi/ripgrep)

`rg` by itself is already better than my old `finf` function because it searches in parallel. Plus it automatically ignores binary files and files in `.gitignore`.

In this test, I ran `finf test` and `rg test` in a directory where I have 78 repos cloned.

```bash
$ time finf test >/dev/null

real    0m23.403s
user    0m10.876s
sys     0m3.520s
```

```bash
$ time rg test >/dev/null

real    0m0.056s
user    0m0.196s
sys     0m0.354s
```

`rg` is _**FAST**_.

Its default output looks like this:

```bash
terraform-provider-logdna/go.mod
7:      github.com/stretchr/testify v1.7.0

build-images/Jenkinsfile
11:    issueCommentTrigger('.*test this please.*')

nodejs/package.json
8:    "test": "test"
12:    "pretest": "npm run lint",
13:    "test": "tap"

puppet-logdna/Gemfile
14:gem "test-kitchen"

env-config-node/lib/definition.js
323:    if (!re.test(this._value)) {
```

For reasons which will become clear later, I prefer that the file path is included on every line rather than as a header and that the line numbers are still included.

This can be achieved with the `--no-heading` and `--line-number` options (line numbers are removed by default if `--no-heading` is passed):

```bash
$ rg --no-heading --line-number test
logdna-browser/tests/index.spec.ts:234:        const data = { test: 'data' };
logdna-browser/tests/index.spec.ts:317:    // todo add better tests when we have better stack traces
logdna-agent/test/unit/logger-client.js:7:const {test} = require('tap')
logdna-agent/test/unit/logger-client.js:18:test('Check logger defaults', async (t) => {
```

## fzf

[Link](https://github.com/junegunn/fzf)

“fzf is a general-purpose command-line fuzzy finder.” I stole that description from `fzf`’s README because I don’t really know how to describe it. I also definitely haven’t come to understand its full power. What I _do_ know is that you can pipe `rg`’s output to `fzf`, and then filter your search results.

For example: here I am running the same `rg --no-heading --line-number test` command piped to `fzf`. Then inside `fzf` I searched for “jenkins” and `fzf` filtered the results as I was typing. Hitting Return prints only the selected result. (Not shown here, but the arrow keys move the selected line.)

{{< image src="code-search/1.gif" >}}

There’s more to do with `fzf`, but first we have to talk about `bat`.

## Bat

[Link](https://github.com/sharkdp/bat)

`bat` is a replacement for `cat` which includes line number printing and syntax highlighting. (It can also show uncommitted git changes, but that’s not important to the rest of this post.)

{{< image src="code-search/2.png" >}}

`bat` can also highlight lines, and show only a given range of lines (both of these things will become useful soon).

{{< image src="code-search/3.png" >}}

## Back to fzf

Now that we know about `bat`, let’s make use of it. `fzf` has a `--preview` flag, which takes in a command to be used to preview the results shown in `fzf`.

The screenshot below is the output of

```bash
rg --no-heading --line-number test | fzf -d: --preview 'bat -f {1}'
```

`fzf -d:` here is telling `fzf` to split the results on the colon delimiter. `{1}` is the first field, in this case the filename, which is what we want to use with `bat`. `bat -f` is `--force-colorization` so that we get the syntax highlighting and line numbers even though we aren’t in a terminal (because we’re inside `fzf`’s preview window).

{{< image src="code-search/4.png" >}}

We can do a little more cleanup at this point. Now that `bat` is being used to render a preview of the file, we don’t really need the matching line printed by `rg` anymore. So let’s `cut` it out. And while we’re at it, we’ll tell `bat` to highlight the line that matches our search using `-H {2}` (`{2}` being the second field delimited by the colons in the output of `rg`).

```bash
rg --no-heading --line-number test | cut -f1,2 -d: | fzf -d: --preview 'bat -f -H {2} {1}'
```

{{< image src="code-search/5.png" >}}

This is amazing! But there’s a catch. In the screenshot above, you can see `bat` can only fit the first 38 lines of the file. This is fine for the currently selected result, because the match is on line 3. But the next result shows a match on line 72. What will I see if I select that result?

{{< image src="code-search/6.png" >}}

The highlight is missing, because line 72 is below the preview frame.

## bc to the rescue!

As I mentioned before, `bat` can take a `--line-range` argument (`-r` is the short-hand for `--line-range`). Additionally, `fzf` makes `$FZF_PREVIEW_LINES` accessible as an environment variable to the commands being passed to `--preview`, whose value is how many lines can be displayed in the preview window.

I saved the following to a file called `range` to a directory in my `$PATH`:

```bash
#!/bin/bash
start=$(echo \
  "height=${FZF_PREVIEW_LINES:-0} / 2;\
  t=${1};\
  maybe_start=t-height;\
  if(maybe_start<0) maybe_start=0;
  print maybe_start;" \
| bc)
echo "${start}:"
```

`range` figures out what to pass as a value to `bat`’s `--line-range` / `-r` flag so that the highlighted line (the line that matches the `rg` search) will be approximately in the middle of the preview (assuming the line is past the half-way point; otherwise `-r` is just `0:`) With `range` now in my `$PATH`, I can do this:

```bash
rg --no-heading --line-number test | cut -f1,2 -d: | fzf -d: --preview 'bat -f -H {2} -r $(range {2}) {1}'
```

{{< image src="code-search/7.png" >}}

Now you can see the highlighted line is visible, because the `bat` preview starts at line 53 instead of 1.

## Tying it all together

```bash
rg --no-heading --line-number test | cut -f1,2 -d: | fzf -d: --preview 'bat -f -H {2} -r $(range {2}) {1}'
```
is not an easy chain of commands to remember. Also I’m dumb and I will forget to use it. So I removed the `finf` function from my `.bashrc`, and put this in `~/bin/finf` instead:

```bash
#!/bin/bash
rg --no-heading --line-number --follow $@ 2>/dev/null | \
cut -d: -f1,2 | \
fzf -d: --preview 'bat -f -H {2} -r $(range {2}) {1}'
```

Now my code searching muscle memory is the same. For the last ten years, if I wanted to search code I did `finf search-term`. Now, if I want to search code I still just do `finf search-term`, but I get a much faster, more powerful, more useful search.

## That’s all well and good, but can we do vim to it?

One of my favorite uses for my old `finf` function was to pipe it to a script I wrote called `vf` (vim file). `vim` has an option that will open a file and put the cursor on the line number indicated with a `+`. For example: `vim +72 logger-node/test/loadtest.js` would open the file from the previous screenshot to the line highlighted. `vf` scrapes the output of my old `finf` function and passes it to `vim` in such a way that `vim` opens straight to the line that matched the search result. Because the `--no-heading` and `--line-number` options for `rg` cause its output to be the same as my old `finf` function, and because `fzf` only outputs the selected line (`fzf -m` can actually support more than one line, but that is outside of the scope of this post), I can pipe this whole thing to my `vf` command to search code, figure out which result I want, and then jump straight to it in my preferred editor.

{{< image width=1000px src="code-search/8.gif" >}}

Here’s `vf`:

```bash
#!/bin/bash
while read input; do
    FILE=`echo $input | cut -f1 -d':'`
    LINE=`echo $input | cut -f2 -d':'`
    if [ "$1" == "-l" ]; then
        echo "vim +$LINE $FILE"
    elif [ $LINE == $FILE ];then
        vim $FILE < /dev/tty
    else
        vim +$LINE $FILE </dev/tty
    fi
done
```

## Using VS Code instead of vim

I did a little poking around, and found that [VS Code supports the same behavior](https://code.visualstudio.com/docs/editor/command-line#_opening-files-and-folders). As long as you pass the `-g` option first, you can `code -g $file:$line-number`.

So here's `cf`, which does the same thing as `vf` but opens VS Code instead of `vim`:

```bash
#!/bin/bash
while read input; do
    FILE=`echo $input | cut -f1 -d':'`
    LINE=`echo $input | cut -f2 -d':'`
    if [ "$1" == "-l" ]; then
        echo "code -g $FILE:$LINE"
    elif [ $LINE == $FILE ];then
        code $FILE
    else
        code -g $FILE:$LINE
    fi
done
```
