---
categories: ephemeral github kubernetes k8s container docker azure AKS
date: "2023-02-04T08:00:00Z"
title: Creating Ephemeral Github Action Runners In A Kubernetes Cluster
draft: false
---

I recently had a challenge at work where developers required the ability to deploy an Azure environment, and run GitHub Action tests against it. The problem with that is, because we are in a corporate environment, we really really like to know the IP address the traffic is coming from so we can whitelist it. The GitHub Action runners hosted by GitHub fail this requirement because we would need a massive whitelist, and anyone running a GitHub Action could potentially access our infrastructure. No good.

The solution is to use a 'self-hosted' runner. That is essentially where you have your own machine, you install a GitHub Runner Agent on it, and whitelist only its IP. But, the problem with this is;
- A GitHub runner is attached to a specific repository. But, you can create a 'Shared' runner if you have Organisational Level admin access organisation level
- A corporation won't let you do things at the GitHub Organisation level (reasonably so). Using a 'Shared' runner is beyond most at a large organisation (and it would probably be massively oversubscribed with jobs)

So, we really need to create a github runner for every repository we need GitHub Actions on. This is porbably fine for a personal project or account, but, we all know that orgs create far more repos than you would think possible. So, creating and managing a runner per repo is exceedingly painful and inefficient if we need to create and register a VM for each repository.

We could improve that by using docker to create many runners on one VM. Problem solved! Yet, we then need a script or process to manage that. We need to make a Dockerfile/script, find the repo, name the runner, add it, recreate it every so often to 'refresh' it and clear out it's disk when many runs have completed etc etc... It's an improvement, but it still seems like a lot of overhead. But, what if we could go a level above an Os and Docker, and use a Kubernetes cluster (which can run docker containers!) to do almost all of this for us?

## K8S GitHub Runners

The solution is a project called the Actions Runner Controller: https://github.com/actions/actions-runner-controller

We can use a couple of helm charts to install the solution on our cluster and use a simple YAML definition to create and attach a Github Runner to our Github repositories on demand.

### PreReqs

I have tested the following on an Azure AKS cluster. Create one in anticipation, it can be low spec with a single node with a spec of 2 CPUs and 4GB RAM. Set your kubectl context to use it and then run these commands. Change the versions if there is a new one available, but this example works as of February 2023.

#### Cert Manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.11.0 --set installCRDs=true
```

#### Actions Runner Controller

Now, we can install the GitHub Action Runner in the cluster. The prereq for this is that you have a GitHub account and a PAT to pass to the controller so it can act on your behalf:  https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

Once we have those place, run this command and put in your PAT

```bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm upgrade --install --namespace actions-runner-system --create-namespace --set=authSecret.create=true --set=authSecret.github_token="REPLACE_YOUR_TOKEN_HERE" --wait actions-runner-controller actions-runner-controller/actions-runner-controller
```

We can then create a github runner for a specific repo by creating a file called something like 'k8s-runner.yaml' and applying it. Amend the 'repository' value to your own.

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

We should now have an agent in our Github repo! Check Settings --> Actions --> Runners. Amend the replica value to a higher number if you need more than one.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2023/Creating-Ephemeral-Github-Action-Runners-In-A-Kubernetes-Cluster/github-runner-created.png"><img src="/assets/images/2023/Creating-Ephemeral-Github-Action-Runners-In-A-Kubernetes-Cluster/github-runner-created.png"></a>
{{< /rawhtml >}}

Then, create a GitHub Action on your repo like this. The important part is the `runs-on: self-hosted` part. This will run a GitHub action, from your runner, on a container image, which is just basic Ubuntu in this example. The dream come true.

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

Each job run is an ephemeral agent. It will remove and create a new one on each run. Perfect!

## Octopus Deploy

To make this a more automated system, simply add your Kubernetes Cluster to Octopus Deploy and then target it with Runbook scripts like these. First create a variable called 'RepositoryName' that is set to promp for a value in an Octopus project, we will use that as our input. The create script will take a variable for the repository name and the delete agent runbook will remove it. Now anyone in your team can make an agent when required.



### Create a Runner (Deploy RAW Kubernetes YAML)

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: GitHubK8SRunner
spec:
  replicas: 1
  template:
    spec:
      repository: #{RepositoryName}
```

### Delete (Run a Kubectl CLI Script)

Choose to run a bash script like this.

```bash
cat << EOF > deployment.yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: ctops-env0-self-hosted-agent-github-runner
spec:
  replicas: 1
  template:
    spec:
      repository: #{Repository Name}
EOF

kubectl delete -f deployment.yaml
```
