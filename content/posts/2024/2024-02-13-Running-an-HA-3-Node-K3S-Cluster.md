---
categories: k8s k3s homelab kubernetes
date: "2024-02-13T08:00:00Z"
title: Running an HA 3 Node K3S Cluster
draft: false
---

Have some kubernetes experience and want to know how to create a 3 node K3S cluster at home? Read on...

# Motivaition

I recently decided to run a kubernetes cluster at home using real hardware as part of study for the CKA exam. So I bought 3 miniPCs that have 4 CPUs, 16GB RAM and 500GB NVMe. Overkill? Maybe. But, I really wanted to do it on real hardware and 'care' about the machines and the applications. Doing that in a VM just doesn't have that same skin the in game feel. So, here are some instructions on how to do set it up. It's not difficult, but thought worth sharing as it's a bit of a tough google.

# Setup and K3S Installation

Get 3 'machines' (VMs are fine for testing
 
- Install Ubuntu 22.04 on each one, k8s1, k8s2 and k8s3. Ensure they have network connectivity and can resolve each other's names.
- Install k3s as control and workers (mostly from https://docs.k3s.io/datastore/ha-embedded)

```bash
# k8s1
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --disable traefik" K3S_TOKEN=k3stoken sh -s - server --cluster-init

# Run on k8s2 and k8s3
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --disable traefik" K3S_TOKEN=k3stoken sh -s - server --server https://k8s1:6443

# Will show all our nodes
kubectl get nodes

# Get kubectl token from k8s1, use in your kubecontext (or lens, k9s etc...)  to see the cluster as one entity
cat /etc/rancher/k3s/k3s.yaml

# Run a test deployment then turn off the node and wait 5 minutes
kubectl create deployment nginx-deploy --image=nginx --replicas=1

# Get the node the pod was scheduled on
kubectl get pods -o wide

# Turn off the node that got the pod scheduled

# The pod will move! to another node!
kubectl get pods -o wide
```

Setting up MetalLB or an external Loadbalancer is not covered here, but you now have a 3 node k3s cluster that is fault tolerant. Enjoy!