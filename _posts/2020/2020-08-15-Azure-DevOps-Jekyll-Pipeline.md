---
layout: post
title:  "Setting Up an Azure DevOps Build Pipeline for a Jekyll Website on Azure Blob Storage"
date:   2020-08-15 18:28:00 +0100
categories: azure devops jekyll cicd blob automation
---

{% include all-header-includes.html %}

If anyone wants to deploy a website using Azure DevOps this should build the site. It took a while to get just right. The tricky parts were azcopy being version 7 on the Ubuntu machine which is awful as far as I can tell, version 10 is much better, so I had to do some wonky stuff. It also purges the cache on the CDN I host from in Azure so that the site gets an HTTPS cert. I might expand this post over the next few weeks, or explain the entire setup process to host a site on Azure Blob Storage as a Static Site. The main benefit is the cost, the last week of hosting this has cost £0.02 so far! Not bad for a full site with an HTTPS cert in place.

Anyway, this is the pipeline YAML file I ended up with. Generate a SAS token and place its value as a variable called 'sastoken' and your own subscription for the purging the cache step.

```yaml
trigger:
- master

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: UseRubyVersion@0
  inputs:
    versionSpec: '>= 2.6'
 
- script: |
    gem install jekyll bundler
    bundle install --retry=3 --jobs=4
  displayName: 'Install Jekyll'
 
- script: |
    bundle install
    jekyll -v
    jekyll build
  displayName: 'Build Jekyll Site'

- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
      mv azcopy azcopy10
      azcopy10 --version
      azcopy10 sync "./_site/" "https://rootisgodstaticwebsite.blob.core.windows.net/`$web$env:SASTOKEN" --delete-destination true
    displayName: 'Update Static Site Blob'
  env:
    SASTOKEN: $(sastoken)

- task: AzureCLI@2
  inputs:
    azureSubscription: 'Put in your subscription'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: 'az cdn endpoint purge --resource-group "www.rootisgod.com" --name "rootisgod" --profile-name "rootisgod-cdn" --content-paths "/*"'
  displayName: 'Purge CDN Cache'
```

{% include all-footer-includes.html %}