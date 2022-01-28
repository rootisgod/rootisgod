---
categories: linux linode digitalocean cloudinit multipass vm ubuntu
date: "2022-01-22T15:50:00Z"
title: Using Multipass Like a Personal Cloud Service
draft: true
---

I'd heard of Multipass for a while, but didn't quite appreciate what it's reason for existence was. Now I get it, and hopefully I will explain it to you as well.

Mutipass is basically a command line driven VM creation service. Doesn't sound too fancy does it? Well, how about I told you it could replace Digitalocean or Linode as your source of quick test machines for 'that little personal project' you've been chipping away at for weeks? We can use multipass to;
- Create an Ubuntu Server VM (any edition you want)
- Set the CPU, RAM and Disk Space
- Connect it to your local network so it can get a 'real' IP, and not some barely useful NAT thing
- Run a Cloud Init script on boot
- Test everything works
- Delete when done

Now, the part of this that excites me is that seems awfully similar to what you get from Linode or DigitalOcean. Now granted, if you spin up a few machines for a few hours then those services are basically perfect, but when you have a machine hanging around a few days you start to get itchy. It's frustrating!

So, lets go over what we need to do to replicate this setup locally. 

SCREECH

Let's go back a bit. I did intend to write this for a Linux Server, ideally Ubuntu 20.04 and run it as a headless UBER system. It would be fast and efficient. Things didn't work out that way. The one thing that stopped it was the inability to get a LAN DHCP address on the multipass VM. It seems almost impossible doing this from Linux. Without that feature, accessing a VM's services (say a docker container port) is actually impossible. Deal breaker. I want to SSH to the UBER machine, spin up a box, and then be able to access it's 'things' from my main desktop. So, Linux is out...

The following guide now uses Windows 10 and Hyper-V as a guid (I know, I know) but it still meets the requirements. And, if you happen to be running Windows 10 as your desktop OS anyway perhaps you don't need the networky bit. Nonetheless, this is how to make some quick VMs and then access them for testing.


Install Hyper-V
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

Install Multipass
```
```

Install Openssh
https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse

```pwsh
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
```

Setup Multipass

```
multipass networks

multipass launch --name=test --network=Ethernet0

multipass launch --name=test --cpus=2 --mem=4G --disk=16G --network=Ethernet0 
```
----------------------------------------------


You will firstly need an Ubuntu Server 20.04 VM (with or without desktop, but I like to keep it light). Ideally you overspec this system as it will host our other machines. I'll use a 4CPU, 16GB RAM and 256GB Disk VM running on the always excellent Unraid.

So, create the VM and get to the terminal.

Run the following (i'm do this as root, cos, y'know, rootisgod)


## Multipass Installation

As easy as...

bash
``` 
snap install multipass
```
## Our First VM

Let's kick the tyres. Lets make a small VM to see what happens (if we dont specify any params we get a random name and 1CPU, 1GB RAM and 5GB disk).

```bash
multipass launch --name vm1 --cpus 2 --mem 4G --disk 16G
```

Then, we can interrogate the system we created, and even connect to it.

```
multipass shell vm1
```

This is a full blown VM. Go crazy and enjoy!


But, we have a problem. The IP is a NAT'd one.

```bash
multipass list
```

So, because I am running on a headless VM without a GUI, I cant really do anything useful, the network is out of reach of anything else I own. Let's fix that.

## Making It Better

What we want to change is our network driver. To do that, run;

```bash
multipass networks
```

Hmm, it says what!?!

```
networks failed: The networks feature is not implemented on this backend.
```

Crap, so, apprrently we are running on QEMU

```bash
multipass get local.driver
```

But, we need LXD instead. Lets delete the first machine as we will change hypervisors in a minute

```bash
multipass delete vm1
```

Now we need to install and change to LXD. So run
```
apt install lxd -y
multipass set local.driver=lxd
```

Then, let's see what networks we have. Aha!

```bash
multipass networks
Name    Type      Description
enp1s0  ethernet  Ethernet device
mpbr0   bridge    Network bridge for Multipass
```

multipass launch --name=vm1 --network=en1ps0

https://gitanswer.com/multipass-launch-network-eth-fails-on-opaque-d-bus-networkmanager-error-cplusplus-1071240751
launch failed: Could not create bridge. Could not reach remote D-Bus object: The name org.freedesktop.NetworkManager was not provided by any .service files

So, we actually need to also install Network Manager
https://gitanswer.com/multipass-launch-network-eth-fails-on-opaque-d-bus-networkmanager-error-cplusplus-1071240751

```bash
apt install network-manager -y
```

 multipass launch --network enp1s0 --network name=bridge0,mode=manual


CHEATSHEET
----------

apt install lxd network-manager -y
snap install multipass
multipass set local.driver=lxd
multipass launch --network ens33


LIBVIRT
https://multipass.run/docs/using-libvirt
apt install libvirt-daemon-system
snap connect multipass:libvirt



multipass launch -n bar --cloud-init cloud-config.yaml


------------------
 multipass list
    5  multipass info foo
    6  multipass exec
    7  multipass exec --name foo ls
   28  multipass launch --help
   29  multipass launch --name foo --network bridged
   30  multipass set local.bridged-network=bridged
   31  sudo multipass set local.bridged-network=bridged
   32  multipass launch --name foo --network bridged
   33  multipass launch --name foo
   34  multipass delete foo
   35  multipass launch --name foo --network bridged
   36  multipass get local.driver
   37  apt install lxd
   38  sudo apt install lxd
   39  sudo multipass set local.driver=lxd
   40  multipass get local.driver
   41  multipass launch --name foo --network bridged
   42  multipass networks
   43  sudo multipass set local.bridged-network=enp1s0
   44  multipass networks
   45  multipass launch --name foo --network enp1s0
   46  multipass list
   47  sudo multipass launch --name foo --network enp1s0