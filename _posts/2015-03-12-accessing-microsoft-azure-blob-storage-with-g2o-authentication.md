
---
layout: default
title: "Accessing Azure Blob Storage with G2O Authentication"
date: 2015-03-12
keywords: azure storage authentication proxy
published: true
---

## tl;dr

This article explains how to securely, and with little effort, expose files in Azure Blob Storage towards the Akamai content delivery network. A proxy app (based on ASP.NET Web API), running in an Azure Cloud Service, checks G2O authentication headers, and then either redirects the CDN to the storage service directly, or fetches the data from the back. 

## Introduction

In this proof-of-concept, we're going to integrate two pieces of technology together: Microsoft Azure Blob Storage, and the Akamai Content Delivery Network. 

Microsoft Azure Blob Storage is an object store, where files (such as JPEG images) can be stored in 'containers'. These files are '[block blobs][block blobs]'. 


[block blobs]: https://msdn.microsoft.com/en-us/library/azure/ee691964.aspx

