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
