---
categories: proxmox virtualization hetzner server cheap
date: "2022-12-12T08:00:00Z"
title: Creating a Cheap but Powerful Proxmox Server with Hetzner
draft: true
---

I'm always looking to try and get some cheap hosting. My local internet connection is pretty bad, and couple that with a Sky Glass TV, which is essential TV over Internet, and my ability to download large ISOs or pull Docker images without killing the internet is limited. 

I would host in somthing like Azure, but the costs are quite frankly, insane. A 2 CPU and 8GB RAM 'shared' instance costs about £60 a month. £60!!! And that doesn't cover storage, IO, or bandwidth. Cheaper providers like Linode or Digitalocean are much more competetitive but they too are pretty steeply priced.

But, one provider seems to have very keen prices. In fact, it is so cheap that you can buy the whole server for less than almost all the Azure VM offerings. The only catch is that you are buying an older generation server, but in reality, its not that bad. I can get a i7-8700 CPU, 128GB RAM (yes 128GB!) and 2 x 1TB SSD disks. For... 50 euros a month. Bargain.You can get a similar machine with half the ram and storage for 40 euros a month, but double RAM for 10 extra is too good to ignore.

This is practically begging for Proxmox to be installed on it. But, you cant get your own ISOs into their system. Instead, we can go from Debian and install proxmox from there. So, i'll document that process.



Create a new network bridge.

```jsx
nano /etc/network/interfaces

### ORIGINAL
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

iface lo inet6 loopback

auto enp0s31f6
iface enp0s31f6 inet static
        address 176.9.23.147/27
        gateway 176.9.23.129
        up route add -net 176.9.23.128 netmask 255.255.255.224 gw 176.9.23.129 dev enp0s31f6
# route 176.9.23.128/27 via 176.9.23.129

iface enp0s31f6 inet6 static
        address 2a01:4f8:150:21a1::2/64
        gateway fe80::1

### ADD THIS PART FOR A NEW BRIDGE
auto vmbr99
iface vmbr99 inet static
        address 10.10.10.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0

    post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up   iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o enp0s31f6 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o enp0s31f6 -j MASQUERADE
    post-up   iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1  
    post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1
```
Reboot server

Download Ubuntu Template (Storage -> Download Template)

Then create a new Container with Ubuntu 22.04, 8GB disk is plenty and 1 CPU and 128MB RAM. IP 10.10.10.2/24. Gateway is set to 10.10.10.1 (the vmbr99 ip)


Then create CT
```
apt update && apt upgrade -y
apt install isc-dhcp-server -y
```

Then

`nano /etc/dhcp/dhcpd.conf`

And then put in the info

```
option domain-name "rootisgod.com";
option domain-name-servers 8.8.8.8;
subnet 10.10.10.0 netmask 255.255.255.0 {
  range 10.10.10.10 10.10.10.199;
  option routers 176.9.23.147;
  option routers 10.10.10.1;
}
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
```

And restart service

`systemctl enable isc-dhcp-server`

`systemctl restart isc-dhcp-server`

## DNS FIREWALL 

I hetzner firewall, add 8.8.8.8/32 as all ports allow access or DNS lookups fail to 8.8.8.8, bizarre...

## Samba Setup

apt install samba

`sudo chmod 755 -R /var/shares/`

nano /etc/samba/smb.conf

[4TB]
comment = 4TB
create mask = 0777
directory mask = 0777
guest ok = Yes
path = /mnt/md0/Samba
read only = No

systemctl restart smbd.service

For samba share access on root from a VM, add the credential to the Windows Credentials folder or else you think you are having a firewall issue, but it is just rejecting you initially.
