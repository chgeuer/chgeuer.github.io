#!/bin/bash

mkdir demo && cd demo

curl -O http://central.maven.org/maven2/io/swagger/swagger-codegen-cli/2.3.1/swagger-codegen-cli-2.3.1.jar

cat > Microsoft.Azure.Management.Resources.json <<-EOF
    { 
        "packageName": "azure", 
        "invokerPackage": "Microsoft.Azure.Management.Resources" 
    }
EOF

java \
   -jar swagger-codegen-cli-2.3.1.jar \
   generate \
   -l elixir \
   -i https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/specification/resources/resource-manager/Microsoft.Resources/stable/2018-02-01/resources.json \
   -o clients/Microsoft.Azure.Management \
   -c ./Microsoft.Azure.Management.Resources.json

sed -n 91,100p clients/Microsoft.Azure.Management/lib/microsoft/azure/management/resources/api/deployments.ex
