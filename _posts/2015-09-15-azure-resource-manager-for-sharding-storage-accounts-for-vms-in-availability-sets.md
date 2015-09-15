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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchgeuer%2Fchgeuer.github.io%2Fmaster%2Fcode%2F20150915-ARM%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>



variables('math').modulo2[copyIndex()]), 

mod(copyIndex(), variables('storageAccountShardingCount'))

Error submitting the deployment request. Additional details from the underlying API that might be helpful: 
Deployment template validation failed: 
The template resource 'fe-0' at line '86' and column '10' is not valid
Template language expression 'concat('http://', concat(variables('storageAccountNames').frontend, mod(copyIndex(), variables('storageAccountShardingCount')), '.blob.core.windows.net/', 'vhds', '/', concat('fe', '-', copyIndex()), '-osdisk.vhd') ' 

is not supported..'.
