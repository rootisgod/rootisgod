---
layout: post
title:  "ESXi 7.0U1 Running on Unraid"
date:   2020-12-16 12:00:00 +0100
categories: Unraid ESXi Nested Virtualization
---

{% include all-header-includes.html %}

# How to setup an ESXi install on Unraid.

I tried to find a guide on how to do this (and not the reverse of running Unraid on ESXi which seem to be everywhere!) and there seems to be a little missing in each case. The tutorial below seems to be a golden path of sorts, and is the motherboard and bios type that worked for me. The same settings on a Q35 motherboard and OVMF BIOS failed to see SATA drives for example, so you really do seem to have to be specific here. 

So, i've brought everything I know toegether into one place. This isn't likely an optimal setup, but, if you want something that works for testing it might get you through. 

The main reason I am doing this is because I have an Unraid box which hosts various fileshares, and a NUC. The Unraid server has 64GB RAM, but the NUC isn't so lucky. I want to have vCenter available as it does a lot of things you really need like setup VM Templates so creating a new machine is easy. I know I could probably just use Proxmox etc etc etc, but I like ESXi and so that's what i'm going for. So, the mission is to not burden my little NUC with vCenter and its 12GB RAM requirement, instead offload to my Unraid server so the NUC can focus on other things.

## Unraid Bootup Parameters
First of all, We need to add ```kvm_amd.nested=1``` to bootup image params on our Unraid machine to enable nested virtualization (so we can run VMs inside our VMs). I run an AMD Unraid machine, so this is the setting for my machine. If running on an Intel system, use ```kvm_intel.nested=1``` instead and just swap what I say below.

So, go to the main page and click the Flash drive icon you have Unraid installed on

![](/assets/images/2020/ESXi-On-Unraid/Image1.png)

Amend the **Syslinux configuration:** section like so by adding ```kvm_amd.nested=1``` (or ```kvm_intel.nested=1``` if you have an Intel system) to the append section. Make one if you don't have it.

```bash
kernel /bzimage
append pcie_acs_override=downstream initrd=/bzroot kvm_amd.nested=1
```

![](/assets/images/2020/ESXi-On-Unraid/Image2.png)

Then reboot your host (sorry!).

## VM Config

Go to VMs tab and click **Add VM**. And add a Linux machine.

![](/assets/images/2020/ESXi-On-Unraid/Image3.png)

![](/assets/images/2020/ESXi-On-Unraid/Image5.png)

At a high level we want to do the following to start;
- CPU Mode is Host Passthrough
- i440fx-5.1 machine
- SeaBIOS BIOS
- 16384MB RAM (I think 8192MB is the ESXi minimum)
- An ESXi 7.0u1 ISO
- 2 CPUs (minimum required, add more if you like)
- Disk 1 - An ESXi Install disk which is a qcow type (which is a thin provisioned) USB disk to install ESXi on. 16GB is more than enough
- Disk 2 - A SATA disk (qcow type) for the actual datastore we will use in ESXi. 100GB is fine for my use case.

So, something like below.

![](/assets/images/2020/ESXi-On-Unraid/Image3b.png)

![](/assets/images/2020/ESXi-On-Unraid/Image7.png)

Then, we want to edit it again and then choose **Form View** to change to XML view (top right) and amend the text on the following items.

![](/assets/images/2020/ESXi-On-Unraid/Image8.png)

![](/assets/images/2020/ESXi-On-Unraid/Image9.png)

#### NOTE 

Never edit this again in the **Form View** as it will undo the changes or even make it an invalid config. So try to change to XML first. It's really annoying...

### CPU

#### Cores
If using 2 CPUs, ensure it has 2 cores and 1 thread each. ESXi needs to believe it has 2 physical cores available. If using 4 cores in your VM you won't have to do this, but I thought worth noting that it is a requirement.

```xml
<topology sockets='1' dies='1' cores='1' threads='2'/>
```

to 

```xml
<topology sockets='1' dies='1' cores='2' threads='1'/>
```


#### Virtualization

And, add a nested Virtualization flag for the host inside the CPU section.

```xml
  <cpu mode='host-passthrough' check='none' migratable='on'>
    <topology sockets='1' dies='1' cores='2' threads='2'/>
    <cache mode='passthrough'/>
    <feature policy='require' name='topoext'/>
  </cpu>
```

to 

```xml
  <cpu mode='host-passthrough' check='none' migratable='on'>
    <topology sockets='1' dies='1' cores='2' threads='2'/>
    <cache mode='passthrough'/>
    <feature policy='require' name='topoext'/>
    <feature policy='require' name='vmx'/>
  </cpu>
```

### Virtual Network

#### Adapter Type 

Change from **virtio-net** to **vmxnet3**

```xml
    <interface type='bridge'>
      <mac address='52:54:00:67:54:a0'/>
      <source bridge='br0'/>
      <model type='virtio-net'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
```

to

```xml
    <interface type='bridge'>
      <mac address='52:54:00:67:54:a0'/>
      <source bridge='br0'/>
      <model type='vmxnet3'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
```

### Full Config 

Here is the full XML file as an example to check against.

```xml
<?xml version='1.0' encoding='UTF-8'?>
<domain type='kvm' id='36'>
  <name>ESXi</name>
  <uuid>fe4d749a-5607-9b0e-5d6c-3e3a357eb6d1</uuid>
  <metadata>
    <vmtemplate xmlns="unraid" name="Linux" icon="linux.png" os="linux"/>
  </metadata>
  <memory unit='KiB'>16777216</memory>
  <currentMemory unit='KiB'>16777216</currentMemory>
  <memoryBacking>
    <nosharepages/>
  </memoryBacking>
  <vcpu placement='static'>4</vcpu>
  <cputune>
    <vcpupin vcpu='0' cpuset='4'/>
    <vcpupin vcpu='1' cpuset='10'/>
    <vcpupin vcpu='2' cpuset='5'/>
    <vcpupin vcpu='3' cpuset='11'/>
  </cputune>
  <resource>
    <partition>/machine</partition>
  </resource>
  <os>
    <type arch='x86_64' machine='pc-i440fx-5.1'>hvm</type>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-passthrough' check='none' migratable='on'>
    <topology sockets='1' dies='1' cores='2' threads='2'/>
    <cache mode='passthrough'/>
    <feature policy='require' name='topoext'/>
    <feature policy='require' name='vmx'/>
  </cpu>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/local/sbin/qemu</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='writeback'/>
      <source file='/mnt/cache/VMs/ESXi/vdisk1.img' index='3'/>
      <backingStore/>
      <target dev='hdc' bus='usb'/>
      <boot order='1'/>
      <alias name='usb-disk2'/>
      <address type='usb' bus='0' port='1'/>
    </disk>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='writeback'/>
      <source file='/mnt/cache/VMs/ESXi/vdisk2.img' index='2'/>
      <backingStore/>
      <target dev='hdd' bus='sata'/>
      <alias name='sata0-0-3'/>
      <address type='drive' controller='0' bus='0' target='0' unit='3'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/mnt/user/Software_and_ISOs/VMware-VMvisor-Installer-7.0U1-16850804.x86_64.iso' index='1'/>
      <backingStore/>
      <target dev='hda' bus='ide'/>
      <readonly/>
      <boot order='2'/>
      <alias name='ide0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0' model='ich9-ehci1'>
      <alias name='usb'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x7'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci1'>
      <alias name='usb'/>
      <master startport='0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0' multifunction='on'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci2'>
      <alias name='usb'/>
      <master startport='2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x1'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci3'>
      <alias name='usb'/>
      <master startport='4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'>
      <alias name='pci.0'/>
    </controller>
    <controller type='ide' index='0'>
      <alias name='ide'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <controller type='sata' index='0'>
      <alias name='sata0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </controller>
    <controller type='virtio-serial' index='0'>
      <alias name='virtio-serial0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </controller>
    <interface type='bridge'>
      <mac address='52:54:00:ce:4c:d9'/>
      <source bridge='br0'/>
      <target dev='vnet0'/>
      <model type='vmxnet3'/>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <source path='/dev/pts/0'/>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
      <alias name='serial0'/>
    </serial>
    <console type='pty' tty='/dev/pts/0'>
      <source path='/dev/pts/0'/>
      <target type='serial' port='0'/>
      <alias name='serial0'/>
    </console>
    <channel type='unix'>
      <source mode='bind' path='/var/lib/libvirt/qemu/channel/target/domain-36-ESXi/org.qemu.guest_agent.0'/>
      <target type='virtio' name='org.qemu.guest_agent.0' state='disconnected'/>
      <alias name='channel0'/>
      <address type='virtio-serial' controller='0' bus='0' port='1'/>
    </channel>
    <input type='tablet' bus='usb'>
      <alias name='input0'/>
      <address type='usb' bus='0' port='2'/>
    </input>
    <input type='mouse' bus='ps2'>
      <alias name='input1'/>
    </input>
    <input type='keyboard' bus='ps2'>
      <alias name='input2'/>
    </input>
    <graphics type='vnc' port='5900' autoport='yes' websocket='5700' listen='0.0.0.0' keymap='en-gb'>
      <listen type='address' address='0.0.0.0'/>
    </graphics>
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
      <alias name='video0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <alias name='balloon0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </memballoon>
  </devices>
  <seclabel type='dynamic' model='dac' relabel='yes'>
    <label>+0:+100</label>
    <imagelabel>+0:+100</imagelabel>
  </seclabel>
</domain>
```

## Install ESXi

Then, power it on and look at the VNC console. Nice!

![](/assets/images/2020/ESXi-On-Unraid/Image10.png)

![](/assets/images/2020/ESXi-On-Unraid/Image11.png)

Now, set a password and install the system to the 16GB USB disk we created earlier.

![](/assets/images/2020/ESXi-On-Unraid/Image13.png)

![](/assets/images/2020/ESXi-On-Unraid/Image14.png)

(this is a bad screenshot, you should see the 100GB disk too but I messed up here, choose the 16GB disk to install to though)
![](/assets/images/2020/ESXi-On-Unraid/Image15.png)

![](/assets/images/2020/ESXi-On-Unraid/Image16.png)

![](/assets/images/2020/ESXi-On-Unraid/Image17.png)

![](/assets/images/2020/ESXi-On-Unraid/Image18.png)

![](/assets/images/2020/ESXi-On-Unraid/Image19.png)

![](/assets/images/2020/ESXi-On-Unraid/Image20.png)

Then reboot the vm and look for the IP address it displays.

![](/assets/images/2020/ESXi-On-Unraid/Image21.png)

Go to that page, like https://192.168.1.63 and login (ignore any browser self-signed certificate warnings)

![](/assets/images/2020/ESXi-On-Unraid/Image22.png)

![](/assets/images/2020/ESXi-On-Unraid/Image23.png)

Success!

## Disks

Now we need to create a new datastore from the 100GB disk we also added to the VM. Just go to the **Storage** icon and then choose to create a new datastore. Then just go through the options like below.

![](/assets/images/2020/ESXi-On-Unraid/Image24.png)

![](/assets/images/2020/ESXi-On-Unraid/Image25.png)

![](/assets/images/2020/ESXi-On-Unraid/Image33.png)

![](/assets/images/2020/ESXi-On-Unraid/Image34.png)

![](/assets/images/2020/ESXi-On-Unraid/Image35.png)

![](/assets/images/2020/ESXi-On-Unraid/Image36.png)

Success! 

![](/assets/images/2020/ESXi-On-Unraid/Image37.png)


## Test VM

Now, we can create a VM to test that this machine works as a virtualization host. I installed Ubuntu 64-bit and it all worked fine, done!

![](/assets/images/2020/ESXi-On-Unraid/Image46.png)

![](/assets/images/2020/ESXi-On-Unraid/Image47.png)

{% include all-footer-includes.html %}