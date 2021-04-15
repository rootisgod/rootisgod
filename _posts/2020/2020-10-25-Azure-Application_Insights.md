---
layout: post
title: "Azure Application Insights for Your Static Website"
date: 2020-10-25 20:00:00 +0100
categories: website hosting metrics javascript
---

{% include all-header-includes.html %}

So, hosting a site on Jekyll and Azure Static Blob storage has one major problem (okay, two big problems, there is no way to easily add a comments section!), but I can't really get any metrics on who visited the site as there is no server backend to record any visits. So, I decided to look at what could be done to get some analytics.

# Azure Application Insights

The simplest and most straightforward solution is to use Azure Application Insights. Now, I don't have much experience of hosting anything so this is very new to me, but I was startled at how easy this was to add to the site. The steps below show how to set this up.

For clarity this is how Application Insights is described on the azure website.

![](/assets/images/2020/Azure-Application-Insights/005.png)

So, it is saying we create a resource and then reference a special key on our site to monitor connections. Because our site is just a static HTML page we can't use the server-side SDKs and so, we fall back to Javascript on the pages we host - [https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript#snippet-based-setup](https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript#snippet-based-setup).

But, there are some pre-reqs first to setting up an Application Insights solution.

## Prereqs

We need to first create a Log Analytics Workspace to hold the metrics we collect, this will also let us query this data. So, we create one first from the Azure Portal, using the defaults and placing it in the same region as your Static Site enabled blob storage.

![](/assets/images/2020/Azure-Application-Insights/010.png)

![](/assets/images/2020/Azure-Application-Insights/020.png)

![](/assets/images/2020/Azure-Application-Insights/030.png)

![](/assets/images/2020/Azure-Application-Insights/040.png)

## Application Insights Resource

Now we can create our Application Insight resource. Choose the same region as our other resources to avoid any bandwidth costs (same region traffic is free). Choose the workspace based resource mode as the classic mode will be deprecated soon.

![](/assets/images/2020/Azure-Application-Insights/050.png)

![](/assets/images/2020/Azure-Application-Insights/060.png)

![](/assets/images/2020/Azure-Application-Insights/070.png)

Once created, we can go to the resource and look for the 'Application Instrumentation Key'.

![](/assets/images/2020/Azure-Application-Insights/080.png)

## Add the Javascript to our Jekyll Site

Now, looking at the previous link above, we just add that to the example javascript snippet provided.

On our site, create a javascript file in the `/assets/js` folder and put in the key. Take the snippet from here and put in your own instrumentation key.

https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript#snippet-based-setup

![](/assets/images/2020/Azure-Application-Insights/090.png)

Then, we can start to add this snippet as an 'include' on our content pages.

_I'm sure there is a way to have this added automatically via the jekyll `_config.yml` file but i'm not there yet, so just add it manually to your pages like below and i'll update this page later when I figure out the better way._

![](/assets/images/2020/Azure-Application-Insights/0100.png)

Then, push and build your site and start browsing a few pages to trigger some data (it's also a good idea to double-check your page source to make sure the javascript code we included is there, it should be or none of this will work!). There is a lot to dig into, and I don't know much yet, but the most useful initial thing I have found are page access counts, and the system accessing it. Look below! Cool! And, best of all, cost is minimal as Application Insights is also a pay-as-you-go, data ingress/egress, consumption based model which for my scale is almost free. Seems like a good start!

![](/assets/images/2020/Azure-Application-Insights/0110.png)

{% include all-footer-includes.html %}
