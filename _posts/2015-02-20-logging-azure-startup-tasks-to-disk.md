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

## Implementation

The solution uses a chain of 4 batch and PowerShell scripts to achieve this goal. Maybe it's too complicatedm but it seemed the easiest for me: 

1 First, the `csdef` file lists a startup task for `commandLine="SetupScripts\install.cmd"`
2 The batch file `install.cmd` launches the PowerShell script `install.ps1` 
3 `install.ps1` 
	- determines deployment ID, role instance ID, 
	- derives logfile names,
	- sets local environment variables accordingly
	- kicks off `install2.cmd`
4 `install2.cmd` starts `install2.ps1` (the actual workhorse), redirecting STDOUT and STDERR to the proper logfile
5 `install2.ps1` does whatever it has to do, simply spitting out data to STDOUT

## CloudService/ServiceDefinition.csdef

First, the `csdef` file lists a startup task for `commandLine="SetupScripts\install.cmd"`.

```xml
<!-- CloudService/ServiceDefinition.csdef -->
<ServiceDefinition ... >
  <WorkerRole name="..." vmsize="...">
    <Startup>
      <Task commandLine="SetupScripts\install.cmd" executionContext="elevated" taskType="simple" />
    </Startup>
  </WorkerRole>
</ServiceDefinition>
```

## WorkerRole/SetupScripts/install.cmd

The batch file `install.cmd` launches the PowerShell script `install.ps1` 

```batch
REM WorkerRole/SetupScripts/install.cmd
cd /d "%~dp0"
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted -File "%~dp0install.ps1"
exit /b 0
```

## WorkerRole/SetupScripts/install.ps1

- determines deployment ID, role instance ID, 
- derives logfile names,
- sets local environment variables accordingly
- kicks off `install2.cmd`

```powershell
# WorkerRole/SetupScripts/install.ps1
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

`install2.cmd` starts `install2.ps1` (the actual workhorse), redirecting STDOUT and STDERR to the proper logfile (`> %logfilename% 2>>&1`)

```batch
REM WorkerRole/SetupScripts/install2.cmd
cd /d "%~dp0"
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted -File "%~dp0install2.ps1" > %logfilename% 2>>&1
exit /b 0
```

## WorkerRole/SetupScripts/install2.ps1

`install2.ps1` does whatever it has to do, simply spitting out data to STDOUT (via `Write-Host`)

```powershell
# WorkerRole/SetupScripts/install2.ps1
[void] [Reflection.Assembly]::LoadWithPartialName("Microsoft.WindowsAzure.ServiceRuntime") 
if (![Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsAvailable)
{
    Write-Host "Not running in fabric, exiting"
    return
}

$logfolder = [System.Environment]::GetEnvironmentVariable("$logfolder")

Write-Host "All my STDOUT goes to $($logfolder)"

Write-Host "Doing some stuff"
[System.Threading.Thread]::Sleep(1000)
Write-Host "Doing other  stuff"
```

Of course, don't forget to mark all the setup files with "Copy Always" in Visual Studio's file properties :-). 

That's it. Have fun, 
Christian