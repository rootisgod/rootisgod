---
categories: linux docker microk8s kubernetes k8s ubuntu jenkins
date: "2021-08-04T21:05:00Z"
title: A Quick Guide to MicroK8S And Learning Kubernetes
---

I spent far too long trying to find a simple way to learn Kubernetes. I spun up Kubernetes clusters in Azure (expensive!), Docker for Windows (argggh. what's going on!) and various other things. And, for some reason, I finally stumbled on `microk8s` from Canonical. Before finding it, I was doing various searches in this space and learned about a whole ecosystem of solutions, including K3S, minikube, KIND, K0S, and probably many more! Perhaps I will do a comparison as a future blog post. But, I settled on microk8s for now as it has lots of features, seems idiot proof, works on Mac, Windows and Linux, and just seems to be ideal. So, lets get it going and install Jenkins as a test. If you haven't used Kubernetes before then maybe give this a read first [https://kubernetes.io/docs/tutorials/kubernetes-basics/](https://kubernetes.io/docs/tutorials/kubernetes-basics/). At the end of it you should have a cluster you can use to do something pretty real-world. This is just the tip of the iceberg, but it will hopefully get you going very very quickly.

# What is microk8s?

It is pretty much a kubernetes managed cluster in a command line. As you start learning Kubernetes you realise that command line and YAML files are king. So, this is actually a fairly good win, you get experience doing things quickly and simply, but also in a realistic manner so that you can take that muscle memory to a 'real' cluster. What kind of tools do you get then? Well...

```bash
rootisgod@kubernetes:~$ microk8s --help
Available subcommands are:
        add-node
        cilium
        config
        ctr
        dashboard-proxy
        dbctl
        disable
        enable
        helm3
        helm
        istioctl
        join
        juju
        kubectl
        leave
        linkerd
        refresh-certs
        remove-node
        reset
        start
        status
        stop
        inspect
```

OMG! If you have used Kubernetes in any capacity previously, you read this and start to have palpitations. It looks like we have a simple way to add nodes, get a dashboard going, install istio/linkerd service meshes, reset the cluster, and just generally do anything with a command or two. Fantastic!

And, if you run `microk8s status` you can see we can enable LOTS of addons with a simple command. Traefik, Kubeflow etc etc.. Finally you can try out all these buzzwords in a simple way!

See here for more info on each - https://microk8s.io/docs/addons

```bash
rootisgod@kubernetes:~$ microk8s status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # The Kubernetes dashboard
    ha-cluster           # Configure high availability on the current node
    metrics-server       # K8s Metrics Server for API access to service metrics
  disabled:
    ambassador           # Ambassador API Gateway and Ingress
    cilium               # SDN, fast with full network policy
    dns                  # CoreDNS
    fluentd              # Elasticsearch-Fluentd-Kibana logging and monitoring
    gpu                  # Automatic enablement of Nvidia CUDA
    helm                 # Helm 2 - the package manager for Kubernetes
    helm3                # Helm 3 - Kubernetes package manager
    host-access          # Allow Pods connecting to Host services smoothly
    ingress              # Ingress controller for external access
    istio                # Core Istio service mesh services
    jaeger               # Kubernetes Jaeger operator with its simple config
    keda                 # Kubernetes-based Event Driven Autoscaling
    knative              # The Knative framework on Kubernetes.
    kubeflow             # Kubeflow for easy ML deployments
    linkerd              # Linkerd is a service mesh for Kubernetes and other frameworks
    metallb              # Loadbalancer for your Kubernetes cluster
    multus               # Multus CNI enables attaching multiple network interfaces to pods
    openebs              # OpenEBS is the open-source storage solution for Kubernetes
    openfaas             # openfaas serverless framework
    portainer            # Portainer UI for your Kubernetes cluster
    prometheus           # Prometheus operator for monitoring and logging
    rbac                 # Role-Based Access Control for authorisation
    registry             # Private image registry exposed on localhost:32000
    storage              # Storage class; allocates storage from host directory
    traefik              # traefik Ingress controller for external access
```

So, let's get it installed.

# Installation

Install Ubuntu 20.04 Desktop Edition in whatever way you please. I recommend the Desktop version as it makes interacting with the cluster simpler for beginners. You can also install microk8s on Windows, so if you want to try that, please feel free, though it requires Hyper-V/Virtualbox so you need to get those going first. Just give it a google for the Windows installer version.

microk8s is installed via a snap. Run this at a cmd line to get the latest stable release.

```bash
sudo apt update
sudo snap install microk8s --classic
```

## Running Without 'sudo'

To get permissions to do anything useful without using sudo or being root, we have to run this to add ourselves to the microk8s group.

```bash
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
newgrp microk8s
```

## Cluster Creation

Okay, we can now get to business. We obviously want to create a cluster. So, just to blank anything I have I will reset the cluster with

```bash
microk8s reset
```

It will take a while and do crazy things, but just leave it until it is finished. Then, type this to start the cluster (if it is not already started)

```bash
microk8s start
```

The, lets check it's status. It will show what is enabled and disabled on the cluster.

```bash
microk8s status
```

Output below

```
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    ha-cluster           # Configure high availability on the current node
  disabled:
    ambassador           # Ambassador API Gateway and Ingress
    cilium               # SDN, fast with full network policy
...
```

Okay, so, running, but nothing seems enabled. There are a few things we will want to re-enable. In particular, CoreDNS, the Kubernetes Dashboard and Persistent Volume Storage for starters. DNS helps us in general find things and is recommended in every install. The Kubernetes Dashboard can be used to access the cluster via a WEB UI and is very useful. Storage ensures that deployments that require PersistentVolumeClaims (think of as a Docker volume) can get some disk space. With those we are pretty much good to go. So type this to get those enabled

```bash
microk8s enable dns dashboard storage
```

### Kubernetes Dashboard Access

Lets check if the Dashboard is available. Run the `microk8s dashboard-proxy` command which will forward the ports of the pod it is running on and let us access it from our machine.

```bash
microk8s dashboard-proxy
```

```
Checking if Dashboard is running.
Dashboard will be available at https://172.31.60.120:10443
Use the following token to login:
eyJhbGciOiJSUzI1NiIsImtpZCI6IjAzRHJzeFZyZ05PQVk2dWx6UlV4amo3SkUzU1kxSWphVXZScXFsOWkxM2MifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZWZhdWx0LXRva2VuLXJ6Zjl6Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImRlZmF1bHQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI3YTYxM2RmMi1hMzNjLTRjMGQtODBlMC1iNGJmYTBlMzY5ZDMiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06ZGVmYXVsdCJ9.f8icfpiLseZvhpQzIqw2vm8Kq5Xi1j1uExv7HqqsC-U0oIpyJt2DVmSMoFN1yJrmbp9OgbqdEo3a9RsSTof7E9NMppsPI6Qap5nVDqkgkPxndGtDRGB0rvLkq0PjduYEKpaO_VaVu2CdQaYoEkzYadepTCNNUHz_AgWVM7pDmHkNscT58jOPxjDPLLtZfyv0uhKa8olrrGqhZQMymxr91UfvuadYCHOCMY5OySEwZXkvaXVEb1muRQTGGzXDaMh__610-r7K5PWaPW2aSd58l3PGmnEVFYI0eDxDJ01ksVScPXShDjVGDT99tqBes13T1qkQIGI3-W88dA28UlWIAw
Forwarding from 0.0.0.0:10443 -> 8443
```

Once the dashboard starts, it may take quite a few seconds, access it the provided link in the output. Enter the token it spits out to authenticate on the page. Voila!

### Installing Something With Helm3

Let's enable helm3 support (avoid helm 2 as it is old) to unlock access to a wealth of pre-made application. Helm is kinda like the docker-compose of kubernetes, and makes complicated installations much simpler, at the cost of not quite having full control of the setup (which spooks me out a bit I must admit). If you are interested, have a google to see what they are made up of, it's pretty much a bunch of YAML templates files with variables, and they get complex quickly!

So enable, helm3 as follows. Simple!

```bash
microk8s enable helm3
```

#### Jenkins helm3 Installation

Let's install everyone's favourite (free) CICD tool! Add the official Jenkins helm repo, search for jenkins, and install to the cluster.

```bash
microk8s helm3 repo add jenkins https://charts.jenkins.io
microk8s helm3 repo update
microk8s helm3 search repo jenkins
```

```
NAME            CHART VERSION   APP VERSION     DESCRIPTION
jenkins/jenkins 3.5.9           2.289.3         Jenkins - Build great things at any scale! The ...
```

This will show us that the jenkins chart is called `jenkins/jenkins`. We will install it. But, first notice that the command is like this. So we are installing it as an app release called `jenkins`, from chart `jenkins/jenkins`.

```
Usage:  helm install [NAME] [CHART] [flags]
```

Install like this

```bash
microk8s helm3 install jenkins jenkins/jenkins
```

Then, access via the handy information it will provide after installation. Get the admin password, and then proxy the website out to our local machine

```bash
microk8s kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password
microk8s kubectl --namespace default port-forward svc/jenkins 8080:8080
...
Forwarding from 127.0.0.1:8080 -> 8080
...
```

Login at http://127.0.0.1:8080

Super!

There is more to it than this, but have a look at the dashboard, look at the various things running, like an agent waiting to be added to the node pool...

## Kubeconfig

If you want or need a kubeconfig file for another application that can talk to a Kubernetes Cluster (like https://k8slens.dev/), simply type

```bash
microk8s config > microk8s.kubeconfig
```

Done! Or, if you just need a token again, run

```bash
microk8s config | grep token
```

## Reset!

If you want to go back to square one just run the reset command again. Local development is dead easy, you could even script everything to get a rudimentary local pipeline going. The possibilities are endless. Have fun!

# Next Steps

Realistically this is a bare minimum setup just to show how easy it can be. From here you can go in almost any direction in kubernetes land. But, how hard was it to setup? Not hard at all! Go read the official docs and learn more, it's a deep subject becoming a must-have on a CV. Have fun!
