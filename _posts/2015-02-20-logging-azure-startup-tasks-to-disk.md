---
layout: default
title: "Logging Azure startup task output to disk"
date: 2015-02-20
keywords: azure startup
published: false
---

# Logging Azure startup task output to disk

https://github.com/chgeuer/UnorthodoxAzureLogging


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




