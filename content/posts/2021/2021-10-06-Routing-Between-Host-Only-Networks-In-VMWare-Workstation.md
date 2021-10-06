---
categories: linux windows vmware workstation vm pfsense firewall homelab
date: "2021-10-04T21:05:00Z"
title: Routing Between Host Only Networks in VMWare Workstation
draft: true
---

Have you ever had a need to create a couple of test machines, but treat them like they were on separate networks? For example, to create two Windows Domain Controllers and simulate a forest.

Probably not, but if you ever do, the obvious solution is to go to the cloud, and use the various VNET and firewall controls they provide to do this. The downside is that this gets expensive pretty quickly... Try creating a few VMs, power them off, and see how disk space is still pretty expensive. And, it doesn't really make testing any easier. If you make a mistake, reverting to a previous state still isn't that simple and creates more cost on disk usage, backup vaults etc.... It's a bit too inflexible compare to a VM snapshot....

So, enter VMWare Workstation, the best desktop hypervisor by a mile (just try a demo and you wont go back). What would be ideal is to create two VMs on our local machine and try to accomplish a split network setup. Simple, right? But, its trickier than I thought. While we do get some network tools, it's fairly basic. VMWare Workstation offers 3 network modes;

-   Bridged: Get an IP for your VM from the 'real' network you Network Card is connected to. You can have one of these on the system
-   NAT: Get an IP from an inbuilt VMWare network which is seperate to your home network. All VMs on this network can see each other, your home network, and have Internet access. This is what you usually choose. You can only have one of these types of network at a time.
-   Host Only: A network where only hosts on that network can see each other. No-one else, not even internet access is allowed. They are effectively 'locked in'. You can create many of these.

So, it seems like we need to create two host only networks, add a VM to each one and then we should have kinda what we need as they are seperate. The problem is they can't ever really see each other. To get around this we have to introduce a router as a go-between. Even VMWare have an article that says to do it this way (https://www.vmware.com/support/ws5/doc/ws_net_advanced_2hostonly_routing.html). This tutorial will cover doing that step-by-step as it seems to be a bit of an exercise left to the reader wherever you stumble on this pattern.

## Without pfSense

```
┌──────VMWARE─VNETS──────┐       .─────────.
│┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐◀ ─ X ▶( Internet )
│└1┘└2┘└3┘└4┘└5┘└6┘└7┘└8┘│       `─────────'
└─────────────▲──▲───────┘
     ┌────────┘  └──────┐
Host Only          Host Only
     │                  │
 ┌───────┐          ┌───────┐
 │  VM   │◀─ ─X─ ─ ▶│  VM   │
 │(VNET5)│ ISOLATED │(VNET6)│
 └───────┘          └───────┘
```

## With pfSense

```
   ┌──────VMWARE─VNETS──────┐      .─────────.
   │┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐◀────▶( Internet )
   │└1┘└2┘└3┘└4┘└5┘└6┘└7┘└8┘◀═╗    `─────────'
   └─────────────▲──▲───────┘ ║
    ┌────────────┤  ├────┐    ║
    │   Host Only│  │Host Only║
    │            │  │    │    ║
┌───────┐ ┌──────┴──┤┌───────┐║
│  VM   │ │   VM    ││  VM   │║
│(VNET5)│ │ pfSense ││(VNET6)│║
└───────┘ │(VNET5+6)│└───────┘║
          │  VNET1  │         ║
          └─────────┘         ║
               ║              ║
               ║ Internet Link║
               ╚═════VNET8════╝
                     (NAT)
```

## What You Need

-   VMWare Workstation (latest is fine, but any reasonably recent version will do)
-   pfSense ISO
-   2 x Windows VMs (I leave you to make these!)

## General Setup

Create Networks

Create two VMs running Windows (though Linux will work too)

Setup Networks

Create pfSense VM

Configure pfSense VM

Test

Snapshot
