---
title: Azure Managed Kubernetes Service (AKS)
weight: 2
linkTitle: Azure Kubernetes Service (AKS)
---

### Overview
The [Azure Managed Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes) (aks-engine) generates the Azure Resource Manager(ARM) templates for Kubernetes enabled clusters in the Microsoft Azure Environment.

### Install `azure CLI`
Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

### Login to the Azure and Set Subscription

* az login
* az account set --subscription "Your-Azure-Subscription-UUID"

### Create the Azure Resource Group and Location

Pick a name for the Azure Resource Group and choose a LOCATION value
among the following:

Get the Azure locations using azure CLI command:

* az account list-locations

example locations:
`centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus`
<br>`southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest`
<br>`brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia`
<br>`canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`


* az group create --name "region-name" --location "location"

### Create a service principal in Azure AD

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/72c299a4-xxxx-xxxx-xxxx-6855109979d9"
{
  "appId": "1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde",
  "displayName": "azure-cli-2017-10-27-07-37-41",
  "name": "http://azure-cli-2017-10-27-07-37-41",
  "password": "ac49a307-xxxx-xxxx-xxxx-fa551e221170",
  "tenant": "ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce"
}
```
Make note of the `appId` and `password`


### Create the AKS cluster
Create the AKS cluster using either by Azure CLI or Azure Portal as per [AKS docs page](https://docs.microsoft.com/en-us/azure/aks/).

###  Attach Data Disk to Azure VM
Follow the instructions from the Azure documentation [How to attach a data disk to a AKS nodes in the Azure portal
](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-attach-disk-portal/)

Your deployment will look something like following:

![Azure Add Disk](https://docs.portworx.com/images/azure-add-disk.png "Add Disk")


### Install Portworx

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

#### Generating the spec

To generate the spec file, head on to the below URLs for the PX release you wish to use.

* [Default](https://install.portworx.com).
* [1.6 Stable](https://install.portworx.com/1.6/).
* [1.5 Stable](https://install.portworx.com/1.5/).
* [1.4 Stable](https://install.portworx.com/1.4/).

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](https://docs.portworx.com/scheduler/kubernetes/px-k8s-spec-curl.html).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

##### Using Kubernetes Secrets to Provision Certificates
Instead of manually copying the certificates on all the nodes, it is recommended to use [Kubernetes Secrets to provide etcd certificates to Portworx](https://docs.portworx.com/scheduler/kubernetes/etcd-certs-using-secrets.html). This way, the certificates will be automatically available to new nodes joining the cluster.

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet.

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.

#### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

Monitor the portworx pods

```bash
kubectl get pods -o wide -n kube-system -l name=portworx
```

Monitor Portworx cluster status

```bash
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

If you are still experiencing issues, please refer to [Troubleshooting PX on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/troubleshooting/troubleshoot-and-get-support) and [General FAQs](https://docs.portworx.com/knowledgebase/faqs.html).

### Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/portworx-install-with-kubernetes/application-install-with-kubernetes/).
