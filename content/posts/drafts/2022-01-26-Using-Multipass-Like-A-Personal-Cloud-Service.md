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
ens33   ethernet  Ethernet device
lxcbr0  bridge    Network bridge
mpbr0   bridge    Network bridge for Multipass
```

Then launch a test VM and use our 'ethernet' address which is the one connected to our LAN. It will offer to create a bridge for us

```bash
multipass launch --network=ens33
Multipass needs to create a bridge to connect to ens33.
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
launch failed: Could not create bridge. Failed DBus call. (Service: org.freedesktop.NetworkManager; Object: /org/freedesktop/NetworkManager; Interface: org.freedesktop.NetworkManager; Method: ActivateConnection): No suitable device found for this connection (device br-ens33 not available because profile is not compatible with software device (mismatching interface name)).
```

The trick is that we need to modify the netplan. So, I have this by default in `/etc/netplan/00-installer-config.yaml`

```yaml
# This is the network config written by 'subiquity'
network:
    ethernets:
        ens33:
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
multipass launch --network=ens33
Multipass needs to create a bridge to connect to ens33.
This will temporarily disrupt connectivity on that interface.

Do you want to continue (yes/no)? yes
```

So, teh cheatsheet for all this is;

```bash
apt install lxd network-manager -y
snap install multipass
multipass set local.driver=lxd
echo $'network:\n  version: 2\n  renderer: NetworkManager' > /etc/netplan/00-installer-config.yaml
reboot
```

Then launch your VM from the ethernet adapter you have. Done!

```bash
multipass networks
multipass launch --network=ens33
```

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
Download: https://multipass.run/download/windows
Install and choose Hyper-V, add to PATH. Reboot

Run the following

```
multipass networks
```

Note the names

```
Name            Type      Description
Default Switch  switch    Virtual Switch with internal networking
Ethernet        ethernet  Red Hat VirtIO Ethernet Adapter
```

The 'Ethernet' one should be the 'real' one in our Hyper-V setup, so we want to bridge dircetly onto that. But, lets launch a VM first to show what we get by default.

```
multipass launch
```

We will get a randomly named machine and the latest Ubuntu LTS edition.

```
multipass launch
Launched: glorious-crake

multipass list
Name                    State             IPv4             Image
glorious-crake          Running           172.17.81.160    Ubuntu 20.04 LTS
```

But, note the IPv4, it's a weirdo Multipass created subnet! This isn't routable from any machine other than the one running multipass. Ugh.

Lets delete it immediately!

```
multipass delete glorious-crake
multipass purge
```

Now, lets create one and specify the 'Ethernet' network.

```
multipass launch --network=Ethernet
```

It will ask us to create a bridged network (note, i lost RDP as well, just reconnect)

```
Multipass needs to create a switch to connect to Ethernet.
This will temporarily disrupt connectivity on that interface.

Do you want to continue (yes/no)? yes
```

Then, let's list the VMs

```
multipass list

Name                    State             IPv4             Image
innocent-earthworm      Running           172.17.93.170    Ubuntu 20.04 LTS
                                          192.168.1.92
```

OMG, we are own the main network. Excellent! Lets install nginx on it (seperate commands for teh machine by a --)

```
multipass exec innocent-earthworm -- sudo apt install nginx -y
```

Then, lets see... (from another machine)

```
http://192.168.1.92
```

Excellent. Job done. To launch a chunkier machine run something like this

```
multipass launch --name=test --cpus=2 --mem=4G --disk=16G --network=Ethernet
---

Happy multipassing!

=========================================================================================================================================

You will firstly need an Ubuntu Server 20.04 VM (with or without desktop, but I like to keep it light). Ideally you overspec this system as it will host our other machines. I'll use a 4CPU, 16GB RAM and 256GB Disk VM running on the always excellent Unraid.

So, create the VM and get to the terminal.

Run the following (i'm do this as root, cos, y'know, rootisgod)

## Multipass Installation

As easy as...

bash

```

snap install multipass

````

## Our First VM

Let's kick the tyres. Lets make a small VM to see what happens (if we dont specify any params we get a random name and 1CPU, 1GB RAM and 5GB disk).

```bash
multipass launch --name vm1 --cpus 2 --mem 4G --disk 16G
````

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

## CHEATSHEET

apt install lxd network-manager -y
snap install multipass
multipass set local.driver=lxd
multipass launch --network ens33

LIBVIRT
https://multipass.run/docs/using-libvirt
apt install libvirt-daemon-system
snap connect multipass:libvirt

multipass launch -n bar --cloud-init cloud-config.yaml

---

multipass list
5 multipass info foo
6 multipass exec
7 multipass exec --name foo ls
28 multipass launch --help
29 multipass launch --name foo --network bridged
30 multipass set local.bridged-network=bridged
31 sudo multipass set local.bridged-network=bridged
32 multipass launch --name foo --network bridged
33 multipass launch --name foo
34 multipass delete foo
35 multipass launch --name foo --network bridged
36 multipass get local.driver
37 apt install lxd
38 sudo apt install lxd
39 sudo multipass set local.driver=lxd
40 multipass get local.driver
41 multipass launch --name foo --network bridged
42 multipass networks
43 sudo multipass set local.bridged-network=enp1s0
44 multipass networks
45 multipass launch --name foo --network enp1s0
46 multipass list
47 sudo multipass launch --name foo --network enp1s0
