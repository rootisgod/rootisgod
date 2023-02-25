---
categories: octopus github actions kubernetes k8s azure devops
date: "2023-02-24T08:00:00Z"
title: Using Github Actions to Build and Octopus to Deploy
draft: false
---

This post will be about how to use Github Actions and Octopus Deploy to create CICD pipeline which will deploy to an Azure webapp. The reason for the post is for me to just have a bsic pipeline I can amend in the future, but also just to show how I do a bit of a DevOps style deployment. First a bit about both parts of the solution. 

### Github Actions

Github Actions is something Github introdiced a couple years ago, and it's changed how people build software. You used to have to use Jenkins or Teamcity in order to pull your code, do a build, store an artifact and then shove that over to the Ops Team. With Github Actions, the source code itself is the trigger to an automated deployment, and the definition for this is WITH the code. This proves very powerful. Previously, many companies had their code stored locally on an SVN or Gitlab style machine, and frankly, that meant the code was trapped. Because Github is SaaS, we can integrate with many other solutions in very interesting ways. It's fair to say that none of this was impossible was before, but it was a lot of management effort.

### Octopus Deploy

At the Ops side, once the devs have created a piece of software, and it is ready to be made 'live', the Ops team generally have something to install. Now, on a personal note, this is one of the most maddening topics around. Many many articles and discussions just say 'and then deploy it' and leave it at that. No! What if we have 5 environments (CI, Dev, Staging, UAT and PROD?). What if users want a custom environment created just for their own purposes? What about access rights to deploy etc etc... Well, Octopus Deploy solves all these problems, and frankly, im not sure why it isn't talked about more. Perhaps Jenkins is solving this for many people, but the ability to have a dashboard and actual clarity as to what is deplyed where is at least 50% of managing software release, so for me, it is essential. Note, I will be using Octopus Cloud to do this, it will simplifya lot of what I am trying to show. You can get the software and install it with a free licence for testing, or you can use a cloud instance. 

## Creating an Application and Deploying

We can now talk about what we are going to do;
- Install .Net framework on a local machine
- Create an App Service Plan and 3 web apps in Azure
- Use Github Actions to build our app
- Use Octopus Deploy to handle the deployment to these environments

# PreReqs

### Azure Web Apps

So, hopefully you have an Azure account as we are going to deploy our app to a webapp to keep things simple... If not, sign up. Now, as an aside, you dont have to deploy the app to an Azure app service, the example works for any type of [deployment target that Octopus Deploy supports](https://octopus.com/docs/infrastructure/deployment-targets), so feel free to just read along if you don't have Azure. 

#### Azure CLI 

We need the azure cli for this (2.45.0 at time of writing), so install from here (Or direct [latest](https://aka.ms/installazurecliwindows)) 
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli 

Once installed, login like so

```powershell
az login
```

#### Creating Webapps

Then, we can create our CICD webapps. This will use the .Net runtime later so we spercify this now
```
az group create -l northeurope -n RootIsGod-CICD
az appservice plan create -g RootIsGod-CICD -n RootIsGod-CICD-AppService-Plan --sku FREE
az webapp create -g RootIsGod-CICD -p RootIsGod-CICD-AppService-Plan --runtime "dotnet:6" -n RootIsGod-CI
az webapp create -g RootIsGod-CICD -p RootIsGod-CICD-AppService-Plan --runtime "dotnet:6" -n RootIsGod-STA
az webapp create -g RootIsGod-CICD -p RootIsGod-CICD-AppService-Plan --runtime "dotnet:6" -n RootIsGod-PRD

```

We have our hosting ready to use. We need an application now.

### .Net SDK

Install the .Net SDK on a machine. Choose the ASP.NET 'Hosting Bundle': https://dotnet.microsoft.com/en-us/download/dotnet/6.0

Go to a generic location on our machine and to create a simple webapp using .Net Core. It will create this in a directory of the same name.

```bash
dotnet new web --name RootIsGod-CICD
```

### Github

Create a new repo in Github. CHoose to NOT initalise it with a Readme file, and then run this on our code folder.

```bash
git init
git add *
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/rootisgod/RootIsGod-CICD.git
git push -u origin main
```

Our code is now in github (I know we probably need an ignore file but bear with me)

### Octopus Deploy 

Get an instance of Octopus Cloud setup here: https://octopus.com/pricing/overview 

Once you are logged in you will see our interface. 

The first thing I always do is create a new space. This paritions our project into it's own virtual instance inside Octopus. You can have many projects inside a single Octopus Deploy, but there is a risk of seeing many other projects alongside yours, other projects seeing your resources, or a wrong permission granting access somewhere it shouldn't. A space mitigates almost all of this and is nearly as good a dedicated instance.

So we will create a new Space called Rootisgod-CICD and switch to it

