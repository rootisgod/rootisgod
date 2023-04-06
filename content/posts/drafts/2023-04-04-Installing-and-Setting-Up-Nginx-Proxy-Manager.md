---
categories: proxmox virtualization hetzner server nginx proxy manager hosting
date: "2023-04-04T08:00:00Z"
title: Installing and Setting Up Nginx Proxy Manager
draft: true
---

REDUNDANT! - https://community.hetzner.com/tutorials/installing-nginx-proxy-manager


In the previous post we set up a powerful Hetzner server for not much money. But, the tricky part I kind of neglected to mention was that because you run from a single IP it can be challenging to host multiple services on it. We will solve that problem in this post using [Nginx Proxy Manager](https://nginxproxymanager.com). This will let us host multiple web sites from a single IP. This guide will also work if you are at home and want one machine with an internal IP to host multiple things, but it is super handy externally where spinning up a new machine means spending more money.

## Pre Requisites

You will need a DNS name that you control. We need to be able to create a DNS A record for each service we require, and it is that DNS name which informs Nginx Proxy Manager where to send the traffic. 

## Nginx Proxy Manager Installation via Podman

The first thing we have to do is install the program. To do this, we will use a Docker container. But, because it is actually easier to install than Docker nowadays(!), we will use Podman. We follow the basic official  instructions, but tweaked. If you know how to run Podman as non-root feel free, but i'm just using a root user and living dangerously.

https://nginxproxymanager.com/guide/#quick-setup


### Installing Docker

The base OS I have is Debian 11. To install Docker is a little trickier than hoped. I did try Podman as the initial install of that is simple, but then getting Docker-Compose and volumes to work made it too difficult, so I fell back to Docker. 

To install Docker we run the below. Feel free to follow the official Debian 11 instructions [here](https://docs.docker.com/engine/install/debian/) but these are the relevant commands. As an aside, I almost made this a podman example as installing podman is simple (apt install podman), but installing docker-compose was not...

```bash
apt-get update
apt-get remove docker docker-engine docker.io containerd runc
apt-get install ca-certificates curl gnupg
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Let's now pull the image to make sure we can get it via Docker.

```bash
docker pull jc21/nginx-proxy-manager:latest
```

Now, lets create a folder for the Nginx Proxy Manager docker-compose file and then

```bash
mkdir nginx-proxy-manager
cd    nginx-proxy-manager
nano docker-compose.yml
```

Enter this

```bash
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

And then run it (note that newer docker installs have compose as a sub-command of docker itself)

```bash
docker compose up -d
```

Then go to your IP/DNS name on port 81 and login with the below

```bash
admin@example.com
changeme
```

Change the username/email address and password. You should be greeted with this screen.

PIC OF SCREEN

### Add Proxmox As A Host

Now, you need to add a DNS A record to your DNS name in the admin panel of your provider. We will call it proxmox in this example. My provider is cloudflare so it looks like this

PIC OF A RECORD

Now, we can create a host in Nginx Proxy Manager and point it to our Proxmox port on 8006.





{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2023/Creating-a-Proxmox-Server-With-Hetzner/summary.png"><img src="/assets/images/2023/Creating-a-Proxmox-Server-With-Hetzner/summary.png"></a>
{{< /rawhtml >}}