---
categories: linux vscode ssh docker development
date: "2022-08-12T12:30:00Z"
title: Setting Up a Remote VSCode Docker Development Machine For Your Windows Desktop
draft: true
---

I currently work on a laptop that work provides me. While it is by no means a low spec machine, it still really struggles with VSCode. This is largely due to docker having to build a container and host everything. VSCode was pretty light but now it can really consume a lot of resources. So, in this post, i'll show you how to create a Linux machine that you can remotely connect to and then use your local VSCode GUI as the forntend, and let a backend VM do the hard work.

