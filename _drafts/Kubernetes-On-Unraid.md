---
layout: post
title:  "Kubernetes on Unraid"
date:   2021-03-13 10:00:00 +0100
categories: sql backup
---

{% include all-header-includes.html %}

NOTES
https://www.reddit.com/r/kubernetes/comments/be0415/k3s_minikube_or_microk8s/

KIND
https://github.com/kubernetes-sigs/kind/issues/1288


Who wants to have a quick Kubernetes cluster on Unraid? Well, it can be installed using [K3S](https://k3s.io).

## Automatic K3S Installation

According to the website, it's as easy as going to the terminal and running;

PIC

```bash
curl -sfL https://get.k3s.io | sh -
```

Succ.. Ah crap.

```bash
[ERROR]  Can not find systemd or openrc to use as a process supervisor for k3s
```

## Manual K3S Installation

So, we have to do this manually... 

### The Unraid USB Install Method 

A short interlude first though. Because Unraid runs on a flash memory USB stick, we really don't want to be running anything on it that might write data often as it will probably trash our write cycles and kill it with wear. So we have to be wary of this and save the executable and launch k3s on a 'real' disk. Preferably a cache disk if you have one as it will be faster than a mechanical HDD.

### K3S Download

But first, let's grab the binary from the github page at https://github.com/k3s-io/k3s/releases/

Then grab the latest version link. We will move to the ```/mnt/user/appdata``` folder (which is a cache drive on my system), create a k3s folder, and download k3s to it, then make it executable.

```bash
mkdir /mnt/cache/appdata/k3s
cd /mnt/cache/appdata/k3s
wget https://github.com/k3s-io/k3s/releases/download/v1.20.4%2Bk3s1/k3s
chmod +x k3s
```

Proof this is a cache disk on my machine and not the USB drive (larger than 32GB)

```bash
root@Unraid:/mnt/user/appdata/k3s# df -h /mnt/cache/appdata/
Filesystem      Size  Used Avail Use% Mounted on
shfs            954G  342G  611G  36% /mnt/user
```

Now, if we run the ```k3s``` command we can see the options to start and stop it.

```bash
root@Unraid:/mnt/user/appdata/k3s# k3s
NAME:
   k3s - Kubernetes, but small and simple

USAGE:
   k3s [global options] command [command options] [arguments...]

VERSION:
   v1.20.4+k3s1 (838a906a)

COMMANDS:
   server         Run management server
   agent          Run node agent
   kubectl        Run kubectl
   crictl         Run crictl
   ctr            Run ctr
   check-config   Run config check
   etcd-snapshot  Trigger an immediate etcd snapshot
   help, h        Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --debug                     (logging) Turn on debug logs [$K3S_DEBUG]
   --data-dir value, -d value  (data) Folder to hold state default /var/lib/rancher/k3s or ${HOME}/.rancher/k3s if not root
   --help, -h                  show help
   --version, -v               print the version
```

From this, we can see that k3s wants to use ```/var/lib/rancher/k3s``` as a data directory by default when run.

But, as mentioned previously, in Unraid you'll see that this folder is on our USB install stick. Not what we want to be using.

```bash
root@Unraid:/mnt/cache/appdata/k3s# df -h /var/lib
Filesystem      Size  Used Avail Use% Mounted on
rootfs           32G  1.8G   30G   6% /
```

So, we want to specify where our data is to be kept when we run k3s.

```bash
root@Unraid:/mnt/user/appdata/k3s# k3s server --data-dir  /mnt/cache/appdata/k3s/
```
So, that creates a lot of text! 


{% include all-footer-includes.html %}