---
layout: post
title:  "Automating Azure with Ansible - Part 2"
date:   2021-01-28 18:00:00 +0100
categories: azure devops ansible automation windows vscode winrm
---

{% include all-header-includes.html %}
{% include all-footer-includes.html %}


# The Plan

Now that we have a basic process and can deploy an Azure Resource Group with Ansible, we can look to improve the playbook to create a whole VM. There are a number of parts to create to get a VM so it's not quite as simple as just 'Make VM', we need other resources like a Public IP address, an NSG to protect access etc etc... We will then use Ansible to configure the OS once deployed. Once you have the basics of this in place the sky is the limit really. So, i'll build it in stages and once complete you will have a decent base to use and hopefully learn enough to improve this for your own needs.

## Creating a VM in Azure

A VM in azure is actually a bunch of different resources joined together. We will create each required resource as we go. One nice thing about Ansible is that we can declare the resources one at a time, run the playbook and check it works. Because the deployment is 'immutable', it will simply deploy what we ask it to, and not create duplicates or any other daft behaviour. Ansible will also NEVER (as far as I know) delete a changed  resource, unlike Terraform, so it is safe to re-run multiple times. This is actually a bigger deal than it sounds. I have previously made Powershell scripts to create Azure Infrastructure and it's fine initally, but eventually the amount of code to check that things deployed, and what to do if it exists already starts to get overwhelming. Using Ansible is a really pleasant experience in comparison. Anyway, lets deploy some resources!

### KeyVault and Network Resources

These are the pre-reqs we need before we deploy a VM. 

#### Keyvault

We don't strictly need this, but it is a best practice to create a KeyVault so we can have Ansible generate a VM password for us and then we save it in the KeyVault. In this way, until we want to RDP to the machine, there is no need to provide or have a credential in the system, we don't care, Ansible will create it and we can look it up when required.


https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_keyvault_module.html

```yaml
- name: Create instance of Key Vault
  azure_rm_keyvault:
  resource_group: myResourceGroup
  vault_name: samplekeyvault
  enabled_for_deployment: yes
  vault_tenant: 72f98888-8666-4144-9199-2d7cd0111111
  sku:
  name: standard
  access_policies:
  - tenant_id: 72f98888-8666-4144-9199-2d7cd0111111
  object_id: 99998888-8666-4144-9199-2d7cd0111111
  keys:
  - get
  - list
```

https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_keyvaultkey_module.html

```yaml
- name: Create a key
  azure_rm_keyvaultkey:
    key_name: MyKey
    keyvault_uri: https://contoso.vault.azure.net/
```

#### Virtual Network (VNET)

Before we even start to think about a VM, we need a Network for it to live on. No network means we can't ever connect to it. So, a Virtual Network will give us a local network and then we make a subnet on it for the machine to live in. I'll stick to a 10.0.0.0/16 range and a subnet of 10.0.0.0/24.

#### Network Security Group (NSG)

We also need a Network Security Group, or NSG. This is essentially a firewall. We can attach it to the VNET subnet where the VM is and limit access to RDP to only our own IP address (type 'whatismyip' in google for yours).

### VM Resources

#### Public IP

#### Network Interface Card

#### VM 

#### Enable WinRM

