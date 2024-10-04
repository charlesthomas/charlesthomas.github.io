---
title: "Building a Raspberry Pi Mail Server: Why"
date: 2013-08-04T22:06:06-04:00
tags:
  - email
  - privacy
  - raspberry pi
---
Updates: [@seanbonner](https://twitter.com/seanbonner) has a great post on privacy vs security, which really gets at the heart of what I was trying to say at the end of this post, but in a much more easy to understand way.
[You should really check it out.](http://blog.seanbonner.com/2013/08/11/encrypting-suspicion/)

I also blogged about the technical details of **how** I built the mail server. [That post is here.](/blog/building-a-raspberry-pi-mail-server-how-2013-08-04/)

{{< image src="pics/rpi-mail-server.jpg" alt="a raspberry pi 2 with an EFF.org sticker" >}}

For a long time, I’ve used Google for mail, calendar, and contact storing and syncing.
I also used it for RSS.
When Google announced they were shutting down Google Reader, I sort of panicked and started moving all of my various web stuffs off of free services.
I moved my Tumblr and Blogger blogs to Hostgator WordPress instances, tried multiple new RSS readers, and tried replacing Dropbox, Google Calendar, and Google Contacts with Owncloud.
Most importantly, I moved 6 years of email off of Gmail and into Hostgator’s mail servers.

And [then PRISM happened](http://www.theguardian.com/world/2013/jun/06/us-tech-giants-nsa-data).
And [then the FBI started requesting web companies provide them with encryption keys](http://news.cnet.com/8301-13578_3-57595202-38/feds-put-heat-on-web-firms-for-master-encryption-keys/).
And [then XKEYSCORE happened](http://www.theguardian.com/world/2013/jul/31/nsa-top-secret-program-online-data).
At this point, very few cloud services are safe from prying eyes.
So I decided to move my mail again.
In house, literally.
The likelihood that the feds have direct access to Gmail and Dropbox is pretty good.
The likelihood that they have direct access to Hostgator is much less.
However, if [they sent Hostgator a “National Security” Letter](http://www.newyorker.com/online/blogs/elements/2013/06/what-its-like-to-get-a-national-security-letter.html), I’d have just as little recourse to protect my data.
It’s just as likely that the government could send an NSL to my ISP, but they aren’t storing my mail; just sending it to me.
Unless they are doing some serious data logging, they wouldn’t have much of my data.
Or at least that’s the hope.
If they really want the data, the only way they’re going to get it is if they have a warrant to enter my house.

I’m sure at this point, you’re thinking that this is an overreaction.
And it probably is.
Or you’re wondering what I have to hide.
Well, that’s none of your business … which is the whole point.
Everyone has some secrets.
If you think you don’t, please feel free to email me your Gmail, Facebook, Twitter, and Bank passwords; along with all of your photos.
Yes, all of them.
I’ll be happy to publish it all for you, right here.
Alternatively, you could read this:
[“Why ‘I Have Nothing to Hide’ Is the Wrong Way to Think About Surveillance”](http://www.wired.com/opinion/2013/06/why-i-have-nothing-to-hide-is-the-wrong-way-to-think-about-surveillance/)

I’d also like to think I’m not doing anything illegal.
But I probably am; just without knowledge of it.
You see, [the average American commits three felonies a day](http://www.amazon.com/gp/product/B00505UZ4G?ie=UTF8&camp=213733&creative=393177&creativeASIN=B00505UZ4G&linkCode=shr&tag=crthomasorg-20&qid=1375644799&sr=8-1).
Yes, THREE.
Yes, YOU.
So maybe I am being paranoid.
Or maybe we’re living in a police state, and you haven’t noticed yet, because they haven’t targeted you yet.
Or they have, but you can’t know, because it’s “vital to national security” that the government doesn’t tell you they’re watching everything you do online.
