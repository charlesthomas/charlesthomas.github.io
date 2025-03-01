---
title: "Converting My YouTube Subscriptions to RSS"
date: 2025-03-01T16:08:25-05:00
tags:
    - hacks
    - rss
    - youtube
---

Recently I started thinking about trying to de-Google my life
([again](/blog/building-a-raspberry-pi-mail-server-why-2013-08-04/)),
and aside from my email archive the only data I really care about is my list of YouTube subscriptions. I've been vaguely aware for a while that every YouTube channel has an RSS feed, but I thought it would be a huge hassle to extract that information and do something useful with it. It turned out to be pretty easy. This post will detail how I liberated my subscription info, converted the subscriptions into a file I could import into my RSS client, and how I subscribe to new channels as I find them.

## Extracting Existing YouTube Subscriptions

Credit to Google; this turned out to be a hell of a lot easier than I expected. [takeout.google.com](https://takeout.google.com) allows anyone to exfiltrate their data from Google. By default it includes way more data than just YouTube subscriptions, so click "Deselect all," then scroll all the way to the bottom of the page and check "YouTube and YouTube Music." That will allow you to click the "All YouTube data included" button, which opens a menu. Click "Deselect all" there, and then re-enable "subscriptions" before clicking "OK," and then "Next Step." There's another page of options for how you want the exported data, and after you "Create export" it may take some time. Eventually you'll end up with a CSV file containing your YouTube subscriptions.

## Converting the Output into Something I Can Import Into My RSS Reader

[This repo on GitHub](https://github.com/rredford/YouTubeDataToRSS) hasn't been updated in 4 years, but still worked for me. I didn't bother cloning it; I just copy/pasted [the raw version of `csvtoopml.py`](https://raw.githubusercontent.com/rredford/YouTubeDataToRSS/refs/heads/main/csvtoopml.py) into a file on my Mac and ran `python3 /path/to/subsubscriptions.csv /path/to/subsubscriptions.opml` to convert the data Google gave me into one my RSS service would accept. I'm currently using Feedbin (although keep an eye out for a post when I start self-hosting something else), and [they make it easy to import (or export) an OPML file](https://feedbin.com/help/how-to-subscribe/).

## Managing New Subscriptions

I've subscribed to the RSS feeds of several new channels since setting this up. The URL format is pretty straightforward:

```
https://www.youtube.com/feeds/videos.xml?channel_id=THE_CHANNEL_ID_HERE
```

And you can even do the same thing with a playlist instead of a channel:

```
https://www.youtube.com/feeds/videos.xml?playlist_id=YOUR_PLAYLIST_ID_HERE
```

The only real trick is that most YouTube channels use a vanity URL and it's more complicated to get the channel ID in those instances. After going through it manually a few times, I found [another GitHub repo](https://github.com/cdevroe/yt-rss) with a bookmarklet that you can add to your browser's bookmark bar to convert the currently open YouTube channel tab straight into the RSS feed. For whatever reason, the repo doesn't make it super easy to drag & drop, and I can't get Hugo (this site's static site generator) to render it correctly, so you may have to fiddle with the repo's instructions for a while.
