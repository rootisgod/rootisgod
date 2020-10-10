---
layout: post
title:  "Using RDP With Linux Mint 20 Cinnamon"
date:   2020-10-10 11:30:00 +0100
categories: linux rdp
---

I like using linux, but frankly, the remote connection options are just horrible. Windows really rules with regards to remotely connecting to a graphical desktop, it's just builtin and there. On linux it generally boils down to;

 - Teamviewer: No thanks, I got hacked before with it!
 - VNC: Slow and a pain to setup session numbers etc etc... Seems to work on some clients, not others... Ugh.
 - X11 Forwarding: I actually havent tried in earnest, but im sure it's fiddly

So, the ideal solution for me is just to have a Linux distro support RDP out of the box. I don't really know of any that do this (email me if you do) so i'm going to document how to do it in Linux Mint 20 Cinnamon edition. This is my general goto distro, and it is super easy.

```bash
sudo apt install xrdp xorgxrdp -y
echo env -u SESSION_MANAGER -u DBUS_SESSION_BUS_ADDRESS cinnamon-session>~/.xsession
```

Then get your ip address using ```ifconfig``` and then use a remote desktop client to RDP to that IP, enter your username and password, and voila!

![](/assets/images/2020/Linux-Mint-RDP/10.png)

![](/assets/images/2020/Linux-Mint-RDP/20.png)

![](/assets/images/2020/Linux-Mint-RDP/30.png)
