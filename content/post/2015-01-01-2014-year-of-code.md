---
title: "2014: Year of Code"
date: 2015-01-01T22:06:06-04:00
tags:
  - open source
---
I set a goal for myself at the beginning of 2014 to contribute to an open source project I didn’t start, and get my contribution accepted by the developers.
As the year went on, I cataloged it in a special section of my blog. Now that the year is over, I’m moving it to a regular post. I’m pretty sure that this is not up to date, since I’ve barely touched my blog in about a year. For example I know I contributed to the Selenium project, and I think that was still in 2014, but it’s not listed anywhere here. At any rate, aside from this paragraph, I moved the thing whole sale from its own page into a regular blog entry.

One of my goals for 2014 is to contribute to an open source project I didn’t start.

As far as I can tell, the only downloads I’ve gotten for the packages I’ve submitted to the [Python Package Index (PyPI)](https://pypi.python.org/pypi) are bots or mirrors.
I want to contribute to something other people will actually use.
This page is for tracking my progress.
(It’s basically just for my own vanity, but that’s true of any personal blog, right?) Since I’m taking the time to log projects I’ve submitted pull requests to, I figured I might as well track everything else I’ve worked on too.
So this page isn’t _just_ the pull requests I’ve submitted, but anything I’ve worked on that’s open source and any closed source projects I’ve actually launched.

TWO more pull requests accepted! This time both for kindle-to-evernote!

I did it! My pull request to python-twitter was accepted. While my goal has been achieved, I plan to continue contributing where I can.

# Pull Requests

## [kindle-to-evernote](https://github.com/jamietr1/kindle-to-evernote)

kindle-to-evernote is a script to scrape the file on your Kindle where highlights, notes, and sync locations are stored, and send the highlights to Evernote where you have easier access to them.

[Accepted! Pull Request #1:](https://github.com/jamietr1/kindle-to-evernote/pull/1)  
This was just a very simple change; adding a pip requirements.txt file to the repo for easier dependency installation, and updated the README on how to use it.

[Accepted! Pull Request #2:](https://github.com/jamietr1/kindle-to-evernote/pull/2)  
This was also a pretty simple change, but it adds functionality. This change allows the user to send the highlight notes to a custom notebook of their choosing in Evernote, rather than the default notebook.

## [represent-map](https://github.com/abenzer/represent-map)

Represent-map is the software RepresentMI is built on.

[Proposed Pull Request #62:](https://github.com/abenzer/represent-map/pull/62)  
Of all the pull requests I’ve submitted so far this year, I think this might be the one I’m most proud of.
The idea for this came less than a week before it was live on RepresentMI, and I managed to do the entire thing in one day.
This change allows custom additional URLs to show specific areas of the RepresentMap.
For example: Detroit and Ann Arbor Hopefully, this will make it easier to showcase startups in certain areas.
Before, the map was too large to see individual pins in some places.

[Proposed Pull Request #61:](https://github.com/abenzer/represent-map/pull/61)  
Added config for Vagrant and setup scripts so that other developers can get an environment up and running quickly.

[Rejected Pull Request #55:](https://github.com/abenzer/represent-map/pull/55)  
Added link to representmap.com to the README.md, so people can find all the places RepresentMap is in use.

[Proposed Pull Request #56:](https://github.com/abenzer/represent-map/pull/56)  
Making customization easier

## [Boom!](https://github.com/tarekziade/boom)

Boom! is a simple load tester

[Proposed Pull Request #41:](https://github.com/tarekziade/boom/pull/41)  
I’ve been looking into using Boom! in more advanced ways than just running the provided script, and had a hard time getting the imports to work.
After my original request got accepted, I was was poking around on the GitHub page, and saw that there was an open issue where someone else wanted the same changes I did, so I submitted another pull request.

[Accepted! Pull Request #39:](https://github.com/tarekziade/boom/pull/39)  
Adding quiet mode to show full results but no progress bar

## [HTTPS-Everywhere](https://github.com/EFForg/https-everywhere)

HTTPS-Everywhere is a browser extension to redirect to https://

[Rejected Pull Request #138:](https://github.com/EFForg/https-everywhere/pull/138)  
Unified shebang (#!), so all python utils repsect virtual envs

## [Python Twitter](https://github.com/bear/python-twitter)

Python Twitter is a Twitter package for Python

[Accepted! Pull Request #141:](https://github.com/bear/python-twitter/pull/141)  
Breaking all twitter classes out into their own file.

## [TornFoursquare](https://github.com/stevepeak/tornfoursquare)

TornFoursquare is a Tornado Mixin for Authenticating & Making Foursqaure API  
calls.

[Proposed Pull Request #1:](https://github.com/stevepeak/tornfoursquare/pull/1)  
in _parse_user_response user is a string, needs to be a dict

# My Open Source Stuff

## [Magpie](https://magpie-notes.readthedocs.org/en/latest/)

[Version 0.0.3:](https://pypi.python.org/pypi/magpie/0.0.3)  
Magpie is my attempt to create a self-hosted Evernote replacement.
While buffertime is my most successful “product,” magpie is already my most successful open source contribution.
It made it at least to [#4 on Hacker News](https://news.ycombinator.com/item?id=7878742), and has, at the time of this writing, 64 stars and 2 forks on [GitHub](https://github.com/charlesthomas/magpie).

## [status_server](https://github.com/charlesthomas/status_server)

Return HTTP response codes by URL

[Version 0.0.1:](https://pypi.python.org/pypi/status_server/0.0.1)  
I was playing around with the internals of Boom!, and I wanted to see how it behaved if it got response codes other than the normal 200.
I built status_server in order to accomplish this.
It just returns the status code from the request URL.
And if more than one code is present in the URL, it picks one of them at random, and returns it.

## [linker](https://github.com/charlesthomas/linker)

Make symlinks for config (“dot”) files from a config repo quickly, based on the machine you’re on and the names of the files themselves.

[Version 0.1.0:](https://pypi.python.org/pypi/linker/0.1.0)  
I am very excited about this version of linker, because I wasn’t the only one that contributed to it, and the feature I did add was at request of someone else.
I submitted linker to reddit, and as a result, someone submitted a couple of issues, and [their own pull request to me](https://github.com/charlesthomas/linker/pull/2)! The whole point of this “Year of Code” thing was to work on something other people would use.
Now I know that at least one person I’ve never met is using something I made.

[Version 0.0.3:](https://pypi.python.org/pypi/linker/0.0.3)  
For years now, I’ve been keeping my machine configuration files in a git repo.
This allows me to track changes (obviously), but also deploy new machines and restore existing machines quite quickly.
However, it isn’t easy to remember which file in the repo goes on what machine and where on that machine it goes.
I made linker a while ago to symlink files from the repo into their proper places.
I finally, however, split it out into its own repo and submitted it to PyPI.

## [moth](https://github.com/charlesthomas/moth)

moth is a Python package, originally intended to be an email based passwordless authentication system. I have since taken to using it for managing sessions in Tornado.

[Version 2.1.0:](https://pypi.python.org/pypi?:action=display&name=moth&version=2.1.0)  
I found a giant bug (no pun intended) in the asynchronous version of moth, which caused errors when you tried to authenticate a token that didn’t exist.
In order to fix this, I converted moth to use the @gen.coroutine style of Tornado, rather than @gen.engine.
I also took this opportunity to learn how to include unit tests in setup.py.

[Version 2.1.1:](https://pypi.python.org/pypi?:action=display&name=moth&version=2.1.1)  
I learned a lot about Python packaging with this version, even though it was the most minor of version bumps.
In addition to tests, moth now has automated testing on push, with [TravisCI](https://travis-ci.org/charlesthomas/moth), and full proper documentation on [ReadTheDocs](https://moth.readthedocs.org/en/latest/).
Additionally, Travis is configured to auto-deploy to PyPI on new versions (if the tests all passed).

## [todo.md](https://github.com/charlesthomas/todo.md)

todo.md is a bash script that can run as a pre-commit git hook to autogenerate a todo.md file in your git repo.

[Version 1.0.0](https://github.com/charlesthomas/todo.md):  
Launched version 1.0.0 of this project in a fully working state.
Could maybe use a few more bells & whistles, but it works for me for now.

[Version 1.1.0:](https://github.com/charlesthomas/todo.md/tree/1.1.0)  
I submitted todo.md to [/r/git](http://www.reddit.com/r/git/comments/20i2bx/todomd_add_to_git_hooks_and_automatically_update/), and shortly thereafter, todo.md got a [feature](https://github.com/charlesthomas/todo.md/issues/1) [request](https://github.com/charlesthomas/todo.md/issues/1) to add exclusion filters.
I added both exclusion and inclusion filters.

## [hey_dummy](https://github.com/charlesthomas/hey_dummy)

hey_dummy is something I wrote not long after I started my current job.
I would launch the test suite on my local machine, then go to my RSS reader while I waited for the results to come in, and forget to check in again on the job.
hey_dummy watches the process for me, and sends a desktop notification to get my attention, so I will remember to look at the results sooner.
Now it’s in its own repo, and it will work on linux and OS X without any code changes; just some flags.

# Launched Projects

## RepresentMI

Based on [Represent.LA](http://represent.la), RepresentMI is a map of the startup community in Michigan.

## [bufferti.me](http://bufferti.me)

I launched [bufferti.me](http://bufferti.me) last year, but I recently got an email from Joel, Buffer’s CEO asking for a feature request.
There’s a Buffer user who emailed them asking for different intervals than the ones I had defaulted in.
This was the second request from Buffer to me, and I think it was the same person making the requests to Buffer.
I suspected that I would get a request like this every so often, so rather than try to deal with the problem piecemeal, I added a new custom option to the interval menu.
Now, users can select “Custom” from the interval dropdown and put in any interval they want.
