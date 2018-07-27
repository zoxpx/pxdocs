---
title: 1. Prepare Your Platform
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

### Create the Azure resource group and location

Get the Azure locations using the Azure CLI command:

```text
az account list-locations
```

Example locations: `centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus`   
`southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest`   
`brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia`   
`canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`

### Create an Azure Resource Group by specifying a name and a location:

```text
az group create –name <region-name> –location <location>
```

### Create a service principal in Azure AD

```text
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/72c299a4-xxxx-xxxx-xxxx-6855109979d9"
{
  "appId": "1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde",
  "displayName": "azure-cli-2017-10-27-07-37-41",
  "name": "http://azure-cli-2017-10-27-07-37-41",
  "password": "ac49a307-xxxx-xxxx-xxxx-fa551e221170",
  "tenant": "ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce"
}
```

### Create the AKS cluster

Create the AKS cluster using either the Azure CLI or the Azure Portal. This is described on the [AKS docs page](https://docs.microsoft.com/en-us/azure/aks/).

### Attach a Data Disk to Azure VM

Follow these instructions: [How to attach a data disk to a AKS nodes in the Azure portal ](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-attach-disk-portal/)

Below is an example of how your deployment may look:

![Azure Add Disk](https://docs.portworx.com/images/azure-add-disk.png)
