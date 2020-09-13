---
layout: post
title:  "Setting Up a Static Website in Azure"
date:   2020-09-12 09:55:00 +0100
categories: azure websites
---

I thought I would blog about how to create a static website for very little money in Azure. Here is the cost of running this website for the last month. Practically free!

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/010.png)

The process is quite simple but it is easy to get some bits wrong so I thought I would document it start to finish for my own knowledge, and for anyone else struggling to figure it out.

You can actually do all this through GitHub Pages, so try that if you don't want to go down this route, but it will ve very educational.

## Buy the Domain Name

First, buy a domain name. I use [GoDaddy](https://www.godaddy.com) as i've never had a problem with them. I'm using an XYZ domain name in this example because it is cheap! Feel free to get a decent .com instead. Don't buy any extras that GoDaddy offer, you probably don't need them. Make sure you do no put something like a mobile phone number in the details when you purchase otherwise you will get calls from random people looking through whois for people to scam and create a website for. An example of a purchase is below.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/020.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/030.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/040.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/050.png)


## Setup Azure

I'm going to assume you have an azure account. If not, sign up here - [https://azure.microsoft.com/en-us/free/](https://azure.microsoft.com/en-us/free/)

### Create a Blob Storage Account

The first thing we need is a storage account inside a new resource group. I just call this **www.mystaticwebsite.xyz** for ease of reference.

Check the pricing here - [https://azure.microsoft.com/en-us/pricing/details/storage/blobs/](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/), but unless you are uploading GB's of files, the best option should still be very very cheap.

| Replication Level | Price | Notes |
|---|---|---|
| LRS | £0.0164 per GB | Most basic. Data is replicated in a regions single data center 3 times |
| ZRS | £0.0172 per GB | Data replicated at the specified region but across 3 data centers |
| GRS | £0.0275 per GB | Data is replicated to a secondary region but it is only available in event of the primary region having an outage |
| RA GRS | £0.0343 per GB | Like above, but your data is always available read-only if primary site has an outage |
| GZRS | £0.0318 per GB | Like GRS and ZRS mixed together. Data replicated to two regions and 3 sites at each region |
| RA GZRS | £0.0397 per GB | Like above but data is available read-only if primary site has an outage |

Now, given that your site is likely in git and you don't mind an outage on, say a blog site, feel free to choose LRS, the most 'risky' option. But, given the site will be almost certainly under a gigabyte in size i'd just go for the most opulent option. The files that make up this site as of now come to a size of under 5 MB. So, cost of storage is £0.0397 * 0.05 which is about £0.002p a month. I'd say just splurge out on the best. Even a 10GB website would cost about £0.40p a month. This doesn't include bandwidth of uploads/downloads, but you can see that the cost for a simple site is pennies. 

Create the blob like below, accept all default options after the name, replication etc... screen. In this example, we don't need the advanced options of file versioning and soft deletions as the site is kept in git so nothing can really go wrong. In a real file keeping scenario these may be valuable settings.

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

### Add an index.html

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

Now, we can look at how to use our domain name and get a free HTTPS certificate from Azure.

## Custom Domain Setup

From the azure blob storage page, it has some instructions to follow if we want to use a custom domain. We will choose the first option. But we first have to make a change to our DNS so azure can check that we own the domain. I tried both DNS names suggested, but only the one with the 'z16' worked. Not sure why, so just use that one of the two (ie mystaticwebsiteblob.z16.web.core.windows.net).

Aside. Interestingly, these both have different IP addresses, so not sure whats happening.

'www' DNS CNAME pointing to mystaticwebsiteblob.blob.core.windows.net
```shell
PS C:\Windows\system32> ping www.mystaticwebsite.xyz
Pinging blob.db1prdstrz01a.store.core.windows.net [52.239.137.36] with 32 bytes of data:
```

'www' DNS CNAME pointing to mystaticwebsiteblob.z16.web.core.windows.net
```shell
PS C:\Windows\system32> ping www.mystaticwebsite.xyz
Pinging web.db1prdstrz01a.store.core.windows.net [52.239.137.33] with 32 bytes of data:
```

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/180.png)

### Domain Name DNS Settings

Go back to GoDaddy and make a change to our DNS settings to create a CNAME. Go to 'Domains' and choose your domain. 

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/190.png)

Then, scroll down a bit and and find the 'Manage DNS' option (ignore the other stuff it's just GoDaddy wanting to make you buy web services from them). 

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/200.png)

We actually already have a 'www' CNAME entry already, GoDaddy have set it up for us so we just have to amend it. Click the little pencil to edit the entry.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/210.png)

Change the '@' value to 'mystaticwebsiteblob.z16.web.core.windows.net'. I also change the TTL to something low just in case I make a mistake and don't want to wait too long for the update to be noticed. 600 seconds is the minimum GoDaddy allows. Hit save. We now have set www.mystaticwebsite.xyz to point to the 'z16' azure blob storage static site.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/220.png)

### Azure Blob Store Custom Domain

Go back to Azure and our blob storage, and the 'Custom Domain' option. Enter in our website name and hit save. Don't tick 'Use indirect CNAME validation'.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/240.png)

It should succeed! Mine actually failed first time, I just hit it again. DNS may take a little time to verify the change, so just wait a few minutes if this happens.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/250.png)

Now, go to the [http://www.mystaticwebsite.xyz](http://www.mystaticwebsite.xyz) site, it should be live!

Arggh, error.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/260.png)

What happened? Well, we are trying to access this site over a non-secure protocol (HTTP) and we have told the blob storage not to allow this. So, jump into the 'Configuration' settings page and disable 'Secure Transfer Required' and hit save. We will make this secure only again once we get an HTTPS certificate in place.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/270.png)

Retry the page.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/280.png)

Success!

## Creating an HTTPS Enabled Site with a CDN

The next step is to involve a CDN (Content Delivery Network). Now, we don't exactly need this but if we enable it we can get a free HTTPS certificate and because it is a consumption cost model it will be pennies to implement and avoid us buying 'real' cert or having complexity in setting up Let Encrypt. 

### Create a CDN

We will create a CDN to get our site up to the HTTPS level. There are 4 options, see here [https://docs.microsoft.com/en-us/azure/cdn/cdn-features](https://docs.microsoft.com/en-us/azure/cdn/cdn-features). We will go for Verizon Premium because it has a rules engine (not something we will really use apart from an HTTP to HTTPS redirect) and real-time usage stats which is pretty cool. And the cost will be pennies for a site of our size, so just do it!

Choose to add a resource from our resource group. Choose a Microsoft CDN (don't worry, the Verizon option is in this one).

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/290.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/300.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/310.png)

Then, enter the options like below. Be sure to choose to crete a CDN endpoint in this dialog box. Some options are dropdowns so you don't have to type in too much and it should be fairly intuitive.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/320.png)

Once created, click on the endpoint

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/330.png)

Then choose to add a custom domain

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/340.png)

But, we need to update our www DNS entry to show we own the domain. So go back to GoDaddy and update our www record it requires.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/350.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/360.png)

The azure custom domain should now be accepted so add it.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/370.png)

And then, we wait for it enable. It took a while to do stage 2 (say 30 minutes) and then it took a good 3-4 hours for the certificate to be replicated across all CDN zones.

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/380.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/390.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/400.png)

![](/assets/images/2020/Setting-Up-A-Static-Website-In-Azure/410.png)

But, eventually... success!

