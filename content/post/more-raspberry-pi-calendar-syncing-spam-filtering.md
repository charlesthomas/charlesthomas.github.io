---
title: "More Raspberry Pi: Calendar Syncing, Spam & Filtering"
date: 2013-08-24T22:06:06-04:00
tags:
  - email
  - raspberry pi
---
**Calendar Syncing: Radicale**

[After I got a mail server running on my Raspberry Pi](https://charlesthomas.dev/blog/building-a-raspberry-pi-mail-server-how-2013-08-04/), I tried to find a way to sync my calendar and contacts to my phone, and computer. I was using Own Cloud, which handles contacts and calendar well. Unfortunately, Own Cloud was built for file syncing (like a self-hosted Dropbox), except it’s REALLY bad at it. It didn’t make sense to use it for the two add-on things I needed, since I couldn’t trust it to serve its primary purpose. I went looking for alternatives, and found [Radicale](http://radicale.org/).

There weren’t any tricks to setting this up; I just used the documentation on the website. I will note that I used the certificate I generated in the Dovecot setup to set Radicale up to sync over HTTPS, rather than unsecured HTTP. I’m using [Thunderbird](https://www.mozilla.org/en-US/thunderbird/) for email on my laptop, because [Enigmail](https://addons.mozilla.org/en-US/thunderbird/addon/enigmail/?src=search) is awesome for handling encrypted email. The extension [Lightning](https://addons.mozilla.org/en-US/thunderbird/addon/lightning/?src=search) adds calendar integration, and another extension, [CALDAV – Search/Subscribe](https://addons.mozilla.org/en-US/thunderbird/addon/caldav-searchsubscribe/?src=search), adds syncing using the protocol Radicale uses. My phone and tablet are both Android ([you can see how I attempt to secure them in a previous blog post here](https://cha.rlesthom.as/2013/07/22/securing-my-android-phone/)), and I installed [CalDAV-Sync beta](https://play.google.com/store/apps/details?id=org.dmfs.caldav.lib) to sync Radicale to my mobile devices.

I attempted to use Radicale to sync my contacts, too, but ran into a bunch of issues. First, the Radicale website specifically states that it doesn’t work with the only CardDav extension for Thunderbird. I installed CardDAV-Sync on my phone and tried to sync my contacts their to the Radicale server, but it seemed to have gotten stuck in an endless loop and never actually transferred any data. Conveniently, it’s pretty easy to export contacts off my phone. Since they change much less often than my calendar, I’ve decided to just back those up manually if/when my contacts change.

**Spam**

I’m using SpamAssassin to filter out junk email. Like most tech projects, it was easy in hind-sight, but a real pain in the ass to actually get working. Spam Assassin is in Apt (Debian’s, hence Raspbian’s, package manager) so installing it was easy. However, actually getting it to filter was trickier. In order to actually do any work, you have to configure Postfix to trigger it. AND you have to write a script to pass filtered and unfiltered email back to Postfix. There’s a [guide to get this working](https://wiki.apache.org/spamassassin/IntegratedSpamdInPostfix), which I followed to the letter. There’s actually multiple options/guides at that link; I used the first one. One important point that caused me a big headache: **the guide specifies the user as spamd, but the Debian/Raspbian user is debian-spamd**.

**Filtering**

Sieve is the go-to filtering software. Again, it was awful to figure out, but in hindsight, it’s easy. Finding guides for this was particularly tough, because the name of the filtering software is Sieve, but Sieve is also the language it uses for writing filtering scripts. It can be installed from apt with `apt-get install dovecot-sieve`. The tricky part for configuring this lies in telling Dovecot how to use Sieve, AND you have to tell Postfix about it, too.

In `/etc/dovecot/conf.d/15-lda.conf`, find the “procotol” section, and change the “mail_plugins” line to include “sieve.” You can replace the existing text or just tack sieve onto the end. While you’re in this file, uncomment the postmaster_address line, and add a legitimate email address. Once you try to restart Dovecot after everything is configured, it will barf if that line is absent or misconfigured. Here’s another thing that took me forever to figure out: in the original Postfix guide I found, it specifies that “mailbox_command = ” should be blank in `/etc/postfix/main.cf`. Somehow, Postfix and Dovecot were working together, without really knowing about each other. (As far as I understand it.) I suspect this is because they happen to be configured to both look in the same place to find (or deliver) the actual mail. Anyway, this is how I have that set now: `mailbox_command = /usr/bin/spamc -e /usr/lib/dovecot/deliver` This also uses Spamassassin (hence `/usr/bin/spamc`). If I had to guess, I’d say mail is probably getting filtered through Spamassassin twice now, but I’m not 100% sure. I am 100% sure that it works in this configuration, so I’m going to leave it. If you actually know how all this crap is supposed to work, and I’m wrong, [feel free to email me](mailto:ch@rlesthom.as) and tell me what I misunderstand or what I’m doing wrong.

Now that Sieve is working, you still have to write filters for it. I setup Spamassassin to prepend “*****SPAM*****” to the beginning of the subject line of messages it considers to be spam. My only real sieve filter now moves messages marked that way to my Junk folder. Here’s the filter code, to serve as an example (and a backup):

`require "fileinto";   if header :contains ["Subject"] "*****SPAM*****" {   fileinto "Junk";   stop;   }`

This text goes into a file in the mail user’s home directory called `.dovecot.sieve` Installing sieve also installs `sieve-test` which takes as arguments the filter file (`.dovecot.sieve`) and an email file (assuming you followed the guides I did, these are likely somewhere in `Maildir`). The script will tell you if and how Sieve will actually filter that email.

That should be all there is to it. I am now running my own mail server, syncing my calendar to my own server, and successfully filtering out spam. I still have a few items left on the mail server to do list, though.

Left to do:

- Backup mail to my laptop (and through my laptop, to Time Machine)
- Configure and install a relay mail server (This is going to be more difficult than I imagined, because the host I originally linked to isn’t taking any more customers)
- Create a script to encrypt all my mail (still not sure if I’m actually going to do this. I discovered recently that my phone can encrypt mail to send, but isn’t very good at decrypting mail I’ve been sent. Maybe I’ll encrypt everything except the inbox?)
