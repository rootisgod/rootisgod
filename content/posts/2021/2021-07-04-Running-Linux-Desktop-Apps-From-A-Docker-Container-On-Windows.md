---
categories: linux docker x11 windows mobaxterm
date: "2021-07-04T22:00:00Z"
title: Running Linux Desktop Apps From a Docker Container on Windows with MobaXterm
---

Ever wonder 'If I ran firefox in a linux docker container from my Windows 10 machine, could I access it like a desktop app somehow?'. Well, yes, you can. And probably any linux desktop app for that matter. But we will use Firefox for simplicity.

Credit for this idea comes from the absolutely fantastic [Docker in Practice 2nd Edition](https://www.manning.com/books/docker-in-practice-second-edition) book from Manning Publications, I can't recommend it enough (and incidentally I seem to have built up a chunky Manning library in the past year. All their books are great and tackle a single subject in depth without squirelling out of mentioning the real-world issues you may face! Manning, if reading, please send me store credit for promotional advertising!). It is described in Technique 29 if you're interested in seeing how to do this in Linux, as the book discusses.

I thought I would write down the most basic of steps on how to do this from a Windows machine. Now nothing in the Linux world is outside of your reach. I think Microsoft will be adding this trick to the Official WSL implementation in the future and so it's lifespan may be limited, but for now, it's still really neat.

# Required Software

Installation is left to you, and a working knowledge of Docker on Windows would be helpful as it has to be working to get going on this.

-   [Mobaxterm](https://mobaxterm.mobatek.net) (free!)
-   [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) (on Windows 10)

# Docker Image Creation and Build

Create a file like this (change firefox to anything else you are interested in running) and save it as dockerfile. It's about as simple as could be. Using the Ubuntu 20.04 image, we update it, install firefox and then make that the process the container runs when is starts.

```dockerfile
FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install firefox -y

CMD /usr/bin/firefox
```

Then, we can build it with this command to get it on our system as the docker image 'firefox'.

```bash
docker build -t firefox .
```

# Mobaxterm Setup

MobaXterm is a free program which can simplify connecting to linux machines (and many other protocols like RDP, FTP, SSH etc etc). It's really great and worth checking out in general. But, the unique selling point (hence the xterm) is the built in X11 server which we can use to get a Linux 'GUI' connection from a Windows machine.

## X11 Server Settings

We will use the MobaXterm built in X11 server to view the running application in docker. There are a few settings to change first though.

To avoid being notified that an application is connecting to our X11 server, we can turn off warnings and allow full access to anything that requests it. Go to **Settings -> Configuration** and the **X11** tab. Then for **X11 remote access** change it to **Full**. Then let it restart the X11 server.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/001.png"><img src="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/001.png"></a>
{{< /rawhtml >}}

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/005.png"><img src="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/005.png"></a>
{{< /rawhtml >}}

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/010.png"><img src="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/010.png"></a>
{{< /rawhtml >}}

## X11 Server Connection

In MobaXterm, we need to find the address/port that the X11 server address is using. Hover over the 'X' icon in the top-right and note what it says.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/015.png"><img src="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/015.png"></a>
{{< /rawhtml >}}

Then, using that address (your one mmay be different to mine), start the container with that information. The command below will also delete the container when you close the running app. Also, any information the container generates will be lost on close! You can map a volume at runtime to capture this, but as every application is different this left as something to figure out yourself!

```
docker run -it --rm -e DISPLAY=10.9.0.15:0.0 firefox
```

Tada!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/020.png"><img src="/assets/images/2021/Running-Linux-Desktop-Apps-From-A-Docker-Container-On-Windows/020.png"></a>
{{< /rawhtml >}}
