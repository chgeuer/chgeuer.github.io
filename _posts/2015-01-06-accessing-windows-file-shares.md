---
layout: default
title: "Accessing my private music from my domain-joined laptop"
date: 2015-01-06
keywords: windows8
published: true
---

This post briefly touches on how to access a Windows 8.1 machine's file shares using a Microsoft Account. When I'm working from home, I like to listen to music which is stored on my private computer. Windows 8 seems to turn off the ``\\server\c$`` admin shares, and I didn't really understand how the whole Microsoft Account thing fits with SMB shares.  

## Turn on file sharing (admin shares) on Windows 8

To turn the admin share ``c$``, ``d$`` etc. back on, you need to set/create the ``LocalAccountTokenFilterPolicy`` registry setting: 

```
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"LocalAccountTokenFilterPolicy"=dword:00000001
```

## Provision the Microsoft Account user name: 

Simply speaking, the SMB user name for the Microsoft account ``christian@outlook.de`` becomes ``MicrosoftAccount\christian@outlook.de`` by prefixing it. For instance, you can now run 

```
NET USE X: \\192.168.0.5\c$ /USER:MicrosoftAccount\christian@outlook.de
```

```xml
<a href="fio" />
```