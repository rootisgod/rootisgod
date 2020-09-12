---
layout: post
title:  "Setting Up a Static Website in Azure"
date:   2020-09-12 09:55:00 +0100
categories: azure websites
---

I thought I would blog about how to create a static website for very little money in Azure. Here is the cost of running this website for the last month. Practically free!

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/010.png)

The process is quite simple but it is easy to get some bits wrong so I thought I would document it start to finish for my own knowledge, and for anyone else struggling to figure it out.

You can actually do all this through GitHub Pages, so try that if you dont want to go down this route, but it will ve very educational.

## Getting a Domain Name

### By the Domain Name

First, buy a domain name. I use [GoDaddy](https://www.godaddy.com) as i've never had a problem with them. I'm using an XYZ domain name in this example because it is cheap! Feel free to get a decent .com instead. Don't buy any extras that GoDaddy offer, you probably dont need them. Make sure you do no put something like a mobile phone number in the details when you purchase otherwise you will get calls from random people looking through whois for people to scam and create a website for. An example of a purchase is below.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/020.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/030.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/040.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/050.png)

### Add a CNAME Alias
todo

## Azure

I'm going to assume you have an azure acoount. If not, sign up here - [https://azure.microsoft.com/en-us/free/](https://azure.microsoft.com/en-us/free/)

### Create a Blob Storage Account

The first thing we need is a storage account inside a new resource group. I just call this **www.mystaticwebsite.xyz** for ease of reference.

Check the pricing here - [https://azure.microsoft.com/en-us/pricing/details/storage/blobs/](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/), but unless you are uploading GB's of files, the best option should still be very very cheap.

| Replication Level | Price | Notes |
|---|---|---|
| LRS | £0.0164 per GB | Most basic. Data is replicated in a regions single datacenter 3 times |
| ZRS | £0.0172 per GB | Data replicated at the specified region but across 3 datacenters |
| GRS | £0.0275 per GB | Data is replicated to a secondary region but it is only available in event of the primary region having an outage |
| RA GRS | £0.0343 per GB | Like above, but your data is always available read-only if primary site has an outage |
| GZRS | £0.0318 per GB | Like GRS and ZRS mixed together. Data replicated to two regions and 3 sites at each region |
| RA GZRS | £0.0397 per GB | Like above but data is available read-only if primary site has an outage |

Now, given that your site is likely in git and you dont mind an outage on, say a blog site, feel free to choose LRS, the most 'risky' option. But, given the site will be almost certainly under a gigabyte in size i'd just go for the most opulent option. The files that make up this site as of now come to a size of under 5 MB. So, cost of storage is £0.0397 * 0.05 which is about £0.002p a month. I'd say just splurge out on the best. Even a 10GB website would cost about £0.40p a month. This doesn't include bandwidth of uploads/downloads, but you can see that the cost for a simple site is pennies. 

Create the blob like below, accept all default options after the name, replication etc... screen. In this example, we dont need the advanced options of file versioning and soft deletions as the site is kept in git so nothing can really go wrong. In a real file keeping scenario these may be valuable settings.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/060.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/070.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/080.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/090.png)

Once created, it should be in your resource group.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/100.png)

The first thing to do is enable 'Static Website'.
![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/110.png)

Once enabled, enter an index document name of 'index.html'. This is generally the root page of a website. If you know yours will be different, enter it here, and save the setting.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/120.png)

### Add a Test File

We now have a live site we can access. Note that we now have a $web folder where we place static website related files.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/130.png)

We just need an index.html file so we can browse and check it works as expected.

Create a file called index.html like below.

```html
<!DOCTYPE html>
<html>
<body>
<h1>Static Site</h1>
<p>A great website!</p>
</body>
</html> 
```

Then, go to the storage account, Containers and the $web folder. Then upload it to the $web folder.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/140.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/150.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/160.png)

Now, we can browse to [https://mystaticwebsiteblob.z16.web.core.windows.net/](https://mystaticwebsiteblob.z16.web.core.windows.net/) and see what happens.

Success!

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/170.png)

Now, we can look at how to add our domain name and get a free HTTPS certificate from Azure.