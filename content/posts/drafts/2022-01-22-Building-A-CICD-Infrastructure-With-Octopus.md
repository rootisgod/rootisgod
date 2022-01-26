---
categories: linux docker kind kubernetes k8s ubuntu jenkins octopusdeploy cicd
date: "2022-01-22T15:50:00Z"
title: Building a CICD Infrastructure With Octopus and KIND
draft: true
---


Building on my previous post, I thought I would show how you can build out and manage a working CICD infrastructure with Octopus Deploy. The benefit of Using octopus Deploy is that it will make things very easy and visible.

- Create a Linux VM (mention Linode!)
- Make a GitHub Repo
- Install Docker and Docker Compose
- Make a Runbook step to install KIND, helm etc...
- Show IAC for the projects
- Use Github packages to deploy

Show how running can ask for a variable name and then deploy that.

## Octopus Deploy Server

Install docker compose 

```
apt update -y && apt upgrade -y
snap install docker
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

There is a blog post (https://octopus.com/blog/octopus-deploy-on-docker) by Octopus on this, but it doesn't include any bind mounts. That means when the container is destroyed, so is your data!!! So let's fix that.
https://hub.docker.com/r/octopusdeploy/octopusdeploy/#!


Install git too
```
apt install git
```

Grab these two files

https://github.com/iaingblack/octopud-deploy-k8s-cicd/tree/master/octopus-deploy-docker-compose

Amend the .env file and add passwords. Make sure the DB password matches the connection string!


Could be useful: https://octopus.com/blog/docker-compose
