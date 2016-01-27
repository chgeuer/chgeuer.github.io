---
layout: default
title: "How to configure Akamai CDN for Azure Media Services – A quick introduction"
date: 2016-01-27 10:00:00
keywords: azure, video, akamai
---

# How to configure Akamai CDN for Azure Media Services – A quick introduction

Tl’dr: For this walkthrough, I assume you have some familiarity with Azure Media Services. I explain how the DNS setup, and Akamai configuration need to look like, to put Akamai CDN in front of your origin server for video streaming. 

[Microsoft Azure Media Services](https://azure.microsoft.com/en-us/services/media-services/) is Microsoft’s PaaS offering for video encoding, and delivery. Through encoding, customers transcode their great original video (sometimes called a 'mezzanine file') into a set of multiple MP4 files in various bitrates and resolutions (multi-bitrate asset). These individual MP4 files are then stored in Azure Blob Storage. An ‘[origin server](https://azure.microsoft.com/en-us/documentation/articles/media-services-deliver-content-overview/)’ can be used for [dynamic packaging](https://azure.microsoft.com/en-us/documentation/articles/media-services-dynamic-packaging-overview/) and streaming into various formats, such as HTTP Live Streaming (HLS), Microsoft IIS Smooth Streaming, MPEG-DASH, and Adobe HTTP Dynamic Streaming (HDS). 

An Azure Media Services Origin Server (formally called 'On-Demand Streaming Reserved Units') has a finite amount of data transmission (egress) capacity of 200 Mbit/sec. As always, having gazillions of users hitting the same machine machine is never a good idea. Fortunately, all this HLS/Smooth/DASH/HDS stuff is just a series of many small HTTP requests, and is cacheable with a CDN. [Azure CDN](https://azure.microsoft.com/en-us/documentation/articles/media-services-manage-origins/#enable_cdn) can easily be enabled for these origin servers. *If you want to use Akamai CDN, instead of the standard Azure CDN, then this walkthrough is for you*: 

## DNS and naming issues: 

First, let's layout some naming bits and pieces: 

