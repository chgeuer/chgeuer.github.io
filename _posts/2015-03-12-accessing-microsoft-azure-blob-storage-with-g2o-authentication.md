---
layout: default
title: "Accessing Azure Blob Storage with G2O Authentication"
date: 2015-03-12
keywords: azure storage authentication proxy
published: true
---

SRC: http://blog.geuer-pollmann.de/blog/2015/03/12/accessing-microsoft-azure-blob-storage-with-g2o-authentication/

## tl;dr

This article explains how to securely, and with little effort, expose files in Azure Blob Storage towards the Akamai content delivery network. A proxy app (based on ASP.NET Web API), running in an Azure Cloud Service, checks G2O authentication headers, and then either redirects the CDN to the storage service directly, or fetches the data from the back. 

## Introduction

In this proof-of-concept, we're going to integrate two pieces of technology together: Microsoft Azure Blob Storage, and the Akamai Content Delivery Network. 

### Microsoft Azure Blob Storage 

Microsoft Azure Blob Storage is an object store, where you can create one or more storage accounts. Within an account, you can create `containers`, and store files such as images or videos as '[block blobs][block blobs]' ) in these 'containers'. In the picture below, you can see three storage accounts, `chgeuerwe123`, `cdndatastore01`, and `cdndatastore02`.

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-ui.png"></img>

A container can be publicly accessible (so that an unauthenticated `GET` requests are permitted) or the container can be locked down to be private (which is by default), so that only authenticated requests are permitted. Authentication comes in two flavors: 

1. You can use one of the two `storage account keys`, and use the [Azure REST API][azure storage REST API] or one of the SDKs to access the private contents. Essentially, the requestor needs to supply one of the master keys as part of the request. The `storage account keys` are obviously confidential, and should not leace your application. 
2. 'Shared Access Signatures': In situations where you want to give external requestors access to a blob in a private container, you can create a so-called 'shared access signature' (SAS), which can be appended to the URL of the blob (or other resource, and which implicitly authorizes the request. 

Below you can see the two storage account keys associated with `cdndatastore01`. 

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-keys.png"></img>

<!--
cdndatastore01
fERfsRKahmEXFXcF2DhHJzIP9dmmpTzFP0B24lfDk2XHrD1KsLqb6EHPCspTRHyVw0g+1cHnuOwI14c6NjQr3Q==
wvIf9ZNVmYLpqsqOjBPBlIqEz5hgkMr0uPoPqeOOMcrnDHpysbed71BwjJ4wCtbc1M8eY/DFOEbOtOLJ+2JYJA==
-->




[block blobs]: https://msdn.microsoft.com/en-us/library/azure/ee691964.aspx
[azure storage REST API]: https://msdn.microsoft.com/en-us/library/azure/dd135733.aspx
