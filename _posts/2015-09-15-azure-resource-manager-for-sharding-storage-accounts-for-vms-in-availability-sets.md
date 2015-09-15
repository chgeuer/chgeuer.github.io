---
layout: default
title: "Sharding of Storage Accounts for High Availability in Azure Resource Manager"
date: 2015-09-15
keywords: azure, "azure resource manager", storage
published: true
---

<!--
<blockquote class="twitter-tweet" lang="en"><p>Want to use <a href="https://twitter.com/Azure">@Azure</a> Blob Storage with Akamai CDN? <a href="http://blog.geuer-pollmann.de/blog/2015/03/12/accessing-microsoft-azure-blob-storage-with-g2o-authentication/">http://blog.geuer-pollmann.de/blog/2015/03/12/accessing-microsoft-azure-blob-storage-with-g2o-authentication/</a></p>&mdash; Chris Geuer-Pollmann (@chgeuer) <a href="https://twitter.com/chgeuer/status/576031655460220928">12. March 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
-->

# tl'dr

- You use Azure Resource Manager. 
- For fault tolerance, you deploy multiple virtual machines, such as a the frontend nodes, into an availability set. You use the `copyIndex()` function for looping through the cluster 
- From a fault tolerance and performance perspective, putting all frontend VM VHD files into a single storage account is a bad idea. 
- This article describes how you can declaratively distribute the OS disks across multiple storage accounts. 

# Intro

[Azure Resource Manager][ARM Intro] is Microsoft Azure's new declarative mechanism for deploying resources, so instead of writing a complex imperative script and firing a large amount of management operations against the Azure Service Management REST API, you describe the overall deployment in a JSON file,  



## current

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchgeuer%2Fchgeuer.github.io%2Fmaster%2Fcode%2F20150915-ARM%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>





## What works

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchgeuer%2Fchgeuer.github.io%2Fb228e09b73c7fa52367365a60de88f05c83a7193%2Fcode%2F20150915-ARM%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

- https://raw.githubusercontent.com/chgeuer/chgeuer.github.io/b228e09b73c7fa52367365a60de88f05c83a7193/code/20150915-ARM/LinuxVirtualMachine.json


``` json
"variables": {
   "math": {
      "modulo2": [ "0", "1", "0", "1", "0", "1", "0", "1", ... ]
   }
}

    variables('math').modulo2[copyIndex()])
```


## What not works

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchgeuer%2Fchgeuer.github.io%2F19fb41271ecdfeda03d6fb7c845b7c3b1459632b%2Fcode%2F20150915-ARM%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

- https://github.com/chgeuer/chgeuer.github.io/blob/19fb41271ecdfeda03d6fb7c845b7c3b1459632b/code/20150915-ARM/LinuxVirtualMachine.json#L123

Error submitting the deployment request. Additional details from the underlying API that might be helpful: Deployment template validation failed: The template resource '...' at line '..' and column '..' is not valid. Template language expression ... is not supported..'

- https://github.com/Azure/azure-content/blob/master/articles/resource-group-template-functions.md

```
    mod(copyIndex(), 2)
    string(mod(int(copyIndex()), 2))
    mod(copyIndex(), variables('storageAccountShardingCount'))
    string(mod(int(copyIndex()), variables('storageAccountShardingCount')))
```





[ARM Intro]: https://azure.microsoft.com/en-us/documentation/articles/resource-group-overview/
