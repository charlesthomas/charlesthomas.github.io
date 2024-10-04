---
title: "Shows What I Know – More Finishing Touches"
date: 2013-09-09T22:06:06-04:00
tags:
  - email
  - raspberry pi
---
I guess I wasn’t done with Postfix after all. After I wrapped up lasts night’s post, I got an email from someone, and tried to reply. Only to get a message that the email failed to send.

It turns out that relayhost was the wrong setting for me. Since my ISP blocks outbound smtp traffic on port 25, I have to use my relay server as my outbound server. By setting the relayhost field, ALL traffic was going through the stunnel. So an email to, say, gmail.com would go from the relay server, through the tunnel, to my primary server, which would then try to send it to gmail.com, only it can’t because it’s blocked.

After some digging, I was able to figure out what I really needed: **transport_maps**. Setting this up, though, and figuring it all out was a total pain. So, without further ado, here’s what I did.

First, add the transport_maps config to _/etc/postfix/main.cf_:

```
transport_maps = hash:/etc/postfix/transport
```

We’ll get to what the `hash:` part means in a bit. After that, I added this line to the actual file `/etc/postfix/transport`:

```
domain.com smtp:127.0.0.1:466
```

Finally, I issued a command with `postmap`:

```
sudo postmap /etc/postfix/transport
```

Postfix wants stuff in weird, binary file database format. The `hash:` bit mentioned earlier is telling postfix which format it will actually be in. By issuing the `postmap` command, you’re building the database from the actual flat file `/etc/postfix/transport`. If you look in `/etc/postfix` you’ll see the file `/etc/postfix/transport.db`.

Now, outgoing mail from me to someone else will be sent as expected, and the mail to me that hits the backup server will still be sent to the primary, and via the stunnel with tls.
