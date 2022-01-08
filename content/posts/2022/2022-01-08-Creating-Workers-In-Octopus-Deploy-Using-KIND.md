---
categories: linux docker kubernetes k8s kind octopusdeploy
date: "2022-01-08T09:00:00Z"
title: Creating Workers In Octopus Deploy Using KIND to Create Local K8S Clusters
draft: true
---

Nice title, eh? This post will discuss how to setup Octopus Deploy with Worker agents created from a KIND Kubernetes cluster running on a Linux box setup as an Octopus Listening Tentacle. Simple, eh? So, the reason for doing this is to try and cram as much possible into a single machine. With a single Linux host we can have many worker agents instead of a multiple Linux hosts for each one, and that means many different projects can 'reuse' that one machine.

Let me just start by saying that i've used Octopus Deploy for many years and always loved it for deploying software to different environments. But, recently, they have started to really get to a place where I think it can handle almost any situation and I would recommend it as a one-stop shop for doing many different tasks. It can likely replace Rundeck and Jenkins, and do so in a more efficient, and importantly, visible way, than almost anything else I have seen. Teams can work together with confidence and that is a large driver in why I think it is so valuable. If you can afford it!

Having said that, one of the relatively new features in Octopus that I think is a complete gamechanger is the ability to run steps from a docker container. This simple addition means you can have a container decked out with all the tools you need to do a terraform/ansible/whatever deployment and no longer have to worry about the worker agent having the software available or installed. This is fantastic. That feature turns a single worker can handle an almost unlimited set of scenarios. See here for more info: https://octopus.com/blog/workers-explained#customized-software

The main problem is that while workers now run containers and will run multiple tasks at once, they can start to block each other and so one worker for everyone to share probably doesn't cut it, except for small environments. If only we could have dynamic workers that would start and stop when required, much like Octopus Cloud (https://octopus.com/docs/infrastructure/workers/dynamic-worker-pools). Well, I don't think we can have that in an Octopus Server which is self-hosted. There is a blog post on running workers on a Kubernetes Cluster here (https://octopus.com/blog/kubernetes-workers) and that is a great way to get that kind of behaviour. But, as always their is a downside, and in case it is that K8S clusters tend to be;
- Expensive to run
- Outside of the host network where the Octopus Deploy Server VM is (im sure you could do VNET peers and things, but again, the cost in Azure/AWS is not trivial)
- Can be a real pain to configure and permission

In my particular use case I would much prefer to host the Octopus Server as a VM and then take advantage of hosting workers in a K8s cluster that is as local as possible. So, finally i'll get to the point, this post will show how to use [KIND](https://www.rootisgod.com/2021/Cheap-and-Accessible-Kubernetes-Clusters-with-KIND/) to host multiple clusters on a single Linux host and create workers from them.

So, some pre-reqs are
- A Octopus Deploy Server running on a local VM
- Setup a single Linux Agent in Octopus with Docker Installed
- Install KIND on it
- Register the Cluster in Octopus Deploy
- Do this: https://octopus.com/blog/kubernetes-workers

Profit!

Some of this will be a bit rough and hard coded, I leave it to the reader to make it work for their environment, this is just a blast through the basic setup.

## Octopus Deploy Setup

Have a server ready to go with Octopus Deploy. Simple.

## Linux Agent

We need a linux machine with Docker installed. In this example I have Ubuntu with Docker installed. I wont explain this as it would take up time and be worse than the official instructions. Follow this and choose the default options for the tentacle: https://octopus.com/docs/infrastructure/deployment-targets/linux/tentacle#installing-and-configuring-linux-tentacle

Then register it into Octopus as a WORKER (again, if you use Octopus you should know how to do this: Infrastructure -> Workers -> Add Worker -> Linux -> Listening Tentacle)

## KIND

### Install

Install KIND like so on this agent

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
sudo mv kind /usr/bin/kind
sudo chmod +x /usr/bin/kind
```

We also need Kubectl

```
sudo snap install kubectl --classic
```


### Create Cluster

Create a file like this called ```workers.yaml``` and put in the IP of your linux agent

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: workers
networking:
  ipFamily: ipv4
  apiServerAddress: 192.168.1.70
  apiServerPort: 45001
```

Then create it like so

```
kind create cluster --config=workers.yaml
```

Then set permissions and get a token for later (see this blog post and section 'Creating an Admin User': https://www.rootisgod.com/2021/Cheap-and-Accessible-Kubernetes-Clusters-with-KIND/)

We can now add it to Octopus Deploy as a Kubernetes Cluster

## Octopus Deploy

### Add Cluster to Octopus

Create an Account with our Token for the KIND cluster in it. We will reference this later: Infrastructure -> Accounts -> Add Account -> Token

Then add a Kubernetes Cluster: Infrastructure -> Deployment Target -> Add Deployment Target -> Kubernetes Cluster -> Listening Tentacle

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/010-Kubernetes-Cluster.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/010-Kubernetes-Cluster.png"></a>
{{< /rawhtml >}}

The health check should pass.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/020-Kubernetes-Cluster-Health-Check.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/020-Kubernetes-Cluster-Health-Check.png"></a>
{{< /rawhtml >}}

### Add Polling Workers

This is where this comes in: https://octopus.com/blog/kubernetes-workers

Be sure to have an API key ready first though. 

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/030-Create-API-Key.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/030-Create-API-Key.png"></a>
{{< /rawhtml >}}

Follow these exact steps, but also choose 'Privileged Mode'!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/040-Kubernetes-Deployment-Priviliged-Mode.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/040-Kubernetes-Deployment-Priviliged-Mode.png"></a>
{{< /rawhtml >}}

Once the Runbook finishes, you should have some new workers!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/050-Runbook-Output.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/050-Runbook-Output.png"></a>
{{< /rawhtml >}}

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/060-New-Workers.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/060-New-Workers.png"></a>
{{< /rawhtml >}}

### Test Run

Then, do a test deployment in a project using that worker pool. Note you can use any container you want, I just used the Octopus Deploy worker to show a 'real-world' image being pulled and used.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/070-Worker-Test-Run.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/070-Worker-Test-Run.png"></a>
{{< /rawhtml >}}


{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/080-Container-Being-Pulled-From-KIND-Workers-Pool-Worker.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/080-Container-Being-Pulled-From-KIND-Workers-Pool-Worker.png></a>
{{< /rawhtml >}}

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/090-It-Ran.png"><img src="/assets/images/2022//assets/images/2022/Creating-Workers-In-Octopus-Deploy-Using-KIND/090-It-Ran.png"></a>
{{< /rawhtml >}}

OTHER NOTES
- I initially did this to also get around a feature of Spaces in Octopus Deploy. Spaces allow a complete segregation of different projects. Each space is almost like a seperate Octopus Deploy instance. This is great but it also means you cannot use a shared pool of workers. By creating a KIND cluster for each space and running the code to add the workers, you can very easily have workers in each space.
- If you run Octopus Deploy on a Linux server you could potentially have everything described running from a single machine!