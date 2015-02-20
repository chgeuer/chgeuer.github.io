---
layout: default
title: "Getting your favorite tools onto your Azure VM"
date: 2015-02-20
keywords: azure interactive RDP
published: true
---

<!-- http://blog.geuer-pollmann.de/blog/2015/02/20/getting-your-favority-tools-onto-your-azure-vm/ -->


<blockquoteclass="twitter-tweet" lang="en"><p>Quickly install your favorite tools onto your <a href="https://twitter.com/Azure">@Azure</a> virtual machine <a href="http://blog.geuer-pollmann.de/blog/2015/02/20/getting-your-favority-tools-onto-your-azure-vm/">http://t.co/SC9D1ornAZ</a> <a href="https://twitter.com/hashtag/IaaS?src=hash">#IaaS</a> <a href="https://twitter.com/hashtag/RDP?src=hash">#RDP</a></p>&mdash; Chris Geuer-Pollmann (@chgeuer) <a href="https://twitter.com/chgeuer/status/568779615734534144">February 20, 2015</a></blockquote> <script asyncsrc="//platform.twitter.com/widgets.js" charset="utf-8"></script>


## Introduction

Whenever I log on to a fresh Windows VM (in Azure) to do debugging, I'm missing my favority tool chain, stuff such as Internet Explorer in a usable mode (not locked down to server), Sublime Text2, or Process Explorer. After going through the installation pain too often, I decided to optimize that flow:

- Have an installation script, versioned in Github
- Use the Chocolatey approach to kick the tires

To get the magic going, on my laptop, I navigate to https://github.com/chgeuer/AzureConvenience and copy the text at the bottom into the clipboard

```
@powershell -NoProfile 
	-ExecutionPolicy unrestricted 
	-Command "((new-object net.webclient).DownloadFile(
		'https://raw.githubusercontent.com/chgeuer/AzureConvenience/master/AzureConvenience.cmd', 
		'AzureConvenience.cmd'))" 
&& call AzureConvenience.cmd
```

Then in the RDP session, I copy the text into a command window, and wait. It uses PowerShell to download my `AzureConvenience.cmd` batch file, which in turn instally my favorite tool chain. The rest of this post goes though the contents of that batch file. 





## Tool chain

### Bring Internet Explorer into a usable shape

This is a copy/paste from [DisableIESecurity](https://github.com/richorama/AzurePluginLibrary/blob/master/plugins/DisableIESecurity/setup.cmd) script from Richard Astbury. 

```batch
REM Internet Explorer, thanks a lot. 
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f
Rundll32 iesetup.dll, IEHardenLMSettings
Rundll32 iesetup.dll, IEHardenUser
Rundll32 iesetup.dll, IEHardenAdmin
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /f /va
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /f /va
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "First Home Page" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Default_Page_URL" /t REG_SZ /d "about:blank" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f
```




### Install [chocolatey](https://chocolatey.org/)

```batch
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
```




### Use [chocolatey](https://chocolatey.org/) to install [Sublime Text 2](http://www.sublimetext.com/2) and put a shortcut onto the desktop

```batch
chocolatey install sublimetext2
mklink "%USERPROFILE%\Desktop\Sublime Text 2" "%ProgramW6432%\Sublime Text 2\sublime_text.exe"
```




### Use [chocolatey](https://chocolatey.org/) to install sysinternals, generate some links and start some tools

```batch
chocolatey install sysinternals
start "" %SystemDrive%\tools\sysinternals\Dbgview.exe /accepteula

REM Process Explorer
start "" %SystemDrive%\tools\sysinternals\procexp.exe /accepteula
# ping, a.k.a. pause 2000 ms
ping 1.1.1.1 -n 1 -w 2000 >NUL
copy %tmp%\procexp64.exe %windir%\system32
mklink "%USERPROFILE%\Desktop\ProcExp64" %windir%\system32\procexp64.exe
start "" %windir%\system32\procexp64.exe
```




### Download and install [CLink](http://mridgers.github.io/clink/), which enables me to Ctrl-V into a command line

```batch
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "((New-Object System.Net.WebClient).DownloadFile('https://github.com/mridgers/clink/releases/download/0.4.3/clink_0.4.3.zip','clink_0.4.3.zip' ));[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem');[System.IO.Compression.ZipFile]::ExtractToDirectory('clink_0.4.3.zip', '.')"
start "" .\clink_0.4.3\clink_x64.exe autorun -i
```

Now should should be able to build your own tool installer. 

That's it. Have fun, 
Christian
