---
categories: ephemeral github kubernetes k8s container docker azure AKS kind
date: "2024-08-21T00:00:00Z"
title: Self Hosted GitHub Kubernetes Action Runners - Revisited
draft: false
---

I wrote a post here last year about GitHub Action Runners. It was a tutorial on how how you can create Ephemeral Runners using a K8S cluster, and attach it to repos as a runner. Well, things have moved on. I tried to set this back up and struggled. There is now a new way, and it is called ARC (Action Runner Controllers). And it took longer to understand how things worked than i'd like to admit. So, how do we set this up now?

## Action Runner Controllers (ARCs) Setup

This video has the best in-depth knowledge of the whole thing: https://www.youtube.com/watch?v=_F5ocPrv6io

But, it is VERY comprehensive. And, it doesn't really quickly get to the point for most use-cases, which is to host runners in a Kubernetes cluster, and have those runners able to run a container image of our choosing.

So, without further ado, here is how to do it with a [KIND cluster](https://kind.sigs.k8s.io). Hopefully once you get this working, you can then use the other information to tweak it for your needs.


### Creating a KIND Cluster

You can use a 'real' cloud K8S clustter if you have one, but a simple way to start this is to just create a KIND K8S cluster on a VM. For a comprehensive guide please see this: [https://www.rootisgod.com/2021/Cheap-and-Accessible-Kubernetes-Clusters-with-KIND/](https://www.rootisgod.com/2021/Cheap-and-Accessible-Kubernetes-Clusters-with-KIND/)

Or, the quick version is here for Ubuntu 24.04.

Install some utils
```yaml
snap install docker --classic
snap install helm --classic
snap install kubectl --classic
```

Install Kind on the VM
```bash
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

We need to create one with the external IP exposed (if you want to manage it from an external machine)

So, create this file (replace IP with VM you are running KIND on) called ```github.yaml```

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k8s1         
networking:
  ipFamily: ipv4
  apiServerAddress: 192.168.1.45
  apiServerPort: 45001
```

Create the cluster like so

```bash
kind create cluster --name github --config github.yaml
```

We should now have our cluster created and our kubectl context set.

### Setup the ARC Components

With a cluster in place, we can now setup GitHub runners on it. We need two things. Firstly, a single runner scale-set controller (we only need one for the whole cluster), and then as many runners scale sets as we require.


#### Runner Scale Set Controller

First, the controller. Install it like so.

```bash
NAMESPACE="arc-systems"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

Check our things are installed with ```helm list -A```. This looks good.

```bash
  NAME            NAMESPACE     REVISION    STATUS      CHART                                   APP VERSION
  arc             arc-systems   1           deployed    gha-runner-scale-set-controller-0.9.3   0.9.3      
```



#### Runner Scale Set

Then, we can create a runner scale set. We can have many of these, and each should have a unique name. But lets just create one for now.

We need a couple of things first, our repo name/org to add our runners to, and a [https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens](Github Personal Access Token), with repo permissions. With those, we can set up a runner for our repo.

```bash
INSTALLATION_NAME="arc-runner-repo"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/iaingblack/arc-runner-repo"
GITHUB_PAT="ghp_your-secret-code-here"

helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    --set containerMode.type="dind" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

Now, the interesting part here is the line ```--set containerMode.type="dind"``` which sets up the ability to run a docker container inside the KIND cluster. Without this it fails. 

We should see it install with another ```helm list -A``` command

```bash
  NAME            NAMESPACE     REVISION    STATUS      CHART                                   APP VERSION
  arc             arc-systems   1           deployed    gha-runner-scale-set-controller-0.9.3   0.9.3      
  arc-runner-repo arc-runners   1           deployed    gha-runner-scale-set-0.9.3              0.9.3
```

Now check your Github repo, we have a runner!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2024/ARC-Runners/runner-registered.png"><img src="/assets/images/2024/ARC-Runners/runner-registered.png"></a>
{{< /rawhtml >}}

### GitHub Actions Test

Now, we need a Github action to test it works.

Create a file in your repo called ```.github/workflows/Test-ARC-Action.yml``` and use this content.

```yaml
name: Test ARC Action
on:
  workflow_dispatch:

jobs:
  Explore-GitHub-Actions:
    # You need to use the INSTALLATION_NAME from the previous step
    runs-on: arc-runner-repo
    container: debian:stable-slim
    steps:
    - run: echo "🎉 This job uses runner scale set runners!"
```

NOTE: The ```runs-on:``` must match the runner name we have setup for our repo. And, we have alos specified a debian container to run the job.

Run it with a manual dispatch.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2024/ARC-Runners/dispatch-trigger.png"><img src="/assets/images/2024/ARC-Runners/dispatch-trigger.png"></a>
{{< /rawhtml >}}

It should work!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2024/ARC-Runners/successful-job.png"><img src="/assets/images/2024/ARC-Runners/successful-job.png"></a>
{{< /rawhtml >}}

## More

There is more info here.It gets complicated quite quickly. But hopeully the above is useful as a minimum viable setup.

QUICKSTART GUIDE - [https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller)


EXAMPLE VALUES   - [https://raw.githubusercontent.com/actions/actions-runner-controller/master/charts/gha-runner-scale-set/values.yaml](https://raw.githubusercontent.com/actions/actions-runner-controller/master/charts/gha-runner-scale-set/values.yaml)
