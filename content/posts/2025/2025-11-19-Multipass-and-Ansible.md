---
categories:  multipass vms mac windows linux ansible
date: "2025-11-19T14:00:00Z"
title: Multipass and Ansible - Best Friends
draft: false
---

The [multipass](https://canonical.com/multipass) obsession continues... In this article, I'm going to show you how multipass makes it very easy to make an Ubuntu VM that you can use as an ansible test machine. We could do this in the cloud, but it can be a real pain getting a VM created quickly, it costs money, you can't make a snapshot, you might need to delete it and start again etc etc... You could also create a VM in proxmox and snapshot it, restart it, revert it etc etc... but that is a lot of steps to a GUI and clicks. Or, you could use multipass to get a brand new VM every 40 seconds. So, here goes, the simplest possible implementation, and then some automation of the steps at the end.

## SSH Keys

So, we need to make sure we have an SSH private and public key first. Multipass instances are passwordless by default, so we use an SSH key to access them. Even though Multipass comes with it's own SSH key, it is in a directory that requires sudo rights to get to it on a Mac... So, just use your own. Generate one like so. Don't password protect it, just hit enter. Also, i'm presuming Linux or Mac here, Windows users, you are on your own!

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_multipass
```

We will get two files,  `~/.ssh/id_multipass` and `~/.ssh/id_multipass.pub`.

## Instance Creation

Start by creating an instance called `ansible-test`

```bash
multipass launch --name ansible-test
```

And then copy the public key to the authorized_users file on the instance so it will let us login via SSH.

```bash
multipass exec ansible-test -- bash -c "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_multipass.pub
```

Then, do an info command and note the IP of it (this example presumes it is 192.168.2.13, yours will be different!).
```bash
multipass info ansible-test
```

## Ansible Playbook

We need to create a small inventory file with the required connection info for ansible to connect to the VM.

Create a file called `inventory.yml` with the IP from before.

```yaml
all:
  hosts:
    ansible-test:
      ansible_connection: ssh
      ansible_host: "192.168.2.13"
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_multipass
```

Then create a file called `playbook.yml` which is what we will run. It is a very simple test playbook, make it as complicated as you like though.

```yaml
---
- name: Write a file on the Multipass VM
  hosts: all
  tasks:
    - name: Create a test file in /tmp
      copy:
        content: "Hello from Ansible!"
        dest: /tmp/ansible_test.txt
        mode: '0644'
```

Then run it

```bash
ansible-playbook -i inventory.yml playbook.yml
```

It should succeed!

```bash
% ansible-playbook -i inventory.yml playbook.yml

PLAY [Write a file on the Multipass VM] *********************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
[WARNING]: Platform linux on host ansible-test is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of another Python
interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.18/reference_appendices/interpreter_discovery.html for more
information.
ok: [ansible-test]

TASK [Create a test file in /tmp] ***************************************************************************************************************************
changed: [ansible-test]

PLAY RECAP **************************************************************************************************************************************************
ansible-test               : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Then, if you want to start again just do this. Not too shabby.

```bash
multipass delete ansible-test
multipass purge
multipass launch --name ansible-test
multipass exec ansible-test -- bash -c "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_multipass.pub
# Update inventory.yml IP address
```

## Taskfile

But...... we could make this even easier. So, here is a [taskfile](https://taskfile.dev) to smooth it out Tweak the SSH key to your liking in the variable at the top. Just create it as `taskfile.yml` and then type `task rebuild` and then run `task ansible-playbook`. Awesome! You can recreate an instance in 40 seconds (Apple M1 Max)

```yaml
version: '3'

vars:
  SSH_KEY: ~/.ssh/id_multipass

tasks:
  launch-instance:
    desc: Launch a Multipass VM named ansible-test
    cmds:
      - multipass launch --name ansible-test

  delete-instance:
    desc: Delete the ansible-test Multipass VM
    cmds:
      - multipass delete ansible-test || true
      - multipass purge

  add-ssh-key:
    desc: Append your public SSH key to the VM's authorized_keys
    cmds:
      - multipass exec ansible-test -- bash -c "cat >> ~/.ssh/authorized_keys" < {{.SSH_KEY}}.pub

  get-vm-ip-unix:
    desc: Get the IP address of the Multipass VM on macOS/Linux and save to .vm_ip
    platforms: [darwin, linux]
    cmds:
      - multipass info ansible-test | grep 'IPv4:' | awk '{print $2}' > .vm_ip

  get-vm-ip-windows:
    desc: Get the IP address of the Multipass VM on Windows and save to .vm_ip
    platforms: [windows]
    cmds:
      - multipass info ansible-test | powershell -Command "Select-String 'IPv4:' | ForEach-Object { \$_.Line.Split(':')[1].Trim() }" > .vm_ip

  get-vm-ip:
    desc: Get the IP address of the Multipass VM and save to .vm_ip (cross-platform)
    cmds:
      - task: get-vm-ip-unix
      - task: get-vm-ip-windows

  generate-inventory:
    desc: Generate Ansible inventory.yml with the VM IP read from .vm_ip
    cmds:
      - |
        VM_IP=$(cat .vm_ip)
        cat <<EOF > inventory.yml
        all:
          hosts:
            ansible-test:
              ansible_connection: ssh
              ansible_host: "$VM_IP"
              ansible_user: ubuntu
              ansible_ssh_private_key_file: {{.SSH_KEY}}
        EOF

  ansible-ping:
    desc: Test Ansible connectivity to the VM (not supported on Windows hosts)
    platforms: [darwin, linux]
    cmds:
      - ansible all -i inventory.yml -m ping

  ansible-playbook:
    desc: Run the Ansible playbook against the VM
    cmds:
      - ansible-playbook -i inventory.yml playbook.yml

  rebuild:
    desc: Delete the ansible-test instance, create a new one, and generate inventory.yml
    cmds:
      - task delete-instance
      - task launch-instance
      - task get-vm-ip
      - task generate-inventory
      - task add-ssh-key
      - task ansible-ping
```

If we run it, success!

```bash
% task rebuild
task: [rebuild] task delete-instance
task: [delete-instance] multipass delete ansible-test || true
task: [delete-instance] multipass purge
task: [rebuild] task launch-instance
task: [launch-instance] multipass launch --name ansible-test
Launched: ansible-test
task: [rebuild] task get-vm-ip
task: [get-vm-ip-unix] multipass info ansible-test | grep 'IPv4:' | awk '{print $2}' > .vm_ip
task: [rebuild] task generate-inventory
task: [generate-inventory] VM_IP=$(cat .vm_ip)
cat <<EOF > inventory.yml
all:
  hosts:
    ansible-test:
      ansible_connection: ssh
      ansible_host: "$VM_IP"
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_multipass
EOF

task: [rebuild] task add-ssh-key
task: [add-ssh-key] multipass exec ansible-test -- bash -c "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_multipass.pub
task: [rebuild] task ansible-ping
task: [ansible-ping] ansible all -i inventory.yml -m ping
[WARNING]: Platform linux on host ansible-test is using the discovered Python interpreter at
/usr/bin/python3.12, but future installation of another Python interpreter could change the meaning of
that path. See https://docs.ansible.com/ansible-core/2.18/reference_appendices/interpreter_discovery.html
for more information.
ansible-test | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
```

If you want to override the SSH key in a run, you can do this as well

```bash
task rebuild SSH_KEY=/path/to/your/key
```

## Location of Multipass SSH Key

This could be useful if you want to just use the native key. Copy to a more central location if you want to avoid using a dedicated Private Key. Just tweak the things above (no need to update the authorized keys!).

| Platform      | SSH Key Location                                                                 |
|---------------|----------------------------------------------------------------------------------|
| macOS         | `/var/root/Library/Application Support/multipassd/ssh-keys/id_rsa`               |
| Linux (snap)  | `/var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa`                     |
| Linux (deb)   | `~/.local/share/multipassd/ssh-keys/id_rsa`                                      |
| Windows       | `%USERPROFILE%\\AppData\\Local\\Multipass\\data\\multipassd\\ssh-keys\\id_rsa`   |
