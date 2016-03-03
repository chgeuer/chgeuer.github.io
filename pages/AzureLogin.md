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
