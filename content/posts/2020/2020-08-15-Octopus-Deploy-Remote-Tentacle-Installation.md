---
categories: ansible octopus
date: "2020-08-15T08:20:00Z"
title: Octopus Deploy Remote Tentacle Installation
---

I've spent a couple of miserable days doing battle trying to install an Octopus Deploy Tentacle agent to remote machines via ansible. The machines in question are created brand new, and we need that agent in order to install software from a build system. The problem is that an agent install requires generating a certificate for that machine. And, if there is no user profile loaded then windows cannot access the cryptographic functions required to generate it (for some reason). The ansible deployment connects to each VM as an admin user via WinRM but this still isnt enough for things to work it seems. This is a long standing issue. See this github [page](https://github.com/OctopusDeploy/Issues/issues/353) for some solutions others have offered. I tried them all (pregenerating certificates via openssl/tentacle.exe, and psexec commands), but had no success. What makes it worse is that the only way to see the logs is to login to the machine, and so you ruin the 'not logged in before' nature of the sytem and everything starts to work remotely. Schrodingers octopus!

So, I thought I would document my solution so I never have to wonder again how I did it. The way to get it to work is to create a Windows Scheduled Task which runs an install script. That process can use the users profile and allows desktop access, so it can run just like you were actually logged in. Nasty but effective.

The ansible and script below are as to the point as I can make it, so there won't be any extras and you need to know ansible a little, but feel free to augment to your needs. It seems solid so far which is the main thing. Again, amend and augment as required, there is a lot more you could do here better, like check if the agent is already installed etc... but it does the job!

## Install Octopus Tasks

Ansible code below. Be sure to have some facts setup or variables in place for things like the 'octopus_tentacle_version', or just hard code them.

```yaml
- name: Install Octopus Tentacle using chocolatey
  win_chocolatey:
      name: octopusdeploy.tentacle
      version: "{{ octopus_tentacle_version }}"
      pinned: yes
      state: present

- name: Upload the Octopus Installer Script for the Scheduled Task
  win_copy:
      src: files/install-tentacle.ps1
      dest: "C:\\scripts\\"
      remote_src: no
      force: true

- name: Create a Scheduled Task to Install the Tentacle to Avoid the Remote Certificate Generation Issue
  win_scheduled_task:
      name: Install Octopus Deploy
      description: Install
      actions:
          - path: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
            arguments: -ExecutionPolicy Unrestricted -NonInteractive -File c:\scripts\install-tentacle.ps1 -tentacle_service_port "10933" -octopus_server_certificate_thumbprint "{{ octopus_server_certificate_thumbprint }}"
      triggers:
          - type: daily
            start_boundary: "2050-01-01T00:00:00Z" # Just a random time, we dont use this
      #---------------------------------------------------------------------------------------------------------------------------------------------
      # Only use an account username and password if you have to run the tentacle as a specific user. Note, this will fail in Windows Desktop Editions
      # as it seems to NEED a real login to occur for the user to exist and do this. This limitation isn't on server editions. Just FYI!
      #username: "{{ hostvars['localhost']['vm_admin_username'] }}"
      #password: "{{ hostvars['localhost']['vm_admin_password'] }}"
      #logon_type: password
      #---------------------------------------------------------------------------------------------------------------------------------------------
      username: SYSTEM
      state: present
      enabled: yes
      run_level: highest

- name: Manually Run the Scheduled Task
  win_shell: Start-ScheduledTask -TaskName "Install Octopus Deploy"

- name: Pause for 15 seconds to allow the Scheduled Task to complete. 15 seconds is plenty in most cases
  pause:
      seconds: 15

- name: Delete the Install Tentacle Scheduled Task
  win_scheduled_task:
      name: Install Octopus Deploy
      state: absent

- name: Restart service, set startup to auto, and also delayed mode as the agent sometimes fails on boot
  win_service:
      name: "OctopusDeploy Tentacle"
      start_mode: delayed
      state: restarted

- name: Test we can get the Octopus Tentacle thumbprint without error. If so, success!
  win_shell: |
      cd "C:\Program Files\Octopus Deploy\Tentacle"
      .\Tentacle.exe show-thumbprint --instance "Tentacle" --nologo
```

## The Tentacle Agent Install Script

This is what the scheduled task runs. It keeps a transcript so you can see what it did. There is slghtly fancier version [here](https://gist.githubusercontent.com/erichexter/b0cca2ff2e3ab120cec8/raw/492fcb7dc41e0470b0e77d4ac74efe6b85d124af/gistfile1.ps1) from the github issue page referenced earlier. It does a little more like set environment and roles of the VM, but the version below is the bare requirements needed to get it in a installed state which is fit for registration.

```powershell
param (
    $tentacle_service_port,
    $octopus_server_certificate_thumbprint
)

$dt=get-date -Format "yyyy-MM-dd"
Start-Transcript -Path "c:\kits\$dt-OctopusInstall.txt"

cd "C:\Program Files\Octopus Deploy\Tentacle"
.\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
.\Tentacle.exe configure --instance "Tentacle" --reset-trust --console
.\Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "$tentacle_service_port" --console
.\Tentacle.exe configure --instance "Tentacle" --trust "$octopus_server_certificate_thumbprint" --console
netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport="$tentacle_service_port"
.\Tentacle.exe service --instance "Tentacle" --install --start --console

Stop-Transcript
```
