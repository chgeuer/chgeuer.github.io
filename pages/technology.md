---
layout: default
title: "Stuff from the web"
date: 2015-11-05
keywords: 
published: true
---


# September 2015

- Windows Service Skeleton: With the [EmptyWindowsService](https://github.com/chgeuer/EmptyWindowsService) project, I've created a simple skeleton where you can wrap your own logic in a console app, which can be executed interactively, but also carries it's own installer and Windows service host. The [Topshelf](https://github.com/Topshelf/Topshelf) project offers a more mature Nuget package for similar things, and also has a nice [Azure](https://github.com/Topshelf/Topshelf.Azure) integration to run on Worker Roles (PaaS).
- The [Azure Resource Visualizer](http://armviz.io/#) project on [Github](https://github.com/ytechie/AzureResourceVisualizer) looks like an interesting way to crawl through ARM deployments.
- [SQL Azure Performance Objective IDs for Azure Resource Manager](https://gist.github.com/chgeuer/9d7fba649880ef4ed44a)
- Powershell to convert a PFX file to BASE64: `[System.IO.File]::WriteAlltext("1.pfx.txt", [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("1.pfx")))`
