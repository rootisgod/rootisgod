---
categories: terraform cloud infrastructure provisioning gitops
date: "2022-08-12T12:30:00Z"
title: Terraform and Multiple DRY Environments
draft: true
---

Describe the setup for versioned modules, a central deployment repo, and a repo with tfvar files.

Make a nice diagram...

## Terraform for teh win!

We have decided at work that we would like to use Terraform going forward. It's at v1.x (finally), and it seems like the rate of change has stopped. It's no exaggeration to say that the changes have been a bit bumpy along the way, and that was just with causal use.

We have been using Ansible until now, and it has been pretty great, but it's shortcomings are becoming clearer.

- If you re-run a playbook, there are no warnings of changes until they have happened. But Terraform can show what's happening before it makes a change.
- No drift detection is possible. We can do this in Terraform.
- Code reuse seems to be very difficult. We tend to keep rewriting the same wheel. Hopefully Terraform Modules can help here.
- Generally, the complexity can spiral as you build out a code base. Terraform Modules should hopefully keep things abstract enough that you can reason about things.
- The testing tools available aren't quite as native as the ones for Terraform, and can be complicated to implement (or I was really pushing Molecule in a direction it wasn't designed for, likely the latter!).
- Just generally, while Ansible is a great tool for configuration, and can be used for infrastructure, we feel that something specially designed for that job seems a smarter bet going forward. And the knowledge and support for a proper CI/CD pipeline should be more readily available.
- Terraform should have a smaller learning curve. Terraform is quite a bit more rigid than Ansible, and so we hope it leads to cleaner code. I think the days of using 0's ans 1's in Terraform for if/else decisions are over!
- Terraform also allows an insight into the wider Hashicorp world if we wish.

But that's not to say Terraform is all milk and honey. The state file aspect of it scares the crap out of it me. Hopefully we never get boxed into a corner fighting it.

## Initial Challenges

The main point of this post is to show how we are trying to build up a way that allows our (small) team to standardise on deployments. The number one issue most people find when they start using Terraform is that you can't easily create multiple environments without duplicating code. You'll go mad looking on youtube for videos about this. The solution seems to be Terragrunt, but that seems overkill (although I may be proven wrong). So, this post will explain the architecture we have come up with.

The main goal is to have environments represented individually and without duplication of code. And if you have used Terrafrom, you’ll know that generally you can create a folder per environment and place a main.tf file and a tfvars file to represent and environment. The issue with this is that you have to create a main.tf file and tfvars for every environment, and keep them consistent. It’s messy. If we only had out tfvars ‘answer file’ things could be manageable. And that’s what we will try and do. 









