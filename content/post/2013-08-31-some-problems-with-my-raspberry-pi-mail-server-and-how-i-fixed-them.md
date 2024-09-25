---
title: "Some Problems with My Raspberry Pi Mail Server, and How I Fixed Them"
date: 2013-08-31T22:06:06-04:00
tags:
  - email
  - raspberry pi
---
Since I moved my mail to [my own mail server](https://charlesthomas.dev/blog/building-a-raspberry-pi-mail-server-how-2013-08-04/) running on a Raspberry Pi in my apartment, I’ve been seeing weird delays in getting email. Most notably from Gmail accounts. I finally got to the bottom of what was happening. …Sort of. To tell you the truth, I found a couple of problems, and fixed them both, and only then tested sending from gmail. I’m pretty sure the last thing I fixed isn’t relevant, but who knows. This stuff probably isn’t worth a new post. But on the off chance that someone has actually been following these guides, I want to make sure they aren’t having the same problem. Plus, as I mentioned before, I’m documenting this as much for myself as anyone else. If something happens to the Pi and I need to do this all over again, I want a guide.

# TLS

Mail servers are VERY confusing to me. Throughout this process I’ve been constantly confused by SMTP and how it works. I was under the impression that sending mail was a separate process for receiving mail and from reading mail. (By reading mail, I mean when I configure Thunderbird or my phone’s email client to connect to the mail server). I was sort of correct, but also critically incorrect. Sending and receiving mail happen together, and reading mail is separate. In terms of the programs I’m using, sending and receiving both happen with Postfix, and reading happens with Dovecot. This misunderstanding is important to overcome, because it was the root of my gmail problem. Because I thought of receiving mail as separate from sending, I never bothered to correctly configure STMPS, or secure SMTP. This is because outbound SMTP traffic is blocked by my ISP, so I’ve been actually sending mail out of a completely different mail server not maintained or configured by me.

It turns out that gmail was bouncing mail to me because TLS was only half configured. I thought by enabling it in `/etc/postfix/main.cf` with `smtpd_use_tls = yes`, then TLS would work on port 25. I had assumed that port 465, the standard STARTTLS port would only be needed if I was making secure STMP connections to my mail server to send mail out. That is incorrect. Gmail, and probably other mail servers as well, connect through 465 in order to send mail to me using TLS. Postfix will not allow TLS over port 25.

So here’s how I fixed it: As I mentioned above, TLS was half configured (in `/etc/postfix/main.cf`), but I needed to enable it in `/etc/postfix/master.cf`. I did this by uncommenting the line starting with `smtps`. It’s important to note that I had [enabled spam filtering](https://charlesthomas.dev/blog/more-raspberry-pi-calendar-syncing-spam-filtering-2013-08-24/) by adding the content filter option to the smtp line of this file. I made sure to tack that on to the end of the stmps line, too. I’m not sure if that was required, but it’s working with it there, and I’d rather be safe than sorry.

Once I restarted Postfix, a port scan showed I was now listening on port 465. The last step here was enabling port forwarding for that port on my router. After that, I was able to get emails from gmail immediately. What I assume was happening is that gmail was trying for days to send mail to me either through port 465 and immediately failing because that port wasn’t open, or it was connecting on port 25 and trying to enable STARTTLS, which Postfix doesn’t allow, and closes the connection. Either way, gmail couldn’t connect to me that way, and would eventually give up and send the mail plain text. Obviously since the whole point of this is to make my email MORE secure, I am much happier now that I know STARTTLS is working.

# Authentication Warnings

The other big problem I had, which may or may not be relevant to the gmail problem I was having is that I would often see warnings about private/auth and no SASL authentication method in the mail logs in `/var/log/mail.*` It turns out these messages were coming from Dovecot trying to authenticate. Which confuses me, because Dovecot and Postfix were working. Maybe it was similar to the problem I pointed out in the Calendar Syncing, Spam, etc post linked above, where they happened to be working together because they’re on the same system and the paths were configured successfully.

At any rate, I had to update the Dovecot config `/etc/dovecot/conf.d/10-master.conf`. According to all the tutorials I found I needed to add config in this file called “client,” however, adding the recommended config resulted in Dovecot failing to start. This is because I’m running Dovecot 2.x.x and that config is for Dovecot 1.x.x, and in their infinite wisdom, whoever wrote Dovecot 2 decided to break compatibility with the configs. So, to actually fix this, here’s what I added to the file, inside the “service auth” block:

```
unix_listener auth-userdb {   mode = 0666   user = postfix   group = postfix   }
unix_listener /var/spool/postfix/private/auth {   mode = 0666   }
```

# Misc

While I was making all of these changes and thinking about the blog, I realized that I wasn’t paying attention to what changes I was making, so I would have to review everything after it was working, in order to write this up. On top of that, I haven’t backed up any of the configs yet. I had been planning to just `dd` the SD card, but that requires taking the mail server offline, and I don’t have a backup yet. Instead I made a git repo on the mail server, and copied all the files into it. Next time I have to change any of this crap, I can just git diff to see what I changed when I write it up. Plus I cloned the repo on my laptop, so it’s now backed up. And Tuesday, it will be doubly backed up, when I plug my laptop into my Time Machine backup drive.

While I was copying everything into the git repo, I decided to copy the SSL certs, too. Except I have two sets. One that was auto-generated by Dovecot when I installed it, and one set I did myself for Postfix. Since the Dovecot set had generic garbage in all the cert’s fields, I decided to change the Dovecot config to use the same certs Postfix is using. Then I only had to copy one set into the repo. In order to change this in Dovecot, I edited `/etc/dovecot/conf.d/10-ssl.conf`. Once you’re in there, it should be pretty obvious what lines to change there. It’s probably worth noting that this make my email clients freak out, because none of the certs were ever signed by a Certificate Authority, and now they had changed. I just had to confirm the security exceptions in each of the clients, and then they were fine again.

# Next Steps

This is my third mail server how_to (I’m not including the [original post](https://charlesthomas.dev/blog/building-a-raspberry-pi-mail-server-why-2013-08-04/), because it was just a rant on why I was setting this all up), and in each one I’ve had a section of what I still had left to do. This is no exception. I’m getting closer to being done with this project, but I’m not there yet.

I happened upon [the post I had read](http://sealedabstract.com/code/nsa-proof-your-e-mail-in-2-hours/) before starting all of this that described using file system level encryption. Now that I found it again, I am going to try setting up EncFS, as that post describes. If that works, then I’m not going to bother with encrypting all mail individually after it comes in. However, if I can’t get that working, either (I already tried TrueCrypt, and it didn’t work), then I am still going to consider that option.

Before I do that, I need a backup mail server. I had intended to use a second Raspberry Pi. Unfortunately, as I stated in the last Next Steps section, the company that was colocating RPis for free is now not doing that. I did find another company that will do it for 36 Euros a year, but there’s a 90 day waiting period. I don’t want to wait that long. I’ve been toying with the idea of getting a Linode VPS. If I do that, then I’ll put the relay mail server there (with EncFS). That will also allow me to stop using HostGator as my SMTP server, and use the Linode instead. Unfortunately for my wallet, I bought and built the second Raspberry Pi before sorting all this out.

On the other hand, I’ve been thinking about building a modified Pirate Box for a while. If I use Linode as my secondary server, then instead of buying a router and dealing with installing DD-WRT on the router, I can just use the RPi instead. This has several advantages. First, it will cost me less money – I’ll just need a WiFi USB card for the Pi, which will be cheaper than the router I was looking at. In addition to that, it should be easier to get Pirate Box running on the RPi than on a router. And finally, RaspberryPirateBox just rolls off the tongue nicely.
