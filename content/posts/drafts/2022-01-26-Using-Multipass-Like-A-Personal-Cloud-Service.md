---
categories: linux linode digitalocean cloudinit multipass vm ubuntu
date: "2022-01-22T15:50:00Z"
title: Using Multipass Like a Personal Cloud Service
draft: true
---

I'd heard of Multipass for a while, but didn't quite appreciate what the need for it was. It's basically a command line driven VM creation service, exclusively for Canonical based products (Ubuntu, microk8s etc...). You can make a machine and then SSH/exec commands to it in a couple minutes. That's really neat, but we have Docker now, so why do we need this? Well, I think it;s still super useful as sometimes you really do need to do something on a 'real' VM, and frankly, sometimes setting up all the ports and volumes can just be a bit of a pain. You can spend longer getting a PostgresSQL container going than it would take to run something natively!

So, a basic workflow can look like this;

-   Create an Ubuntu Server VM (any edition you want)
-   Set the CPU, RAM and Disk Space
-   Connect it to your local network so it can get a 'real' IP, and not some barely useful NAT thing
-   Run a Cloud Init script on boot
-   Test everything works
-   Delete when done

Now, the part of this that excites me is that seems awfully similar to what you get from Linode or DigitalOcean. Now granted, if you spin up a few machines for a few hours then those services are basically perfect, but when you have a machine hanging around a few days you start to get itchy. It's frustrating! And, DigitalOcean has a per-hour minimum pricing model, so if you spin up a chunky machine, mess it upa dn delete it after a few mintues, you get charged the full hours worth. It's pennies, but it all adds up.

Multipass will work just fine if you look at the docs and run a command like the below.

```
multipass launch --name vm1 --cpus 2 --mem 4G --disk 16G
```

Done, great! But, there is one limitation I hit, networking. By default, the machine you create is given a weird NAT'd type of address. Ideally I want to run a chunkyish Linux VM which will run Multipass, SSH into it, launch a machine and then check the website etc I deployed from my remote workstation. I can't do that without setting up a route rule on my machine like this (assuming the Multipass host server has IP 192.168.1.7);

```
sudo ip route add 172.17.81.160/24 via 192.168.1.7
```

This is a decent workaround, but I would prefer the Multipass VMs I create have an IP address on my LAN, then I never have to add rules to any of my machines. We do have the ability to change networking modes on Multipass, but from an Ubuntu Server 20.04 install I seemed to get issues with the network bridge creation, so this should show the procedure that works.

### Install an Ubuntu VM

Create a large VM (4CPUs, 16GB RAM and 128GB Disk would be a good start!) and install Ubuntu 20.04 server.

### Install Multipass

As easy as

```bash
snap install multipass
```

After we install Multipass, we need a few changes. By default, Multipass uses QEMU and with that hypervisor we cannot amend networks. If we try to do so, we get this message

```bash
multipass networks
networks failed: The networks feature is not implemented on this backend.

multipass get local.driver
qemu
```

So, we need to change LXD. Let's install it.

```bash
apt install lxc -y
```

And then change multipass to use it (note it is 'lxd' though, not 'lxc'), and then see what networks we have

```bash
multipass set local.driver=lxd
multipass networks

Name    Type      Description
enp1s0   ethernet  Ethernet device
lxcbr0  bridge    Network bridge
mpbr0   bridge    Network bridge for Multipass
```

Then launch a test VM and use our 'ethernet' address which is the one connected to our LAN. It will offer to create a bridge for us

```bash
multipass launch --network=enp1s0
Multipass needs to create a bridge to connect to enp1s0.
This will temporarily disrupt connectivity on that interface.

Do you want to continue (yes/no)? yes

launch failed: Could not create bridge. Could not reach remote D-Bus object: The name org.freedesktop.NetworkManager was not provided by any .service files
```

Crap. Let's install Network Manager as it controls the networking in LXC.

```bash
apt install network-manager -y
```

Then re-run our command, a different problem now...

```bash
launch failed: Could not create bridge. Failed DBus call. (Service: org.freedesktop.NetworkManager; Object: /org/freedesktop/NetworkManager; Interface: org.freedesktop.NetworkManager; Method: ActivateConnection): No suitable device found for this connection (device br-enp1s0 not available because profile is not compatible with software device (mismatching interface name)).
```

The trick is that we need to modify the netplan. So, I have this by default in `/etc/netplan/00-installer-config.yaml`

```yaml
# This is the network config written by 'subiquity'
network:
    ethernets:
        enp1s0:
            dhcp4: true
    version: 2
```

We change it to this

```yaml
# This is the network config written by 'subiquity'
network:
    version: 2
    renderer: NetworkManager
```

And then run reboot for total effect! NOTE: My IP changed on this machine so network changes are made.

Reconnect, and try again!

```bash
multipass launch --network=enp1s0
  Multipass needs to create a bridge to connect to enp1s0.
  This will temporarily disrupt connectivity on that interface.

  Do you want to continue (yes/no)? yes
```

It should create a VM and if you run multipass list you will get the Local LAN IP you can use.

## Cheatsheet

So, the cheatsheet for all this is below;

```bash
apt install lxd network-manager -y
snap install multipass
multipass set local.driver=lxd
echo $'network:\n  version: 2\n  renderer: NetworkManager' > /etc/netplan/00-installer-config.yaml
reboot
```

Then launch your VM from the ethernet adapter you have (note, a bridge adapter will be created, but use the 'rea' name). Done!

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
