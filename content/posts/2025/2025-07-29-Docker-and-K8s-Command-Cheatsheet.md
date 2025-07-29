---
categories: docker k8s kubernetes
date: "2025-07-29T00:00:00Z"
title: Cheatsheet for Docker and Kubernetes Commands
draft: false
---

I seem to have 5 different places where I keep example commands to do the little things in Docker or Kubernetes. Things like attach to a running node, start a proxy, tag an image etc etc... So here it is.

Note: This will likely update over time

# Kubernetes

## Env Setup

```
alias k=kubectl
export KUBE_EDITOR=“nano”
export do="--dry-run=client -o yaml"
export now="--grace-period 0 --force"

source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
```

## Pods

Get YAML from a pod: `k run nginx --image=nginx $do > nginx.yaml`

Enter a Running Pod: `kubectl exec -it <pod-name> -- /bin/bash`

Start a temp pod in a cluster that deletes on exit: `kubectl run -it --rm ib-test --image=debian`


# Docker

## Install via Snap (Ubuntu)

```
sudo snap refresh
sudo snap install docker
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
sudo snap restart docker
```

You will also need to disable and re-enable the docker snap if you added the group while it was running.
```
sudo snap disable docker
sudo snap enable  docker
```

## Images

Remove Old Images: `docker system prune`

Run an interactive container: `docker container run -it [yourImage] bash`

Run an interactive container that deletes itself: `docker container run --rm -it [yourImage] bash`

Run an interactive container that deletes itself with a mount point: `docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it [yourImage] bash`

Tag a resource with another tag: `docker tag reponame/myimage:latest newreponame/myimage:other`

## Mac

### x64 Builds 

Set this to get a real x64 build on Mac Silixon (ARM): `FROM --platform=linux/amd64 python:3.10-buster`

Or export it: `export DOCKER_DEFAULT_PLATFORM=linux/amd64`

## Data Folder

To change it on Linux do this

```
systemctl stop docker
mkdir -p /root/docker
rsync -aqxP /var/lib/docker/* /root/docker
mv /var/lib/docker/ /var/lib/old-docker/
nano /etc/docker/daemon.json

{
  "data-root": "/root/docker"
}

systemctl start docker
```