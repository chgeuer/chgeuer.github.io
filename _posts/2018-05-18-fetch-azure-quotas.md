---
layout: default
title: "Fetch Microsoft Azure information via shell"
date: 2018-05-18  09:30:00
---

When customers have multiple Azure subscriptions, it can be overwhelming to keep an eye on whether they run into some of Azure's [subscription and service limits, quotas, and constraints](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits). 

The following [script](https://github.com/chgeuer/PullQuotaData/blob/master/pull-quota-data.sh) might help to make that task a bit easier: It uses the Azure `cli` to iterate over your subscriptions, and all data center locations within these subscriptions, and then prints out the relevant information as tab-separated lines to STDOUT. 

When you redirect the output to a text file (`./get-quota-info.sh > quotas.tsv`), you can open the text file in a text editor, copy/paste the contents into Excel, create a table from it, and filter. 

The text output looks like below (just tabs, no spaces), and contains the following data: 

- subscription id
- azure location
- azure network resource provider (compute or storage)
- the name of the quota
- the current value
- the overall limit

```text
724467b5-bee4-484b-bf13-deadbeef1234    northeurope   network    RouteFilterRulesPerRouteFilter           0        1
724467b5-bee4-484b-bf13-deadbeef1234    northeurope   network    RouteFiltersPerExpressRouteBgpPeering    0        1
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    availabilitySets                         0     2000
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    cores                                    3      100
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    virtualMachines                          2    10000
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    virtualMachineScaleSets                  0     2000
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    standardDSv3Family                       2      100
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    standardDSv2Family                       1      100
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    basicAFamily                             0      100
724467b5-bee4-484b-bf13-deadbeef1234    westeurope    compute    standardA0_A7Family                      0      100
```

So you can see that my subscription `724467b5-bee4-484b-bf13-deadbeef1234` currently utilizes 3 (out of 100) CPU cores in the West Europe Azure DC. 

![Excel screenshots][excel]

### The script `get-quota-info.sh`

```bash
#!/bin/bash

subscriptions=$(az account list --query "[].id" -o tsv)
for subscription in ${subscriptions} 
do 
    az account set --subscription "${subscription}"
    locations=$(az account list-locations --query "[].name" -o tsv)
    for location in ${locations} 
    do
        ncls=$(az vm list-usage --location "${location}" \
               --query "[].[name.value, currentValue, limit]" -o tsv)
        while read -r ncl; do
            echo "${subscription}    ${location}    compute    $ncl"
        done <<< "$ncls"

        ncls=$(az network list-usages --location "${location}" \
               --query "[].[name.value, currentValue, limit]" -o tsv)
        while read -r ncl; do
            echo "${subscription}    ${location}    network    $ncl"
        done <<< "$ncls"
    done
done
```

[excel]: /img/2018-05-18\/xcel.png "Excel screenshots"
