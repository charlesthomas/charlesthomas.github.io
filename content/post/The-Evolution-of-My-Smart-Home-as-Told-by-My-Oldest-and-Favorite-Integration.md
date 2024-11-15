---
title: "The Evolution of My Smart Home as Told by My Oldest and Favorite Integration"
date: 2024-11-14T19:56:23-05:00
tags:
    - automation
    - home-assistant
    - homelab
    - kubernetes
    - shortcuts
---

{{< image src="screenshots/home-assistant-coffee-pot.png" alt="screenshot from my Home-Assistant dashboard showing a coffee pot button, and the times it's scheduled to turn the pot on" >}}

When I bought my first house ten years ago,
I had just moved 750 miles via UPS.
I boxed up and shipped what few belongings I cared to keep and then I got on a plane with all of my clothes; giving away,
selling off,
trashing,
or otherwise abandoning on the curb what little furniture & large electronics I had.

The furniture in the new house was either handed down to me,
or it came from the clearance section of the cheapest furniture store in town.
Including a floor model lamp with a severely bent plug.
I wasn’t convinced it was safe to leave plugged in unattended,
so after a couple of weeks of unplugging it at night & when I left the house,
I bought a two-pack of WiFi-enabled smart outlets and set the lamp up to only have power when the sun wasn’t up but I was.

With the second outlet in the two pack I setup what is still my favorite and most important smart home integration: I plugged in my drip coffee pot.

In the beginning,
just being able to grab my phone first thing in the morning and turn the coffee pot on remotely (but still manually) felt like a luxury.
Having the lamp working automatically opened my eyes to more possibilities.
It wasn’t long before I had an Amazon Echo in my bedroom so I could tell Alexa to turn the coffee pot on before I even touched my phone.

The first floor of that house had a long hallway with poorly positioned light switches.
I bought a hub,
some smart bulbs,
a couple motion sensors,
and set it all up so that the hallway lit up automatically as you walked through it.
Around this time I was also experimenting with various media setups,
and landed on AppleTVs.
Once I realized I could control smart home devices through the AppleTV remote,
I had my first smart home crisis: none of the cheap stuff I bought was HomeKit compatible.

My first attempt to resolve this was to try HomeBridge; software that mimics a HomeKit compatible bridge to connect your non-HomeKit devices through.
This worked in theory,
but was very unreliable,
and hard to keep running.
At the time I wasn’t up on containers,
so I was maintaining a bunch of VMs on a Dell Edge,
including the one for HomeBridge.
Keeping it running was a huge hassle,
and half the time it was running it still didn’t work.

Gradually I replaced my cheapo lighting with Philips Hue and as I did so I started taking advantage of the automation features in Apple Home.
This included an Apple Home automation that turned my coffee pot on automatically on a schedule,
so that I didn’t even have to holler for Alexa any more.

Another fun automation from that era involved a smart outlet and a door sensor: I happened to catch some kids trying to steal my bike off the front porch one day,
so I got myself another smart outlet and a door sensor… My office was down that same long hallway,
so when deliveries were left at the porch I often wouldn’t see or hear it.
I hooked up an automation to turn on the smart outlet for 90 seconds if the door sensor detected an opening during my work hours.
Plugged into that outlet was one of those rotating alarm lights.
🚨 😆

After about 3 years in that house,
I ended up buying a condo downtown.
I made enough on the sale of the house that I had plenty to spare after the condo mortgage down payment,
and I went all in on Hue.
Some time after that Apple launched their remake of the Workflows app as Shortcuts,
and my coffee pot automation got another upgrade.
Instead of a fixed schedule,
I setup a Shortcuts automation to turn my coffee pot on when I turned the alarm clock on my phone off.
At that time I was not keeping to a routine,
so there were days I’d wake up early and the coffee wasn’t ready,
and other days where I’d wake up so late it had that awful burnt taste.
By setting it to go off when my alarm went off,
it was always piping hot by the time I stumbled out of my bedroom,
no matter the time of day.

As I added more and more WiFi-based devices to my home,
I started hitting a problem all too common to the smart home crowd: my WiFi just kept getting worse.
I’m sure this was exacerbated by the fact that I always bought the cheapest option available,
but you put enough crappy WiFi chips on the network and the quality gear like phones & laptops will be impacted.

This only got worse during the pandemic when I moved into a different unit in the building.
I made my brother move in with me,
so that his travel for work wasn’t a danger to our parents with whom he was living at the time.
The new unit was double the size of the old,
so not only was the WiFi unstable,
now we had range issues to contend with.
It was fairly rare for the coffee pot automation to fail,
but it did happen,
and it was miserable every time.
The only thing worse than having to debug networking issues is having to do it first thing in the morning without coffee.

[After I got laid off in the last quarter of 2023](https://charlesthomas.dev/blog/automating-myself-out-of-a-job-2024-01-06/),
I decided to keep my Kubernetes skills sharp by building out a k3s cluster on some micro form-factor Dell Optiplexes I bought as a lot on eBay.
I’d seen a demo of someone running Home-Assistant in their k8s home lab with a USB Zigbee coordinator dongle that was hot-swappable thanks to `node-feature-discovery` and `descheduler`.
That was also around the time that Philips announced they’d soon start requiring an account to use their app to control Hue bulbs,
and a smart garage door opener company closed their API to force people to use their app so they could force ads on their users.
There’s very little I won’t do to avoid even normal advertising,
let alone surveillance capitalism,
so I installed Home-Assistant into my cluster with a USB Zigbee dongle of my own,
and figured out how to connect my Hue stuff to it.

I didn’t know this when I cheaped out (a recurring theme),
but the most important difference between a bargain Zigbee coordinator and a good one is follow-through.
The USB dongle I had was fire-and-forget; like UDP.
As a result,
even though my Zigbee network was fairly large and well distributed through the apartment (most non-battery-powered Zigbee devices are also signal repeaters),
the commands from the dongle didn’t always make it through to the intended device.
So even though my WiFi was better (because I also swapped all the WiFi outlets with Zigbee outlets),
and the Zigbee devices more reliable than WiFi ones,
I still had days where I woke up to a distinct lack of coffee smell emanating from the kitchen (😱).

Like I said,
though,
I didn’t know a better coordinator would fix this.
I thought this was as good as I could get.
Then two things happened:

1. My eBay machines started having drive failures
2. [Cameron Gray posted this video about his Zigbee upgrade](https://www.youtube.com/watch?v=v6L-WPWa5Go)

The upsides of experiencing a disk failure on a node in my cluster were several:

- I learned about how to recover from [an etcd corruption](https://github.com/charlesthomas/homelab/blob/main/docs/dr/raft.md)
- I developed a protocol for draining, decommissioning, and rebuilding a node in the cluster (blog post forthcoming)
- I discovered my longhorn setup couldn’t tolerate replica loss
- I got to test the hot-swappable Zigbee dongle, because it happened to be plugged in to the node that died

It took me a while to figure all of this out.
For a while when the node died I just rebooted it,
and it came back ok.
It was easier to keep the Zigbee dongle plugged in to the bad drive; while swapping the dongle did actually cause Zigbee2MQTT to be rescheduled onto the new node,
it couldn’t come up since my longhorn configuration wasn't right.
I decided to invest in the exact same network based Zigbee coordinator from the video.
I knew it would work with my setup because it was similar enough to the one in the video.

To keep a long story from getting even longer,
I’ll spare the specifics,
but in swapping Zigbee coordinators I learned that keeping the network key the same wasn’t sufficient for the devices to automatically pick up the new one.
This meant connecting to the new one by force (resetting the devices by physically touching them all).
This was especially a nightmare for the Hue stuff.
The only way I could pair them to anything was to pair them back to the Hue bridge I happened to still be using because I couldn’t find a Hue Sync integration for Home-Assistant that would work without the official bridge.
Pairing them back to the original bridge required reading the serial number off of each device.
I knew that,
from some mishaps setting this all up originally,
but at that time I had assumed it would be a one-time problem.
This time,
I had the presence of mind to catalog all of the serial numbers,
so that at least I wouldn’t have to physically touch each of my three dozen bulbs again.

The biggest bummer of all the resetting was my kitchen lights.
I really didn’t want to get up a fifteen foot ladder (the apartment has two story ceilings which under all other circumstances I love) to read the serials off my track lighting.
So much so that I wired a [Sonoff Zigbee relay](https://sonoff.tech/product/diy-smart-switches/zbmini-l2/) into the switch on the wall instead.
In the end this turned out to be a happy little accident,
because I now prefer relays wherever possible.
We’ve had some other outages since then,
and being able to use the normal light switch is great! I’ve got 6 of them wired in now,
and I'm considering some switchless relays to wire into the normal outlets,
so that I can do away with all the bulky external Zigbee outlets littered throughout the place.

There’s one final piece to the take off the coffee pot automation (at least for now).
Using the Shortcuts automation to turn the coffee pot on when I turned off my alarm served me well for a long time.
But over the last few years my sleep habits have improved significantly.
Aside from having two start times (week days and weekends),
and the occasional “I feel like crap and I stayed up too late so I’m going to turn my alarms off and sleep until I wake up naturally” days,
it’s actually better to schedule the coffee pot to turn on.
At some point I watched a video about including Helpers in automations.

Helpers are a Home-Assistant device,
but they usually involve manual intervention.
For example the [Disk Usage Monitor I setup as a Home-Assistant Dashboard](https://charlesthomas.dev/blog/meet-em-where-they-live-choosing-home-assistant-over-grafana-for-observability-2024-10-27/) uses 3 Number Helpers and a Date-Time Helper.
Although they’re all updated automatically,
it’s not via a Home-Assistant integration,
but using curl and the API.
After creating two Date-Time Helpers (week days time and weekends time),
I deleted my Shortcuts automation and created a Home-Assistant automation to replace it.
The automations read the Helpers to know what time to trigger (filtering on day of the week; eg [the week day automation](https://github.com/charlesthomas/homelab-home-assistant/blob/main/automations/Coffee-Pot-Weekdays.yaml) excludes itself from firing on Saturday & Sunday).
This has two benefits over the Apple-based solution.
Firstly,
I have the time set to be about half an hour *before* I expect to wake up.
Second,
the automations turn the pot off again after being on for ten minutes.
By putting these two things together,
I’ve got the coffee brewed early enough that it’s cooled slightly by the time I pour,
so that I can drink it right away.
☕️

Perfection!

... for now ...
