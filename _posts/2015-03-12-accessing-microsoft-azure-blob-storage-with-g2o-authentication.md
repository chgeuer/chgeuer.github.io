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

The end-to-end solution is avaiable here: https://github.com/chgeuer/G2O2AzureBlobStorage

## Introduction

In this proof-of-concept, we're going to integrate two pieces of technology together: Microsoft Azure Blob Storage, and the Akamai Content Delivery Network. 

### Microsoft Azure Blob Storage 

Microsoft Azure Blob Storage is an object store, where you can create one or more storage accounts. Within an account, you can create `containers`, and store files such as images or videos as '[block blobs][block blobs]' ) in these 'containers'. In the picture below, you can see three storage accounts, `chgeuerwe123`, `cdndatastore01`, and `cdndatastore02`.

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-ui.png"></img>

A container can be publicly accessible (so that an unauthenticated `GET` requests are permitted) or the container can be locked down to be private (which is by default), so that only authenticated requests are permitted. Authentication comes in two flavors: 

1. You can use one of the two `storage account keys`, and use the [Azure REST API][azure storage REST API] or one of the SDKs to access the private contents. Essentially, the requestor needs to supply one of the master keys as part of the request. The `storage account keys` are obviously confidential, and should not leace your application. 
2. 'Shared Access Signatures': In situations where you want to give external requestors access to a blob in a private container, you can create a so-called 'shared access signature' (SAS), which can be appended to the URL of the blob (or other resource, and which implicitly authorizes the request. In addition, an SAS can be an ad-hoc signature, or it can be associated with a policy. Simply speaking, you cannot easily revoke an ad-hoc signature, but you have to change the storage account key. An SAS which corresponds to a policy can be revoked by deleting the policy. 

Below you can see the two storage account keys associated with 'cdndatastore01'. 

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-keys.png"></img>

Let's say we have two containers called 'public' and 'private1' (being, well, publicly accessible and privately locked down), and various blobs in these storage accounts: 

- The 'public' container in storage account 'cdndatastore01' contains a file 'data/somePublicImage.jpg'
- The 'private1' container contains a file 'someLockedDownImage.jpg'

When we look at the URL of a blob, it consists of the following parts: 

- Protocol: You can access Azure Blob Storage both through 'http' and 'https'
- Hostname: Each storage account has a unique hostname (`http(s)://cdndatastore01.blob.core.windows.net` in our case)
- Container: The Container name comes after the hostname https://cdndatastore01.blob.core.windows.net/public/
- Blob name: You can model a directory hierarcy inside a container by putting a `/` character into a blob name, and most tools support the illusion of a `data` folder. When I use a tool such as CloudXPlorer to look at my files, I see this: 

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-cloudxplorer.png"></img>

As a result, my public image is now accessible at [https://cdndatastore01.blob.core.windows.net/public/data/somePublicImage.jpg](https://cdndatastore01.blob.core.windows.net/public/data/somePublicImage.jpg):

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-public-image.png"></img>

An unauthenticated GET against my private image [https://cdndatastore01.blob.core.windows.net/private1/someLockedDownImage.jpg](https://cdndatastore01.blob.core.windows.net/private1/someLockedDownImage.jpg) only gives me a 404: 

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-private-image-404.png"></img>

I have to create an SAS [.../private1/someLockedDownImage.jpg?sv=2014-02-14&sr=b&si=g2o&sig=...&se=2015-03-12T11%3A53%3A54Z](https://cdndatastore01.blob.core.windows.net/private1/someLockedDownImage.jpg?sv=2014-02-14&sr=b&si=g2o&sig=H%2BTnGl2Yw80uXax6t%2BLB4FAgQvNh4FRkShHr3Qmnmg4%3D&se=2015-03-12T11%3A53%3A54Z) to successfully GET the image. 

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/blob-storage-private-image-200.png"></img>

For details around shared access signatures, check out these [great][sas1] [articles][sas2]. Suffice to say, that I added a policy to my container with the identifier `g2o`, which you can see being referenced in the `&si=g2o` part of my SAS. 

### The Akamai CDN

A content delivery network (CDN) is a large network of HTTP cache servers, distributed around the globe. When you fetch a file from a CDN, the DNS routes you to the nearest 'edge node' or 'edge server' in the CDN. If not already cached, this edge node then fetches the original file from the 'origin server'. This origin server usually is some web server where the original file assets are stored. 

In Azure, there are various services where it can make sense to deploy a CDN in front, to reduce traffic on these servers: Compute services such as Azure Cloud Services, or Virtual machines, Azure Media Services Origin Servers, or Azure Blob Storage.  

[Microsoft Azure already comes with an included CDN][[azure cdn], and you can put Azure CDN in front of your 
[cloud services][using azure cdn with cloud service] or [Azure blobs][azure cdn for blob storage]. 

However, Micosoft also has customers who already use Akamai for their CDN needs. To support these customers, the [Azure Media Services Team][azure media services blog] offers a [mechanism to turn on Akamai's G2O authentication for Azure Media Services Origin Servers][using wams origin with g2o]; simply speaking, you can put Akamai's CDN in front of your Azure Media Services origin servers for video streaming, and *only* Akamai's CDN nodes (called edge nodes, or global hosts) can fetch data from your server. 

### G2O Authentication

The term 'G2O' stands for 'ghost to origin' or 'global host to origin' authentication, and is a mechanism for enabling an origin server to authenticate the inbound request from the CDN's edge node (ghost). As I said, [Azure Media Services support G2O][using wams origin with g2o], and other players (such as [nginx][nginx module g2o] or the [Akamai Community][akamai community]) as well. Simply speaking, G2O defines HTTP headers which have to be added to the request, and 5 different cryptographic algorithms to compute these headers. 

The `X-Akamai-G2O-Auth-Data` HTTP header contains the ID of the cryptographic algorithm (1-5), the IP addresses of the edge node and the actual requesting client, the current time (as UNIX epoch), some unique ID to prevent replay attacks (which usually is called 'nonce' in the security community), and a 'nonce' (which is called key identifier in the security community). 

```csharp
int version, string edgeIP, string clientIP, long time, string uniqueId, string nonce
```

After cryptographically processing the input from the `X-Akamai-G2O-Auth-Data` header and the URL's local path with the cryptograhic key associated with the 'nonce', the resulting cryptograhic value is tranported in the `X-Akamai-G2O-Auth-Sign` header. (I resist to call is a 'signature' because it is a symmetric system, not offering data origin authentication, just message integrity and peer entity authentication.)

The five [G2O algorithms][my g2o implementation] are based on pretty 'conventional' crypto, but for just keeping the egress load on origin servers low, it's certainly OK. Have a look at my [test vectors][test vectors] for how these strings look like. 

```csharp
using SignAlgorithm = System.Func<byte[], byte[], byte[], byte[]>;

private static readonly ReadOnlyDictionary<int, SignAlgorithm> algorithms = 
                    new ReadOnlyDictionary<int, SignAlgorithm>(
                            new Dictionary<int, SignAlgorithm>
{
    { 1, (key, data, urlpath) => MD5(key, data, urlpath) },
    { 2, (key, data, urlpath) => MD5(key, MD5(key, data, urlpath)) },
    { 3, (key, data, urlpath) => HMAC_Sign("HMACMD5", key, data, urlpath) },
    { 4, (key, data, urlpath) => HMAC_Sign("HMACSHA1", key, data, urlpath) },
    { 5, (key, data, urlpath) => HMAC_Sign("HMACSHA256", key, data, urlpath) }
});
```

## The solution

After defining the protocol foundation, we can now focus on the actual solution: 

### Interaction flow

<img src="/img/2015-03-12-accessing-microsoft-azure-blob-storage-with-g2o-authentication/flow.png"></img>

Simply speaking, we deploy an SAS generator proxy app. Then in Akamai, we configure our SAS Generator Service as origin, and turn on "Redirect Chasing". When clients get a file from the CDN, the edge servers attempt to fetch the files from our SAS Generator Service, which authenticates them using G2O and redirects them to blob storage, with an SAS URL. 

1. The first step in the flow is the user's browser making a DNS query for `cdn.customer.com` against the customer's DNS Server. The DNS Server returns CNAME or A record the edge node `a123.g2.akamai.net`. 
2. The client's browser sends a `GET` request against the edge node and retrieves the resource `/images/public/data/somePublicImage.jpg`. 
3. The edge node sends a `GET` request against the CNAME of the configured origin, like `contosoorigin.cloudapp.net` but with a `Host` header of `cdn.customer.com`, retrieving the resource `/images/public/data/somePublicImage.jpg`. From the point of view of the CDN, this is a full origin server, hosting the content. From an implementation perspective, this is just a tiny ASP.NET WebAPI Controller which 
	- validates the G2O Headers to make sure the called is indeed the CDN, 
	- extracts the first segment of the URL path (`/images` in our example), and checks whether there is a storage account associated with this alias,
	- extracts the second segment of the URL path (`public` in our example), and checks whether the this container is actually exposed in config
	- generates a SAS URL for the real Azure Blob Storage Account (without the `images` part), and returns an HTTP 302 Redirect back to the CDN. 
	- As a last step, the URL's scheme (http or https) must match the one of the inbound request, an important detail for the next step to work. 
4. After the CDN's edge node receives the 302 redirect response, it checks two things: 
	- The configuration at Akamai must have "Redirect Chasing" enabled, otherwise the edge server refuses to follow that redirect.
	- The scheme of the 302 Response (with or without TLS) must be equal to the origin requests scheme, otherwise the AkamaiGHost sends you a fancy "404 An error occurred while processing your request".
	- Now the CDN edge node uses the 302 address to retrieve the actual contents from CDN. This request is now validated by Azure Blob Storage using the shared-access-signature magic.


# Implementation details

## G2O OWIN Middleware

The [G2OHandlers][G2OHandlers] project contains a full-fledged OWIN Middleware for handling G2O authN. 

```csharp
 public void Configuration(IAppBuilder app)
{
    Func<string, string> keyResolver ...;
    app.EnforeG2OAuthentication((Func<string,string>) keyResolver);
    ...
}
```

In order to check whether an inbound http request is permitted, the OWIN middleware needs access to the cryptographic key material. You must supply a `Func<string,string> keyResolver` handler, which gets an Akamai 'nonce' (key identifier like `"193565"`) as input, and returns the key (like `"07bf84629be85d68a3ef343d"`). 

As a result, the [G2OAuthenticationHandler.cs][G2OAuthenticationHandler.cs] issues an `AuthenticationTicket` with various claims containing all the G2O validation data. The `ClientIP`, i.e. the IP address of the actual client itself, is currently not validated, but the implementation could easily be extended to support geo-fencing scenarios (if you believe an IP address still has meaning in this century). 

## G2O HttpClientHandler

The implementation also contains an [G2OHttpClientHandler.cs][G2OHttpClientHandler.cs] 

```csharp
// Use https://raw.githubusercontent.com/chgeuer/WhatIsMyIP/master/WhatIsMyIP/ExternalIPFetcher.cs
// for determining my own IP address. Sorry, I'm in the home office behind a NAT ...

var path = "/images/public/data/somePublicImage.jpg";

var g2oClientHandler = new G2OHttpClientHandler(
    version: 3, // 1..5
    edgeIP: ExternalIPFetcher.GetAddress().IPAddress.ToString(), 
    clientIP: "1.2.3.4", // harrr harrr :-)
    nonce: "193565",
    nonceValue: "07bf84629be85d68a3ef343d");

var client = new HttpClient(g2oClientHandler);
var response = client.SendAsync(
	new HttpRequestMessage(HttpMethod.Get,
	"http://contosocdn.cloudapp.net" + path )).Result;
```

With this baby, you can simply impersonate a CDN edge node for debugging purposes. 





[block blobs]: https://msdn.microsoft.com/en-us/library/azure/ee691964.aspx
[azure storage REST API]: https://msdn.microsoft.com/en-us/library/azure/dd135733.aspx
[sas1]: http://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-shared-access-signature-part-1/
[sas2]: http://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-shared-access-signature-part-2/
[azure cdn]: http://azure.microsoft.com/en-us/documentation/articles/cdn-how-to-use/
[azure cdn for blob storage]: http://azure.microsoft.com/en-us/documentation/articles/cdn-how-to-use/#Step2
[azure media services blog]: http://azure.microsoft.com/blog/topics/media-services/
[using wams origin with g2o]: https://msdn.microsoft.com/en-us/library/dn735905.aspx#sec2
[using azure cdn with cloud service]: http://azure.microsoft.com/en-us/documentation/articles/cdn-cloud-service-with-cdn/
[nginx module g2o]: https://github.com/refractalize/nginx_mod_akamai_g2o
[akamai community]: https://community.akamai.com/people/B-3-181J6KL/blog/2015/02/17/ghost-to-iis-origin-module
[my g2o implementation]: https://github.com/chgeuer/G2O2AzureBlobStorage/blob/master/G2OHandlers/G2OAlgorithms.cs
[G2OHandlers]: https://github.com/chgeuer/G2O2AzureBlobStorage/tree/master/G2OHandlers
[test vectors]: https://github.com/chgeuer/G2O2AzureBlobStorage/blob/master/G2OTests/G2OCryptoUnitTest.cs

[G2OAuthenticationHandler.cs]: https://github.com/chgeuer/G2O2AzureBlobStorage/blob/master/G2OHandlers/G2OAuthenticationHandler.cs
[G2OHttpClientHandler.cs]: https://github.com/chgeuer/G2O2AzureBlobStorage/blob/master/G2OHandlers/G2OHttpClientHandler.cs

