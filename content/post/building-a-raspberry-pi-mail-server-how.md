---
title: "Building a Raspberry Pi Mail Server: How"
date: 2013-08-04T22:06:06-04:00
tags:
  - email
  - privacy
  - raspberry pi
---
{{< image src="pics/rpi-parts.png" alt="raspberry pi 2, an external hard-drive, and some other parts; still in their packaging" >}}

Now that I’ve ranted about [why I decided to build my own mail server](/blog/building-a-raspberry-pi-mail-server-why-2013-08-04/), it’s time to explain how.

In order to build my own mail server, I decided to use Postfix and Dovecot on a Raspberry Pi.
I chose these three very specifically.
Postfix and Dovecot are the go-to for building a mail server, and Raspberry Pis have been the home server of choice ever since they were announced.
By selecting these, I was certain I would be able to get the most community support, and I would be able to find the most comprehensive guides on how to set everything up.

# Step 0: Buying the parts

Aside from the large, helpful Raspberry Pi community, the other advantage of the computer’s popularity is the fact that you can buy the thing on Amazon.
Which meant quick shipping, since I have Prime.
[Raspberry Pis are sold as just the board](http://www.amazon.com/gp/product/B009SQQF9C?ie=UTF8&camp=213733&creative=393177&creativeASIN=B009SQQF9C&linkCode=shr&tag=crthomasorg-20),
[which meant I also needed a case](http://www.amazon.com/gp/product/B00ASJRMT0?ie=UTF8&camp=213733&creative=393177&creativeASIN=B00ASJRMT0&linkCode=shr&tag=crthomasorg-20),
and [an SD Card for storage](http://www.amazon.com/gp/product/B007JRB0TC?ie=UTF8&camp=213733&creative=393177&creativeASIN=B007JRB0TC&linkCode=shr&tag=crthomasorg-20).
One thing I didn’t buy was a power adapter.
Pis are powered by micro USB (just like your phone – assuming you aren’t using an iPhone).
Because micro USB is so popular, and I am a gadget addict, I was lousy with micro USB cables and USB power bricks.
If you don’t have extra of these lying around,
[you’re going to need to pick those up, too](http://www.amazon.com/gp/product/B005LFXBJG?ie=UTF8&camp=213733&creative=393185&creativeASIN=B005LFXBJG&linkCode=shr&tag=crthomasorg-20).
Finally, RPis have an ethernet port, but not WiFi.
If you want your Pi to be wireless,
[you’re going to need a USB WiFi card](http://www.amazon.com/gp/product/B003MTTJOY?ie=UTF8&camp=213733&creative=393185&creativeASIN=B003MTTJOY&linkCode=shr&tag=crthomasorg-20).

# Step 1: Assembly & First Boot

Once everything showed up, it was pretty simple to put it together.
The case has 4 philips head screws, and the RPi only fits in it one way.
The SD card is slotted in after assembly, so you don’t have to worry about waiting until after you’ve imaged it to put the case together.

After the Pi was physically assembled, I flashed the SD card with Raspian; a special Raspberry Pi version of Debian.
There’s a couple of ways to install an operating system onto the SD card.
The easiest is probably a system they call NOOBS.
However, NOOBS requires plugging the RPi into a monitor, keyboard, and mouse.
Since I only have a laptop at home, I don’t have a keyboard or mouse.
I hadn’t anticipated this, so I had to flash the SD card.
[Instructions for NOOBS is on the official RPi site.](http://www.raspberrypi.org/downloads)
[The same page links to this guide, which I used to flash the card from my laptop.](http://elinux.org/RPi_Easy_SD_Card_Setup#Using_command_line_tools_.281.29)
My laptop has an SD card reader built in.
If you want to flash the card, rather than using NOOBS,
[you’re going to need an SD card reader, too.](http://www.amazon.com/gp/product/B0046TJG1U?ie=UTF8&camp=213733&creative=393177&creativeASIN=B0046TJG1U&linkCode=shr&tag=crthomasorg-20&qid=1375649709&sr=8-1&keywords=sd+card+reader)

After the card was flashed, I popped it into the RPi and booted it for the first time.
The OS has a default user/password.
I SSHed in as that user, and was warned to run `raspi-config`.
In there, I did a couple of important things.
First, the image for Raspian sets the file system size at only 2GB, but I used an 8GB card.
In `raspi-config`, I expanded the filesystem.
I also changed the hostname in the Advanced Options menu.
The last thing I did on first boot was set the time zone.
It’s set to UTC by default.
This probably doesn’t matter for a lot of RPi applications, but dates and times are important for mail.
In order to do this, I used `/usr/sbin/tzconfig`.

# Step 2: Server Hardening

After configuring the time zone, I rebooted the Pi to make sure everything I changed stuck.
It did, so I moved on to securing the Pi.
First, I created a new user, and set a good password for it.

```bash
sudo useradd -m username
sudo passwd username
```

Next, I added the new username to `/etc/sudoers`.
While I was in there, I also removed the default username.

Now that the new user was in place, I copied my SSH public key to the new user’s authorized keys.
This allows me SSH access without using the user’s system password.
Now that I was logged in as the new user, I removed the default user.

```bash
sudo userdel -fr default_username
```

After the default user was removed, I edited `/etc/ssh/sshd_config`.
[Following this guide](https://help.ubuntu.com/community/SSH/OpenSSH/Configuring),
I disabled password authentication (so that not only could I get into the system with my SSH key, but I HAD to get into the system using my SSH key), set the new username as the only allowed user, and disabled root login.

# Step 3: Configuring Postfix

Now that the server was bought, built, installed, and configured, I moved on to the intended purpose: configuring the RPi as a mail server.
For the most part, [I followed this guide](https://help.ubuntu.com/community/Postfix).
The guide got me most of the way, but I did have to make some other changes.
I set `smtpd_tls_auth_only = yes`, which is the opposite of what the guide suggests.
I also set `smtpd_sasl_type = dovecot` and `smtpd_sasl_path = private/auth`.
Those last two settings were the result of basically copying someone else’s working settings.
The other thing worth mentioning, is that I enabled port 587 for secure submission.
It’s in the guide linked above, but in a later, optional section.
Somewhere along the way, I also ran into permission problems with “private/auth.” That’s a file; its full path is `/var/spool/postfix/private/auth`.
It got created automatically but with the wrong permissions.
It was owned by root, so I had to run

```bash
sudo chown postfix:postfix /var/spool/postfix/private/auth
```

# Step 4: Configuring Dovecot

Again, [I followed a pre-existing guide](https://help.ubuntu.com/community/Dovecot).
As I mentioned, the whole reason I chose these particular pieces of software is because I knew there would be good help available.
While the Postfix guide contained almost all of the information I needed, the Dovecot guide needs some serious updating.
Specifically, many of the settings in the guide are either no longer needed, or are now in different places.

The “Choice of Protocols” section can be completely ignored.
“Choice of Mailboxes” contains good information, but it tells you to put the settings in `/etc/dovecot/dovecot.conf`.
The correct location (or rather, the place I put the config, and it worked) is `/etc/dovecot/conf.d/10-mail.conf`.
The next two sections: “Setting up Maildir” and “Test” were still good, as-is.
I didn’t make the change in the “Authentication” section.
The “SSL” stuff mentions the wrong config file, too.
It’s really `/etc/dovecot/conf.d/10-ssl.conf`.
The rest of the guide contained configuration that is either now default, or for some other reason no longer needed.

# Step 5: Adding the Mail User

The username I configured in previous steps is not the one I want to get mail from.
That user is intended for doing the config, etc.
Now that everything was in place, I needed to add the mail user.
By default, Postfix & Dovecot use system users and their passwords as the database for what email addresses can get mail through the servers.
This means that if I want the email address “ch@rlesthom.as,” I need to own the domain “rlesthom.as”, and I need the mail server to have a user account called “ch.”

```bash
sudo useradd -m ch
sudo passwd ch
```

This created the ch user account, and set the password.
I **did NOT** add this user to `/etc/sudoers`.
I also edited `/etc/passwd`, and changed ch’s shell from `/bin/bash` to `/bin/false`.
This means that while the user exists, and can now get mail, it doesn’t have shell access; it can’t do anything on the system.

# Step 6: Turning Everything On & Testing

Now that everything is set up, it’s time to turn it on, and see if it works.

```bash
sudo /etc/init.d/dovecot start
sudo /etc/init.d/saslauthd start
sudo /etc/init.d/postfix start
```

Next, I configured my laptop’s email client to use the RPi’s IP address, and tested everything out.
I obviously ran into problems here, and fine-tuning was involved.
That lead me to set all of the stuff I’ve already mentioned above.

# Step 7: Network Configuration

Now that everything was working inside my network, I had to set up my router, so that the mail server would work outside.
In my router’s config, I forwarded the following ports to the RPi’s IP address: 25 (smtp), 993 (imaps), 587 (smpts).

I also set up static DHCP for the RPi’s MAC address.
This ensured that the next time the RPi asks for an IP from the DHCP server, it is guaranteed to get the same one.
Without this, it’s possible everything would randomly stop working, because your mail is being sent to (for example) 192.168.1.5 when it should be going to 192.168.1.7.

Finally, I had to update DNS.
Email knows where to go using DNS – specifically a record called MX.
I added an A record for the external IP my ISP gave me to home.cha.rlesthom.as.
My external address was found via [What Is My IP?](https://www.whatismyip.com/).
Next I created a new MX record which pointed to home.cha.rlesthom.as and set the priority to 0.
I also lowered the existing MX record to a lower priority (a higher number).
This way, if something happens to my mail server, or my home internet, I can still get mail from my old Hostgator mail server.

# Step 8: Moving My Mail Archives

After I got everything working, I migrated all of my mail off of Hostgator, and onto the RPi.
This was easily done inside Thunderbird, by just dragging and dropping.
After the mail was on the RPi, I tarballed and gzipped all the mail, and moved it down to my laptop as a backup.
Now that I had the mail in three places, I nuked it from one: Hostgator.
I used the shred command to not only delete the files, but write junk over the files first, so that the data can’t be recovered.

# Problems

I encountered a ton of problems in setting all of this up.
Many involved the correct config settings for Postfix and Dovecot, which I’ve already described above.

I wanted to store my mail inside a Truecrypt volume.
This presented many problems.
First, I had to figure out how to compile Truecrypt on the RPi, because there are no official RPi binaries for it.
[I found a guide for it](http://www.carrier-lost.org/blog/raspberry-pi-truecrypt-on-raspbian),
which included a link to a pre-compiled binary, which was really handy.
The guide also mentioned that for whatever reason, Truecrypt volumes couldn’t be created on the RPi.
Once the volume was created and transferred to the RPi, though, it worked just fine.
This lead to all kinds of weirdness with me trying to transfer a Truecrypt volume to the RPi.
Once I got it there, though, I ran into a problem I couldn’t overcome.
For whatever reason, Dovecot would just NOT store data in the Truecrypt volume.
Ultimately, I just gave up on this idea.
I am toying with the idea of PGP encrypting all of my emails individually, but I haven’t decided if that’s worth the effort.

If you look at the photo at the top of the post, you’ll see that there’s an external hard drive in it.
I had intended to attach that to the RPi to use for storage.
I ended up not doing this for several reasons.
First, the drive doesn’t have the ability to plug into a power source; it’s 100% USB powered.
I didn’t even bother to try, but I don’t think the RPi has enough power to power the drive.
Secondly, even though I have 6 years of email, it’s less than a gigabyte of data.
The hard drive is 1TB; total over-kill.
The 8GB SD card in the Pi is more than enough storage.
However, it isn’t redundant.
Instead of using the hard drive as backup storage for the RPi, I’m going to use it an an encrypted Time Machine drive for my laptop.
This allowed me to kill my Crash Plan service.
One less place that my data exists in the cloud, where the feds or someone else can get at it.

One problem that I knew of in advance, but totally blanked on when I bought all the equipment was a known, weird problem with my router.
I use a m0n0wall router, which is super awesome and crazy powerful, but it has a glaring flaw.
It can not, under any circumstances, allow you to access stuff in your network using your external IP or any DNS names.
This means that if my email clients on my laptop, phone, and tablet are configured to pull mail from home.cha.rlesthom.as, it will work fine outside my house, but as soon as I connect to my home WiFi, I won’t be able to get any mail.
M0n0wall has a way around this, luckily.
Basically I changed a setting in my router to make anything trying to connect to home.cha.rlesthom.as connect to the RPi’s internal IP address instead.
If you are using any cheapo big box store router, like a Linksys or DLink, etc, this should not be an issue.

Finally, the last big problem I encountered, which I haven’t figured out how to deal with is this: my ISP blocks outbound traffic on port 25.
This means that **I can’t send mail from my RPi**.
In researching what to do about this, I found that most ISPs either block outbound port 25 by default but enable it at a customer’s request, or they leave it open by default and block it if there are complaints about a customer sending SPAM.
_My ISP_ charges **$20 per month** to unblock the port.
Since I already have a working SMTP server on Hostgator, I just set all of my email clients to fetch mail from the RPi, but send it through Hostgator.
It’s worth noting that saving messages to a Sent folder is a working of IMAP, not SMTP.
This means that even though the messages are going out from Hostgator, they are still being stored on the RPi.

# Next Steps

Now that I’ve successfully moved my mail out of Gmail and Hostgator, the next step is to move my contacts and calendar out of Google, too.
If you read the “Why” post, you’ll see that I tried Owncloud.
This allowed me to move calendar and contacts into Owncloud.
The only problem is Owncloud is **REALLY** bad at file syncing.
Since that was the whole reason I started using it, I need to find another service that will handle calendar and contacts.
I’m still partially using Dropbox, but for stuff that I really care about keeping secure, I’ve started using Spideroak.
It isn’t self-hosted, which sucks.
But it works, and they claim to have no access to my (or any user’s) data.
The files get encrypted on the user’s computer before being sent to their servers, and they have no access to the encryption key passwords, so they can’t unencrypt the data.
I’m in the process of trying to set up Radicale, which is a contact / calendar syncing server, written in Python.
Once I get that all set up, it will probably be its own post.

The next big hurdle is setting up regular backups.
Technically, Thunderbird is a complete backup of my mail server, but I want to be 100% sure I’ve got everything, so after Radicale is setup, I’ll create a script to tarball and gzip my mail and calendar / contact files.
Then I’ll add a script to my laptop to grab them.
As I already mentioned, my laptop is now being backed up via Apple’s Time Machine.
The Time Machine drive is at work, so I also have off site backup, just by taking my laptop to work and plugging my USB hub in five days per week.

As I mentioned, I don’t like that my mail is unencrypted on the server, even though all the connections are encrypted.
[I found this guide to encrypt all mail individually, and in place.](https://grepular.com/Automatically_Encrypting_all_Incoming_Email)
I haven’t actually decided if this is worth the effort yet, but I may give it a shot.

Right now, since I’m hosting the mail server myself, I have no spam filter.
I already know someone who set up open-source filtering software on their Postfix/Dovecot setup, so I have a resource to help me with that.
It may become another blog post.

Finally, I really don’t like that my backup email server is the server I already chose to abandon.
Why did I spend time and money to leave Hostgator, just to remain dependent on it?
One more advantage of using a Raspberry Pi is that [there are currently data centers that are willing to host them for free.](https://www.edis.at/en/server/colocation/austria/raspberrypi/)
Why? Publicity, I guess.
Why they’re willing to host my hardware for free isn’t important to me.
That they will do it at all is what I really care about.
Since I now know I don’t need anything other than the RPi itself to store my mail, I can build another one and ship it to Austria for about $100.
I would set that one up as a relay mail server.
That means that if and when it gets mail, it only holds it until the main mail server comes back online, and then it just forwards it to the primary mail server (the RPi in my apartment).
I could also set that one up as the primary for SMTP server for outgoing mail, since the data center wouldn’t block outbound traffic on port 25.

Soup to nuts, this project took me about a week.
It was a fun (and frustrating) project to set up.
I learned a lot on the way, too.
This is not the first time I tried to figure out Postfix, but it was my first success.
I still have some work to do, but at this point, I consider this a success, and a good stopping point.
