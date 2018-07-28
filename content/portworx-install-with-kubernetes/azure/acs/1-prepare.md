---
title: 1. Prepare Your Platform
weight: 1
---

### Install the Azure Container Service Engine

The ACS Engine binary files are located [here](https://github.com/Azure/acs-engine/releases). To install the ACS Engine on Linux, run this command:

`curl -L https://aka.ms/InstallAzureCli | bash`

### Install the Azure CLI

Follow the steps [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) to install the Azure CLI.

### Login to Azure and set the subscription

```text
az login
az account set –subscription <Your-Azure-Subscription-UUID>
```

### Create the Azure resource group and location

Get the Azure locations using the Azure CLI command:

```text
az account list-locations
```

Example locations: 

`centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus`   
`southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest`   
`brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia`   
`canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`

### Create an Azure resource group by specifying a name and a location

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

### Select and customize the deployment configuration

The example deployment here uses Kubernetes with pre-attached disks and VM scale sets. Find a sample JSON file in the acs-engine repository here: [examples/disks-managed/kubernetes-preAttachedDisks-vmas.json](https://github.com/Azure/acs-engine/blob/master/examples/disks-managed/kubernetes-preAttachedDisks-vmas.json)

Ensure that the Portworx target nodes have at least one “local” attached disk which can be used to contribute storage to the global storage pool.

For the `masterProfile`, specify an appropriate value for `dnsPrefix` which will be used for fully qualified domain name \(FQDN\) \[ Ex: “myacsk8scluster”\].   
Use the default `vmSize` or select an appropriate value for the machine type and size.   
Specify the number and size of disks that will be attached to each DCOS private agent as per the template default:

```text
[...]
"diskSizesGB": [128, 128, 128, 128]
[...]
```

Specify the `adminUsername` and public key data in `keyData`

Specify the `clientId` and `secret`  which are located under the `servicePrincipalProfile`  

### Generate the Azure Resource Management \(ARM\) templates

```text
acs-engine generate my-k8s-preAttachedDisks-vmas.json
```

The output files are generated in the `_output/$NAME` directory where `$NAME` corresponds to the name used for the `dnsPrefix`.  For more information on the specific files that are generated, see this [article](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md).

### Deploy the generated ARM template

```text
az group deployment create \
    --name "$NAME" \
    --resource-group "$RGNAME" \
    --template-file "./_output/$NAME/azuredeploy.json" \
    --parameters "./_output/$NAME/azuredeploy.parameters.json"
```

where `$RGNAME` corresponds to the resource group name created above, and `$NAME` corresponds to the above value used for `dnsPrefix`
