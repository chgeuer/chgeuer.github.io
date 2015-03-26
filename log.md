---
layout: default
title: "My little tech journal"
---

## March 2015

- [plyr](https://github.com/Selz/plyr) is a pretty neat extension to the `<video>` tag with a slick UI. 
- [deploy.azure.com](https://deploy.azure.com/#/form/infohome) is a mechanism to push github-based repositories into Azure Resource Manager. 
- [{m}brace](http://www.m-brace.net/) looks very interesting for scaling compute jobs into compute clusters, and has an Azure hosting. Implemented in F#
- Curated [Azure and Linux links](http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-opensource/) by Ralph Squillace
- Given TortoiseGit often prevents me from undocking USB sticks: `powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "Stop-Process -Name TGitCache"`
- [Exponential Backoff And Jitter](http://www.awsarchitectureblog.com/2015/03/backoff.html) describes how to avoid that systems collectively DDoS their own backend after a failure.  
- [Microsoft Azure Event Hubs](http://robtiffany.com/azure-iot-services-event-hubs/) 
- Upload Azure blobs from AngularJS-based Web Apps: http://ngmodules.org/modules/angular-azure-blob-upload and https://code.msdn.microsoft.com/AngularJS-with-Web-API-c05b3511
- [Azure Media Services Explorer](https://github.com/Azure/Azure-Media-Services-Explorer/)
- [Decrypting TLS Browser Traffic With Wireshark – The Easy Way!](https://jimshaver.net/?p=406): Define environment variable `SSLKEYLOGFILE` so that Chrome writes that file, and configure Wireshark (Preferences -> Protocols -> SSL -> (Pre)-Master-Secret log filename) to use that file. 
- Startup Podcast [ZenFounder](http://zenfounder.com/)
- [MSBuild is open source](http://blogs.msdn.com/b/dotnet/archive/2015/03/18/msbuild-engine-is-now-open-source-on-github.aspx)
- [Slack for Windows](http://slackhq.com/post/113969353750/slack-for-windows)
- [Azure Storage Table Design Guide: Designing Scalable and Performant Tables](http://azure.microsoft.com/en-us/documentation/articles/storage-table-design-guide/)
- Azure VM Extensions
	- [Automate Linux VM Customization Tasks Using CustomScript Extension](http://azure.microsoft.com/blog/2014/08/20/automate-linux-vm-customization-tasks-using-customscript-extension/)
	- [Automate Linux VM OS Updates Using OSPatching Extension](http://azure.microsoft.com/blog/2014/10/23/automate-linux-vm-os-updates-using-ospatching-extension/)
	- [Format Data Disks with Azure VM Custom Script Extension for Linux](http://blog.fullscale180.com/format-data-disks-with-azure-vm-custom-script-extension-for-linux/) and the [script](https://gist.githubusercontent.com/trentmswanson/9c22bb71182e982bd36f/raw/47330d83bd884e88ef56edf5dae5597a1d989554/autopart.sh)
