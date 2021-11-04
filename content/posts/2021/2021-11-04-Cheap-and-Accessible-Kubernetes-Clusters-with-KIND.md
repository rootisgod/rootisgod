---
categories: linux docker kubernetes k8s kind microk8s cost
date: "2021-11-04T15:00:00Z"
title: Cheap and Accessible Kubernetes Clusters with KIND
draft: false
---

[I have a post about microk8s](https://www.rootisgod.com/2021/A-Quick-Guide-to-MicroK8S-And-Learning-Kubernetes/) and how it is an amazing way to get a working Kubernetes cluster going very quickly. And that is still very true. However, it has a small problem i've only just realised, you can only have a single cluster running on a machine. So, if you want a few independent clusters running on one machine, I think you are out of luck.

This is now a problem for me as my main use case for kubernetes is to test deployments using Octopus Deploy. Ideally, I should have multiple clusters so that I can simulate a 'real' pipeline of CI to PRD. In theory, I could use namespaces to seperate things out in a kind of artificial way (and still use microk8s), but i'd rather do it properly. 

The other issue is cost. Ideally we could use the cloud to create instances and test with those. But, the cloud is expensive. If we want a short lived cluster then fine, but sometimes you just kinda want some resources to be used when you want/need and not have to faff about. Even if using DigitalOcean or something, waiting a few minutes for a cluster can get very boring very quickly. If you are using AKS on Azure you can wait even longer, and pay even more... So, what can we do to get clusters quickly and easily?

# Enter KIND

## Overview 
KIND (Kubernetes in Docker - https://kind.sigs.k8s.io) is another option in the varied dev/desktop Kubernetes market. It seems slightly less feature rich than microk8s but it makes up for it in giving a nice simple setup experience for very little effort. And it has a few tricks up its sleeve. 

## Installation

We really only need two things, Docker installed on the host (left as an exercise to the reader!) and kubectl. The process to install KIND is almost identical to kubectl so let me just explain it at a high level;
- Download the binary file for KIND: ```curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64```
- Move it to the /usr/bin folder: ```sudo mv kind /usr/bin/kind```
- Run a ```sudo chmod +x /usr/bin/kind``` to make it executable

The URLS are below;

- KUBECTL: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux
- KIND: https://kind.sigs.k8s.io/docs/user/quick-start/


## Creating Clusters

The command to create a cluster, called ```k8s1```, is like this

```bash
kind create cluster --name k8s1
```

Then it goes off and creates a cluster.

```bash
Creating cluster "k8s1" ...
✓ Ensuring node image (kindest/node:v1.21.1) 🖼
✓ Preparing nodes 📦  
✓ Writing configuration 📜 
✓ Starting control-plane 🕹️ 
✓ Installing CNI 🔌 
✓ Installing StorageClass 💾 
Set kubectl context to "kind-k8s1"
You can now use your cluster with:

kubectl cluster-info --context kind-k8s1
```

Simple! We now have a working cluster.

NOTE: The kubernetes context name has ```kind-``` in front of OUR name. Just remember this...

Lets see what our context is just to be sure. 

```bash
kubectl config current-context

  kind-k8s1
```

And get some info about the API port used (more on this later).

```bash
kubectl cluster-info --context kind-k8s1

    Kubernetes control plane is running at https://127.0.0.1:42931
    CoreDNS is running at https://127.0.0.1:42931/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

If we make another cluster called ```k8s2``` (not shown), and we want to change contexts, this is how we do so with kubectl

```bash
kubectl config use-context kind-k8s2
```

Back to ```k8s1``` though, and now we need to make an admin user and get a token so we can do something useful, like connect to it.

## Creating an admin-user

Create a file called ```admin-user-serviceaccount.yaml```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
```

And create a file called ```admin-user-rbac.yaml```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
```

Then, we can write a script to setup an admin user on the current cluster in our context. Create a file called ```setup-admin-user.sh``` with the content below and then ```chmod +x setup-admin-user.sh``` and run the file. It will create the admin user and also give us a token as output, and write it to a file called token.txt

```bash
kubectl apply -f admin-user-serviceaccount.yaml
kubectl apply -f admin-user-rbac.yaml
echo '- - - - - - - - - - - - - - - - - - - - - - - - - -'
kubectl get -n kube-system secret $(kubectl get -n kube-system sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" | tee token.txt
echo
echo '- - - - - - - - - - - - - - - - - - - - - - - - - -'
```

Then, we can install a dashboard, and then proxy it. Create a file called ```dashboard-and-proxy.sh``` and then ```chmod +x dashboard-and-proxy.sh``` and run the file.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
kubectl proxy
```

Then go to: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/logins

Login with the token. Voila! We have a working dashboard and cluster. Create another cluster, change context and redo this as often as required.

## YAML File Defined Clusters

We have a fairly solid setup. But one thing that is a problem is that we cannot access the cluster remotely from another machine. Thus, it's kinda useless in a pipeline or remote build etc... If I want to have Octopus Deploy access this cluster, it currently cannot as it is listening on localhost and a random port (remember ```kubectl cluster-info --context kind-k8s1```.

If we want to override some parameters on cluster creation, we can. KIND has a kubernetes inspired YAML template format available to us (https://kind.sigs.k8s.io/docs/user/configuration/). This means we can create clusters to a known spec and set them up as we want. What a great feature! So let's delete our original ```k8s1``` cluster and recreate it from a YAML file. We will have the cluster exposed on the network with an IP address of the host. Let's just assume our host has an IP address of 192.168.1.45, and we'll set the cluster port number as 45001 (see what I did there?).

**NOTE:** The KIND team say not to expose a cluster outside your local dev machine, but as long as you aren't hosting this in a production scenario I can't really see the harm, but so you know - https://github.com/kubernetes-sigs/kind/issues/873

Delete our original cluster

```bash
kind delete cluster --name=k8s1
```

Then, create a file called ```k8s1.yaml```. In  this, we shall put in the following;

```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k8s1         
networking:
  ipFamily: ipv4
  apiServerAddress: 192.168.1.45
  apiServerPort: 45001
```

And then we shall create a cluster like so by referencing this file

```bash
kind create cluster --config=k8s1.yaml

    Creating cluster "k8s1" ...
    Set kubectl context to "kind-k8s1"
    You can now use your cluster with:
    kubectl cluster-info --context kind-k8s1
```

If we run the cluster info command we see it is now bound to the IP of the machine and the port we specified.

```bash
kubectl cluster-info --context kind-k8s1

    Kubernetes control plane is running at https://192.168.1.45:45001
    CoreDNS is running at https://192.168.1.45:45001/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

Now, rerun the commands from before to set an admin user. Check our context is k8s1, and then setup the admin user

```bash
kubectl config current-context

  k8s1

./setup-admin-user.sh

    serviceaccount/admin-user created
    clusterrolebinding.rbac.authorization.k8s.io/admin-user created
    - - - - - - - - - - - - - - - - - - - - - - - - - -
    eyJhbGciOiJSUzI1NiIs......X94j9w
    - - - - - - - - - - - - - - - - - - - - - - - - - -
```

Then, in Octopus, or wherever you setup the cluster, use that IP address, port, and token as the connection details and you are sorted! Octopus log from a connectivity test below.
```bash
Creating kubectl context to https://192.168.1.45:45001 (namespace default) using a Token 
kubectl version to test connectivity 
Client Version: v1.16.10 
Server Version: v1.21.1 
```

Now, rinse and repeat. We can add as many clusters from file definitions as we like. We give each a different name and port number, and we can have lots of Kubernetes clusters ready for testing. A simple script could even set them up for you and delete when finished. Put all this in source control for automation of a process and you can be even happier. The sky is the limit! Enjoy!
