---
title: Install Portworx on Kubernetes using Rancher 2.x
linkTitle: Rancher 2.x
keywords: Install, Rancher 2.x, Helm
description: Install Portworx on Kubernetes using Rancher 2.x with a public catalog (Helm Chart)
weight: 6
series: px-rancher
noicon: true
hideSections: true
---

This guide provides instructions for installing Portworx on Kubernetes using Rancher 2.x with a Helm chart available from the public catalog.

{{<info>}}
**NOTE:** Currently, Portworx does not support the `RancherOS` distro.
{{</info>}}

## Prerequisites

* You must have a Kubernetes cluster imported into Rancher
* Your cluster must meet the [requirements](/start-here-installation/) for installing a Portworx cluster

## Install Portworx on Kubernetes using Rancher 2.x

Perform the following steps to install Portworx:

1. Go to your cluster, and then select the **System** namespace. The following screenshot uses a cluster named `dev` as an example:

    ![Screenshot showing the System namespace](/img/rancherSystemNamespace.png)

2. From the top navigation bar, select **Apps**:

    ![Screenshot showing the Apps menu location](/img/rancherSelectApps.png)

3. Select the **Launch** button to open the catalog:

    ![Screenshot showing the Launch button menu location](/img/rancherSelectLaunch.png)

4. Search for the Portworx catalog and select the **Portworx** card to start the Helm chart form:

    ![Screenshot showing how to Launch the Portworx Helm chart](/img/rancherSearchAndSelectPortworx.png)

5. Populate the various required sections of the **Configuration Options** of the Helm chart form:

     * In the **Key Value Store Paramters** section, specify an internal or external ETCD.

        ![Screenshot showing the KVDB section of the Helm chart form](/img/rancherKvdb.png)

     * In the **Storage Parameters** section, specify whether your cluster is located on-prem or on a cloud provider, and choose your disk configuration.

        ![Screenshot showing the Storage Parameters section of the Helm chart form](/img/rancherStorageParameters.png)
       
     * In the **Portworx version to be deployed.** field, select the Portworx version you want to deploy. Currently recommended version is **2.5.1**
        
        ![Screenshot showing the PX Version section of the Helm chart form](/img/rancherPXVersion.png)


6.  Select the **Launch** button to deploy Portworx to your cluster:

    ![Screenshot showing the launch button of the Helm chart form](/img/rancherHelmLaunch.png)


    Depending on your network and cluster performance, it may take between 5 and 20 minutes to install Portworx. Once the installation is completed, the Portworx processes will be shown as green.

## Post-Install

Once you have a running Portworx installation, below sections are useful.

{{<homelist series2="k8s-postinstall">}}

## Upgrade

Follow these steps to upgrade Portworx on Kubernetes using Rancher 2.x:

{{< widelink url="/install-with-other/rancher/rancher-2.x/upgrade" >}} Upgrading Portworx on Kubernetes using Rancher 2.x
{{</widelink>}}
