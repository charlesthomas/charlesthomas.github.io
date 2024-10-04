---
title: "IT: Good to Great with 3 Rules"
date: 2009-08-26T21:51:10-04:00
tags:
    - productivity
    - work
---
There is what I consider to be a big problem in the IT field today.
Most people think that anyone who is ‘good with computers’ can be plucked from their parent’s basement, and dropped into a corporate job, managing that company’s computers.
That is just not true.
Perhaps I am a snob, because I went to college to earn a degree in System Administration, or maybe because I worked at a place where the 3 rules I will mention ingrained these ideas in my head.
Or maybe, the misconception that being ‘good with computers’ means a good IT person is because the people doing the hiring just don’t get it.
Or maybe they have only ever had bad IT people.
Who knows? The point is, knowledge isn’t everything.
It certainly isn’t nothing, either.
This isn’t about learning how computers work, or how to be a passable administrator.
This is about being great at your job.
If you want to continue to run around putting out fires all day, then by all means, move along.
But if you want to be really good – even great – at IT, and you want to stop chasing after issues, and see them coming or know how to deal with them before they are even reported, then read on.
These 3 rules (for lack of a better term) will make your life easier.
I know, because it did mine.

# Rule 1: Write down everything you do

This sounds like a colossal waste of time when you first hear it.
“I will never have this problem again.” Yes.
You will.
No matter what the issue, if you have seen it once, you will see it again.
If it was a user error, the same user won’t write anything down, so they can’t be trusted not to make the same mistake again, and even if they do, they won’t prevent other users from making the same mistake.
If it is a piece of code, it may be a piece of code you use again; maybe not even remotely related to what you used it for the first time.
If it is a server change, then what happens if the server fails and you have to revert to a backup, or start again with new hardware?

If it is complicated, you will know tomorrow where you left off today.
If it is simple, then you will be prepared for the next time it comes up.
If you are not the only person in your department, then you will be able to more easily explain to your co-workers.
If you are the only guy, then you have just made training your eventual replacement easier.
(Your replacement because you were promoted for being so awesome at your job after following these rules.
NOT your replacement because you were fired, because you are too awesome at your job, because you are following these rules.)

Documentation is always painful in the short term, but not once have I ever looked at a piece of documentation later and thought “There is no need for this.” But more than I care to admit, I have thought “I know I fixed this once.
How did I do it? I wish I had written it down.” Painful in the short term, but future you loves past you for taking the time, because you just saved future you from having to rework the same (or a similar) issue.

The most success I have had with making sure I write everything down are a ticket system, a wiki, and good old pen and paper.
I have used 3 different ticket systems at various jobs, and the best one by leaps and bounds is RT.
I am not familiar with any wiki software other than mediawiki (think wikipedia – it runs on mediawiki), but the biggest shortcoming of it is in the access controls.
They are lacking.
This lead my last place of work to create 2 wikis: customer-facing, and internal only.
Finally, I find it much easier to take notes with pen and paper than I do a keyboard.
If I am working on something, I take notes on paper as I go, and then after it is resolved, or I stop working on it, I am able to review my notes, and update the ticket system and/or the wiki.
I have also started playing with Evernote, but that will be covered in a later post (I hope).

# Rule 2: Turn everything you do regularly into a procedure
You have faithfully followed the first rule, and now have an extensive set of documentation.
This is fantastic, but here’s the problem: documentation is worthless if it isn’t used.
Using a wiki means it is searchable, which is perfect for those weird issues that come up only rarely.
What about the things you do every day, or once every month? If there is something that you have to do at regular intervals, or even at random, yet frequent, intervals, then it makes sense to turn it into a procedure.
You have a server that, without fail, crashes every 30 days.
You are still trying to figure out why, but you know that all it takes to correct is a server reboot.
You could just reboot the server every time, except that the mail server that runs on it doesn’t always come back up reliably, unless you kill the service/demon before you reboot the server.
You know this.
But what about your co worker who has been tasked with the job while you are on vacation?

Create a procedure (even if it is short) that says:
Reboot mail server
(to be done every 30 days)
1) Log in to server, and stop mail service/demon
2) Collect logs (this is an ongoing issue, remember)
3) Reboot server
4) Update ticket #1345 with date/time of server reboot, and copy logs to ticket.
5) Once the server is back up, check the status of the mail service/demon

This is a pretty basic procedure, but if you have this documented, then when you go on vacation, you don’t have to worry about whether that damn mail server is going to crash while you are gone.
Instead, you tell your co-worker to check the last reboot timestamp in the ticket, and if it is 29 days ago or  more, search the wiki for “Reboot mail server” and follow the procedure.
You don’t need to go into detail, because the details are already written down.
No need to tell him to remember to pull the logs, and don’t forget the mail service/demon, and what was that ticket number again? The more complex the task, the more useful this is.
Plus, if you hire a new guy, the new guy not only has something to do to train (sit down and read through any written procedures) but if when he has to fly solo on a ticket, because you are too busy, he already has a guide to step him through the process.

This also makes tiered support much easier.
How? Well, if you have a troubleshooting procedure for some piece of software that is used frequently within your company, and in the procedure as a last step it says “Escalate” then your second tier will always know where to go next.
They will know what was already done.
Of course, this is in your ticket, too, but since the tier two guys have their own written procedures, they can pick up where you left off that much quicker.

Additionally, there will always be something new that comes up.
An issue that breaks the mold.
The beautiful thing about this is that you can just readjust the mold.
When you have the base case written down, then it is easier to determine that something is an outlier.
You have followed everything in the procedure to the letter, and something is still not working.
Because it was a written procedure, it took you less time to get to this point, because you didn’t have to re-invent the wheel to get there.
Now you can take the time to resolve this unique issue.
Not only that, but once you do resolve it, you can update the procedure, and now anyone else on the team can fix the issue if it ever happens again.

# Rule 3: Make everything as modular as possible
This step is one that I have found intensely useful, and one that many people don’t see to think about.
Even in places where I have seen a documentation system, and even a set of procedures, they don’t always understand the concept of modularization.
The goal is to make everything easily updated, changed removed from, or added to.

The easiest way to understand this is with scripting.
I worked at a place where we developed a perl script that would run on a host machine, and send back the programs that were installed on the machine.
The server piece of the script then updated a database, which was search-able via a web interface.
This meant that you could search for any program, and get a list of machines that the program was installed on, or search a computer and get all of the programs that were installed on it.
This was really useful, but while developing the script, we realized that there were lots of other pieces of information we could gather at the same time.
What we did was develop the script so that it could implement new functions on the fly.
It would scan a certain directory for all of the module (or library) files, which were all run in the same way, and run each module in the file.
This meant that adding functionality to the script was as simple as dropping in a new module.
This allowed us to have the host computer kick back uptimes and IP addresses without rewriting the existing script.
We designed the initial script as a framework for loading modules and connecting to the database, then removed the program scanning portion and made it the first module.
Now all we had to do was come up with new module ideas, script them to work within the standard of the framework, and drop it in the modules folder.

I have since taken that mindset and applied it to other things.
For example, I currently work for a company that creates database-driven software.
There is a query that I use that I may run as many as 100 times per day.
It is a fairly complex query, involving nested queries, because each client has a test and production server for hosting the software, the index fields in the tables the query runs against don’t always match.
To get around that, I created a script that will take as input for the main query the output of the nested query.
This means that with copy and paste and some minor editing, I am able to use this seemingly custom query over and over again; saving myself a lot of time in the process.
To make this more clear, I have copied a generalized version of the script here:

```sql
UPDATE db.table_a SET last_update = SYSDATE, last_username = 'crthomas',
text = '$1' WHERE nbr IN ( SELECT table_a_nbr FROM db.table_b WHERE
field_1 = $2 AND field_2 = '$3' );
```

To make this query work in any of our client’s environments, all I have to do is replace the $ variables with the proper data.
Not only that, but the script does not have to be altered from one client’s test environment to the same client’s production environment.

I have found that following these 3 rules have made my life a lot easier.
It takes some time in the short run, but it almost always saves time long-term.
It makes you look efficient and effective, and it gives you more free time to work on stuff that might be more interesting.
It makes you look great.
