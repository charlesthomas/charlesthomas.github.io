---
title: "Migrating My Custom Domain from Gmail to Fastmail"
date: 2025-04-11T08:34:30-04:00
tags:
    - email
    - rss
    - youtube
---

I've been thinking about migrating off of Google Workspace for my custom domain for months. I wasn't particularly concerned with what I think of as the "normal data" (emails/calendars/contacts), but I was very concerned with my YouTube subscription list. [I ended up exporting the data and converting it into OPML format to import into my RSS client.](/blog/converting-my-youtube-subscriptions-to-rss-2025-03-01/) It took some effort, but the process went relatively smoothly.

An aside, but I have to say I am so much happier using YouTube this way. I've been off social media all year (except occasionally popping on to Linked In, but I hate it there so leaving is easy; it doesn't really count), but I like having videos (and marketing emails -- perhaps a future post?) in the same place as my news feeds so much that I'm thinking about bringing social media back into my life in a sort of "read-only mode" via RSS.

Anyway, once I had exfiltrated the most important stuff from my Google account I was fresh out of excuses for not fully migrating. I was considering self-hosting it, but decided against that for two reasons:
1. My k3s cluster has been much less stable than I'd like, although I think I may have finally figured out why.
2. I was worried about reputation issues. IE getting flagged as spam any time I tried to send mail. Which I do so rarely that I anticipated it being a problem not really worth solving, thus being a big headache every time I actually needed to send mail.

I did absolutely no research, and moved to Fastmail. I seem to recall being recommended to them, but I don't remember who from or when. ¯\_(ツ)_/¯ 

I will say, so far I'm impressed (with one exception I'll come back to). They have an imperfect-but-still-pretty-good Google migration tool; a masking service, so you can generate random @fastmail.com addresses to forward mail to your real account without needing to give it away; and, the feature I think is most interesting, you can have multiple custom domains associated to one account without extra cost. The pricing is the same as Google: $6/user/month, or you can pay a year at a time for sixty bucks, which is what I went with.

After signing up for an account I used the migration tool to connect to my Google account via OAuth. That allowed their tool to [import my email, contacts, and sort-of import my calendars](https://www.fastmail.com/how-to/move-from-gmail/). The calendar thing was the most confusing, so I'll come back to it later. Once the migration was complete, I went through their **very good** docs on [setting up my custom domain](https://www.fastmail.help/hc/en-us/articles/360058753394-Custom-domains-with-Fastmail). The Settings include a button to confirm DNS is all correct, which was really nice to have. I sent a test mail from my vanilla `@gmail.com` account and saw that it ended up in Fastmail and not in my Google Workspace email. I figured if anyone was likely to hang on to the old info it'd be Google; if Google is sending mail to the right place surely everyone else will be, too.

Just before trying to delete my Google Workspace account, I had the presence of mind to hit [takeout.google.com](https://takeout.google.com) and start two exports: one containing my emails, contacts, and calendar data (just in case); another for my Google Drive documents. For now I just dumped all that into my iCloud Drive.

This is where things go negative. First, Google _bills_ monthly, but apparently does annual contracts for Workspaces. So even though I want my account deleted now, I have to wait until the end of September. Which of course means I need to continue paying $6/month until the end of September. 🖕

Fastmail scammed me good, too. I signed up on a 30 day free trial, which was great. I was able to do the migration, use a custom domain, everything on the free trial. Excellent! But I was seeing warning in the UI about the fact that I was at risk of losing my account & my data if I let the trial end before putting in billing info. At this point I was committed to being on Fastmail for the foreseeable future, so I went ahead and put in my cred card. Fastmail immediately ended my 30 day trial after 30 minutes and billed me. 👎

Back to the calendar for the final negative. The migration tool claims to not support calendars, so I manually imported my Google-exported iCal files only to see that I had all the calendar data twice. I went ahead and deleted the ones I had imported manually. Then I realized that the other set _weren't_ imports. Fastmail had subscribed to the calendars as if they were from an external provider. Meaning that when my Google Workspace finally does go away in September, I would have lost all my calendar data from both places if I hadn't realized my mistake. To correct this I had to disconnect the calendar integrations, and then manually import the calendars again. ☹️

Ultimately I'm happy with the choice in provider. The entire process -- from deciding to do the migration; to being completely done; including all the extra exports, DNS changes (with propagation), and messing with the calendars multiple times -- took less than an hour. Should have done this along time ago. Last September, perhaps. 😖
