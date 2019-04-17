---
title: GCP Marketplace
logo: /logos/gcp.png
weight: 2
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce, gcp marketplace
description: Setup a production-ready Portworx cluster on Google Cloud Platform Marketplace.
noicon: true
series: px-k8s-gcp
---

## Prerequisites

{{% content "portworx-install-with-kubernetes/cloud/gcp/shared/prerequisites.md" %}}

## Permissions

_Portworx_ requires permissions to create GCE PDs using the compute APIs. Also, the GCP marketplace requires that the clusters have Read permissions for storage APIs. These permissions can be added to the node pools from the UI when creating the GKE cluster. If using `gcloud`, type the following command to create a cluster with the correct permissions:

```text
gcloud container clusters create portworx-gke \
    --zone us-east1-b \
    --disk-type=pd-ssd \
    --disk-size=50GB \
    --machine-type=n1-standard-4 \
    --num-nodes=3 \
    --image-type ubuntu \
    --scopes compute-rw,storage-ro
```

### Service Account

The service account associated with your GKE cluster should have permissions to create
and mount GCE PDs.

---

On GCP Marketplace, you have 2 options for installing Portworx.

## Option 1: Install Portworx from the marketplace

Before we start installing Portworx, here are a few things you should keep in mind:

* When installing _Portworx Enterprise_ from the GCP Marketplace it will automatically
install on all the worker nodes in your GKE cluster.
* The marketplace installer will also create some Service Accounts to be used by
the various components. It is recommended to let the installer create these
service accounts instead of choosing pre-existing ones.
* When installing from the marketplace, the billing agent will automatically report
billing information based on the number of nodes to GCP. Please refer to the
marketplace listing for the pricing information.

Now, let’s look more closely at how to install _Portworx Enterprise_ from the marketplace.

* First, use the search bar at the top to search for _Portworx_. You should see something like the following:

![gcp-search-bar](/img/gcp-search-bar.png "gcp-search-bar")

* Select the app and you will see information about it:

![portworx-enterprise-app-details](/img/portworx-enterprise-app-details.png "portworx-enterprise-app-details")

* Next, let's click configure to go to the configuration page:

![product-configuration-page](/img/product-configuration-page.png "product-configuration-page")

 Here, you will be required to do a few things: select the Kubernetes cluster and the namespace, type the name of the app, and choose the physical disks you want to provision and attach to each node. Note that these disks will automatically get attached to the nodes on reboots and node failures.

 When everything is set, go ahead and click "Deploy".

* Now, the installer asks you to confirm that your cluster meets minimum resource requirements. Then, it will proceed with the actual install:

![portworx-enterprise-product-deployment-progress](/img/portworx-enterprise-product-deployment-progress.png "portworx-enterprise-product-deployment-progress")

* Once the installation is finished, we can check the status of our new app:

![portworx-enterprise-product-install-details](/img/portworx-enterprise-product-install-details.png "portworx-enterprise-product-install-details")

## Option 2: Install Portworx using CLI

You can also choose to install _Portworx_ using the CLI. You will still need to
generate a license key from the GCP portal and create a Kubernetes Secret that
can be used to report billing information.

### Create Reporting Secret

Navigate to the _Portworx_ listing on the GCP Marketplace and click on
`Configure`. Then, click on the `Install via command line` tab. Here you can generate a license key to be used for the reporting.

Choose a service account you want to be associated with the billing and click `Generate license key`. This will download the license key to your system. Apply the license key to your GKE cluster using the following commands:

```text
NS=<namespace_where_you_installed_portworx>
kubectl apply -n $NS license.yaml
```

{{% content "portworx-install-with-kubernetes/cloud/gcp/shared/install-gke.md" %}}

### Edit the Portworx Daemonset

Once _Portworx_ has been installed, please edit the `portworx` Daemonset with the following:

```text
kubectl edit daemonset -n $NS portworx
```

And add the following environment variables to the `portworx` container so that
_Portworx_ can read the license generate above

```text
REPORTING_SECRET: Name of the secret generated above
REPORTING_SECRET_NAMESPACE: Namespace where you installed Portworx
```

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}

## Upgrade

When an upgrade is available on the marketplace you can install the new version with a new name in the same namespace as the previous install. This will replace all the components for the application with the updated version.

You can remove the old version of the application once all the components in the new version are running.


## Uninstall

**WARNING: Uninstalling _Portworx_ is a destructive process and you will not be able to recover volumes provisioned by _Portworx_. Please use this with caution.**

You can uninstall _Portworx_ from your GKE cluster by running the following command:

```text
curl -fsL https://install.portworx.com/px-wipe | bash
```

This will remove all _Portworx_ specific state from the nodes and clean all the disks used by _Portworx._

Once the above script completes successfully you can delete the Application object created by GCP.

You can find more information about uninstalling Portworx [here](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/).
