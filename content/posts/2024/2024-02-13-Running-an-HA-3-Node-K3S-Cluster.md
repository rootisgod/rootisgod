---
categories: k8s k3s homelab kubernetes
date: "2024-02-13T08:00:00Z"
title: Running an HA 3 Node K3S Cluster
draft: false
---

Have some kubernetes experience and want to know how to create a 3 node K3S cluster at home? Read on...

# Motivation

I recently decided to run a kubernetes cluster at home using real hardware as part of study for the CKA exam. So I bought 3 miniPCs that have 4 CPUs, 16GB RAM and 500GB NVMe. Overkill? Maybe. But, I really wanted to do it on real hardware and 'care' about the machines and the applications. Doing that in a VM just doesn't have that same skin the in game feel. So, here are some instructions on how to set it up. It's not difficult, but thought worth sharing as it's a bit of a tough google.

# Setup and K3S Installation

Get 3 'machines' (VMs are fine for trying it out)
 
- Install Ubuntu 22.04 on each one, k8s1, k8s2 and k8s3. Ensure they have network connectivity and can resolve each other's names.
- Install k3s as control and workers (info below, mostly from https://docs.k3s.io/datastore/ha-embedded)

```bash
# k8s1 - Create as our initial cluster master
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --disable traefik" K3S_TOKEN=k3stoken sh -s - server --cluster-init

# k8s2 and k8s3 - Add to the cluster
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --disable traefik" K3S_TOKEN=k3stoken sh -s - server --server https://k8s1:6443

# SSH to the k8s1 vm

# Will show all our nodes and roles (example below)
kubectl get nodes

  NAME   STATUS   ROLES                       AGE   VERSION
  k8s1   Ready    control-plane,etcd,master   99m   v1.28.6+k3s2
  k8s2   Ready    control-plane,etcd,master   97m   v1.28.6+k3s2
  k8s3   Ready    control-plane,etcd,master   96m   v1.28.6+k3s2

# Get our kubectl context file from k8s1, use in your kubecontext (or lens, k9s etc...)  to access the cluster
cat /etc/rancher/k3s/k3s.yaml

# Run a test deployment
kubectl create deployment nginx-deploy --image=nginx --replicas=1

# Get the node the pod was scheduled on
kubectl get pods -o wide

  NAME                           READY   STATUS    RESTARTS   AGE   IP         NODE
  nginx-deploy-d845cc945-r86f8   1/1     Running   0          1m   10.42.2.4   k8s3

# Turn off the node that got the pod scheduled
ssh root@k8s3
sudo poweroff

# Go back to k8s1, get pods again. The pod will move to another node!
kubectl get pods -o wide
NAME                           READY   STATUS        RESTARTS      AGE     IP          NODE
nginx-deploy-d845cc945-9rk7b   1/1     Terminating   1 (8m ago)    10m     10.42.1.3   k8s2
nginx-deploy-d845cc945-r86f8   1/1     Running       0             11s     10.42.2.4   k8s3
```

Excellent! an HA cluster.

# More

Setting up MetalLB or an external Loadbalancer is not covered here. To go further I recommend this video: https://www.youtube.com/watch?v=UoOcLXfa8EU&t=1006s