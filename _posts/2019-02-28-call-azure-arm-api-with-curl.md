---
layout: default
title: "Call the Azure ARM API via plain cURL"
date: 2019-02-28  09:30:00
---

# Signing in to Azure from `bash`

Please note all of these shell samples use [`jq`](https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64) for JSON parsing...

## A few variables first

```bash
#!/bin/bash

aadTenant="chgeuerfte.onmicrosoft.com"
resource="https://management.azure.com/"
```

## Doing a device login

```bash
#!/bin/bash

# --proxy http://127.0.0.1:8888/ --insecure \

deviceResponse="$(curl \
    --silent \
    --request POST \
    --data-urlencode "client_id=04b07795-8ddb-461a-bbee-02f9e1bf7b46" \
    --data-urlencode "resource=${resource}" \
    "https://login.microsoftonline.com/${aadTenant}/oauth2/devicecode?api-version=1.0")"

device_code="$(echo "${deviceResponse}" | jq -r ".device_code")"
sleep_duration="$(echo "${deviceResponse}" | jq -r ".interval")"
access_token=""

while [ "${access_token}" == "" ]
do
    tokenResponse="$(curl \
        --silent \
        --request POST \
        --data-urlencode "grant_type=device_code" \
        --data-urlencode "client_id=04b07795-8ddb-461a-bbee-02f9e1bf7b46" \
        --data-urlencode "resource=${resource}" \
        --data-urlencode "code=${device_code}" \
        "https://login.microsoftonline.com/common/oauth2/token")"

    if [ "$(echo "${tokenResponse}" | jq -r ".error")" == "authorization_pending" ]; then
      echo "$(echo "${deviceResponse}" | jq -r ".message")"
      sleep "${sleep_duration}"
    else
      access_token="$(echo "${tokenResponse}" | jq -r ".access_token")"
      echo "User authenticated"
    fi
done

echo "${access_token}"
```

## Using a service principal

```bash
#!/bin/bash

resource="https://management.azure.com/"
aadTenant="chgeuerfte.onmicrosoft.com"
SAMPLE_SP_APPID="*** put your service principal application ID here ***"
SAMPLE_SP_KEY="***   put your service principal application secret here ***"

access_token="$(curl \
    --silent \
    --request POST \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_id=${SAMPLE_SP_APPID}" \
    --data-urlencode "client_secret=${SAMPLE_SP_KEY}" \
    --data-urlencode "resource=${resource}" \
    "https://login.microsoftonline.com/${aadTenant}/oauth2/token" | \
        jq -r ".access_token")"
```

## Using managed VM identity (running on an Azure VM)

```bash
#!/bin/bash

resource="https://management.azure.com/"

access_token="$(curl -s -H Metadata:true \
    "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=${resource}" | \
    jq -r ".access_token")"
```

## Fetch the subscription ID on an Azure VM

```bash
#!/bin/bash

subscriptionId="$(curl -s -H Metadata:true \
    "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | \
    jq -r ".compute.subscriptionId")"
```

## Invoke the ARM API

```bash
#!/bin/bash

curl -s -H "Authorization: Bearer ${access_token}" \
    "https://management.azure.com/subscriptions/${subscriptionId}/resourcegroups?api-version=2018-05-01" | \
    jq -r ".value[].name"

#resourceGroupName="HEC42-AZ1-westeurope-1"
#vaultName="vault-${resourceGroupName}"
#https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.RecoveryServices/vaults/${vaultName}/backupJobs/47ad3164-a567-4168-944e-9740a28e9f35?api-version=2018-01-10

```
