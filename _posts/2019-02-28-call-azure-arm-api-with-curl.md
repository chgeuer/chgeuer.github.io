---
layout: default
title: "Call the Azure ARM API via plain cURL"
date: 2019-02-28  09:30:00
---

# Signing in to Azure from `bash`

Sometimes I need a zero-install way to interact with Azure. I have no specific Azure utilities at hand, no Python, no nothing. Usually, Azure management is done using PowerShell, the [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) or, if you want raw REST calls, the [armclient](https://github.com/projectkudu/ARMClient). But for my customer, even can be too much ceremony.

So the question was how can I get going with purely `bash`, [`cURL`](https://curl.haxx.se/) and [`jq`](https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64) for JSON parsing?

If you're running inside a VM, with Managed Identity enabled, you can easily fetch a token. But unfortunately the VM wasn't authorized to hit the resource I care about.

Next stop service principals. Problem is customer's AD admin team running a tough regime, and don't hand out service principals.

So ultimately, how can I get my actual AAD user identity avail in the shell? In the end, all I need is a bearer token.

Let's dive right in:

## A few variables first

I want to authN against 'my' Azure AD tenant, and want to hit the Azure ARM REST API:

```bash
#!/bin/bash

aadTenant="chgeuerfte.onmicrosoft.com"
resource="https://management.azure.com/"
```

## Doing a device login

For the full user login, i.e. device authN, here's what happens under the hood: The code needs to fetch a device code, and then use that code to poll and validate whether the user authenticated. Quick hint: If you wanna snoop on cURL's requests with something like [fiddler](https://www.telerik.com/fiddler), you should add this `--proxy http://127.0.0.1:8888/ --insecure` to the calls. 

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

Assuming we have a 'real' service principal, we can do this: 

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

## Using managed VM identity (running inside an Azure VM)

```bash
#!/bin/bash

resource="https://management.azure.com/"

access_token="$(curl -s -H Metadata:true \
    "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=${resource}" | \
    jq -r ".access_token")"
```

## Fetch the subscription ID, from the Azure VM's instance metadata endpoint

```bash
#!/bin/bash

subscriptionId="$(curl -s -H Metadata:true \
    "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | \
    jq -r ".compute.subscriptionId")"
```

## Invoke the ARM API, for example with a listing of resource groups

```bash
#!/bin/bash

subscriptionId="724467b5-bee4-484b-bf13-d6a5505d2b51"

# --proxy http://127.0.0.1:8888/ --insecure \

curl --silent --get \
    --header "Authorization: Bearer ${access_token}" \
    "https://management.azure.com/subscriptions/${subscriptionId}/resourcegroups?api-version=2018-05-01" | \
    jq -r ".value[].name"
```

## Fetching a secret from Azure KeyVault using a managed identity

This little script demonstrates how to fetch a secret from an Azure KeyVault, using a managed identity on an Azure VM. Just adapt `key_vault_name` and `secret_name` accordingly, and of course ensure that the managed identity can actually read the secret. 

```bash
#!/bin/bash

get_secret_from_keyvault() {
   local key_vault_name=${1}
   local secret_name=${2}

   resource="https://vault.azure.net"
   access_token="$(curl -s -H Metadata:true \
      "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&bypass_cache=true&resource=${resource}" | \
      jq -r ".access_token")"

   apiVersion="7.0"

   #
   # Fetch the latest version
   #
   secretVersion="$(curl -s -H "Authorization: Bearer ${access_token}" \
      "https://${key_vault_name}.vault.azure.net/secrets/${secret_name}/versions?api-version=${apiVersion}" | \
      jq -r ".value | sort_by(.attributes.created) | .[-1].id")"

   #
   # Fetch the actual secret's value
   #
   secret="$(curl -s -H "Authorization: Bearer ${access_token}" \
      "${secretVersion}?api-version=${apiVersion}" | \
      jq -r ".value" )"

   echo "${secret}"
}

echo "The secret is $(get_secret_from_keyvault "chgeuerkeyvault" "secret1")"
```

## Shutdown a VM, quite radically (skip graceful shutdown, just turn it off) 

```bash
#!/bin/bash

...

subscriptionId="..."
resourceGroup="myrg"
vmName="somevm"

curl \
  --proxy http://127.0.0.1:8888/ --insecure \
  --silent \
  --include \
  --request POST \
  --header "Authorization: Bearer ${access_token}" \
  --header "Content-Length: 0" \
  "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Compute/virtualMachines/${vmName}/powerOff?skipShutdown=true&api-version=2019-03-01"
```


Thanks for reading, if you liked it, I'd appreciate a [retweet](https://twitter.com/chgeuer/status/1101119486747439105).
