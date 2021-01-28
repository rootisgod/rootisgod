---
layout: post
title:  "Automating Azure with Ansible"
date:   2021-01-28 18:00:00 +0100
categories: azure devops ansible automation windows
---

{% include all-header-includes.html %}
{% include all-footer-includes.html %}

This post will quite lengthy, but it will outline how to use Ansible to deploy and setup Windows machines on Azure and achieve the automation holy grail and have Infrastructure as Code.
I'll show an efficient way to setup the development and deployment environment on Windows, which isn't something you could easily do until relatively recently.

One question might be 'What is Ansible and why use it?'. The best answer I have is that Ansible is a simple but powerful way to get started with Configuration Management of Infrastructure, and it is also a very hot trend right now in lots of areas. Ansible is starting to really dominate the market. Terraform is also a contender but it is more difficult to use well in my opinion, and the state file concept causes a few headaches that ansible can simply circumvent. I won't go too deep into it, but with Ansible we essentially declare a resource and tell Ansible we would like it created. Be it a VM, a disk, a software package installed on a Windows machine, you name it, ansible can likely do it. Terraform can also do most of this but stops short of simple OS configuration capability and it likes to keep track of what is created in a state file and it really starts to get complicated when you get an error, or worse, you lose your original state file.

# What We Will Do

So, we will perform the following steps;

 - Setup Docker on a Windows VM
 - Install VS Code  
 - Create an Azure Account
 - Create an Azure Service Principal Account
 - Create an Ansible Docker Container in VSCode
 - Create our Ansible Playbook  
 - Make a Basic VM and deploy it...

## VM Setup

So, first thing is to get a Windows machine for developing on. As long as you are running a version of Windows 10 newer than 2018ish you should be fine.

### Setup Docker 

So, first thing is to setup Docker on your Windows machine. I'll not rewrite a guide which will go out of date, so follow this link, but you need virtualization enabled in your BIOS as well, so be sure to do that first.

[https://docs.docker.com/docker-for-windows/install/](https://docs.docker.com/docker-for-windows/install/)

### Install VS Code

Install the 'Stable' VS Code from here - [https://code.visualstudio.com](https://code.visualstudio.com)


## Setup a Github Account (Optional)

Now, optionally, setup a github account - [https://github.com](https://github.com)

It is optional, but you probably want to do this to track your code. This post is not a git tutorial as adding that in would complicate things too much. Feel free to do so yourself though.

## Azure

Now, we need an Azure account. If you have one then great, if not, see the next step.

### Create an Azure Account

We need an Azure account. Go here and sign up! Sorry, no instructions, I'm sure you will figure it out :)

[https://azure.microsoft.com/](https://azure.microsoft.com/)


## Create an Azure Service Principal Account

We now need a way for the Ansible Playbook we create later to authenticate as 'us', but in a way that Ansible can understand. The easiest way to do this is to create what is called a 'Service Principal'. It's like an API key with permissions. The key point is to NEVER EVER NEVER store the values for this in github in a public repo (or even a private one). It is essentially a way to access an account for free and have someone else foot the bill. Be careful if using github and pushing your code.

To get a 'Service Principal' login to your Azure Account at [https://portal.azure.com](https://portal.azure.com)

Then, go to the 'Azure Active Directory' resource and choose to create a 'New registration' (I had to blur some existing ones I have, your's will be empty).

![](../assets/images/2020/Automating-Azure-With-Ansible/005.png)

Call it something sensible like 'Ansible-Automation' and click 'Register'.

![](../assets/images/2020/Automating-Azure-With-Ansible/010.png)

Now, we will have a 'Service Principal' created. Note down the 3 items highlighted (not in a file Git tracks!).

![](../assets/images/2020/Automating-Azure-With-Ansible/015.png)

Then, click 'Certificates & secrets' and choose 'New client secret' and add a name and a duration (a year is recommended just so you never ever forget it exists, choose never expires with caution!)

![](../assets/images/2020/Automating-Azure-With-Ansible/020.png)

Then, you get one chance to record the secret, so click the little clipboard icon and copy/paste somewhere and save it (again, definitely not in git!)

![](../assets/images/2020/Automating-Azure-With-Ansible/025.png)

The Service Principal is now created, but it has no permissions. Let's give it 'Contributor' access to the subscription. Contributor is a powerful level of access which allows the creation of any resource, but not the ability to change permissions in Azure. It's about as good as it gets for someone to create resources though, so again, keep all this information secret and out of git ;)

Go to your subscription and choose 'Access Control (IAM)' and click 'Add'.

![](../assets/images/2020/Automating-Azure-With-Ansible/030.png)

Then add our 'Service Principal' and give it a 'Contributor' role as explained above. Hit save, and we are done! 

![](../assets/images/2020/Automating-Azure-With-Ansible/035.png)

Just make sure you have all 4 pieces of information handy about the 'Service Principal' handy from earlier;

- Tenant ID
- Application (Client ID)
- Object ID
- Secret

## Docker and VSCode

Now we are at a point where we can start to look at what we need to do next to create our Ansible environment. The first thing we need to do is create a 'dockerfile' which has the ansible setup we need to deploy to Azure. So, let's do that. 

### VSCode Setup

We also need some extensions for VSCode, but not many! Load VSCode and find and install these;

TODO

### Create our Ansible dockerfile

## Create an Ansible Docker Container in VSCode



- Create our Ansible Playbook
- Make a Basic VM and deploy it...
