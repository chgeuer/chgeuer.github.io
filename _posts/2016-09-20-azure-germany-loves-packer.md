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




```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    [...],
    "resources": [
        {
            "type": "Microsoft.Compute/virtualMachineScaleSets",
            [...],
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













| Custom Script Extension | packer |
| ------------- | ------------- |
| Content Cell  | Content Cell 1 |
| Content Cell  | Content Cell  |




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
