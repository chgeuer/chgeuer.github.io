---
layout: default
title: "How to configure Akamai CDN for Azure Media Services – A quick introduction"
date: 2016-01-27 10:00:00
keywords: azure, video, akamai
---

<blockquote class="twitter-tweet" lang="en"><p>How to configure <a href="https://twitter.com/Akamai">@Akamai</a> for<a href="https://twitter.com/Azure">@Azure</a> Media Services - A quick introduction <a href="http://blog.geuer-pollmann.de/blog/2016/01/27/configure-akamai-cdn-for-azure-media-services/">http://blog.geuer-pollmann.de/blog/2016/01/27/configure-akamai-cdn-for-azure-media-services/</a></p>&mdash; Chris Geuer-Pollmann (@chgeuer) <a href="https://twitter.com/chgeuer/status/692355042691715073">27. January 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

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

For streaming my video assets, I want a neat and clean 'vanity' hostname, i.e. I do not want some Azure or Akamai artefacts show up in the URL. In my case, I'd like to have my viewers to get the videos from `videos.geuer-pollmann.de`.  `videos.geuer-pollmann.de` will be a DNS CNAME pointing to Akamai, but I **also** want to configure Azure Media Services to accept requests for that URL. Specifically, Akamai will be configured to forward the incoming host header to the origin, so `mediaservice321.streaming.mediaservices.windows.net` must be configured to accept requests for `videos.geuer-pollmann.de`, even if the real DNS doesn't point to the origin server directly. 

Before I can configure my 'custom host name' `video.geuer-pollmann.de` for my streaming endpoint, Azure wants some proof that I excercise control over the `geuer-pollmann.de` domain, and they want me to create some DNS entry to show that. In the dashboard of my 'Azure Media Services Account', I can see it has a 'media service id' called `13b2246c-82f5-40f5-b102-cf7d74b956ab`. Azure now asks me to configure my own DNS server to let `13b2246c-82f5-40f5-b102-cf7d74b956ab.geuer-pollmann.de` to be a CNAME entry pointing to `verifydns.mediaservices.windows.net`. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/02-custom-host-name.png"></img></div>

At my own DNS provider, I add the verification entry: 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/03-verify-dns.png"></img></div>

A quick `dig` query against DNS tells me when I'm done

```
$ dig @8.8.8.8 +noall +answer 13b2246c-82f5-40f5-b102-cf7d74b956ab.geuer-pollmann.de

13b2246c-82f5-40f5-b102-cf7d74b956ab.geuer-pollmann.de. 21590 IN CNAME verifydns.mediaservices.windows.net.
verifydns.mediaservices.windows.net.                     3590 IN A     1.1.1.1
```

Now I can finally tell Azure to accept my custom host name on the origin server: 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/04-add-custom-host-name.png"></img></div>

## Akamai Configuration

On the Akamai side, you first need to have access to the [Luna control center](https://control.akamai.com/homeeng/view/main). You might need to work with your Akamai representative how to get access. 

### Create an 'Adaptive Media Delivery' property

In Luna, you now login to your contract, and create an 'Adaptive Media Delivery' property, and name it (for simplicity) with your intended public host name. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/05-akamai-create-property.png"></img></div>

### Add the hostname

Inside the property, you then add the real hostname to the property. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/06-akamai-add-property-hostname.png"></img></div>

### Use the Standard Hostname. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/07-akamai-standard-hostname.png"></img></div>

### Choose IPv4.

<div align="center"><img src="../../../../../img/2016-01-27-akamai/08-akamai-ipv4.png"></img></div>

### Review

In the review screen, Akamai now knows that requests for `video.geuer-pollmann.de` will be coming in, and tells us that these will have to go to `video.geuer-pollmann.de.akamaized.net`. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/09-akamai-review-hostname.png"></img></div>

### Configure my vanity hostname in my own DNS

Now I need to configure my own DNS so that `video.geuer-pollmann.de` is a CNAME entry for `video.geuer-pollmann.de.akamaized.net`, and I also set the time-to-live (TTL) to an hour. 

After my own DNS forward, I can check: 

```
$ dig @8.8.8.8 +noall +answer video.geuer-pollmann.de

video.geuer-pollmann.de. 3599 IN CNAME video.geuer-pollmann.de.akamaized.net.
```

### Configure "Origin Server" and "Content Provider Code"

Now that the public vanity hostname is set, both in Akamai and our DNS, we can continue Akamai configuration. In the "property configuration settings" --> "Default Rule" --> "Behaviors", we set finish our configuration: 

- The "Origin Server" needs to be configures like this: 
	- The "Origin Type" is set to "Your Origin".
	- The "Origin Server Hostname" is set to the physical hostname of the Azure origin server, in our case `mediaservice321.streaming.mediaservices.windows.net`.
	- The "Forward Host Header" is set to "Incoming Host Header". This is exactly why we added `video.geuer-pollmann.de` to the custom host names in Azure. 
- The "Content Provider Code" (CP Code) is set to whatever you need for proper Akamai billing. For the uninitiated, a CP code seems to be an Akamai construct like a cost center, which allows you to group costs for a particular client under that CP code. So all costs related to a CP code show up together in your Akamai bill. 

<div align="center"><img src="../../../../../img/2016-01-27-akamai/10-akamai-config-finish.png"></img></div>

## Start up the engines

After that long configuration spree, we're pretty much set. The only thing missing is to actually enact the configuration, and to tell Akamai to "start up the engines". When we look up in our Akamai "Property Version Information", we see that the "Production Status" and "Staging Status" are set to INACTIVE. 

The production system is the world-wide set of CDN edge nodes. Changes and reconfigurations to the production system certainly take a bit longer to propagate globally. It is a good idea to first test the waters with the staging environment; the staging environment is a small set of machines which enact config changes much faster, and are not indended to be hit by production traffic. When you see an `*.akamaized.net` hostname, it is production. When you see `*.akamaized-staging.net`, well, you get the idea. 

### To turn on staging, you switch to the "Activate" tab ...

<div align="center"><img src="../../../../../img/2016-01-27-akamai/11-akamai-activate-1.png"></img></div>

### ... and activate "Staging"

<div align="center"><img src="../../../../../img/2016-01-27-akamai/12-akamai-activate-2.png"></img></div>

## Test the staging environment

After we turned the staging environment, it is available at `video.geuer-pollmann.de.akamaized-staging.net`. Let's say we have an asset in Azure Media Services, and when we open the URL of the HLS manifest in Safari, we can play it: 

```
http://mediaservice321.streaming.mediaservices.windows.net/deadbeef-1234-4321-effe-deadbeef0000/MyMovie-m3u8-aapl.ism/manifest(format=m3u8-aapl)
```

What we **could** do now is to replace the AMS hostname with the Akamai staging hostname: 

```
http://video.geuer-pollmann.de.akamaized-staging.net/deadbeef-1234-4321-effe-deadbeef0000/MyMovie-m3u8-aapl.ism/manifest(format=m3u8-aapl)
```

Problem is, it doesn't work. The Akamai edge nodes in the staging environment correctly connect to `mediaservice321.streaming.mediaservices.windows.net`, but if you remember, we said `ForwardHostHeader == IncomingHostHeader`. So the edge node sets the http Host header to `Host: video.geuer-pollmann.de.akamaized-staging.net`. And our origin only accepts requests for either `mediaservice321.streaming.mediaservices.windows.net` or `video.geuer-pollmann.de`. 

A little trick helps: We figure out the concrete IP address of one of the staging servers: 

```
$ dig @8.8.8.8 +noall +answer video.geuer-pollmann.de.akamaized-staging.net

video.geuer-pollmann.de.akamaized.net. 21599 IN CNAME a1612.w10.akamai-staging.net.
a1612.w10.akamai-staging.net.             19 IN A     165.254.92.136
a1612.w10.akamai-staging.net.             19 IN A     165.254.92.138
```

Then we basically use Notepad/vim/Emacs/SublimeText to edit our `/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts` file, and force our local laptop to send requests to the vanity host `video.geuer-pollmann.de` to one of the staging network nodes, such as `165.254.92.136`. Then we open the production URL in Safari, and voila. 

```
http://video.geuer-pollmann.de/deadbeef-1234-4321-effe-deadbeef0000/MyMovie-m3u8-aapl.ism/manifest(format=m3u8-aapl)
```

If that looks good, **we revert our messing around in the hosts file**; otherwise, we might experience hard-to-debug problems on our development machine :-). 

## Turning on production

Last step would be to turn on the production system, give it some time, and check if your DNS entries chain up correctly: 

```
$ dig @8.8.8.8 +noall +answer video.geuer-pollmann.de

video.geuer-pollmann.de.                3599 IN CNAME video.geuer-pollmann.de.akamaized.net.
video.geuer-pollmann.de.akamaized.net. 21599 IN CNAME a1612.w10.akamai.net.
a1612.w10.akamai.net.                     19 IN A     2.16.62.49
a1612.w10.akamai.net.                     19 IN A     2.16.62.57
```

Hope you have fun... If you like that post, give it a retweet on Twitter, or comment below. 
