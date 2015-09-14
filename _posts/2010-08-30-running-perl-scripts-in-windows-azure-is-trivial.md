---
layout: default
title: "Running Perl scripts in Windows Azure is trivial"
date: 2010-08-30 01:00:00
keywords: perl, azure, paas
---

In this article, I describe how to run a Perl script in a Windows Azure worker instance. One of our partners in our e-Science research project VENUS-C heavily relies on Perl for scientific computations, so I was curious to see through how many hoops I would have to jump to get this going. I did not need any advanced Kung-Fu, it just worked out of the box. Problem solved. 

#The quick facts

Simply speaking, your Azure worker needs to do the following:

1. In your OnStart() method, download and ‘install’ Perl 
	- By shipping it with your .cspack file, or 
	- by dynamically downloading it from a well-known location and 
	- Unzipping it to a local resource folder. 
2. Launch Perl with your script ◾Make sure your ProcessStartInfo.EnvironmentVariables["Path"] contains the subdirectories "perl\site\bin", "perl\bin" and "c\bin" 
	- If necessary, grab the script’s stdout/stderr output. 


#The long explanation

##Which Perl

When looking for an up-to-date Perl distribution for Windows, I stumbled across Strawberry Perl (http://strawberryperl.com/). This distribution comes in two flavors: an MSI installer and a ‘portable’ version. The MSI installer is useful for a clean install/uninstall on your regular Windows box where you are the administrator. The portable installation, which is a 55MB ZIP file, is suitable for environments where you cannot run an installer, such as Windows Azure, where you currently (as of August 2010) have no administrative privileges. I did not try other Perl distributions, but the process described here should apply to others as well. Anyway, get a ‘portable’, i.e. an XCopy-deployable version. 

##Deploying Perl

###Downloading

To get the Perl binaries onto your worker instance, you basically have two options: You can either ship your binaries as part of your published cloud service, or you fetch Perl when your role starts. Including the Perl ZIP file as a resource in your worker role has the advantage that you have a self-contained package without any moving parts. In the sample attached to this article, the worker role downloads and extracts the Perl distribution in the OnStart() method. A configuration setting lists alternative download locations, such as a fast and cheap CDN location and the fallback on the master site. Alternatively, you can store such a pre-requisite for your worker role in Azure blob storage. 


```xml
<ServiceConfiguration ...>
  <Role name="WorkerRole">
    <ConfigurationSettings>
      <Setting name="PerlDownloadAddresses" 
               value="http://d10xg45o6p6dbl.cloudfront.net/projects/s/strawberry-perl/strawberry-perl-5.12.1.0-portable.zip 
                      http://strawberryperl.com/download/strawberry-perl-5.12.1.0-portable.zip" />


    </ConfigurationSettings>
    <Instances count="1" />
  </Role>
</ServiceConfiguration>
```

Using .NET’s System.Net.WebClient class, you can quickly download the file locally:

```c#
string downloadAddress = "http:// ... URL ... /strawberry-perl-5.12.1.0-portable.zip";
string localPerlArchiveFilename = "strawberry-perl-5.12.1.0-portable.zip";
new WebClient().DownloadFile(downloadAddress, localPerlArchiveFilename);
```
 
### Unzipping

The local copy of the Perl ZIP file then needs to be unpacked, for example using the Ionic.Zip.dll from CodePlex. The unpacked Perl distribution has a size of ca. 190MB, so reserving local storage of 250MB sounds reasonable. 

```xml
<ServiceDefinition ...>
  <WorkerRole name="WorkerRole">
     ...
    <LocalResources>
      <LocalStorage name="PerlDir" 
                    cleanOnRoleRecycle="false" 
                    sizeInMB="250" />
    </LocalResources>
  </WorkerRole>
</ServiceDefinition>
```

In your worker role, you can fetch the corresponding directory

```c#
string perlfolder = RoleEnvironment.GetLocalResource("PerlDir").RootPath;
```

Using Ionic.Zip.dll, you quickly unzip if necessary:

```c#
using (var zip = new ZipFile(localPerlArchiveFilename))
{
   zip.ExtractAll(perlfolder, 
      ExtractExistingFileAction.DoNotOverwrite);
}
```

# Running the script

When you look at the Perl distribution, it ships with a file called ‘portableshell.bat’. The main thing it does is that it adds the appropriate folders to the Path environment variable. The following subfolders need to be in the path:

- "perl\site\bin", 
- "perl\bin" and 
- "c\bin" 


```c#
string perlfolder = RoleEnvironment.GetLocalResource("PerlDir").RootPath; 
string currentDir = (new DirectoryInfo(".")).FullName; 

ProcessStartInfo psi = new ProcessStartInfo()
{
    Arguments = perlcommandline, 
    CreateNoWindow = true, 
    UseShellExecute = false, 
    RedirectStandardOutput = true, 
    RedirectStandardError = true
}; 

string[] relPathExtensions = new[] { @"perl\site\bin", 
                                @"perl\bin", @"c\bin" }; 
IEnumerable<string> pathExtensions = relPathExtensions
    .Select(p => Path.Combine(currentDir, perlfolder, p)); 
string path = psi.EnvironmentVariables["Path"]; 
List<string> pathSegments = new List<string>(); 
pathSegments.AddRange(path.Split(';')); 
pathSegments.AddRange(pathExtensions); 
path = string.Join(";", pathSegments); 
psi.EnvironmentVariables["Path"] = path;
    
string pathToPerlExecutable = Path.Combine(
      currentDir, perlfolder, @"perl\bin\perl.exe"); 
pathToPerlExecutable = (new FileInfo(pathToPerlExecutable)).FullName;
psi.FileName = pathToPerlExecutable;
```

When launching Perl, you use the executable in "perl\bin\perl.exe". 

Given that your script is running at a remote location (in a Microsoft data center), you need to ensure that you capture the output (stdout / stderr) of the script. In the code snippet below, I’m just tracing it into Azure diagnostics.

```c#
ProcessStartInfo psi = ...
Process process = Process.Start(psi);
string stdout = process.StandardOutput.ReadToEnd();
string stderr = process.StandardError.ReadToEnd();
Trace.TraceInformation("Script output: " + stdout);
Trace.TraceError("Script error output: " + stderr);
```

# Summary

What you should take away from this article is that running Perl on the Azure is a very straightforward experience: get and install Perl, setup the execution environment for your process, and here you go… Just launch Perl. 

