---
title: Add clusters to PX-Central On-prem
weight: 3
keywords: add cluster, PX-Central, On-prem, license, GUI, k8s
description: Learn how to add clusters to your PX-Central on-prem dashboard.
noicon: true
series: k8s-op-maintain
hidden: true
---

Once you've installed PX-Central, you're ready to add the clusters you'll manage with it.

## Prerequisites

Ensure you meet the following prerequisites on the cluster you will be adding to PX-Central on-prem:

* Open ports on your cluster:

    | Port | Component | Purpose | Incoming/Outgoing |
    | :---: |:---:|:---:|:---:|
    | 31240 | PX-Central | Sends metrics data to PX-Central on-prem | Outgoing |

* You must be admin or have permissions to create and configure `Clusterrole`, `Clusterrolebinding` objects on your cluster. If you don't meet this prerequisite, you'll still be able to add your cluster to PX-Central, but you wont be able to use the Lighthouse monitoring features.

## Add a cluster to PX-Central on-prem

1. From the **PX-Central** home page, select the **Lighthouse** icon:

    ![Select the Lighthouse icon](/img/select-the-lighthouse-icon.png)

2. Select the **Add PX Cluster** button:

    ![Add Portworx cluster](/img/add-portworx-cluster.png)

3. Populate the fields in the **Add Portworx Cluster** page:

    * Enter a descriptive cluster name
    * In the **Cluster endpoint** field, specify the IP address of a worker node, and the port range. If you modify the default port range, you can select the **Verify** button
    * _(Optional)_ In the **Metrics URL** field, specify your Grafana endpoint:

    ![Enter cluster details](/img/enter-cluster-details.png)

4. Select the **Submit** button.

<!-- The following note looks out of place. Shall we move it to the "Uninstall PX-Central on-premises" section? -->

{{<info>}}
**NOTE:** When you remove a cluster from PX-Central on-prem, it does not remove Prometheus from that cluster, and Grafana will continue to show cluster metrics dashboards.
{{</info>}}
