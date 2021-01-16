---
title: View your cluster's cloud snapshots in PX-Central on-prem
linkTitle: Cloud snapshots
weight: 5
keywords: monitor cluster, PX-Central, On-prem, license, GUI, k8s
description: Learn how to display the list of cloud snapshots in PX-Central on-prem.
noicon: true
series: k8s-op-maintain-1-2-0
hidden: true
---

Cloud snapshots reside on your cloud storage accounts. Thus, you must configure PX-Central to access and display them.

## Prerequisites

* You've added at least one cluster to PX-Central. See the [Add clusters to PX-Central On-prem](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/add-clusters/) page for details.

## Display the list of your cloud snapshots in PX-Central on-prem

1. From the **PX-Central** home page, select the **Lighthouse** icon:

    ![Select the Lighthouse icon](/img/select-the-lighthouse-icon.png)

2. Select your cluster, to go to the cluster details page:

    ![Select your cluster](/img/select-your-cluster.png)

3. Select the **Cloud Snapshots** tab:

    ![Select the cloud snapshots tab](/img/select-cloud-snapshots.png)

4. Select the **+** icon:

    ![Add cloud credentials](/img/add-cloud-credentials.png)

5. Select a cloud type from the **Cloud Type** radio group, enter the details of your cloud account at the expanded prompt, and then select the **Submit** button:

    ![Cloud account details](/img/cloud-account-details.png)

Once you've added your cloud storage credentials to PX-Central, it will display a list of the cloud snapshots located on cloud storage:

    ![The list of your cloud snapshots](/img/your-cloud-snapshots.png)
