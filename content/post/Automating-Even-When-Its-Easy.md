---
title: "Automating Even When It's Easy - Or: Why Can't I Remember the Syntax for Password-less Sudo?"
date: 2024-11-03T11:07:58-05:00
tags:
    - automation
    - bash
    - steal-this-code
---

One of the most impactful books I've ever read is
[Time Management for System Administrators](https://www.oreilly.com/library/view/time-management-for/0596007833/)
by Tom Limoncelli.
I have read it multiple times,
and every time I take away something new.
It's a little dated (post-PDA/pre-smart-phone),
but I'd still recommend it more often if it weren't for the problematic life-goals section.

A section I think of often is when to automate something.
It's effectively just an
[Eisenhower Matrix,](https://en.wikipedia.org/wiki/Time_management#The_Eisenhower_Method)
but the axes are Difficulty and Frequency.

|           | **Easy** | **Hard** |
| --------- | -------- | -------- |
| **Rare**  |       ❌ |        ✅ |
| **Often** |       ✅ |        ❌ |


### Easy & Rare: ❌

If the thing is an easy one-off,
don't waste time automating it.

### Hard & Often: ❌

Limoncelli makes the case that if it's hard and you do it often,
you **shouldn't** be _automating_;
you should be _buying_ your way out of the problem.

### Easy & Often: ✅

It should be obvious that if it's easy and you do it a bunch,
you should automate it.

### Hard & Rare: ✅

Automating things that are hard and rare is the most interesting to me,
because I think it's the least obvious.
The argument is that by scripting something,
you're taking the time to make sure you get it right;
both the details of individual steps,
but also the order of operations.

---

I **can NOT** remember the syntax for `/etc/sudoers`.
I probably learned it at least once at some point,
but I mess with it so rarely that I'm lucky to remember to use `visudo`,
let alone the proper syntax.

Last week one of the nodes in my `k3s`
[homelab](https://github.com/charlesthomas/homelab)
went offline.
It turned out this was due to an SSD failure.
This was the 2nd node that died for the same reason,
so I decided that I would just bite the bullet and replace all the drives.
Including the drive I had already replaced recently,
because I decided to double the storage
(from 256GB to 512GB per node).

I may blog about that procedure separately,
so I won't go into all the details here,
but the bit that's relevant to this post
is that I wanted to give the user running `k3s` passwordless `sudo`.

Every single time I want to do this,
I have to google it.
I knew going in I'd have to do it 4 times since there are 4 nodes,
and because my
[steal-this-code](https://github.com/charlesthomas/steal-this-code)
is new and so fresh in my mind,
I decided I'd script it:

```bash
#!/bin/bash
user=${1:-$(whoami)}
echo "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$user
```

The script is so simple,
and I'll rarely need it,
but simple doesn't mean easy.
It's so hard for me to remember the syntax to do this,
but it doesn't matter anymore because I've automated it;
proving Limoncelli's point:
If it's hard [to remember] and you're not going to do it very often:
**Automate it.**
