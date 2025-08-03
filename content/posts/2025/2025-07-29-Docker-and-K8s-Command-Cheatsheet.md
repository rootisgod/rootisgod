---
categories: docker k8s kubernetes
date: "2025-07-29T00:00:00Z"
title: Cheatsheet for Docker and Kubernetes Commands
draft: false
---

I seem to have 5 different places where I keep example commands to do the little things in Docker or Kubernetes. Things like attach to a running node, start a proxy, tag an image etc etc... So here it is.

Note: This will likely update over time

# Kubernetes

alias k=kubectl

## Env Setup

| Command | Description |
|---------|-------------|
| `alias k=kubectl` | Create a shortcut for kubectl |
| `export KUBE_EDITOR="nano"` | Set nano as the default editor for kubectl |
| `export do="--dry-run=client -o yaml"` | Shortcut for dry-run output in YAML |
| `export now="--grace-period 0 --force"` | Shortcut for immediate resource deletion |
| `source <(kubectl completion bash)` | Enable bash completion for kubectl |
| `complete -F __start_kubectl k` | Enable completion for the k alias |

## Pods

| Command | Description |
|---------|-------------|
| `k run nginx --image=nginx $do > nginx.yaml` | Get YAML from a pod |
| `kubectl exec -it <pod-name> -- /bin/bash` | Enter a running pod |
| `kubectl run -it --rm ib-test --image=debian` | Start a temporary pod that deletes on exit |


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

| Command | Description |
|---------|-------------|
| `docker system prune` | Remove old images and containers |
| `docker container run -it [yourImage] bash` | Run an interactive container |
| `docker container run --rm -it [yourImage] bash` | Run and auto-delete interactive container |
| `docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it [yourImage] bash` | Run container with a bind mount |
| `docker tag reponame/myimage:latest newreponame/myimage:other` | Tag a resource with another tag |

## Mac

### x64 Builds 

| Command | Description |
|---------|-------------|
| `FROM --platform=linux/amd64 python:3.10-buster` | Build x64 image on Mac Silicon |
| `export DOCKER_DEFAULT_PLATFORM=linux/amd64` | Set default platform for Docker builds |

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