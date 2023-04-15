---
categories: linux linode digitalocean cloudinit multipass vm ubuntu
date: "2022-01-31T20:00:00Z"
title: Using Multipass Like a Personal Cloud Service
draft: false
---

I'd heard of Multipass for a while, but didn't quite appreciate what the need for it was. It's basically a command line driven VM/LXD creation service, exclusively for Canonical based products (Ubuntu, microk8s etc...). You can make a machine and then SSH/exec commands to it in a couple minutes. That's really neat. In a containerised world, it's refreshingly old school and functional.

## A Quick Example

As a sneak peek, to create a multipass machine, we can run something like this. We got a new machine!

```bash
multipass launch --name vm1 --cpus 2 --mem 4G --disk 16G

multipass list

  Name                    State             IPv4             Image
  demented-native         Running           10.86.127.172    Ubuntu 20.04 LTS
```

## Why Do This In Multipass?

Now, the part of Multipass that excites me most is that it seems awfully similar to what you get from Linode or DigitalOcean. You can get a machine in around a minute for very little effort. Now granted, if you spin up a few machines for a few hours then those services are basically perfect, but when you have a machine hanging around a few days you start to get itchy. It's frustrating! And, DigitalOcean has a per-hour minimum pricing model, so if you spin up a chunky machine, mess it up and delete it after a few minutes, you get charged the full hours worth. It's pennies, but it all adds up. Also, when you launch a VM in these environments, it is exposed to the internet immediately. By keeping everything local you can confidently go crazy without worrying about getting shouted at (quite rightly) by Infosec...

So, what's the catch? There is one limitation I hit, networking. By default, the machine(s) you create are given a weird NAT'd type of address by Multipass. Ideally I want to run a chunkyish headless Linux VM which will run Multipass and then access those systems from anywhere on my LAN. But, the systems I launch on that won't be accessible externally without setting up a route rule on my 'desktop' machine like this (assuming the Multipass NAT addresses are subnet 10.68.127.0 and the Multipass host server has IP 192.168.1.10);

```bash
sudo ip route add 10.86.127.0/24 via 192.168.1.10
```

This is a decent workaround, but I need to do it from every machine I want that access. And forget about access from a phone/tablet. We do have the ability to change networking modes on Multipass to allow any system we create to bridge to our LAN and get a DHCP address, but from an Ubuntu Server 20.04 install I seemed to get issues with the network bridge creation. So, this should show the procedure that works (and is the main point of this post!).

## Setting Up Multipass

Here is how to set this up.

### Install an Ubuntu VM

Using a physical machine or a large VM (4CPUs, 16GB RAM and 128GB Disk would be a good start!), install Ubuntu 20.04 server. Personally, i'm using Unraid as it is always on at my home and blessed with lots of RAM.

### Installing Multipass and Setting Up Networking

I had a lot more text about this, but really, what you need to know is that by default the VM engine used by Multipass on Linux is QEMU. But this will not allow us to override the network settings in Multipass. So, we need to change its settings to use LXD (a more robust LXC from what I can see) and then change the network settings. And, LXD needs to use Network Manager as the network stack, but this is not the default with Ubuntu Server. So, we install that as well, change multipass to LXD and then allow Network Manager full control over the network. Why we have to do all that, no idea! But, this is what finally got things going for me.

#### Cheatsheet

So, the cheatsheet for all this is below.

```bash
apt install lxd network-manager -y
snap install multipass
multipass set local.driver=lxd
echo $'network:\n  version: 2\n  renderer: NetworkManager' > /etc/netplan/00-installer-config.yaml
reboot
```

Then launch your VM from the ethernet adapter you have (note, a bridge adapter will be created, but use the 'real' name when launching systems), check we got a LAN IP, and you are good to go.

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

Tada! The new system has a LAN IP of 192.168.1.35. It's gone native!

(or like mentioned earler, use a route from your existing machine, but you'll get bored of remembering to do this very quickly...)

```bash
sudo ip route add 10.86.127.0/24 via 192.168.1.10 (IP of your multipass server)
```

## MOAR!

### Cloudinit

You can create 'templates' for machines using cloudinit. Want a machine to use for Kubernetes CKAD learning? Call this file ```ckad.yaml```

```yaml
users:  
  - default  
package_update: true  
package_upgrade: true  
packages:
  - nano
runcmd:
 - snap install docker
 - snap install microk8s
 - snap install kubectl
```
  
Create the VM like so

```bash
multipass launch --name ckad --cpus 2 --mem 8G --disk 64G --cloud-init ckad.yaml
```
When you login the machine will be pre-configured. See here for LOTS more options - https://cloudinit.readthedocs.io/en/latest/reference/examples.html

### The Docker In The Room

Yeah, docker can probably do this, but it's not as easy to remember all the fancy commands. But, I can SSH to a machine all day long...

### Multipass Docs

There is way more - https://multipass.run/docs/working-with-instances
