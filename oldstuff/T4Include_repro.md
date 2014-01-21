---
layout: default
title: "Repro of a T4Include Prob I encountered"
date: 2014-01-21 13:00:00
---

# A problem I bumped into with the T4Include NuGet package:

When I have an Owin project, a whole bunch of packages for OWIN have extension methods, which are all blended into the global::Owin namespace. 

In the example below, the [BasicAuthenticationExtensions.cs](https://github.com/thinktecture/Thinktecture.IdentityModel/blob/master/source/Thinktecture.IdentityModel.Owin/Basic%20Authentication/BasicAuthenticationExtensions.cs) for example have a "namespace Owin" declaration. 



