---
categories: docker nuget sonatype mexus dockerhub
date: "2025-03-09T00:00:00Z"
title: Proxying DockerHub with Nexus
draft: false
---

I have pretty bad internet, around 4MB/s, and also a Sky Glass TV. Guess what happens when I pull some Docker images, no TV! Instead, I have to tweak the docker host I am using have to pull images in a single threaded manner. And then if I have multiple hosts, or i'm trying out a new Kubernetes cluster things get annoying even quicker. It just gets annoying and frustrating.

The solution, is some kind of local proxy. So, taking inspiration from using Sonatype Nexus to be a Chocolatey Nuget server, I thought I would try and do the same thing for Docker Images. There seems to be only one person discussing how to do this (https://www.youtube.com/watch?v=dpWxWr90MGI&t=20s). So, shout out to them, this is just my contribution to doing this as a blog post so more people might find it easily, and i'll just cover setting up Docker and Kubernetes to use the internal proxy.



Then in daemon.json

```
  "insecure-registries": [
    "192.168.1.249:8082"
  ],
```


```
{
  "registry-mirrors": ["http://192.168.1.249:8082"],
}
```

So it looks like this


```
{
  "insecure-registries": [
    "192.168.1.249:8082"
  ],
  "registry-mirrors": ["http://192.168.1.249:8082"],
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false
}
```


Run this to check

```
docker info --format '{{.RegistryConfig.Mirrors}}'
```

## KIND

And then if you want to create a KIND cluster and also make use of this

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: ./daemon.json
    containerPath: /etc/docker/daemon.json
    readOnly: true
- role: worker
  extraMounts:
  - hostPath: ./daemon.json
    containerPath: /etc/docker/daemon.json
    readOnly: true
```

And then create `daemon.json` in the same folder with this


```json
{
  "registry-mirrors": ["http://192.168.1.249:8082"],
  "insecure-registries": ["192.168.1.249:8082"]
}
```


```
kind create cluster --config kind-config.yaml
```