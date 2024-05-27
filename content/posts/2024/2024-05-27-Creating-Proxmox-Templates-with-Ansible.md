---
categories: proxmox ansible k8s microk8s ubuntu debian
date: "2024-05-27T08:00:00Z"
title: Creating Proxmox Templates with Ansible
draft: false
---

Given VMWare seems to have imploded, the new hotness is Proxmox. And it really is good, especially for a homelabber (no more vcenter!). But, the one thing I always struggled with was creating a template I could use to create a new machine in seconds. So, this guide should show you how to use ansible to create templates in seconds.

# Creating a Template

This is what we need to create in Ansible. As a note, because Ansible clusters need unique IDs for machines, we can add a unique value to the VMID if we just increment it for each host.

Also, this is 99% from this guy, massive props, I didnt realise it was this simple: https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs


```yaml
---
- hosts: all
  vars:
    base_value: 9000
  tasks:
    - name: Set incremented value for each host
      set_fact:
        VMID: "{{ base_value | int + ansible_play_hosts.index(inventory_hostname) + 1 }}"

    - name: Create a shell script with the incremented VMID
      template:
        src: ./scripts/create-ubuntu-2404-template.sh.j2
        dest: /tmp/create-ubuntu-2404-template.sh
        mode: '0755'

    - name: Execute the script
      shell: /tmp/create-ubuntu-2404-template.sh
```

This is the script we run to create the VM template in proxmox. Place it in a ```./scripts``` folder. It will setup a machine template and create a template we can use to create VMs. Tweak anything below as you see fit. In particular, the place to pickup the SSH authorised key for access.

```bash
#! /bin/bash

VMID={{ VMID }}
STORAGE=local-lvm

set -x
wget -qN https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 128G
qm destroy $VMID
qm create $VMID --name "ubuntu-2404-template" --ostype l26 \
    --memory 2048 --balloon 0 \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --cpu host --cores 2 --numa 1 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0,mtu=1
qm importdisk $VMID noble-server-cloudimg-amd64.img $STORAGE
qm set $VMID --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$VMID-disk-1,discard=on
qm set $VMID --boot order=virtio0
qm set $VMID --ide2 $STORAGE:cloudinit

mkdir -p /var/lib/vz/snippets
cat << EOF | tee /var/lib/vz/snippets/ubuntu.yaml
#cloud-config
runcmd:
    - apt-get update
    - apt-get install -y qemu-guest-agent
    - systemctl enable ssh
    - reboot
# Taken from https://forum.proxmox.com/threads/combining-custom-cloud-init-with-auto-generated.59008/page-3#post-428772
EOF

qm set $VMID --cicustom "vendor=local:snippets/ubuntu.yaml"
qm set $VMID --ciuser $USER
qm set $VMID --sshkeys ~/.ssh/authorized_keys
qm set $VMID --ipconfig0 ip=dhcp
qm template $VMID
```

# Deployment

Run it like this. Make a hosts file (say you have 3 proxmox machines that all need a template)

```yaml
192.168.1.100 ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/ssh
192.168.1.101 ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/ssh
192.168.1.102 ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/ssh
```

Then run like so

```bash
ansible-playbook -i hosts playbook.yml
```

We should get some templates!
