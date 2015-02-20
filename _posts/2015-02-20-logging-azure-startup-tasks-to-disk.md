---
layout: default
title: "Logging Azure startup task output to disk"
date: 2015-02-20
keywords: azure startup development 
published: true
---

# Logging Azure startup task output to disk

When I develop an Azure cloud service (PaaS), I often have setup scripts which need to run. Usually, these scripts generate some form of output on STDOUT and STDERR, which I'd like to capture somewhere. So the easiest way would be to write that output to some fixed location, such as `C:\logs` and grab it from there. 

The problem with this approach is that it doesn't work well in the development fabric, i.e. when I simulate multiple WebRoles or WorkerRoles on my development laptop, cause all scripts running in parallel, writing to the same folder, isn't a great idea. I wanted a solution where the real setup script simply spits out log data to the console, and where that output is written to a _unique_ directory. 

In this sample, you can see that this unique directory is a folder like `C:\log-deployment25(0).TableLoggingCloudService.WorkerRole_IN_3`, where the folder name contains the deployment ID and instance ID, and a new log file for each execution of the setup script (for instance, after a machine reboot).

You can have a look at my [github project](https://github.com/chgeuer/UnorthodoxAzureLogging) for a sample implementation. 

<div>
	<img src="/img/2015-02-20-logging-azure-startup-tasks-to-disk/cdrive.png" alt="screenshot C:\-Drive"></img>
</div>

## CloudService/ServiceDefinition.csdef

```xml
<ServiceDefinition ... >
  <WorkerRole name="..." vmsize="...">
    <Startup>
      <Task commandLine="SetupScripts\install.cmd" executionContext="elevated" taskType="simple" />
    </Startup>
  </WorkerRole>
</ServiceDefinition>
```

## WorkerRole/SetupScripts/install.cmd

```batch
cd /d "%~dp0"
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted -File "%~dp0install.ps1"
exit /b 0
```

## WorkerRole/SetupScripts/install.ps1

```powershell
[Reflection.Assembly]::LoadWithPartialName("Microsoft.WindowsAzure.ServiceRuntime") 
if (![Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsAvailable)
{
    Write-Host "Not running in fabric, exiting"
    return;
}

$drive = "C"
$prefix = "log-"
$logfolder = "$($drive):\$($prefix)$([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::CurrentRoleInstance.Id)"
$logfilename = "$($logfolder)\$([System.DateTime]::UtcNow.ToString("yyyy-MM.dd--HH-mm-ss-fff")).txt"

if (-not (Test-Path -Path $logfolder)) 
{ 
    [void] (New-Item -ItemType Directory -Path $logfolder ) 
}
[System.Environment]::SetEnvironmentVariable("$logfolder", $logfolder)
[System.Environment]::SetEnvironmentVariable("logfilename", $logfilename)
Start-Process -NoNewWindow -Wait -FilePath "$($Env:windir)\System32\cmd.exe" -ArgumentList "/C $(Get-Location)\install2.cmd"
```

## WorkerRole/SetupScripts/install2.cmd

```batch
cd /d "%~dp0"
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted -File "%~dp0install2.ps1" > %logfilename% 2>>&1
exit /b 0
```

## WorkerRole/SetupScripts/install2.ps1

```powershell
[void] [Reflection.Assembly]::LoadWithPartialName("Microsoft.WindowsAzure.ServiceRuntime") 
if (![Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsAvailable)
{
    Write-Host "Not running in fabric, exiting"
    return
}

$logfolder = [System.Environment]::GetEnvironmentVariable("$logfolder")

Write-Host "Doing some stuff"

[System.Threading.Thread]::Sleep(1000)

Write-Host "Doing other  stuff"
```




