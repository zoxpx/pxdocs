---
title: 1. Prepare Your AKS Platform
keywords: on cloud, AKS, Azure Kubernetes Service, Microsoft, Kubernetes, k8s
description: Learn about preparing Portwork on Azure Kubernetes Service.
weight: 1
---

To set up the Azure Kubernetes Service (AKS) to use Portworx, follow the steps below. For more information on AKS, see this [article](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes).

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

### Create a Service Principal and secret in Azure AD

{{% content "shared/azure-cloud-user-requirements.md" %}}

### Create the AKS cluster

Create the AKS cluster in the above Resource Group using either the Azure CLI or the Azure Portal. This is described on the [AKS docs page](https://docs.microsoft.com/en-us/azure/aks/). If you have already deployed an AKS cluster, then create the Service Principal for the Resource Group in which your AKS cluster is present.
