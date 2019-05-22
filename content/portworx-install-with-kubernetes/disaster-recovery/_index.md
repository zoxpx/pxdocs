---
title: "Disaster Recovery (DR) for Kubernetes"
linkTitle: "Disaster Recovery (DR)"
keywords: cloud, backup, restore, snapshot, DR, PX-DR, migration
hidesections: true
---

This section describes the different methods for achieving Disaster Recovery (DR) between *multiple* Kubernetes clusters when using Portworx.

There are 2 primary options for this:

1. **Metro DR**: Nodes are in the *same* Metro Area Network ([MAN](https://en.wikipedia.org/wiki/Metropolitan_area_network))
2. **Asynchronous DR**: Nodes are across *different* regions/datacenters

Choosing between these options depends on how your cluster nodes are laid out. Below section helps you make that choice.

## 1. Metro DR: Nodes are in the Metro Area Network (MAN)

![Portworx metro overview](/img/px-metro-overview.png)

### When

You should use this option when:

* Nodes in all your Kubernetes clusters are in the same **Metro Area Network** ([MAN](https://en.wikipedia.org/wiki/Metropolitan_area_network)). These could be nodes that are in
  * The same cloud region. They can be in different zones.
  * The same datacenter or datacenters that are just 50 miles apart.
* The network latency between the nodes is lower than ~10ms.

### What

The option has the following characteristics:

* A **single Portworx cluster** that stretches across multiple Kubernetes clusters.
* Portworx installation on all clusters use a common **external key-value store** (e.g etcd).
* Volumes are automatically **replicated** across the Kubernetes clusters as they share the same Portworx storage fabric.
* This option will have zero **RPO** and **RTO** less than 60 seconds.


### How

Click on the section below for instructions on how to setup this option.

{{< widelink url="/portworx-install-with-kubernetes/disaster-recovery/px-metro" >}}How to setup Metro DR{{</widelink>}}

## 2. Asynchronous DR:Nodes are across different regions/datacenters

![Portworx Scheduled migration overview](/img/scheduled-migration-overview.png)

### When

You should use this option when:

* Nodes in all your Kubernetes clusters are in the different regions or datacenter.
* The network latency between the nodes is high.

### What

The option has the following characteristics:

* A separate Portworx cluster installation for each Kubernetes clusters.
* Portworx installations on each cluster can use their own key-value store (e.g etcd).
* Users create scheduled migrations of application and volumes between 2 clusters that are paired.
* This option will have an **RPO** of 15 minutes and **RTO** less than 60 seconds.

### How

Click on the section below to instructions on how to setup this option.

{{< widelink url="/portworx-install-with-kubernetes/disaster-recovery/async-dr" >}}How to setup Asynchronous DR{{</widelink>}}


## Licensing

Please note that the Disaster Recovery (PX-DR) license is not included with the PX-Enterprise Trial license.
If you are interested in testing or purchasing this functionality, please reach out to us at support@portworx.com.
