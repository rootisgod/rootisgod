---
categories: terraform opentofu git azure gitops 
date: "2024-11-19T00:00:00Z"
title: Using Taskfile to Deploy Terraform Environments in Azure
draft: false
---

Ever deploy Azure environments with Terraform and get sick of having to remember all the various variables you need to export to make it work? Especially if you have multiple subscriptions? Well, worry no more. We can use Taskfile to make things easier. It's like a make file we can use to create some logic.


## The Basics

To deploy infrastructure to Azure with Terraform and a Service Principal, and a blob backend, you have to setup quite a lot of export variables. Something like this;

```bash
export ARM_SUBSCRIPTION_ID=b2430365-30d6-4825-a19c-a3250fa7a2ea
export ARM_CLIENT_ID=470a4b4a-1017-4708-b968-e66e376467a8
export ARM_TENANT_ID=3623e59e-4084-4db8-b1c2-3c4ef454e21a
export ARM_CLIENT_SECRET=Add_Secret_Here
export ARM_ACCESS_KEY=Add_Key_Here
export BACKEND_RG_NAME=Terraform
export BACKEND_SA_NAME=testingtfmstatefiles
export BACKEND_CONTAINER_NAME=statefiles
```

And then run some unholy combination of commands to get everything just right, and pass the statefile name.

```bash
 terraform init --backend-config="key=env1.state" --backend-config="resource_group_name=$BACKEND_RG_NAME" --backend-config="storage_account_name=$BACKEND_SA_NAME" --backend-config="container_name=$BACKEND_CONTAINER_NAME"
```

This all becomes a pain to manage, especailly if you have multiple azure subscriptions or environments to flip between.

So, Taskfile and .env files to the rescue.

## TaskFiles

Install Taskfile from here: https://taskfile.dev/installation/

Then, create some ```.env``` files files to represent two Azure subscriptions (these are made up, use your own existing setup!). You can add these to Git as I dont think any of it should be sensitive.

```.env.subscriptionA```
```bash
# Subscription Values
ARM_SUBSCRIPTION_ID=0476bba5-5cab-4a81-9c29-bd557b67a8e2
ARM_CLIENT_ID=1fd57630-e822-4f65-9298-e06213191ee5
ARM_TENANT_ID=357a3f1c-56fe-468b-9c9e-065e2baf3906

# Backend Values
BACKEND_RG_NAME=Terraform
BACKEND_SA_NAME=terraformstatefilesa
BACKEND_CONTAINER_NAME=statefiles
```
```.env.subscriptionB```
```bash
# Subscription Values
ARM_SUBSCRIPTION_ID=c2d51981-13a9-4a62-b866-1e69754eea10
ARM_CLIENT_ID=d134025f-6c20-470b-8ab7-cd5212e340ca
ARM_TENANT_ID=6ccb3ce3-4d0b-45d2-8bfa-aea867e635af

# Backend Values
BACKEND_RG_NAME=Terraform
BACKEND_SA_NAME=terraformstatefilesb
BACKEND_CONTAINER_NAME=statefiles
```

Then create some Terraform ```tfvar``` files with our variable values, like this;

```env1.tfvars```
```hcl
rgName = "Test-RG-1"
```

```env2.tfvars```
```hcl
rgName = "Test-RG-2"
```

And then a terraform file which will deploy a resource group and expect an Azure blob backend.

```main.tf```
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

variable "rgName" {
    description = "Resource Group Name"
    type        = string
}

resource "azurerm_resource_group" "this" {
  name     = var.rgName
  location = "NorthEurope"
}
```

And, last but not least, our ```Taskfile.yaml``` which contains the tasks we can run
```yml
version: '3'

env:
  ENV: subscriptionA    # default value
  VARFILE: env1.tfvars  # default value

tasks:
  clean:
    cmds:
      - rm -rf .terraform
      - rm -rf .terraform.lock.hcl
  init:
    dotenv: ['.env.{{.ENV}}']
    cmds:
      - terraform init --backend-config="key={{.VARFILE}}.state" --backend-config="resource_group_name=$BACKEND_RG_NAME" --backend-config="storage_account_name=$BACKEND_SA_NAME" --backend-config="container_name=$BACKEND_CONTAINER_NAME"
  plan:
    dotenv: ['.env.{{.ENV}}']
    cmds:
      - terraform plan -var-file="{{.VARFILE}}"
  apply:
    dotenv: ['.env.{{.ENV}}']
    cmds:
      - terraform apply -var-file="{{.VARFILE}}"
  destroy:
    dotenv: ['.env.{{.ENV}}']
    cmds:
      - terraform destroy -var-file="{{.VARFILE}}"
```

Your files should look like this

```bash
.env.subscriptionA
.env.subscriptionB
env1.tfvars
env2.tfvars
main.tf
Taskfile.yaml
```

## Deployments!

So what did that buy us? It bought us simplicity. I can deploy the same code to my required azure subscription by just exporting the correct Service Principal key and Azure Storage Account key. Now you can just keep those two things as a secret in 1Password or wherever, and have Taskfile remember the boring bits in a git repo.


```bash
export ARM_CLIENT_SECRET=Add_Secret_Here
export ARM_ACCESS_KEY=Add_Key_Here
```

And run like this
```bash
task init    ENV=subscriptionA
task plan    ENV=subscriptionA VARFILE=env1.tfvars
task apply   ENV=subscriptionA VARFILE=env1.tfvars
task destroy ENV=subscriptionA VARFILE=env1.tfvars
task clean
```


Then, if you want to change from Subscription A to Subscription B, just export the next SP secret and storage key, and change the ENV and VARFILE you reference.
```bash
export ARM_CLIENT_SECRET=Add_Secret_Here
export ARM_ACCESS_KEY=Add_Key_Here

task init    ENV=subscriptionB
task plan    ENV=subscriptionB VARFILE=env2.tfvars
task apply   ENV=subscriptionB VARFILE=env2.tfvars
task destroy ENV=subscriptionB VARFILE=env2.tfvars
task clean
```

It's not much, but it can take the fiddlyness out of changing environments or subscriptions when testing Terraform deployments. Add any extra variables you need and go to town. No more trying to remember what you need to provide, the taskfile will remember the logic required, leaving you free to quickly test the code you require.
