---
categories: ephemeral github kubernetes k8s container docker azure AKS
date: "2023-02-04T08:00:00Z"
title: Creating Ephemeral Github Action Runners In A Kubernetes Cluster
draft: false
---

I recently had a challenge at work where I had to allow developers to deploy a functioning Azure environment, but also allow them to access the environment from GitHub Actions. The problem in a corporate environment is that we really really really like to know the IP address you are coming from, and whitelist that. The GitHub Action runners hosted by GitHub fail this requirement. The solution is to use a 'self-hosted' runner that you can create and know the IP address used. The problem is that in general;
 - A corporation won't let you do things at the GitHub Organisation level (resonably so)
 - A GitHub runner that can listen for jobs for multiple repos is set at the per repo level 
 
Given that, you really need a github runner per repo, where you have admin/owner access as the developer.

But, we all know that orgs create far more repos than you would think possible. So, while self-hosted runners are great, creating and managing a runner per repo is exceedingly painful and inefficient.

The ideal solution is to use docker to create a runner as required. We could have one VM that could run multiple containers as runners. Problem solved! Yet, we then need a script or process to manage that. It's an improvement, but it still seems like we need a process and scripts to manage that. We have more efficency, but the management piece hasn't got too far forward. But, what if we could go a level above that and use a Kubernetes cluster (which can run docker containers!) to do almost all of this for us?

The project is called [Github Actions Runner Controller](https://github.com/actions/actions-runner-controller) aims to solve this problem. We can use a couple of helm charts to allow us to create a YAML definition that would create and attach a Github Runner to our Github repositories on demand.

## PreReqs

I have tested the following on an Azure AKS cluster. Create one in anticpation, it can be nothing fancy and the defaults are fine, just set your contect to use it.

Then run these commands. Change the versions if there is a new one available, but this example works as of February 2023.

```yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.11.0 --set installCRDs=true
```

Afterwards, we should have the ability to create a GitHub Runner. The prereq for this is that you have a GitHub account and a PAT [https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token](Creating A Personal Account Token).

Once we have those place, run this command and put in your PAT

```azure
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm upgrade --install --namespace actions-runner-system --create-namespace --set=authSecret.create=true --set=authSecret.github_token="REPLACE_YOUR_TOKEN_HERE" --wait actions-runner-controller actions-runner-controller/actions-runner-controller
```

It should succeed (if not add quay.io to your corporate firewall!)

We can then create a github runner for a specific repo by creating a file called 'k8s-runner.yaml' and applying it. Amend the 'repository' value to your own.

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: GitHubK8SRunner
spec:
  replicas: 1
  template:
    spec:
      repository: iaingblack/GithubRunner
```

Run that with `kubectl apply -f k8s-runner.yaml`, and voila!

We should now have an agent in our Github repo!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2023/Creating-Ephemeral-Github-Action-Runners-In-A-Kubernetes-Cluster/github-runner-created.png"><img src="/assets/images/2023/Creating-Ephemeral-Github-Action-Runners-In-A-Kubernetes-Cluster/github-runner-created.png"></a>
{{< /rawhtml >}}

Amend your GitHub Actions like so. The important part is the `runs-on: self-hosted` part. This will run a GitHub action, from your runner, on a container image. The dream come true. 

```yaml
name: Test-Job

on:
  workflow_dispatch:

jobs:
  test-job:
    runs-on: self-hosted
    container:
      image: ubuntu:22.04
    steps:
      - name: Show OS
        run: cat /etc/os-release
```

Each job run is an ephemeral agent. It will renew on each run. To create more agents in case of many long running jobs being active, simply adjust the replica value.