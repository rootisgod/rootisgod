---
categories: chocolatey windows nuget
date: "2025-02-23T00:00:00Z"
title: Running a Private Chocolatey Server
draft: false
---

I have pretty bad internet, around 4MB/s, and also a Sky Glass TV. Guess what happens when I pull some Docker images, no TV! Instead, I have to tweak the docker host I am using have to pull images in a single threaded manner. And then if I have multiple hosts, or i'm trying out a new Kubernetes cluster things get annoying even quicker. It just gets annoying and frustrating.

The solution, is some kind of local proxy. So, taking inspiration from using Sonatype Nexus to be a Chocolatey Nuget server, I thought I would try and do the same thing for Docker Images. There seems to be only one person discussing how to do this (https://www.youtube.com/watch?v=dpWxWr90MGI&t=20s). So, shout out to them, this is just my contribution to doing this as a blog post so more people might find it easily, and i'll just cover setting up Docker and Kubernetes to use the internal proxy.



