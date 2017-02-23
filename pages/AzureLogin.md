---
layout: default
title: "Azure RM Logins"
---

- Azure Resource Manager Login Stuff
    - [Certificate-based auth with Azure Service Principals from Linux command line](http://blogs.msdn.com/b/arsen/archive/2015/09/18/certificate-based-auth-with-azure-service-principals-from-linux-command-line.aspx)
    - [Authenticating a service principal with Azure Resource Manager](https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/)
    - [Python access to ARM](https://github.com/gbowerman/azurerm)


```
"<TenantId>"      is something like "adadadad-adad-adad-adad-adadadadadad"
"<ApplicationId>" is something like "40302010-feda-deaf-beef-deadbeef0123"
```

# Setup service principal in Powershell

## Install Azure Powershell according the [docs](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

```ps1
# Install the Azure Resource Manager modules from the PowerShell Gallery
Install-Module AzureRM
Install-AzureRM
Install-Module Azure

Import-AzureRM
Import-Module Azure
```

## Create a certificate using `makecert.exe`

```ps1
$subjectName = "CN=AzureServicePrincipal"
$certificateFile = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "$($subjectName.Replace('CN=', '')).cer")
$azureADTenantID = $env:AzureADTenantID; # "adadadad-adad-adad-adad-adadadadadad"
$subscriptionID = $env:AzureSubscriptionID; # "706df49f-998b-40ec-aed3-7f0ce9c67759"
$manualBillingAdmin = $env:AzureManualBillingAdmin; # "billingoperator@contoso.onmicrosoft.com"
$appName = "Azure Service Principal for Automation"
$dummyUrl = "http://localhost/serviceprincipal"

# fetch makecert from some random dude on the Internet :-/
(New-Object Net.WebClient).DownloadFile('https://gist.github.com/chgeuer/f2334a3222215ef93ff234fd7dcf1a01/raw/9bba6abee1812e9917c21dd8c50fe226bcdfcc7d/makecert.exe', 'makecert.exe')
.\makecert.exe -r -pe -len 2048 -a sha512 -h 0 -sky signature -ss My -n "$($subjectName)"

$cer = (dir Cert:\CurrentUser\My\ | where { $_.Subject -eq $subjectName })
$certThumbprint = $cer.Thumbprint
$certOctets = $cer.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
[System.IO.File]::WriteAllBytes($certificateFile, [System.Byte[]]$certOctets)
$credValue = [System.Convert]::ToBase64String($certOctets)

# $certOctets = Get-Content -Path $certificateFile -Encoding Byte
# $cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,[System.Byte[]]$certOctets)
```

## Fill in your Azure details

```ps1
$credential = Get-Credential -UserName $manualBillingAdmin -message "Provide your organizational credentials for $($manualBillingAdmin)"
Login-AzureRmAccount -Tenant $azureADTenantID -SubscriptionId $subscriptionID -Credential $credential
Select-AzureRmSubscription -SubscriptionId $subscriptionID

$application = New-AzureRmADApplication -DisplayName $appName -HomePage $dummyUrl -IdentifierUris $dummyUrl -KeyType AsymmetricX509Cert -KeyValue $credValue
Start-Sleep -Seconds 1

# Remove-AzureRmADServicePrincipal -ObjectId

New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId
Start-Sleep -Seconds 1
New-AzureRmRoleAssignment  -ServicePrincipalName $application.ApplicationId -RoleDefinitionName Contributor

Write-Host "Use SubscriptionID  == $($subscriptionID)"
Write-Host "Use azureADTenantID == $($azureADTenantID)"
Write-Host "Use clientID        == $($application.ApplicationID)"
Write-Host "Use certThumbprint  == $($certThumbprint)"
```

# Powershell / X509

- Src: [Authenticate service principal with certificate - PowerShell](https://github.com/Azure/azure-content/blob/master/articles/resource-group-authenticate-service-principal.md#authenticate-service-principal-with-certificate---powershell)

```ps1
$tenantId = "942023a6-efbe-4d97-a72d-532ef7337595"
$applicationId = "4bc204cb-3282-43b1-aa1f-960f5faa4b23"
$certThumbprint = "B8789A48A020FB1F5589C9ACAF63A4EBFFF5FA1C"


Login-AzureRmAccount `
	-ServicePrincipal `
	-TenantId $tenantId `
	-ApplicationId $applicationId `
	-CertificateThumbprint $certThumbprint
```


# Powershell / Password

```ps1
$tenantId = "942023a6-efbe-4d97-a72d-532ef7337595"
$applicationId = "4bc204cb-3282-43b1-aa1f-960f5faa4b23"
$password = "shdfhskjfskhfkjh"

Login-AzureRmAccount `
	-ServicePrincipal `
	-TenantId $tenantId `
	-ApplicationId $applicationId  `
	-Credential $(New-Object -TypeName System.Management.Automation.PSCredential `
		-ArgumentList $applicationId, `
			$(ConvertTo-SecureString -Force -AsPlainText $password))
```

# Azure XPLAT CLI / X509


```
cert=$(openssl x509 -in "C:\certificates\examplecert.pem" -fingerprint -noout | `
    sed 's/SHA1 Fingerprint=//g'  | sed 's/://g')

tenantId=$(azure account show -s <subscriptionId> --json | jq '.[0].tenantId' | `
    sed -e 's/^"//' -e 's/"$//')

appId=$(azure ad app show --search exampleapp --json | jq '.[0].appId' | sed -e 's/^"//' -e 's/"$//')

azure login `
    --service-principal `
    --tenant "$tenantId" `
    -u "$appId" `
    --certificate-file C:\certificates\examplecert.pem `
    --thumbprint "$cert"
```


# Azure XPLAT CLI / Password

- [Authenticate service principal with password - Azure CLI](https://github.com/Azure/azure-content/blob/master/articles/resource-group-authenticate-service-principal.md#authenticate-service-principal-with-password---azure-cli)

```
azure login 
	--service-principal 
	--tenant "<TenantId>"
	-u "<ApplicationId>" 
	-p "<password>" 
```





In my customer engagements, I usually push early for deployment automation of some sort. My preferred way to deploy to Azure is using Azure Resource Manager JSON Templates, alongside with developer-side automated scripts. Personally I also appreciate the notion of Service Principals, i.e. using "strong" credentials such as an X.509 Certificate to authenticate to Azure Resource Manager (ARM) API. 

In order to make it a bit more interesting, this article uses the "Microsoft Azure Germany" environment, instead of the 'regular' Azure. 

## Registering Azure Germany under the hood

When you install the latest Powershell for Azure (v1.5.0 at time of this writing), the command `Get-AzureEnvironment | select Name` should look like this:

```powershell
PS C:\> Get-AzureEnvironment | select Name

Name
----
AzureCloud
AzureChinaCloud
AzureUSGovernment
AzureGermanCloud
```

The last line `AzureGermanCloud` indicates that Powershell already knows the specific management endpoints for Germany.

*If* you do not have that, you might consider re-installing the Powershell module

```powershell
# Install the Azure Resource Manager modules from the PowerShell Gallery
Install-Module AzureRM
Install-AzureRM
Install-Module Azure

Import-AzureRM
Import-Module Azure
```
For the `azure-cli` side of things, the output of `azure account env list` should look like this: 

```batch
PS C:\> azure account env list

info:    Executing command account env list
data:    Name
data:    -----------------
data:    AzureCloud
data:    AzureChinaCloud
data:    AzureUSGovernment
data:    AzureGermanCloud
info:    account env list command OK
```

*If* you miss that last line, you can add the environment yourself:

```batch
azure account env add ^
  --environment                               AzureGermanCloud ^
  --portal-url                                http://portal.microsoftazure.de/ ^
  --publishing-profile-url                    https://manage.microsoftazure.de/publishsettings/index ^
  --management-endpoint-url                   https://management.core.cloudapi.de/ ^
  --resource-manager-endpoint-url             https://management.microsoftazure.de/ ^
  --gallery-endpoint-url                      https://gallery.cloudapi.de/ ^
  --active-directory-endpoint-url             https://login.microsoftonline.de ^
  --active-directory-resource-id              https://management.core.cloudapi.de/ ^
  --active-directory-graph-resource-id        https://graph.cloudapi.de/ ^
  --storage-endpoint-suffix                   .core.cloudapi.de ^
  --key-vault-dns-suffix                      .vault.microsoftazure.de ^
  --sql-server-hostname-suffix                .database.cloudapi.de 
```

## Setup of a Service Principal in Azure Active Directory (AAD)

The following Powershell script can be used to 

1. Login interactively to Azure 
2. Create a new application in Azure Active Directory. An application is a process which is cryptographically known to Azure AD (AAD). 
3. Promote that application to become a service principal, i.e. giving it the right to request authN tokens from AAD. 
4. Registering that new service principal as a `Contributor` to my Azure Subscription. 

### Loggin in interactively

```
azure login -e AzureGermanCloud -u {username}
azure login --environment AzureGermanCloud --user chgeuer@msftger.onmicrosoft.de --password XXX
```


### A few variables to start with

The initial log-in to Azure Germany happens with a regular Azure AD user, in my case that's `chgeuer@msftger.onmicrosoft.de`. 

```powershell
$subscriptionId = "deadbeef-fb63-43e6-afa2-d832f709f700"
$tenantId = "deadbeef-e2bf-48c0-b025-23e47c410293"
$userName = "chgeuer@msftger.onmicrosoft.de"
$environmentName = "AzureGermanCloud"
```
### Get the user's interactive password into the Powershell environment

```powershell
$cred = Get-Credential `
    -UserName $userName `
    -Message "Login $userName to $environmentName"
```

### Login to Azure with the interactive credential

```powershell
Add-AzureRmAccount `
    -EnvironmentName $environmentName `
    -Tenant $tenantId `
    -Credential $cred

Login-AzureRmAccount `
    -EnvironmentName $environmentName `
    -TenantId $tenantId `
    -SubscriptionId $subscriptionId `
    -Credential $cred
```

### Register the application

In order to authenticate to Azure later, I want my service principal to use an X.509 Certificate. You can just bake yourself an own one using `makecert.exe` if you like. In my case, I saved a copy of the actual certificate on my local harddisk, which I then read into Powershell: 

```powershell
$certificateFile = "D:\credentials\azure-work\CN_Lenovo W530 Cert Christian.cer"

$certOctets = Get-Content -Path $certificateFile -Encoding Byte
$credValue = [System.Convert]::ToBase64String($certOctets)

$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 `
    -ArgumentList @(,[System.Byte[]]$certOctets)
```

### Create the Azure AD application

Each application must have a name and a URL. In case your application is an actual web application, that URL would correspond to the real web site address. In my case, that's just some non-existent dummy URL: 

```powershell
$appName = "Service Principal Lenovo my Laptop $($userName)"
$dummyUrl = "http://some-domain.com/whatever"

$application = New-AzureRmADApplication `
    -DisplayName $appName `
    -HomePage $dummyUrl `
    -IdentifierUris $dummyUrl `
    -KeyType AsymmetricX509Cert `
    -KeyValue $credValue
```

### Promote the app to become a service principal

As part of a larger script, you should pause execution for a few seconds, as it might take 1-2 seconds for that service principal information to propagate through AAD. 

```powershell
New-AzureRmADServicePrincipal `
    -ApplicationId $application.ApplicationId

Start-Sleep -Seconds 2
```

### Tell Azure that the service principal can manage my subscription

```powershell
New-AzureRmRoleAssignment ` 
    -ServicePrincipalName $application.ApplicationId `
    -RoleDefinitionName Contributor


Write-Host "Login like this: "
Write-Host ""
Write-Host "Login-AzureRmAccount \`"
Write-Host "     -ServicePrincipal \`"
Write-Host "     -TenantId '$($tenantId)' \`"
Write-Host "     -ApplicationId '$($application.ApplicationId)' \`"
Write-Host "     -CertificateThumbprint '$($cer.Thumbprint)' \`"
Write-Host "     -EnvironmentName 'AzureGermanCloud'"
```

## Use that service principal to log-in to Azure

### Use that service principal to log-in to Azure using Powershell

The following code assumes that you imported the certificate into your Windows Certificate store. As you can see, the `CurrentUser\My` certificate store contains the X509 cert, and I also own the private key:

```powershell
Get-ChildItem Cert:\CurrentUser\My | `
    where { $_.Thumbprint -eq "B8789A48A020FB1F5589C9ACAF63A4EBFFF5FA1C" } | `
    select ThumbPrint,Subject,HasPrivateKey
```

Output is

```txt
Thumbprint                               Subject                       HasPrivateKey
----------                               -------                       -------------
B8789A48A020FB1F5589C9ACAF63A4EBFFF5FA1C CN=Lenovo W530 Cert Christian          True
````

With this information I can now login with the service principal's identity: 

```powershell
Login-AzureRmAccount `
	-ServicePrincipal `
	-TenantId 'deadbeef-e2bf-48c0-b025-23e47c410293' `
	-ApplicationId 'deadbeef-0980-46a6-a7fa-7ca8845aaca1' `
	-CertificateThumbprint 'B8789A48A020FB1F5589C9ACAF63A4EBFFF5FA1C' `
	-EnvironmentName 'AzureGermanCloud'
```

Output is

```text
Environment           : AzureGermanCloud
Account               : deadbeef-0980-46a6-a7fa-7ca8845aaca1
TenantId              : deadbeef-e2bf-48c0-b025-23e47c410293
SubscriptionId        : deadbeef-fb63-43e6-afa2-d832f709f700
SubscriptionName      : MSFTGER Test Subscription
CurrentStorageAccount :
```

### Use that service principal to log-in to Azure using node.js / azure-cli

The same thing can be done using the azure-cli. The main difference is that the azure-cli isn't aware of Windows certificate stores, but still requires access to the certificate's private key. In this case, the private key is in a PEM-file on my laptop's harddisk: 

```batch
azure config mode arm

azure login ^
  --environment AzureGermanCloud ^
  --service-principal ^
  --tenant "deadbeef-e2bf-48c0-b025-23e47c410293" ^
  --username "deadbeef-0980-46a6-a7fa-7ca8845aaca1" ^
  --thumbprint "B8789A48A020FB1F5589C9ACAF63A4EBFFF5FA1C" ^
  --certificate-file "D:\credentials\azure-work\CN_Lenovo W530 Cert Christian.pem" ^
  --json ^
  --verbose
```

Output is

```text
info:    Executing command login
verbose: Authenticating...
info:    Added subscription MSFTGER Test Subscription
info:    login command OK
```

# Add mgmt cert to Azure Germany via ASM API

```powershell
Invoke-WebRequest `
   -uri https://management.core.cloudapi.de/$subID/certificates `
   -Method Post `
   -Headers @{"x-ms-version"="2012-03-01"} `
   -Certificate $authcert `
   -Body $xml.outerxml `
   -ContentType "application/xml" 
```

# Update Azure CLI 2.0 (Python) and change cloud

```
pip install --upgrade azure-cli
az cloud set --name AzureGermanCloud
```
