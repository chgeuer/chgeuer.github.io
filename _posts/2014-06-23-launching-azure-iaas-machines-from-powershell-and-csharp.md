---
layout: default
title: "Launching Azure IaaS VMs from Powershell and C#"
date: 2014-06-23
keywords: azure, iaas, virtual machines, powershell
published: true
---


Microsoft Azure's IaaS 'Virtual Machines' feature allows customers to enrich machines with so-called 'extensions' at provisioning time. For instance, the BGInfo extension displays machine parameters (IP addresses etc.) on the admin's desktop wallpaper. Extensions for [Chef and Puppet][ChefAndPuppetAnnouncement] allow automation in large IaaS deployments by controlling all the VMs from a central management instance. 

In some cases, you may just want to inject some custom script into a fresh Linux or Windows machine. Sandrino Di Mattia wrote a nice introductory [blog article][CustomScriptExtensionSandrinoDiMattia] about Microsoft's so-called "CustomScript" extension. Basically, the extension get's the address of a Powershell Script file, this script is downloaded upon machine startup and executed. For a customer engagement in the gaming industry, I needed a simple way to inject custom bits into a to-be-started VM, and I wanted to do that from the C#-side with the [Microsoft Azure Management Libraries (MAML)][MicrosoftAzureManagementLibrariesWilcox]. 

# Doing it all from PowerShell

To test the waters first, I tried the Powershell route as well to ensure everything works in principle.

## Setting the deployment variables

The first part is probably self-explanatory: Define machine names, machine sizes, etc. One thing I prefer is to keep actual credential information out of my scripts (and demos), so that the admin password for the Azure VMs is in an environment variable on my laptop. This ensures I do not accidentally 'git push' my password into a gist or so.  

```powershell
$vmname =         "cgp$([System.DateTime]::UtcNow.ToString("yyMMddhhmmss"))"

$datacenter =     "West Europe"

$adminuser =      "chgeuer"

# passwords do not belong in version control :-)
$adminpass =      $env:AzureVmAdminPassword

# ExtraSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4
$instanceSize =   "Basic_A0"                                                 

# security by obscurity
$externalRdpPort = 43379
```

## Lookup of the VM image name

The names of VM images in Azure must be unique, but I prefer to keep these ephemeral-looking strings out of my script, and use something more verbose. This code helps me to lookup a concrete VM image name based on a human-understandable label:  

```powershell
# One from Get-AzureVMImage | select Label
$imageLabel = "Windows Server 2012 R2 Datacenter, May 2014"            

$imageName = (Get-AzureVMImage | `
	Where-Object Label -eq $imageLabel).ImageName
```

## Subscription Name lookup

In contrast to C#, on the Powershell side of things, we need to supply a "subscription name" to retrieve the proper Azure credentials, instead of a subscription (GUID) ID. Here, I prefer to have the 'hard' subscription ID in my code, cause my customer's subscription names are not always very helpful:  

```powershell
$subscriptionId = "deadbeef-2222-3333-dddd-1222deadbeef"

$subscriptionName = (Get-AzureSubscription | `
	select SubscriptionName, SubscriptionId | `
	Where-Object SubscriptionId -eq $subscriptionId | `
	Select-Object SubscriptionName)[0].SubscriptionName
```

>
> Forgive that I use PowerShell's word-wrap operator (backtick) to spread long command lines  in this sample. [Splatting][PowerShellSplatting] is certainly better, but bear with me for the demo. 
>


## Determine VHD storage path

A reverse-lookup for 'some' storage account in the correct Azure region helps me to figure out where I want the OS Disk's VHD to be placed. I prefer to name the OS Disk's blob name individually, otherwise Azure chooses a disk name for me.

```powershell
$storageAccount = (Get-AzureStorageAccount | `
	Where-Object Location -eq $datacenter)[0]

$storageAccountName = $storageAccount.StorageAccountName

$storageAccountKey = (Get-AzureStorageKey `
	-StorageAccountName $storageAccount.StorageAccountName).Primary

$storageContext = New-AzureStorageContext `
	-StorageAccountName $storageAccount.StorageAccountName `
	-StorageAccountKey $storageAccountKey

$osDiskMediaLocation = "https://$($storageAccount.StorageAccountName).blob.core.windows.net/vhds/$vmname-OSDisk.vhd"
```

## A script that writes scripts

The next step is to upload the Powershell-Script which we want to run inside the machine to Azure blob storage (into a private container). To do so, we

- create a local PS1 file on our laptop, 
- create the 'scripts' container in blob storage if necessary and
- upload the script to the container. 

For simplicity's sake, I just took Sandrino's mkdir-Script which takes a single parameter. Using this mechanism (having one script per VM), you can now customize these script contents with machine-specific deployment information. Given that the script will be stored in a private blob, you can also throw machine-specific, private information in there:  

```powershell
#
# Script Contents
#
$launchScriptFilename = "$($vmname).ps1"

$scriptContainer = "scripts"

$scriptContent = @'
param($dir)
mkdir $dir
'@

$scriptContent | Out-File $launchScriptFilename 

if (($(Get-AzureStorageContainer -Context $storageContext) | where Name -eq $scriptContainer) -eq $null) 
{
	New-AzureStorageContainer `
		-Context $storageContext `
		-Container $scriptContainer 
}

Set-AzureStorageBlobContent `
	-Context $storageContext `
	-Container $scriptContainer `
	-BlobType Block `
	-Blob $launchScriptFilename `
	-File $launchScriptFilename
```

## Create the VM configuration

The actual magic of configuring the VM lies in the ``Set-AzureVMCustomScriptExtension`` call; by specifying ``-StorageAccountKey``, ``-StorageAccountName``, ``-ContainerName`` and ``-FileName``, the stored Powershell file is downloaded from the private blob storage container onto the VM and called with ``-ExecutionPolicy Unrestricted``and the proper ``-Argument``.

```powershell

# 
# configure the VM object
#
$vm = New-AzureVMConfig `
		-Name "$vmname" `
		-InstanceSize $instanceSize `
		-ImageName $imageName `
		-MediaLocation $osDiskMediaLocation `
		-HostCaching "ReadWrite" | `
	Add-AzureProvisioningConfig `
		-Windows `
		-AdminUsername $adminuser `
		-Password $adminpass  | `
	Remove-AzureEndpoint `
		-Name RDP | `
	Add-AzureEndpoint `
		-Name RDP `
		-LocalPort 3389 `
		-PublicPort $externalRdpPort `
		-Protocol tcp | `
	Set-AzureVMCustomScriptExtension `
		-StorageAccountKey $storageAccountKey `
		-StorageAccountName $storageAccount.StorageAccountName `
		-ContainerName $scriptContainer `
		-FileName $launchScriptFilename `
		-Run $launchScriptFilename `
		-Argument 'c:\hello_from_customscriptextension'

```


## The full Powershell Script

```powershell

# Azure Cmdlet Reference
# http://msdn.microsoft.com/library/azure/jj554330.aspx

$vmname =         "cgp$([System.DateTime]::UtcNow.ToString("yyMMddhhmmss"))"

Write-Host "Machine will be at $($vmname).cloudapp.net"

$subscriptionId = "deadbeef-2222-3333-dddd-1222deadbeef"

$imageLabel =     "Windows Server 2012 R2 Datacenter, March 2014"            # One from Get-AzureVMImage | select Label
$datacenter =     "West Europe"
$adminuser =      "chgeuer"
$adminpass =      $env:AzureVmAdminPassword
$instanceSize =   "Basic_A0" # ExtraSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4
$externalRdpPort = 54523

#
# Calculate a bunch of properties
#
$subscriptionName = (Get-AzureSubscription | select SubscriptionName, SubscriptionId | Where-Object SubscriptionId -eq $subscriptionId | Select-Object SubscriptionName)[0].SubscriptionName




$imageName = (Get-AzureVMImage | `
	Where-Object Label -eq $imageLabel).ImageName

$storageAccount = (Get-AzureStorageAccount | `
	Where-Object Location -eq $datacenter)[0]

$storageAccountName = $storageAccount.StorageAccountName

$storageAccountKey = (Get-AzureStorageKey `
	-StorageAccountName $storageAccount.StorageAccountName).Primary

$storageContext = New-AzureStorageContext `
	-StorageAccountName $storageAccount.StorageAccountName `
	-StorageAccountKey $storageAccountKey

$osDiskMediaLocation = "https://$($storageAccount.StorageAccountName).blob.core.windows.net/vhds/$vmname-OSDisk.vhd"

#
# Fix the local subscription object
#
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName 

#
# Script Contents
#
$launchScriptFilename = "$($vmname).ps1"

$scriptContent = @'
param($dir)
mkdir $dir
mkdir C:\testdir
'@

$scriptContent | Out-File $launchScriptFilename 

$scriptContainer = "scripts"
if (($(Get-AzureStorageContainer -Context $storageContext) | where Name -eq $scriptContainer) -eq $null) 
{
	New-AzureStorageContainer `
		-Context $storageContext `
		-Container $scriptContainer 
}

Set-AzureStorageBlobContent `
	-Context $storageContext `
	-Container $scriptContainer `
	-BlobType Block `
	-Blob $launchScriptFilename `
	-File $launchScriptFilename

# Get-AzureStorageBlobContent -Context $storageContext -Container $scriptContainer -Blob $launchScriptFilename

# 
# configure the VM object
#
$vm = New-AzureVMConfig `
		-Name "$vmname" `
		-InstanceSize $instanceSize `
		-ImageName $imageName `
		-MediaLocation $osDiskMediaLocation `
		-HostCaching "ReadWrite" | `
	Add-AzureProvisioningConfig `
		-Windows `
		-AdminUsername $adminuser `
		-Password $adminpass  | `
	Remove-AzureEndpoint `
		-Name RDP | `
	Add-AzureEndpoint `
		-Name RDP `
		-LocalPort 3389 `
		-PublicPort $externalRdpPort `
		-Protocol tcp | `
	Set-AzureVMCustomScriptExtension `
		-StorageAccountKey $storageAccountKey `
		-StorageAccountName $storageAccount.StorageAccountName `
		-ContainerName $scriptContainer `
		-FileName $launchScriptFilename `
		-Run $launchScriptFilename `
		-Argument 'c:\hello_from_customscriptextension'

#
# Create the VM
#
New-AzureVM -ServiceName "$vmname" -Location $datacenter -VMs $vm
```


# Doing it all from C#

To illustrate the whole steps from C# using the [Azure Mgmt libraries][MicrosoftAzureManagementLibrariesWilcox], check the following Github Repo: [https://github.com/chgeuer/LaunchVMinAzureWithCustomScript](https://github.com/chgeuer/LaunchVMinAzureWithCustomScript). 

The interesting piece is the C# code from [``Program.cs``][ProgramCS] which kicks off the deployment: It uses an X.509 certificate (stored in the LocalMachine\\My store) to connect to Azure, upload the Powershell-snippet to blob storage, and launch the VM. 

```csharp
var powerShellCode = @"
param($dir)
mkdir $dir
mkdir C:\testdir
";

var agent = new ScalingAgent(
    subscriptionID: "deadbeef-2222-3333-dddd-1222deadbeef",
    subscriptionManagementCertificateThumbprint: "A5596EA671EFFFFFFFFFFFFFFFFFFF88A5E4BF0F",
    storeLocation: StoreLocation.LocalMachine);

await agent.LaunchVMAsync(
    vmname: string.Format("cgp{0}", System.DateTime.UtcNow.ToString("yyMMddhhmm")),
    imageLabel: "Windows Server 2012 R2 Datacenter, May 2014",
    datacenter: "West Europe",
    instanceSize: "Basic_A2",
    adminuser: "chgeuer",
    adminpass: Environment.GetEnvironmentVariable("AzureVmAdminPassword"),
    externalRdpPort: 54523,
    powershellCode: powerShellCode, 
    powerShellArgs: "c:\\hello_from_customscriptextension");

``` 

Inside the [``ScalingAgent.cs``][ScalingAgentCS] file, I use a fluent API implemented in [ScalingExtensions.cs][ScalingExtensionsCS]. After the Powershell-script is uploaded to the storage account, I can create a new ``Role`` object, which is then deployed using the ``computeManagementClient.VirtualMachines.CreateDeploymentAsync()`` call. The subsequent calls to ``AddWindowsProvisioningConfiguration()``, ``AddInputEndpoint()`` or ``AddCustomScriptExtension()`` basically configure the ``Role``. 

```csharp
var role = new Role
{
    RoleName = vmname,
    Label = vmname,
    RoleSize = instanceSize,
    // VMImageName = imageName,
    ProvisionGuestAgent = true,
    RoleType = "PersistentVMRole",
    OSVirtualHardDisk = new OSVirtualHardDisk
    {
        HostCaching = "ReadWrite",
        MediaLink = new Uri(osDiskMediaLocation),
        Name = vmname,
        Label = vmname,
        SourceImageName = imageName
    }
}
.AddWindowsProvisioningConfiguration(
    computerName: vmname,
    adminUserName: adminuser,
    adminPassword: adminpass,
    resetPasswordOnFirstLogon: false,
    enableAutomaticUpdates: true)
.AddInputEndpoint(new InputEndpoint
{
    Name = "RDP",
    EnableDirectServerReturn = false,
    Protocol = "tcp",
    Port = externalRdpPort,
    LocalPort = 3389
})
.AddBGInfoExtension()
.AddCustomScriptExtension(
    storageAccount: realStorageAccount,
    containerName: containerName,
    filename: filename,
    arguments: powerShellArgs);



var status = await computeManagementClient.VirtualMachines.CreateDeploymentAsync(
    serviceName: vmname,
    parameters: new VirtualMachineCreateDeploymentParameters
    {
        Name = vmname,
        Label = vmname,
        DeploymentSlot = DeploymentSlot.Production,
        Roles = new List<Role> { role }
    });

```



If you think that post was helpful, a quick comment below or on [twitter.com/chgeuer](http://twitter.com/chgeuer) would be appreciated.  


[ChefAndPuppetAnnouncement]: http://weblogs.asp.net/scottgu/azure-updates-web-sites-vms-mobile-services-notification-hubs-storage-vnets-schedule-autoscale-and-more
[CustomScriptExtensionSandrinoDiMattia]: http://fabriccontroller.net/blog/posts/customizing-your-microsoft-azure-virtual-machines-with-the-new-customscript-extension/
[MicrosoftAzureManagementLibrariesWilcox]: http://www.jeff.wilcox.name/2014/04/wamlmaml/
[PowerShellSplatting]: http://technet.microsoft.com/en-us/magazine/gg675931.aspx
[ProgramCS]: https://github.com/chgeuer/LaunchVMinAzureWithCustomScript/blob/master/Program.cs
[ScalingAgentCS]: https://github.com/chgeuer/LaunchVMinAzureWithCustomScript/blob/master/ScalingAgent.cs
[ScalingExtensionsCS]: https://github.com/chgeuer/LaunchVMinAzureWithCustomScript/blob/master/ScalingExtensions.cs

