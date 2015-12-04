---
layout: default
title: "Stuff from the web"
date: 2015-11-05
keywords: 
published: true
---


# December 2014

- Slick vector images: http://www.freepik.com
- [Deploy to Azure Resource Groups using the SDK](http://devian.co/2015/10/31/deploy-to-azure-resource-groups-using-the-sdk/)
- [The Moral Character of Cryptographic Work](http://web.cs.ucdavis.edu/~rogaway/papers/moral.html)
- [How to Build a SQL Server AlwaysOn Failover Cluster Instance with SIOS DataKeeper using Azure Resource Manager](http://azurecorner.com/sql-server-alwayson-failover-cluster-instance-with-sios-datakeeper-using-azure-resource-manager/)
- [Lessons learned - Hosting large-scale backends like the “Eurovision Song Contest” on Microsoft Azure](https://channel9.msdn.com/Events/microsoft-techncial-summit/Technical-Summit-2015-The-Next-Level/Lessons-learned-Hosting-large-scale-backends-like-the-Eurovision-Song-Contest-on-Microsoft-Azure)
- [Node.js on Windows and MAX_PATH explanation and workarounds](https://github.com/Microsoft/nodejs-guidelines/blob/master/windows-environment.md#workarounds)
- [Running Drush on Windows Azure Websites](https://sunithamk.wordpress.com/2014/04/01/drupal-running-drush-on-windows-azure-websites/)
- [HTTP Live Streaming In Javascript](https://blog.peer5.com/http-live-streaming-in-javascript/)
- [Multimedia on Linux Command Line: wget, PdfTK, ffmpeg, flac, SoX](https://sandilands.info/sgordon/multimedia-on-linux-command-line)
- [From 20 to 2,000 engineers on GitHub: Azure, GitHub and our Open Source Portal](http://www.jeff.wilcox.name/2015/11/azure-on-github/)
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Windows)

# November 2014

- [Elixir](http://elixir-lang.org/) and [Phoenix Framework](http://www.phoenixframework.org/)
- Cool blog rolls: [The Morning Brew](http://blog.cwa.me.uk/) and [Morning Dew](http://www.alvinashcraft.com/)
- [Hostnames and usernames to reserve](https://ldpreload.com/blog/names-to-reserve) in SaaS systems, so regular users cannot grab them
- Cool web site designs: 
	- http://www.patrickalgrim.me/
	- https://codyhouse.co/gem/horizontal-timeline/
- Windows Defender also blocks [AdWare](http://www.heise.de/security/meldung/Windows-mit-verstecktem-Adware-Killer-3023579.html). Just create under `HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\MpEngine` a DWORD called `MpEnablePus` with value `1`. 
- [Distributed Machine Learning Toolkit](https://github.com/Microsoft/DMTK)
- [In the cloud, we trust](http://news.microsoft.com/stories/inthecloudwetrust/)
- [THE AZURE REST API, OR RATHER RESOURCE MANAGEMENT API](http://devian.co/2015/11/03/the-azure-rest-api-or-rather-resource-management-api/)
- [Streams as the team interface](https://vimeo.com/144863186)
- [C41 – DIY Film Processing at Home](http://camerafilmphoto.com/diy-film-processing-c41-home/) #photography
- [ASP.NET 5 DNX beta8, Connection Refused in Docker?](http://blog.markrendle.net/asp-net-5-dnx-beta8-connection-refused-in-docker/)


# September 2015

- Windows Service Skeleton: With the [EmptyWindowsService](https://github.com/chgeuer/EmptyWindowsService) project, I've created a simple skeleton where you can wrap your own logic in a console app, which can be executed interactively, but also carries it's own installer and Windows service host. The [Topshelf](https://github.com/Topshelf/Topshelf) project offers a more mature Nuget package for similar things, and also has a nice [Azure](https://github.com/Topshelf/Topshelf.Azure) integration to run on Worker Roles (PaaS).
- The [Azure Resource Visualizer](http://armviz.io/#) project on [Github](https://github.com/ytechie/AzureResourceVisualizer) looks like an interesting way to crawl through ARM deployments.
- [SQL Azure Performance Objective IDs for Azure Resource Manager](https://gist.github.com/chgeuer/9d7fba649880ef4ed44a)
- Powershell to convert a PFX file to BASE64: `[System.IO.File]::WriteAlltext("1.pfx.txt", [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("1.pfx")))`
