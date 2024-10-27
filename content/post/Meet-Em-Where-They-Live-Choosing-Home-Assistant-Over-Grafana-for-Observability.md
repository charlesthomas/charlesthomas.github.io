---
title: "Meet 'Em Where They Live: Choosing Home-Assistant Over Grafana for Observability"
date: 2024-10-27T12:58:50-04:00
tags:
    - grafana
    - home-assistant
    - homelab
    - observability
---

When I
[got laidoff](https://href.crt.lol/431zh)
last year and started building out my
[homelab](https://href.crt.lol/bWJuB),
I upgraded my NAS from 8 to 32TB.
As part of the new NAS setup I created two shares with quotas,
which together are limited to 8TB;
the size of the old NAS.
I took the old NAS and a raspberry-pi with Tailscale installed to my folks',
and added a cronjob to my `k3s` cluster to sync those shares.
Now I've got an 8TB
[offsite-backup](https://href.crt.lol/lgCGY)
of my most critical files.
I also have access to 1TB of dedicated space on a shared, externally hosted VM.

I am not the only user of these shares,
but I am the only person with direct access to them.
Managing the usage on the 1TB share in particular has always been an issue,
even when it was just me making use of it.
At some point after I got `grafana` running in my homelab,
it occurred to me that I could find a way to scrape the disk usage on all these shares,
and keep an eye on them in `grafana`.
I had intended to use it as an exercise in learning `telegraf`.

Eventually it dawned on me:
The problem isn't that **I** don't know how full the drives are.
I can find that easily enough because I have `ssh` access to all the machines hosting these shares.
The problem is that _my other users_ don't have any access at all.
They also don't have access to `grafana`,
and even if they did they don't know how to use it.
My users **do** have access to `home-assistant`,
and they know how to use it.

It turns out `home-assistant` has an API endpoint you can hit really easily with `curl`,
in order to update a device.

This is the `curl` command I use to set the percentage used of my 32TB NAS:

```bash
curl -s -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" \
-d "{\"state\": \"${nas01}\", \"attributes\": {\"unit_of_measurement\": \"%\"}}" \
"https://ass.crt.house/api/states/input_number.nas01"
```

I tied all this together as another cronjob in my `k3s` cluster.
It's a series of individual scripts,
but I mount them all from a single
[ConfigMap](https://href.crt.lol/SzeCh).

I'm quite happy with the end-result,
and now my users know how hard we're all hitting these shares,
without me needing to be extra vigilant so I have time to warn them.

{{< image src="screenshots/home-assistant-storage-dashboard.png" alt="An iPhone screenshot of a home-assistant dashboard showing three guages, each nidicating the percent used of 3 different drive shares" >}}
