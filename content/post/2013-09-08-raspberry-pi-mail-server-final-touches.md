---
title: "Raspberry Pi Mail Server: Final Touches"
date: 2013-09-08T22:06:06-04:00
tags:
  - email
  - raspberry pi
---
**Updates:** _It turns out the relayhost setting below didn’t work for me. [Here’s what I did instead.](https://charlesthomas.dev/blog/shows-what-i-know-more-finishing-touches-2013-09-09/)_

If you’ve read any of my prvious posts about this ([previous posts listed here](https://charlesthomas.dev/tags/raspberry-pi/)), you’ll know they pretty much all included a “Next Steps” section. I have finally finished everything on the lists, so unless I discover I’ve done something wrong, or I think of something else this needs, I should be done with this project. Here’s what was left:

# Setting Up a Relay Mail Server

This was pretty straightforward, at least at the start. I bought a [Linode](https://www.linode.com) and then used [the same guide](https://help.ubuntu.com/community/Postfix) from [the original “How” post](https://charlesthomas.dev/blog/building-a-raspberry-pi-mail-server-how-2013-08-04/) to get Postfix up and running on it. From there, I just followed [this guide](http://www.howtoforge.com/postfix_backup_mx) to set up the new Postfix server as a relay back to my Raspberry Pi.

The big issue I ran into here was that I initially had both Postfix servers configured with the same hostname (just _rlesthom.as_) in main.cf. This caused a problem when trying to communicate between the two servers. To fix this, I just changed the _my_hostname_ field to the same name they have on my DNS server. After that, I was able to relay mail from my backup Linode server to my Raspberry Pi. The only problem was that it was relaying the mail over port 25; the communication was unencrypted.

# Using Stunnel to Make the Relay Server Send Mail to the Main Server Using an Encrypted Connection

It turns out that Postfix is incapable of relaying mail with encryption. After some DuckDuckGo-ing (If Googling can be a word, so can DuckDuckGo-ing), I found the answer to this problem was `stunnel`. Stunnel is in apt, so it was easy to install. The configuration was relatively simple, too, although I did hit a stumbling block: stunnel is encrypted at the start, but STARTTLS works by opening a plain-text connection, and then telling the server to **Start** the **TLS** encryption (hence the name). Stunnel can do this, too – you just have to add `protocol = smtp` to the stunnel config. However, in all the guides I found, this was not mentioned. Stunnel config is really short and sweet, so I’ll just dump my config here. This is `/etc/stunnel/stunnel.conf`:

```
client = yes
output = /var/log/stunnel4/stunnel.log
sslVersion = SSLv3
[smtps]
accept = 127.0.0.1:466
connect = primary.mail.server.com:465
protocol = smtp
```

It should be fairly obvious what’s going on here: stunnel is running in client mode, logging to `/var/log/stunnel4/stunnel.log`, using SSL version3, listening to plain-text connections on `localhost (127.0.0.1)`, and sending the encrypted traffic to `primary.mail.server.com, port 465`. Again, the `protocol` field is important; the connection won’t open to the remote server without it.

There’s one important thing left to do in order to get this working: reconfigure Postfix to relay mail through stunnel, instead of sending it to the main Postfix server directly. This is done by changing the `relay_hosts` field in `/etc/postfix/main.cf` to this:

```
relay_hosts = 127.0.0.1:466
```

# Regularly Making an Encrypted Backup

This was probably the easiest step of the entire process, mostly because I am already familiar with `tar` and `gpg`. I created a cron job on the Raspberry Pi to create an encrypted tarball in my home directory once per day. (gpg compresses by default, so there’s no need to gzip it, too.) Now when I’m on my laptop at home, I’ll just `scp` it down. And, as I’ve mentioned in previous posts, I have a Time Machine drive at work for offsite backup.

Here’s the cron job:

```
2 3 * * * tar -cO /home/email_user/Maildir | gpg -r email_address --encrypt > /home/system_user/mail.tar.gpg
```

# Encrypting the Maildir File System

This was pretty easy to set up, too. I used [this blog post’s EncFS section as a guide](http://sealedabstract.com/code/nsa-proof-your-e-mail-in-2-hours/). One important note on that, though: If you look at the comments section, you’ll see people having trouble with the encfs command. I found the solution, and posted a comment, but at the time of this writing, the comment hasn’t been approved by the blog’s author. At any rate, here is the version of the command that worked for me:

```
encfs –public /encrypted_mail /decrypted_mail
```
