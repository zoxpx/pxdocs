---
title: ACS-Engine with Kubernetes and Portworx
weight: 3
linkTitle: Azure Container Engine with Kubernetes
---

### Overview
The [Azure Container Service Engine](https://github.com/Azure/acs-engine) (acs-engine) generates ARM (Azure Resource Manager) templates for Docker enabled clusters on Microsoft Azure with your choice of DC/OS, Kubernetes, Swarm Mode, or Swarm orchestrators. The input to the tool is a cluster definition. The cluster definition is very similar to (in many cases the same as) the ARM template syntax used to deploy a Microsoft Azure Container Service cluster.

The cluster definition file enables the following customizations to your Docker enabled cluster:

* choice of DC/OS, Kubernetes, Swarm Mode, or Swarm orchestrators
* multiple agent pools where each agent pool can specify:
* standard or premium VM Sizes,
* node count,
* Virtual Machine ScaleSets or Availability Sets,
* Storage Account Disks or Managed Disks (under private preview),
* Docker cluster sizes of 1200

The instructions below are presented only as a *template* for how to deploy Portworx on ACS-Engine for Kubernetes.

### Install `acs-engine` and `azure CLI`
Install the released version of the [`acs-engine` binary](https://github.com/Azure/acs-engine/releases)

From a Linux host:
* ```curl -L https://aka.ms/InstallAzureCli | bash```

### Login to Azure and Set Subscription

* az login
* az account set --subscription "Your-Azure-Subscription-UUID"

### Create Azure Resource Group and Location

Pick a name for the Azure Resource Group and choose a LOCATION value
among the following:  
`centralus,eastasia,southeastasia,eastus,eastus2,westus,westus2,northcentralus`
<br>`southcentralus,westcentralus,northeurope,westeurope,japaneast,japanwest`
<br>`brazilsouth,australiasoutheast,australiaeast,westindia,southindia,centralindia`
<br>`canadacentral,canadaeast,uksouth,ukwest,koreacentral,koreasouth`

* az group create --name "$RGNAME" --location "$LOCATION"

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

### Select and customize the deployment configuration

The example deployment here uses Kubernetes with pre-attached disks and VM scale sets.
A sample json file can be found in the acs-engine repository under [examples/disks-managed/kubernetes-preAttachedDisks-vmas.json](https://github.com/Azure/acs-engine/blob/master/examples/disks-managed/kubernetes-preAttachedDisks-vmas.json)

The most important consideration for Portworx is to ensure that the target nodes have at least one "local" attached disk
that can be used to contribute storage to the global storage pool.  The above sample json includes four, which you are free to customize.

For the `masterProfile`, specify an appropriate value for `dnsPrefix` which will be used for fully qualified domain name (FQDN) [ Ex: "myacsk8scluster"].
<br>Use the default `vmSize` or select an appropriate value for the machine type and size.
<br>Specify the number and size of disks that will be attached to each DCOS private agent
as per the template default:

```
[...]
"diskSizesGB": [128, 128, 128, 128]
[...]
```

Specify the appropriate admin username as `adminUsername` and public key data as `keyData`

Fill in the servicePrincipalProfile values.   `clientId` should correspond to the `appId` and `secret` should correspond to the `password`
from the above "Create a service principal in Azure AD" step.

### Generate the Azure Resource Management (ARM) templates

```
acs-engine generate my-k8s-preAttachedDisks-vmas.json
```

The template will get generated in the `_output/$NAME` directory where *$NAME* correspods
to the name used for the `dnsPrefix`.   `acs-engine` will generate the appropriate files for
`apimodel.json`, `azuredeploy.json`, and `azuredeploy.parameters.json`

### Deploy the generated ARM template

```
az group deployment create \
    --name "$NAME" \
    --resource-group "$RGNAME" \
    --template-file "./_output/$NAME/azuredeploy.json" \
    --parameters "./_output/$NAME/azuredeploy.parameters.json"
```

where $RGNAME corresponds to the resource group name created above, and $NAME corresonds to the above value used for `dnsPrefix`

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

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/portworx-install-with-kubernetes/application-install-with-kubernetes/).
