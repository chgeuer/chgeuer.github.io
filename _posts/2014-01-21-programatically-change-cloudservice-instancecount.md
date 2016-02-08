---
layout: default
title: "Programatically change the number of instances in a Windows Azure Cloud Service"
date: 2014-01-21
keywords: WindowsAzure, "Platform as a Service"
---

# Summary

I did not find a quick and dirty example on how to use the Windows Azure Management Linrary (WAML) to change the number of instances for the different roles in a Windows Azure Cloud Service: 

```csharp
using System;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Xml.Linq;
using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.Management.Compute;
using Microsoft.WindowsAzure.Management.Compute.Models;

namespace ManageClienttest
{
    class Program
    {
        private static X509Certificate2 FindX509Certificate(string managementCertThumbprint)
        {
            X509Store store = null;

            try
            {
                store = new X509Store(StoreName.My, StoreLocation.LocalMachine);
                store.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);
                X509Certificate2Collection certs = store.Certificates.Find(
                    findType: X509FindType.FindByThumbprint,
                    findValue: managementCertThumbprint,
                    validOnly: false);
                if (certs.Count == 0)
                {
                    return null;
                }

                return certs[0];
            }
            finally
            {
                if (store != null) store.Close();
            }
        }
        static void Main(string[] args)
        {
            var subscriptionid = "aaaaaaaa-bbbb-3443-5445-655678879889";
            var managementCertThumbprint = "DEADBEEF12312327E649C41517FB13F09203035D";
            var servicename = "thethingbeforecloudappnet";

            X509Certificate2 managementCert = FindX509Certificate(managementCertThumbprint);
            SubscriptionCloudCredentials creds = new CertificateCloudCredentials(subscriptionid, managementCert);
            ComputeManagementClient computeManagementClient = CloudContext.Clients.CreateComputeManagementClient(creds);

            var detailed = computeManagementClient.HostedServices.GetDetailed(servicename);

            var deployment = detailed.Deployments
                .First(_ => _.DeploymentSlot == DeploymentSlot.Production);

            var xConfig = XDocument.Parse(deployment.Configuration);

            Func<string, XName> n = (name) => XName.Get(name,
                "http://schemas.microsoft.com/ServiceHosting/2008/10/ServiceConfiguration");
            Func<XDocument, string, int> getInstanceCount = (doc, rolename) =>
            {
                var role = doc.Root.Elements(n("Role")).FirstOrDefault(_ => _.Attribute("name").Value == rolename);
                if (role == null) return -1;
                var v = role.Element(n("Instances")).Attribute("count").Value;
                return int.Parse(v);
            };
            Action<XDocument, string, int> setInstanceCount = (doc, rolename, newInstanceCount) =>
            {
                if (newInstanceCount < 1)
                {
                    newInstanceCount = 1;
                }

                var role = doc.Root.Elements(n("Role")).FirstOrDefault(_ => _.Attribute("name").Value == rolename);
                role.Element(n("Instances")).Attribute("count").Value = newInstanceCount.ToString();
            };
            Action<XDocument, string, int> changeInstanceCount = (doc, rolename, deltaCount) =>
            {
                int oldCount = getInstanceCount(doc, rolename);
                var newCount = oldCount + deltaCount;
                setInstanceCount(doc, rolename, newCount);
            };

            changeInstanceCount(xConfig, "WorkerRoleA", 2); // adds two instances to WorkerRoleA (scale-up) 
            changeInstanceCount(xConfig, "WorkerRoleB", -5); // removes 5 instances from WorkerRoleB (scale-down)

            var response = computeManagementClient.Deployments.ChangeConfigurationBySlot(
                serviceName: detailed.ServiceName,
                deploymentSlot: deployment.DeploymentSlot,
                parameters: new DeploymentChangeConfigurationParameters()
                {
                    Configuration = xConfig.ToString()
                });

            Console.WriteLine(response.StatusCode.ToString());

            Console.ReadLine();
        }
    }
}
```

