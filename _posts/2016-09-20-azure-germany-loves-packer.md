---
layout: default
title: "Microsoft Azure Germany loves packer.io"
date: 2016-09-20 11:31:00
---

![Microsoft Azure Germany loves packer.io][header]

In the [previous article][serviceprincipalgermany], I described how you can create a service principal in Azure Active Directory (incl. Azure Germany). In this article, we will explore how to use [Hashicorp's open-source `packer` toolchain][packer] to automatically create custom VM images, both for Windows- and Linux-VMs. 

Before we dig into the details, let's first explore which options we have to get software packages installed on a VM in the cloud: 

## How to install software on a VM in the cloud?

### Manual installation

The easiest, ad-hoc approach is to just spin off a Windows/Linux VM, then RDP/ssh into the box, copy the bits over, and click sudo start setup.exe and the like. Clearly, that's a low barrier of entry, but is totally error-prone, non-repeatable and labor intense. When new versions of the software get released, patches are rolled out, etc., somebody must invest time to build a new "golden master" VM image. 

### Configuration Management Systems: Chef, Puppet, Ansible & Saltstack

Configuration Management Tools such as [puppet][puppetazure], [Chef][chefazure], [Ansible][ansibleazure], [Salt Stack][saltazure] or [Powershell Desired State Configuration][dscazure] provide a great story for managing large fleets of VMs in the cloud, preventing configuration drift, applying changes to large sets of machines, etc. 

Often though, these tools need some sort of central server running somewhere, like a 'DSC pull server' or a 'Chef server' to host and run the runbooks, recipies, and what have you. 

### Custom Script Extension

For simple cases of automating software installation, Azure supports the [custom script extension][azureCustomScriptExtension]. This extension allows an ARM-based VM deployment to refer to a shell script, and additional assets, which upon deployment time are downloaded onto the VM, and executed. 

The following example ensures that a `.sh`-script and an `.tar.gz`-archive are downloaded to the VM, and the script is executed using the BASH shell:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    ...,
    "resources": [
        {
            "type": "Microsoft.Compute/virtualMachineScaleSets",
            ...,
            "properties": {
                "virtualMachineProfile": {
                    "extensionProfile": {
                        "extensions": [
                            {
                                "name": "CustomScriptExtensionVMSS",
                                "properties": {
                                    "publisher": "Microsoft.OSTCExtensions",
                                    "type": "CustomScriptForLinux",
                                    "typeHandlerVersion": "1.4",
                                    "autoUpgradeMinorVersion": false,
                                    "settings": {
                                        "fileUris": [
                                            "https://raw.githubusercontent.com/chgeuer/repo/master/scripts/install-stuff.sh",
                                            "https://bits.blob.core.windows.net/software/mypackage.tar.gz",
                                        ],
                                        "commandToExecute": "bash install-stuff.sh mypackage.tar.gz"
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }
    ]
}
```

The previous example lists directly downloadable resources. Using "Shared Access Signatures" to control access to blobs in Azure Storage, with ARM template parameters, and the ARM `[concat()]` function, you can also ensure that confidential assets are not plain on the Internets (as I do here for illustration purposes). 

The largest disadvantage of the custom script extension is the impact on runtime performance, respectively deployment latency: When you deploy a set of VMs using an ARM template, assuming each of these machines need to download and install a reasonably complect software package, it can take quite a while until all machines are ready to rock. 

### packer

[Hashicorp's open-source `packer` tool][packer] is an executable which can be launched on a local machine (such as a developer's laptop, or a build server). `packer` spins up a VM in one or more data centers (and one or more clouds for that matter). Once the VMs are up and running, `packer` connects to the VM (using Powershell WinRM for Windows VMs, or ssh for Linux VMs), and *does whatever you want it to do*. Most important, you can let packer upload files, and run commands on the remote machine. At the end of all tasks on the VM, packer runs sysprep and shuts down the VM, resulting in a 'golden image' you can then use to fire off readily installed VMs. 

Compared to the custom script extension, packer shifts waiting time away from the actual VM provisioning: Whenever the software department releases a new version, the build server can connect to all deployment environments (cloud vendors and data centers), and create the latest and greated image. So longer "compile time", much faster "startup time". 

## Install `packer`

`packer` is a stand-alone compiled binary, implemented in Go. You can grab compiled Mac OS X/Linux/Windows binaries from the [packer downloads page][packerDownload], or you compile it yourself.

### Building packer from scratch (on Windows)

If you're running on Windows, first install Go from the [downloads page][goDownload]. I used the `go1.7.1.windows-amd64.msi` installer. This installs Go under `C:\go`. In addition, you need a [`git` command line client][gitDownload] (so that the Go build process can fetch the packer source code). 

#### Set a bunch of environment variables

After installing Go, you need to set a few environment variables. The `setx /M` changes HKLM and needs admin privileges.

```
mkdir %USERPROFILE%\go
setx    GOPATH %USERPROFILE%\go
setx    GOBIN  %GOPATH%\bin
setx    PATH  %PATH%;%GOBIN%
setx /M GOROOT C:\Go\
setx /M GO15VENDOREXPERIMENT 1
```

Then, start a new shell (to pick up the changed environment variables) and run the command `go get github.com/mitchellh/packer`. That fetches the packer source code from github, compiles everything, and stores the `packer.exe` binary into your home directory's `%USERPROFILE%\go\bin\packer.exe`

## Security Setup

The next thing you need is a so-called 'service principal' in Azure Active Directory which has 'Contributor' access to your Azure subscription. In short, a service principal is a user account, used by an automated process (such as packer), which can login to Azure. 

First, you create an app in Azure Active Directory:

```bash
azure ad app create --json \
  --name "Service Principal Packer" \
  --home-page "https://packer.geuer-pollmann.de" \
  --identifier-uris "https://packer.geuer-pollmann.de" \
  --key-type Password \
  --password SuperLongPassword123.-
```

Then, list the applications you have, pick your `packer` app, and take note of the application ID (`appId`):

```bash
azure ad app list --json
```

This call returns 

```json
[
  {
    "displayName": "Service Principal Packer",
    "objectType":  "Application",
    "appId":       "1326f47c-eaea-42aa-8aa8-ff99fbaf3da9",
    "objectId":    "aa0f0531-f84d-4205-b4a4-31016e136bc9",
    "availableToOtherTenants": false,
    "identifierUris": [ "https://packer.geuer-pollmann.de" ],
    "replyUrls":      [],
    "homepage":       "https://packer.geuer-pollmann.de"
  },
  ...
]
```

In the next step, we promote our app to be a "service principal", and we list the service principals we have: 

```bash
azure ad sp create --json -vv --applicationId 1326f47c-eaea-42aa-8aa8-ff99fbaf3da9

azure ad sp list --json
```

```json
[
 {
   "displayName": "Service Principal Packer",
   "objectType":  "ServicePrincipal",
   "appId":       "1326f47c-eaea-42aa-8aa8-ff99fbaf3da9",
   "objectId":    "56e6ca9e-f654-4f92-88c5-5347c621efc7",
   "servicePrincipalNames": [ "http://geuer-pollmann.de/packer", "1326f47c-eaea-42aa-8aa8-ff99fbaf3da9" ]
 },
 ...
]
```

This time note down the `objectId` of the service principal listing. (Note that the `appId` from the `azure ad app list` and `azure ad sp list` calls is the same, but the `objectId` differs).

By this time, you should have 5 specific values: 

  1 Your Azure Active Directory TenantID (use the `tenantId` from `azure account show --json`)
  2 Your Azure Subscription ID (the `id` from `azure account show --json`)
  3 Your service principal's `appId`
  4 Your service principal's `objectId`
  5 Your service principal's password. If you don't know this one, it's certainly `SuperLongPassword123.-`. If so, you simply copy and pasted the code snippet above into your console. DO NOT COPY RANDOM STUFF INTO YOUR ADMIN CONSOLE. Even if I tell you so. Bad security practice. Call `azure ad sp delete` and `azure ad app delete` to delete the current service principal account, and start again. With. A. Secure. Password. Please. 










- [Create a service principal who is Contributor in your subscription](https://github.com/chgeuer/platform.sh.azure/blob/088d921e78fa3233d59107880b63308151a0afe4/arbitrary-code.sh#L9-L39)
- Store the service principal's password in an environment variable named `PACKER_AZUREPUBLIC_CLOUD_CLIENTKEY` 
- Store the JSON below in local file, and tweak your Azure AD Tenant ID, Subscription ID, service principal's client ID, etc. 







## Provisioning a Windows VM


![packer interactions with Azure provisining a Windows VM][windowsflow]








[header]: /img/2016-09-20-packer-germany/azure-loves-packer.png "Microsoft Azure loves packer.io"
[windowsflow]: /img/2016-09-20-packer-germany/packer-windows-deployment.png
[serviceprincipalgermany]: /blog/2016/06/27/azure-arm-serviceprincipal
[packer]: https://www.packer.io/
[packerBuilderAzure]: https://www.packer.io/docs/builders/azure.html
[puppetazure]: https://puppet.com/blog/managing-azure-virtual-machines-puppet
[chefazure]: https://github.com/chef/chef-provisioning-azure
[ansibleazure]: https://docs.ansible.com/ansible/guide_azure.html
[saltazure]: https://docs.saltstack.com/en/latest/topics/cloud/azure.html
[dscazure]: https://azure.microsoft.com/en-gb/documentation/articles/automation-dsc-overview/
[azureCustomScriptExtension]: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-extensions-customscript/
[packerDownload]: https://www.packer.io/downloads.html
[goDownload]: https://golang.org/dl/
[gitDownload]: https://git-scm.com/download/win

