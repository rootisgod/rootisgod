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

