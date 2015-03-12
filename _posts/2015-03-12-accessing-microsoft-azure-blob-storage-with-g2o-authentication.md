---
layout: default
title: "Accessing Azure Blob Storage with G2O Authentication"
date: 2015-03-12
keywords: azure storage authentication proxy
published: false
---

SRC: http://blog.geuer-pollmann.de/blog/2015/03/12/accessing-microsoft-azure-blob-storage-with-g2o-authentication/

## tl;dr

This article explains how to securely, and with little effort, expose files in Azure Blob Storage towards the Akamai content delivery network. A proxy app (based on ASP.NET Web API), running in an Azure Cloud Service, checks G2O authentication headers, and then either redirects the CDN to the storage service directly, or fetches the data from the back. 

## Introduction

In this proof-of-concept, we're going to integrate two pieces of technology together: Microsoft Azure Blob Storage, and the Akamai Content Delivery Network. 

### Microsoft Azure Blob Storage 

Microsoft Azure Blob Storage is an object store, where you can create one or more storage accounts. Within an account, you can create `containers`, and store files such as images or videos as '[block blobs][block blobs]' ) in these 'containers'. In the picture below, you can see three storage accounts, `chgeuerwe123`, `cdndatastore01`, and `cdndatastore02`.

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-ui.png"></img>


Blobs in a container can be publicly available (so that an unauthenticated `GET` returns the contents) or it can be locked down to be private, so that only authenticated requests are permitted. Authentication comes in two flavors:

- Each storage account has 





[block blobs]: https://msdn.microsoft.com/en-us/library/azure/ee691964.aspx

