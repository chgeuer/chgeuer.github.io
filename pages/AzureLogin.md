---
layout: default
title: "Azure RM Logins"
---


```
"<TenantId>"      is something like "adadadad-adad-adad-adad-adadadadadad"
"<ApplicationId>" is something like "40302010-feda-deaf-beef-deadbeef0123"
```

# Powershell / X509

```
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

```
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

Unclear...

# Azure XPLAT CLI / Password

```
azure login 
	--service-principal 
	--tenant "<TenantId>"
	-u "<ApplicationId>" 
	-p "<password>" 
```



