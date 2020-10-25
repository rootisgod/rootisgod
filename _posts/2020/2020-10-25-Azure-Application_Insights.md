---
layout: post
title:  "Azure Application Insights for Your Website"
date:   2020-10-25 20:00:00 +0100
categories: website hosting metrics javascript
---

{% include azure_app_insights.js %}
{% include header.md %}

So, hosting a site on Jekyll and Azure Static Blob storage has one major problem (okay, two big problems, there is no way to easily add a comments section either!), but I can't really get any metrics on who visited the site as there really aren't any logs to parse. So, I decided to look at what I could quickly do to see what is going on.

# Azure Application Insights

The simplest and most straightforward solution is Azure Application Insights. Now, I don't have much experience of hosting anything so this is very new to me, but I was startled at how easy this was to add to my site. This description shows the steps involved.

For clarity this is how Application Insights is described on the azure website.

![](/assets/images/2020/Azure-Application-Insights/005.png)

So, it is saying we create a resource and then get a special key to use on our site to monitor it. Because our site is just a static HTML page we can't use the server-side SDKs and so, we fall back to Javascript on the pages we host - https://docs.microsoft.com/en-us/azure/azure-monitor/app/javascript#snippet-based-setup. But, there some pre-reqs first.

## Prereqs

We need to create a Log Analytics Workspace to hold the metrics we collect and let us query it. So, create one first from the Azure Portal, using the defaults and in the same region as your Static Site enabled blob storage.

![](/assets/images/2020/Azure-Application-Insights/010.png)

![](/assets/images/2020/Azure-Application-Insights/020.png)

![](/assets/images/2020/Azure-Application-Insights/030.png)

![](/assets/images/2020/Azure-Application-Insights/040.png)

## Application Insights Resource

Now we can create our Application Insight resource. Choose the same region as your other resources and the Log Analytics Workspace we just created. Choose the workspace based resource mode as classic will be deprecated soon. 

![](/assets/images/2020/Azure-Application-Insights/050.png)

![](/assets/images/2020/Azure-Application-Insights/060.png)

![](/assets/images/2020/Azure-Application-Insights/070.png)

Once created, we can go to the resource and look for the 'Application Instrumentation Key'.

![](/assets/images/2020/Azure-Application-Insights/080.png)


## Add the Javascript to our Jekyll Site

Now, looking at the previous link above, we just add that to the example javascript snippet provided.

On our site, create a javascript file in the ```/assets/js``` folder and put in your key. 

![](/assets/images/2020/Azure-Application-Insights/090.png)

Then, we can start to include this on our pages. 

*I'm sure there is a way to do this in the jekyll ```_config.yml``` file but i'm not there yet, so just add it manually to your pages like so (i'll update this later when I figure out the better way).*

![](/assets/images/2020/Azure-Application-Insights/0100.png)

Then, push and build your site and start browsing a few pages to trigger some data (it's also a good idea to double-check your page source to make sure the javascript code we included is there, it should be or none of it will work!). There is a lot to dig into, and I don't know much yet, but the most useful initial thing I have found are page access counts, and the system accessing it. Look below! Cool! And, cost is minimal so far as it is also pay-as-you-go data consumption based and almost free. Seems like a good start!

![](/assets/images/2020/Azure-Application-Insights/0110.png)
