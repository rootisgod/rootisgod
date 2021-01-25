This guy has a very nice writeup of the process.

https://www.linuxsysadmins.com/adding-usb-network-adapter-to-esxi-7/

And this guy;

https://tech-addict.fr/home-lab-usb-network-adapters-for-esxi/

I did try this with a Realtek 8153 adapter, but it just wouldnt work. It would show with ```lsusb``` but never appear as a physical adapter. A look at the ```vmkernel.log``` showed this error. Game over, no idea how to solve it...

```
2020-12-19T16:57:41.614Z cpu2:131593)cdce_attach: Attaching device vid:pid/0xbda:0x8153 configIndx 1 ConfigNum 2 bIfaceIndex 0
2020-12-19T16:57:41.614Z cpu2:131593)cdce_attach: find class - 10/0/0 - 1
2020-12-19T16:57:41.614Z cpu2:131593)cdce_attach: set alt index0 1 alt 0 index1 0
2020-12-19T16:57:41.659Z cpu2:131593)cdce_attach:set alt 0 error 16
2020-12-19T16:57:41.659Z cpu2:131593)cdce_attach: No valid alternate setting found 0
2020-12-19T16:57:41.659Z cpu2:131593)cdce_attach: Attach Device 0bda:8153 FAIL
```

https://flings.vmware.com/usb-network-native-driver-for-esxi



https://flings.vmware.com/usb-network-native-driver-for-esxi?download_url=https%3A%2F%2Fdownload3.vmware.com%2Fsoftware%2Fvmw-tools%2FUSBNND%2FESXi701-VMKUSB-NIC-FLING-40599856-component-17078334.zip

Check these devices;

https://flings.vmware.com/usb-network-native-driver-for-esxi

This Fling supports the most popular USB network adapter chipsets found in the market. The ASIX USB 2.0 gigabit network ASIX88178a, ASIX USB 3.0 gigabit network ASIX88179, Realtek USB 3.0 gigabit network RTL8152/RTL8153 and Aquantia AQC111U. These are relatively inexpensive devices that many of our existing vSphere customers are already using and are familiar with.
ESXi701-VMKUSB-NIC-FLING-40599856-component-17078334.zip

esxcli software component apply -d /path/to/the component zip

has to be full path

[root@localhost:/vmfs/volumes/5fddc430-daaed44c-8aee-525400b16a9b/vibs] esxcli software component apply -d /vmfs/volumes/5fddc430-daaed44c-8aee-525400b16a9b/vibs/ESXi701-VMKUSB-NIC-FLING-40599856-component-17078334.zip 

Installation Result
   Components Installed: VMware-vmkusb-nic-fling_2.1-6vmw.701.0.0.40599856
   Components Removed: 
   Components Skipped: 
   Message: The update completed successfully, but the system needs to be rebooted for the changes to be effective.
   Reboot Required: true


Power off

Add USB NIC to Unraid host

add this to its config (or use another machine to add and find the correct setting)
    </video>
    <hostdev mode='subsystem' type='usb' managed='no'>
      <source>
        <vendor id='0x0bda'/>
        <product id='0x8153'/>
      </source>
      <address type='usb' bus='0' port='1'/>
    </hostdev>
    <memballoon model='virtio'>


    <hostdev mode='subsystem' type='usb' managed='no'>
      <source>
        <vendor id='0x0bda'/>
        <product id='0x8153'/>
      </source>
      <address type='usb' bus='0' port='1'/>
    </hostdev>


Power on

[root@localhost:~] lsusb
Bus 001 Device 001: ID 0e0f:8001 VMware, Inc. Root Hub
Bus 002 Device 001: ID 0e0f:8001 VMware, Inc. Root Hub
Bus 003 Device 001: ID 0e0f:8001 VMware, Inc. Root Hub
Bus 004 Device 001: ID 0e0f:8002 VMware, Inc. Root Hub
Bus 004 Device 002: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
Bus 004 Device 003: ID 46f4:0001 QEMU 
Bus 004 Device 004: ID 0627:0001 Adomax Technology Co., Ltd 


ne1000 driver...

https://www.virtuallyghetto.com/2020/08/enhancements-to-the-community-ne1000-vib-for-intel-nuc-10.html

[root@localhost:/vmfs/volumes/5fddc430-daaed44c-8aee-525400b16a9b/vibs] esxcli s
oftware component apply -d /vmfs/volumes/5fddc430-daaed44c-8aee-525400b16a9b/vib
s/Intel-NUC-ne1000_0.8.4-3vmw.670.0.0.8169922-offline_bundle-16654787.zip 
Installation Result
   Components Installed: Intel-NUC-ne1000_0.8.4-3vmw.670.0.0.8169922
   Components Removed: 
   Components Skipped: 
   Message: The update completed successfully, but the system needs to be rebooted for the changes to be effective.
   Reboot Required: true

   ~ # /etc/init.d/usbarbitrator stop
(optional) Use this command to permanently disable the USB arbitrator service after reboot.
~ # chkconfig usbarbitrator off

reboot

```
[root@localhost:~] esxcli network nic list
Name    PCI Device    Driver    Admin Status  Link Status  Speed  Duplex  MAC Address         MTU  Description
------  ------------  --------  ------------  -----------  -----  ------  -----------------  ----  -----------
vmnic0  0000:00:03.0  nvmxnet3  Up            Up            1000  Full    52:54:00:b1:6a:9b  1500  VMware Inc. vmxnet3 Virtual Ethernet Controller
```

Check kernel.log



