---
title: Add clusters to PX-Central On-prem
weight: 5
keywords: add cluster, PX-Central, On-prem, license, GUI, k8s
description: Learn how to add clusters to your PX-Central on-prem dashboard.
noicon: true
series: k8s-op-maintain
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

1. From the **PX-Central** home page, select the **+ Add Cluster** button.
2. Enter the **Endpoint** and **Port** number, if it's different from the default value, then select the **Verify Cluster** button.
3. At the expanded prompt:

    1. Confirm the cluster details: Cluster name, UUID, Orchestrator, and version.
    2. Enter your cluster's **KubeConfig**; you find this by entering the `kubectl config view --flatten --minify` command in your cluster.
    3. Select the **Verify Cluster** button followed by the **Submit** button to verify and add your cluster.

Once added, PX-Central returns to the landing page which now includes your newly added cluster.

{{<info>}}
**NOTE:** When you remove a cluster from PX-Central on-prem, it does not remove Prometheus from that cluster, and Grafana will continue to show cluster metrics dashboards.
{{</info>}}