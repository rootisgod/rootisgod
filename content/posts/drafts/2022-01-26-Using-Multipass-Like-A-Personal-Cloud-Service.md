---
categories: linux linode digitalocean cloudinit multipass vm ubuntu
date: "2022-01-22T15:50:00Z"
title: Using Multipass Like a Personal Cloud Service
draft: true
---

I'd heard of Multipass for a while, but didn't quite appreciate what the need for it was. It's basically a command line driven VM/LXD creation service, exclusively for Canonical based products (Ubuntu, microk8s etc...). You can make a machine and then SSH/exec commands to it in a couple minutes. That's really neat.

## A Quick Example

As a sneak peek, to create a multipass machine, we can run something like this

```bash
multipass launch --name vm1 --cpus 2 --mem 4G --disk 16G
```

## Why Do This?

Now, the part of Multipass this that excites me most is that seems awfully similar to what you get from Linode or DigitalOcean. You can get a machine in around a minute for very little effort. Now granted, if you spin up a few machines for a few hours then those services are basically perfect, but when you have a machine hanging around a few days you start to get itchy. It's frustrating! And, DigitalOcean has a per-hour minimum pricing model, so if you spin up a chunky machine, mess it up and delete it after a few minutes, you get charged the full hours worth. It's pennies, but it all adds up. Also, when you launch a VM in these environments, it is exposed to the internet immediately. By keeping everything local you can confidently go crazy without worrying about getting shouted at (quite rightly) by Infosec...

So, what's the catch? There is one limitation I hit, networking. By default, the machine(s) you create are given a weird NAT'd type of address by Multipass. Ideally I want to run a chunkyish headless Linux VM which will run Multipass and then access the systems from anywhere. But, the systems I launch on that won't be accessible externally without setting up a route rule on my 'desktop' machine like this (assuming the Multipass host server has IP 192.168.1.10);

```bash
sudo ip route add 10.86.127.0/24 via 192.168.1.10
```

This is a decent workaround, but I need to do it on any machine I have. And forgot about access from a phone/tablet. We do have the ability to change networking modes on Multipass to allow any system we create to bridge to our LAN and get a DHCP address, but from an Ubuntu Server 20.04 install I seemed to get issues with the network bridge creation. So, this should show the procedure that works (and is the main point of this post!).

## Setting Up Multipass

Here is how to set this up.

### Install an Ubuntu VM

Create a large VM (4CPUs, 16GB RAM and 128GB Disk would be a good start!) and install Ubuntu 20.04 server.

### Installing Multipass and Setting Up Networking

I had a lot more text about this, but really, what you need to know is that by default the VM engine on Linux is QEMU. This will not allow us to override the network settings in Multipass. So, we need to use LXD (a more robust LXC from what I can see) and then change the network settings. LXD needs to use Network Manager as the network stack, and this is not the default with Ubuntu Server. So, we install that, change multipass to LXD and then allow Network Manager full control over the network. Why we have to do all that, no idea! But, this is what finally got things going for me.

#### Cheatsheet

So, the cheatsheet for all this is below.

```bash
apt install lxd network-manager -y
snap install multipass
multipass set local.driver=lxd
echo $'network:\n  version: 2\n  renderer: NetworkManager' > /etc/netplan/00-installer-config.yaml
reboot
```

Then launch your VM from the ethernet adapter you have (note, a bridge adapter will be created, but use the 'real' name). Done!

```bash
multipass networks

  Name       Type      Description
  enp1s0     ethernet  Ethernet device
  mpbr0      bridge    Network bridge for Multipass

multipass launch --network=enp1s0

  Multipass needs to create a bridge to connect to enp1s0.
  Do you want to continue (yes/no)? yes
  Creating vm....

multipass list

  Name                    State             IPv4             Image
  sinewy-kookaburra       Running           10.86.127.216    Ubuntu 20.04 LTS
                                            192.168.1.35
```

Tada!

(or like mentioned earler, use a route from your existing machine)

```bash
sudo ip route add 10.86.127.0/24 via 192.168.1.10 (IP of your multipass server)
```

## MOAR!

### The Docker In The Room

Yeah, docker can probably do this, but it's not as easy to remember all the fancy commands. But, I can SSH to a machine all day long...

### Multipass Docs

There is way more. Multipass can also launch a cloud-init script on boot, so it is even more of a Linode/DigitalOcean replacement.

https://multipass.run/docs/working-with-instances
