---
layout: default
title: "How to configure Akamai CDN for Azure Media Services – A quick introduction"
date: 2016-01-27 10:00:00
keywords: azure, video, akamai
---

Tl’dr: For this walkthrough, I assume you have some familiarity with Azure Media Services. I explain how the DNS setup, and Akamai configuration need to look like, to put Akamai CDN in front of your origin server for video streaming. 

[Microsoft Azure Media Services](https://azure.microsoft.com/en-us/services/media-services/) is Microsoft’s PaaS offering for video encoding, and delivery. Through encoding, customers transcode their great original video (sometimes called a 'mezzanine file') into a set of multiple MP4 files in various bitrates and resolutions (multi-bitrate asset). These individual MP4 files are then stored in Azure Blob Storage. An ‘[origin server](https://azure.microsoft.com/en-us/documentation/articles/media-services-deliver-content-overview/)’ can be used for [dynamic packaging](https://azure.microsoft.com/en-us/documentation/articles/media-services-dynamic-packaging-overview/) and streaming into various formats, such as HTTP Live Streaming (HLS), Microsoft IIS Smooth Streaming, MPEG-DASH, and Adobe HTTP Dynamic Streaming (HDS). 

An Azure Media Services Origin Server (formally called 'On-Demand Streaming Reserved Units') has a finite amount of data transmission (egress) capacity of 200 Mbit/sec. As always, having gazillions of users hitting the same machine machine is never a good idea. Fortunately, all this HLS/Smooth/DASH/HDS stuff is just a series of many small HTTP requests, and is cacheable with a CDN. [Azure CDN](https://azure.microsoft.com/en-us/documentation/articles/media-services-manage-origins/#enable_cdn) can easily be enabled for these origin servers. *If you want to use Akamai CDN, instead of the standard Azure CDN, then this walkthrough is for you*. 

*Pricing Note*: In March 2015, Microsoft [announced](https://azure.microsoft.com/en-us/blog/announcing-azure-media-services-integration-with-azure-cdn-content-delivery-network/) that as part of the integration between Azure Media Services and Azure CDN, "you are not charged for the outbound traffic from the Azure data center to the CDN edge nodes". So when a customer watches a video, and the video isn't cached in the CDNs edge node (or point of presence / POP), the edge node fetches the video from the origin server, caches it and sends the now cached content to the customer. The transfer from the origin server in Azure to the Azure CDN edge node does not show up on your Azure bill, the delivery from the Azure CDN to the customer's laptop does show up. This integration is only enacted for the Azure CDN! **When you self-configure Akamai CDN in front of an Azure Origin Server, then the data transfers from Azure to Akamai show up on your Azure invoice, and the delivery of cached content from Akamai to the viewer shows up on your Akamai invoice.** 


## DNS and naming issues: 

First, let's summarize some naming bits and pieces: 

### Have an Azure Media Services Account

When I create an Azure Media Services account, I have to choose an account name. In this example, it will be `mediaservice321`.  

### Have a (reserved) streaming unit

There is a now shared default 'streaming endpoint' called `mediaservice321.streaming.mediaservices.windows.net`. 

To get the 200 Mbit/sec per streaming unit, and for all the fancy DNS CNAME tricks, I need to scale my streaming endpoint to have one or more (reserved) streaming units. Out of the box, it has 0 streaming units. After that scale operation, I have the 200 Mbit/sec per streaming unit, and I can configure custom host names. 

### Have a clean host name

For streaming my video assets, I want a neat and clean hostname, i.e. I do not want some Azure or Akamai artefacts show up in the URL. In my case, I'd like to have my viewers to get the videos from `videos.geuer-pollmann.de`.  `videos.geuer-pollmann.de` will be a DNS CNAME pointing to Akamai, but I **also** want to configure Azure Media Services to accept requests for that URL. Specifically, Akamai will be configured to forward the incoming host header to the origin, so `mediaservice321.streaming.mediaservices.windows.net` must be configured to accept requests for `videos.geuer-pollmann.de`, even if the real DNS doesn't point to the origin server directly. 

Before I can configure my 'custom host name' `video.geuer-pollmann.de` for my streaming endpoint, Azure wants some proof that I excercise control over the `geuer-pollmann.de` domain, and they want me to create some DNS entry to show that. In the dashboard of my 'Azure Media Services Account', I can see it has a 'media service id' called `13b2246c-82f5-40f5-b102-cf7d74b956ab`. Azure now asks me to configure my own DNS server to let `13b2246c-82f5-40f5-b102-cf7d74b956ab.geuer-pollmann.de` to be a CNAME entry pointing to `verifydns.mediaservices.windows.net`. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/02-custom-host-name.png"></img></div>

In my own DNS, I add the verification entry: 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/03-verify-dns.png"></img></div>

Now I can finally tell Azure to accept my custom host name on the origin server: 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/04-add-custom-host-name.png"></img></div>









