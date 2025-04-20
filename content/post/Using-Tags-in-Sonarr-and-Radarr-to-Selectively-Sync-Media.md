---
title: "Using Tags in Sonarr and Radarr to Selectively Sync Media"
date: 2025-04-19T20:47:07-04:00
tags:
    - bash
    - homelab
    - jq
---

When
[I got laid off](/blog/automating-myself-out-of-a-job-2024-01-06/)
I got really lucky and had an offer pretty quickly.
After I got my homelab up and running, I decided to put some of my severance toward a new NAS, and upgade my storage.
I moved the original off site, and installed
[Syncthing](https://syncthing.net/)
on both of them to keep a redundant copy of my most crucial data.

The old NAS has about 1/4 the storage of the new one,
so I decided to be selective with the media I synced to it,
so that the stuff that was the most important would have a backup,
but the rest wouldn't fill it up.

My original solution to this was to have two different media folders,
one for the stuff that would sync off site,
and one for the rest of the stuff that wouldn't.
This turned out to be a hassle to maintain.
[Jellyfin](https://jellyfin.org),
[Plex](https://plex.tv),
[Radarr](https://radarr.video),
and
[Sonarr](https://sonarr.tv),
all support having multiple media directories,
but Radarr & Sonarr both remember to which directory last added something,
which meant I kept adding stuff to the wrong places,
and then having to shuffle stuff around to fix it.

Today I figured out how to use their APIs enough to write scripts that can hardlink all of the media with a specific tag to a separate location, so that Syncthing can find it and send it to the off site NAS. They each run via `cron` once per day on my primary NAS. I put the scripts in their respective homelab repos:

- [`sync-radarr.bash`](https://github.com/charlesthomas/homelab-radarr/blob/main/bin/sync-radarr.bash)
- [`sync-sonarr.bash`](https://github.com/charlesthomas/homelab-sonarr/blob/main/bin/sync-sonarr.bash)

Now instead of taking care to make sure I have the right location when I add new media,
I can just add the "sync" tag after the fact.
The scripts don't do cleanup,
if I decide to remove the tag from something,
but I expect that to be rare enough that I won't mind the manual cleanup involved there.
