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
* Your cluster must meet the [requirements](https://github.com/start-here-installation/) for installing a Portworx cluster

## Install Portworx on Kubernetes using Rancher 2.x

Perform the following steps to install Portworx:

1. Navigate to the global cluster overview page. From the top navigation bar, select **Apps**:

    ![Screenshot showing the location of the apps tab in Rancher](/img/rancherNavigateApps.png)

2. Select the **Launch** button to open the catalog:

    ![Screenshot showing the launch button location](/img/rancherLaunch.png)

3. Search for the Portworx catalog and select the **View Details** button to start the Helm chart form:

    ![Screenshot indicating the search and select locations](/img/rancherSearchSelect.png)

4. Populate the various required sections of the **Configuration Options** of the Helm chart form:

     * In the **Configuration Options** section, name your project `kube-system`, and select `System` from the **Target Projects** dropdown:

        ![Screenshot showing the Helm chart form](/img/rancherConfigOptions.png)

        <!-- See the [Rancher documentation](https://rancher.com/docs/rancher/v2.x/en/catalog/multi-cluster-apps/#launching-a-multi-cluster-app) for more information. -->

     * In the **Key Value Store Paramters** section, specify an internal or external ETCD.

        ![Screenshot showing the KVDB section of the Helm chart form](/img/rancherKvdb.png)

     * In the **Storage Parameters** section, specify whether your cluster is located on-prem or on a cloud provider, and choose your disk configuration.

        ![Screenshot showing the Storage Parameters section of the Helm chart form](/img/rancherStorageParameters.png)


4. Select the **Launch** button to deploy Portworx to your cluster:

    ![Screenshot showing the launch button of the Helm chart form](/img/rancherHelmLaunch.png)


    Depending on your network and cluster performance, it may take between 5 and 20 minutes to install Portworx. Once the installation is completed, the Portworx processes will be shown as green.

## Post-Install

Once you have a running Portworx installation, below sections are useful.

{{<homelist series2="k8s-postinstall">}}

## Upgrade

Follow these steps to upgrade Portworx on Kubernetes using Rancher 2.x:

{{< widelink url="/install-with-other/rancher/rancher-2.x/upgrade" >}} Upgrading Portworx on Kubernetes using Rancher 2.x
{{</widelink>}}
