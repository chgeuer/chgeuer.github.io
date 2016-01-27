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

First, let's layout some naming bits and pieces: 

### Media Services Account Name

When you have created an Azure Media Services account, you have chosen an account name. In this example, it will be `mediaservice321`.  

<div>
	<img src="../../../../../img/2016-01-27-akamai/01-create-media-services-account.png" alt="creating an Azure Media Services Account"></img>
</div>

