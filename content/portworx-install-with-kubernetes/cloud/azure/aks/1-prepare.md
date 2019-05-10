---
title: 1. Prepare Your AKS Platform
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, aks, Azure
description: Learn about preparing Portwork on Azure Kubernetes Service.
weight: 1
---

To set up the Azure Kubernetes Service \(AKS\) to use Portworx, follow the steps below. For more information on AKS, see this [article](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes).

### Install the Azure CLI

Follow the steps [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to install the Azure CLI.

### Login to the Azure and set the subscription

```text
az login
az account set –subscription <Your-Azure-Subscription-UUID>
```

### Check locations to create AKS cluster

Get the Azure locations using the Azure CLI command:

```text
az account list-locations
```

Example locations:
```
centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus
southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest
brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia
canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth
```

### Create an Azure Resource Group
Create a Resource Group by specifying its name and location in which you will be deploying your AKS cluster.
```text
az group create –name <resource-group-name> –location <location>
```

### Create a Service Principal in Azure AD
This Service Principal will be used to grant _Portworx_ permissions to manage the disks used in the cluster. Store the `password` which acts as the client secret and the `appId` will is the client ID.
```text
az ad sp create-for-rbac \
   --role="Contributor" \
   --scopes="/subscriptions/72c299a4-xxxx-xxxx-xxxx-6855109979d9/resourceGroups/<resource-group-name>"
{
  "appId": "1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde",
  "displayName": "azure-cli-2017-10-27-07-37-41",
  "name": "http://azure-cli-2017-10-27-07-37-41",
  "password": "ac49a307-xxxx-xxxx-xxxx-fa551e221170",
  "tenant": "ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce"
}
```

### Create the AKS cluster

Create the AKS cluster in the above Resource Group using either the Azure CLI or the Azure Portal. This is described on the [AKS docs page](https://docs.microsoft.com/en-us/azure/aks/). If you have already deployed an AKS cluster, then create the Service Principal for the Resource Group in which your AKS cluster is present.
