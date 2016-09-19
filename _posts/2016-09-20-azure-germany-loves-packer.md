---
layout: default
title: "Microsoft Azure Germany loves packer.io"
date: 2016-09-20 11:31:00
---

![Microsoft Azure Germany loves packer.io][header]

In the [previous article][serviceprincipalgermany], I described how you can create a service principal in Azure Active Directory (incl. Azure Germany). In this article, we will explore how to use [Hashicorp's open-source `packer` toolchain][packer] to automatically create custom VM images, both for Windows- and Linux-VMs. 


## Provisioning a Windows VM

![packer interactions with Azure provisining a Windows VM][windowsflow]

[header]: /img/2016-09-20-packer-germany/azure-loves-packer.png "Microsoft Azure loves packer.io"
[windowsflow]: /img/2016-09-20-packer-germany/packer-windows-deployment.png
[serviceprincipalgermany]: /blog/2016/06/27/azure-arm-serviceprincipal
[packer]: https://www.packer.io/
[packerBuilderAzure]: https://www.packer.io/docs/builders/azure.html
