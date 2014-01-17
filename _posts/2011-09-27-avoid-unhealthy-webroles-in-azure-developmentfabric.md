---
layout: blog-post
title: "Avoiding unhealthy roles when configuring IIS with the ServerManager in the local Azure development fabric"
date: 2011-09-27 11:00:00
keywords: WindowsAzure, "Platform as a Service"
---


# 10-second summary

In your Azure start-up code, you use the ServerManager class to modify your IIS settings. Some of your web role instances in the development fabric don’t come up and stay ‘unhealthy’. This article describes a possible cure for that. 

# Problem

In this article, I describe a solution to the problem where some of your Windows Azure web role instances in the development fabric get stuck in an unhealthy state, and thus do not start, when you use the ServerManager to tweak your Application Pool settings. 

In our Windows Azure development project, we have a web role, which in turn has has multiple virtual applications (i.e. the CSDEF file contains many WebRole/Sites/Site/VirtualApplication elements). In our development environment, we use the ServerManager utility to change the identity under which the application pools run, so that they do not run under the "NETWORK SERVICE" account, but under a given user account (see [Wade's article][wade] for details). Assuming we deploy 5 web role instances, and each has 4 virtual applications, we have to modify the settings for 5*(1+4)=25 application pools (it's 1+4, because in addition to the 4 virtual applications, we also need to we need to modify the actual web role itself). 


```xml
<WebRole name="Cloud.WebRole" vmsize="Small"> 
    <Sites> 
      <Site name="Web"> 
        <VirtualApplication name="App1" physicalDirectory="..\Site.App1" /> 
        <VirtualApplication name="App2" physicalDirectory="..\Site.App2" /> 
        <VirtualApplication name="App3" physicalDirectory="..\Site.App3" /> 
        <VirtualApplication name="App4" physicalDirectory="..\Site.App4" /> 
        <Bindings> 
          <Binding name="HttpPort80" endpointName="HttpPort80" /> 
          <Binding name="HttpsPort443" endpointName="HttpsPort443" /> 
        </Bindings> 
      </Site> 
    </Sites>
```

The term 'modifying a setting of an application pool' means that you use the type Microsoft.Web.Administration.ServerManager (from %WINDIR%\System32\inetsrv\Microsoft.Web.Administration.dll) to modify the application pools, and then call the serverManager.CommitChanges() method. When running multiple instances in your Windows Azure development fabric, your RoleEntryPoint.OnStart() method potentially run in parallel with other  RoleEntryPoint.OnStart(), and in the case of for ‘slow’-starting instances which are still being configured by the development fabric, you also run parallel to the fabric’s IisConfigurator.exe utility. 


Why is that a problem? Well, in order to enact a configuration change, you need to call the [serverManager.CommitChanges()][servermanagercommit] method which essentially modifies a file in the local file system (namely "C:\Windows\system32\inetsrv\config\applicationHost.config"). And as you can imagine, this is the perfect opportunity for race conditions: Imagine a situation where one of your role instances (successfully) calls [ServerManager.CommitChanges()][servermanagercommit], while the IisConfigurator.exe is in the process of configuring another role instance. Then IisConfigurator.exe fails to configure that other role (and crashes), that role is marked as ‘Unhealthy’ in the fabric and does not come off the ground. So, letting IisConfigurator.exe running into a race condition with your own code can ruin your day.

# How the fix works

## The CrossProcessBarrier

First of all, please keep in mind that this problem only occurs when running multiple web roles in the local development fabric. In a real deployment in a Windows Azure data center, your RoleEntryPoint.OnStart() is called after IisConfigurator.exe did it’s thing. 

So on your laptop, you want to ensure that only one process at a time uses the ServerManager class. Your RoleEntryPoint.OnStart() code should run when IisConfigurator.exe has fully finished it’s business. So we ‘simply’ need to wait in the OnStart() code of each role, until …, yeah, hm, until when exactly? When all OnStart() methods are ‘at the same point’, that’s the right time when IisConfigurator is done. 

In the Task Parallel Library, there is a nice construct called System.Threading.Barrier, which defines how many ‘participants’ should wait for each other, and when all participants reach the barrier, it releases them at once. Unfortunately, System.Threading.Barrier is for tasks and threads within the same process, and doesn’t work across different processes on Windows. So we need something that mimics a barrier, but uses Windows synchronization primitives which work across processes. 

We developed a small utility type called [CrossProcessBarrier][CrossProcessBarrier]. It uses global Mutex objects so synchronize across processes, and provides all we need. To enlist multiple participants in a cross-process barrier, we need some sort of identifier for each participant. Each participant needs to know the identifiers of the other participants. Based on these identifiers, each instance of the CrossProcessBarrier checks whether the others are already running (via a Mutex), and – once they all exist – releases the waiting thread. For a sample, see the [unit test][unittest] for the CrossProcessBarrier. 

## The ServerManagerBarrier

After having this cross-process synchronization primitive, the remaining step is to use that in our WebRole. The ServerManagerBarrier.ApplyServerManagerActions(Action<ServerManager> a) method allows you to pass in an Action<ServerManager> delegate in which you can safely apply the modifications you want to apply to IIS7. So that method (1) ensures you’re not trashing IIsConfigurator.exe, and (2) ensures your different web roles do not collide.

## An example

The example similar to what Wade Wegner does in his article on [“Programmatically Changing the AppPool Identity in a Windows Azure Web Role”][apppoolidentity]. 

```c#
var appPoolUser = "EUROPE\\chgeuer"; 
var appPoolPass = "top$secr3tPa55w0rd";

Action<ServerManager> updateIdentity = (serverManager) => 
{ 
    var sitename = RoleEnvironment.CurrentRoleInstance.Id + "_Web"; 
    var appPoolNames = serverManager.Sites[sitename].Applications.Select(app => app.ApplicationPoolName).ToList();

    foreach (var appPoolName in appPoolNames) 
    { 
        var pool = serverManager.ApplicationPools[appPoolName];

        pool.ProcessModel.IdentityType = ProcessModelIdentityType.SpecificUser; 
        pool.ProcessModel.UserName = appPoolUser; 
        pool.ProcessModel.Password = appPoolPass; 
    } 
    serverManager.CommitChanges(); 
};

ServerManagerBarrier.ApplyServerManagerActions(updateIdentity); 
```

# How do I get it? 

In your development project: Nuget!

The [NugetPackage WindowsAzure.DevelopmentFabric.IISConfigurator.Syncronizer][nuget] brings the library down right into your web role. Check out the sample in the [TweakIdentityWhenRunningInCorpnet()][tweakidentity] method on how to use it. 

# Source….

If you prefer source, grab it on [GitHub][azureiisconfiguratorsyncSource]  

[wade]: http://www.wadewegner.com/2011/01/programmatically-changing-the-apppool-identity-in-a-windows-azure-web-role/#comment-4251
[servermanagercommit]: http://msdn.microsoft.com/en-us/library/microsoft.web.administration.servermanager.commitchanges(v=vs.90).aspx
[nuget]: http://www.nuget.org/List/Packages/WindowsAzure.DevelopmentFabric.IISConfigurator.Syncronizer
[tweakidentity]: https://github.com/chgeuer/azureiisconfiguratorsync/blob/master/src/WindowsAzure.DevelopmentFabric.IISConfigurator.Syncronizer/MicrosoftCorpnetAuthenticationFixer.cs
[apppoolidentity]: http://www.wadewegner.com/2011/01/programmatically-changing-the-apppool-identity-in-a-windows-azure-web-role/
[unittest]: https://github.com/chgeuer/azureiisconfiguratorsync/blob/master/src/Tests/UnitTest1.cs
[CrossProcessBarrier]: https://github.com/chgeuer/azureiisconfiguratorsync/blob/master/src/WindowsAzure.DevelopmentFabric.IISConfigurator.Syncronizer/CrossProcessBarrier.cs
[azureiisconfiguratorsyncSource]: https://github.com/chgeuer/azureiisconfiguratorsync
