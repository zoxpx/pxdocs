---
title: Add clusters to PX-Central On-prem
weight: 5
keywords: add cluster, PX-Central, On-prem, license, GUI, k8s
description: Learn how to add clusters to your PX-Central on-prem dashboard.
noicon: true
series: k8s-op-maintain-1-0
hidden: true
---

Once you've installed PX-Central, you're ready to add the clusters you'll manage with it.

1. From the **PX-Central** home page, select the **+ Add Cluster** button.
2. Enter the **Endpoint** and **Port** number, if it's different from the default value, then select the **Verify Cluster** button.
3. At the expanded prompt:

    1. Confirm the cluster details: Cluster name, UUID, Orchestrator, and version.
    2. Enter your cluster's **KubeConfig**; you find this by entering the `kubectl config view --flatten --minify` command in your cluster.
    3. Select the **Verify Cluster** button followed by the **Submit** button to verify and add your cluster.

Once added, PX-Central returns to the landing page which now includes your newly added cluster.
