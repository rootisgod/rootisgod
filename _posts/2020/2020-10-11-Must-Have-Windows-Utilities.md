---
layout: post
title:  "My Must Have Software"
date:   2020-10-11 13:00:00 +0100
categories: software utilities
---

Here is a list of my must have software items. Most of these are paid, but I feel they are all well worth the cash. In going through this I have noticed a few traits I seem to gravitate towards;

**Multiplatform**

I use a Mac at home and use Windows at work. Linux is a hobby OS which I run to keep up to date on other technologies. So, having one tool to learn, because learning new software is hard, is a massive bonus for me.

**One off fee**

I abhor a monthly fee. It just makes me feel anxious that when I don't load it for a few days I feel like I then need to increase my usage to justify the monthly fee, which messes with my head. I don't think I use any tool with a monthly fee now outside of something like Tidal for music. I did have gitkraken, Adobe Photography Plan and intellij at one point but eventually just grew tired of the charges. I do think that the £10 a month for the Adobe Photography Plan is actually really great value, but it is still too much like jumping on a tiger I can't get off. I do remember when Photoshop was hundreds of pounds and it is great anyone can afford it now, but for causal use it seems like you can never have that satisfaction of owning it outright and you have to find an alternative (Affinity Photo for example). Jetbrains have a slightly different tack, you get a 'licence' but they lock you at the version available when you purchased it, so you lose the updates released over that year. But, it's better than nothing, and I can see why they made the choice. Some items below are a single fee with a year of maintenance updates and i'm fine with that. I'd rather do that than be left empty.

**Better than open source tools**

I would use open source if I could in most cases, but usually, for more 'complete' pieces of software, paying for something established is usually worth it. Unless a massive company is behind it, such as...

## Visual Studio Code - https://code.visualstudio.com/ - $FREE

The absolute king of IDEs at the moment. Free, multi-platform and an all-in-one coding platform. Just learn this now and enjoy. It's not even totally required to use it as a programming editor, the git integration and markdown preview means I use it to write this blog. Create post, preview, commit, push, done! And, there are endless plugins, like a spellchecker, bracket colorizer, remote docker container connections (with the code you are working on available on the container, making something like ansible playbook writing from a windows machine an absolute doddle). It's definitely an immediate install for any machine I have.

## Beyond Compare - http://scootersoftware.com/ - $60

Multiplatform and has a ton of uses. I use this mainly to mirror files and be absolutely sure that what I think happened, has happened. The GUI gives a very simple colour scheme to show when source and destination locations are out of sync. You can adjust the filter rules to ignore timestamps (sometimes files are copied in an OS and while identical, have a different timestamp) and do binary comparisons on each side. It can also do text diff, image diff and a few other things. One of the most nifty is if you give it a zip file on one side and a folder on the other, it can compare those, so you can be confident if something you zipped is identical to an existing folder, great for archiving. I'd be a little lost without this. Robocopy and diffmerge could do what it does, but this just works and when working with file copying i'd rather not make a 'oops, typo' mistake at any time, so worth it just for that alone in my mind.

## Snagit - https://www.techsmith.com/store/snagit - £45

Yeah, you can get greenshot for free, and use the windows snipping tool, but if you do any kind of documentation at all then this makes it 10 times easier. It keeps a 'library' of past screenshots and allows easy adding of arrows and annotations, automatically add a black border on capture etc... It will even grab text from an image which can be pretty useful when some applications will not allow a selection of text. And, for simple video captures for a quick walkthrough of something, it's super effective. Again, it's nothing mind-blowing, but it just does it so well. I'm kind of surprised nothing else like it exists for free. I did almost just use greenshot, but even a simple thing like adding a 1px black border to each capture wasn't possible. And that is a dedicated screen capture app, surely that would be a fairly sensible thing to add? Anyway, i'm not going to complain about something free, but if you ever do any type of documentation then get this as it will absolutely save you time in spades.

## CopyQ - https://hluk.github.io/CopyQ/ - $FREE

Tired of having to go back to something you had already put on the clipboard and retrieving it, like a key from a keyvault in azure and you already left the page, and you can't be bothered navigating back to get it again? Get this. Keeps the last x amount of copy/pastes for you. And is even searchable, so if you copy a snippet of code and want to go back to what it had, just search for a variable name or something like it and it will appear. Very handy when you need it. Maybe not infosecs dream come true, but still good!

## Mobaxterm - https://mobaxterm.mobatek.net/ - $69

Use linux but are working on windows? Get this. It's an all-in-one gui for SSHing, X11 forwarding, VNCing, RDPing and SSH tunelling from a windows machine. I wish I had found it earlier. It is a little expensive (though the free edition allows up to 12 connections), but it just makes doing things seamless when you want a one stop shop to connect to almost anything going. It also has some very nice features like automatically showing the files on a Linux VM (like WinSCP) when you connect, and showing RAM/CPU usage in a taskbar at the bottom. It doesn't update massively all that often, so buy once, wait a few years and upgrade again if you see a jump in features you find useful.

## Remote Desktop Manager Free - https://remotedesktopmanager.com/home/download - $FREE

I use this at work and it has hundreds of sessions in it. I found this before Mobaxterm, so perhaps I don't need this as much, but it has been very solid and has always been pretty decent to use. Seems more corporate and so perhaps it just seems a bit more solid. I don't use it's features to the limit, but if you want the enterprisey 'on steroids' mobaxterm this might be it.

## Sublime Text - https://www.sublimetext.com/ - $80

I've used notepad++ for a long time. But, sublime text combines the benefits of VS Code style setup with a super fast start time. I can still get by with notepad++ but i'm trying to use sublime text more as not having Notepad++ on mac or Linux is starting to get annoying, so I would rather just use one tool. In theory you can just use VSCode as a text editor but when your install starts to have a lot of plugins it gets slow to load, and when you just want to see a file it's nice to have it instantly. Again, not an essential tool really, but just having a consistent tool to use is great.

## Sublime Merge - https://www.sublimemerge.com/ - $99

I battled with a number of Git IDEs for a while, and again (lol) I got sick of 'xyz' only being on windows but not mac, or it's a subscription price (GitKraken!), or they are just pretty nasty to use. So, I just decided that Sublime Merge would likely be the best overall choice and went from there. It is a little less visually helpful or nice to look at compared to something like GitKraken, but I don't mind that. And, if you like to see what is happening under the hood, Sublime Merge will show you the commands it is using when you do various operations on the git repo, so it can help show you what's going on. I had no idea a squash commit was so crazy to type! A solid choice if you want to pay once and run on any OS.

## VMWare Workstation and Fusion - https://my.vmware.com/web/vmware/evalcenter?p=fusion-player-personal - $FREE

These are both free for personal use now! Worth it just for that. Generally a better option than Virtualbox and allows nested guests so you can do crazy things like run a Windows VM which runs a vagrant container which launches virtualbox. Nice! Fusion on Mac lets you load a Bootcamp partition as a VM inside Mac OSX which is ridiculously handy. 

https://blogs.vmware.com/teamfusion/2020/08/announcing-fusion-12-and-workstation-16.html

## Unraid - https://unraid.net/product - From $59 (6 Disks)

A bit of a different thing here. This is essentially a NAS system at heart, but it is much more than that. It has a Linux base which you can use to mount hard disks and share on a network. But, it also allows;
 - VM Host Server - Run VMs of any OS you like
 - Docker Container Server - Run whatever you like without the heaviness of a VM
 - Wireguard Server - VPN into your network
 - PCIE Passthrough to VM Ability - Run a game server or a transcoding plex media server with a GPU

So, if you want a do-it-all machine you can stick behind the TV or in a cupboard, this is it! I currently have an AMD 2600 machine, with 64GB of RAM and 6 hard disks of many TB's. It can do almost anything. I seriously urge anyone who needs something like this to give it a shot. I ran a home ESXi server and a Synology NAS for a few years and this beats them both hands down for a simple home setup. Even if you don't need file hosting i'd say it's worth buying just as a hypervisor and docker container host.

Check out some of these videos for inspiration: https://www.youtube.com/c/SpaceinvaderOne/videos
