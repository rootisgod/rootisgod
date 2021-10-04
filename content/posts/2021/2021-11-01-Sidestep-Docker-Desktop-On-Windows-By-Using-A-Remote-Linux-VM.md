---
categories: linux docker windows desktop
date: "2021-11-01T21:05:00Z"
title: Sidestep Docker Desktop On Windows By Using A Remote Linux VM.md
draft: true
---

https://code.visualstudio.com/docs/containers/ssh
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows

## Windows
- Generate an ssh key
- Install Pageant
- Download Docker CLI exe - https://github.com/StefanScherer/docker-cli-builder/releases
- Copy to Windows System32
- Set docker host
```powershell
$Env:DOCKER_HOST='ssh://root@192.168.1.73'
ssh -i ~/.ssh/id_rsa root@192.168.1.73
```

```cmd
PS C:\Users\iain> ssh-keygen -m PEM -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\iain/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in C:\Users\iain/.ssh/id_rsa.
Your public key has been saved in C:\Users\iain/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:DmxIskF/YPLnFeagp1BPPfNsvpnJZ/Hy5iYAq/hJqQ0 iain@NUC
The key's randomart image is:
+---[RSA 4096]----+
|  o + o.o        |
| . * = ++.       |
|  + = = o=       |
|   * O .. +      |
|  . o = S=       |
|     . +. o .    |
|    E.o... * o   |
|    .=..  * = +  |
|    ..+    o Bo  |
+----[SHA256]-----+
PS C:\Users\iain>
```

Copy to Linux VM
```cmd
type .\.ssh\id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmPRdMFbikNagwWQAV2but4Bchp5pfmO41J0Fe6L/P8pvehf/BYflmY6pGFPYXc7Etpbh9iOjz+dJbkpS5RYSAp9TOxEKQXli/plemdtasipmaN4yFyXcq+ks36X7QffEWMhReDtuQGuaZtu/FVnRCMO8tbyox+mWkco3P+88npNj2AJ8TlS1aRYPpkTeYqAODQCiYVGsdJ8fi1KBQ4MxN7t7VoWrUaYb5zxoFuQPiTDifptb00HlzwctGIo6KIIiQiEypi7XdVB3lXIbcXk8uY6jzd8ChIYR2nlsMDQ42Y+iwLoAILkvvQ9vdD7tr/b5WsDXlk98CpZO5wq43UersWGQox5DGCQRMFvvSD2GkdomkYJA7TMqFw1P5nxp1T2pYanJyrDOXygmmGTzqBN6VY/rQKffcERxSozCT9dF6YZSW+rNWCsQAJj0YpNgz7NTpgn+lYLFnp1m1lXO67cFCh5imRhXA/KVQ852aB23xEf3JBrYW0lJ7dUzTKrRF7rTagiFgW1hE7gRWhAfpinZwFNw2GG0XFx+rULBcxaU3tYYI/iIhwwzCnQgN4snicAH3OET8AwDeWeCZtBKf4boWMsow3GUNrHwWJ3S4Cy/+hxvRTt4Mi7jO6inMkvhzS5D6C5p9iGImU0ku+AjWScNPxcFUUfaKN3HQr09p2jotcw== iain@NUC
```

Add to Linux VM
```bash
nano /root/.ssh/authorized_keys
```

Check connection
```cmd
ssh -i ~/.ssh/id_rsa root@192.168.1.73
```

Add DOCKER_HOST ENV var value like ssh://root@192.168.1.73

Restart VSCode
User SSH DOCKER AGENT

```cmd
SSH_AUTH_SOCK=pageant

Set-Service ssh-agent -StartupType "Automatic"
Start-Service ssh-agent
ssh-add ~/.ssh/id_rsa

PS C:\Users\iain\.ssh> start-ssh-agent
Found ssh-agent at 21172
Found ssh-agent socket at pageant
Starting ssh-agent:  done
Identity added: /c/Users/iain/.ssh/id_rsa (/c/Users/iain/.ssh/id_rsa)

Microsoft Windows [Version 10.0.19043.1237]
(c) Microsoft Corporation. All rights reserved.
```

In order to use an SSH DOCKER_HOST, you must configure an ssh-agent.
https://code.visualstudio.com/docs/containers/ssh


## Linux
Set a root password

```bash
sudo su
passwd
```

Set authorised keys
```
```

Enable root login to ssh daemon
```bash
nano /etc/ssh/sshd_config
PermitRootLogin yes
```

```bash
systemctl restart sshd.service
```
