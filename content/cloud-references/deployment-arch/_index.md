---
title: Deployment architectures for Portworx
linkTitle: Deployment architectures
description: Understand various deployment architectures for Portworx
keywords: Deployment architecture, disaggregated architecture, converged architecture, Hyperconverged, AWS, Amazon Web Services, GCP Google Cloud Platform, VMWare vSphere
weight: 1
series: arch-references
---

There are 2 primary approaches you can take when architecting your Portworx deployment.

* A) **Disaggregated** where the storage nodes are separate from the compute nodes

* B) **Converged** where compute and storage nodes are the same

These two approaches are discussed below.

## Approach A: Separate Storage and Compute clusters


![Portworx deployment architecture for cloud](/img/px-cloud-arch-A.png)

### What

* Separate Storage cluster (green above). Nodes in this cluster have disks.
* Separate Compute cluster (yellow above). The application container workloads run in this cluster.
* The Portworx installation (orange above) spans across both of these clusters to provide a single storage fabric.
* The Storage and Compute clusters are different orchestrator clusters (e.g different Kubernetes clusters) that share the storage fabric.

### Why

You would chose this option if you have a very dynamic compute environment, where the number of compute nodes can elastically increase or decrease based on workload demand. Some examples of what can cause this elasticity are:

* Autoscaling up or down due to increasing and decreasing demands. An example would be to temporarily increase the number of worker nodes from 30 to 50 to handle the number of PODs in the system.
* Instance upgrades due to kernel updates, security patches etc
* Orchestrator upgrades (e.g Kubernetes upgrade)

Separating storage and compute clusters mean such scaling & management operations on the storage cluster don't interfere with the compute cluster, and vice versa.

{{<info>}}
**NOTE:**
Portworx Inc. recommends this approach in autoscaling cloud environments.
{{</info>}}

## Approach B: Hyperconverged Storage and Compute clusters

![Portworx deployment architecture hyperconverged](/img/px-deployment-arch-hyperconverged.png)

### What

* A single cluster with nodes providing storage and compute both (green above). (e.g a single Kubernetes cluster)
* The cluster could have certain nodes that don't have disks. These nodes can still run stateful applications.
* Scaling & managaging operations on this cluster affect both Storage and Compute nodes.

### Why

This approach is suitable for clusters that typically have the following characteristics:

* Hyperconveged compute and storage to achieve high performance benchmarks
* The instances in the cluster are mostly static. This means they don't get recycled very frequently.
* Scaling up and scaling down of the cluster is not that frequent
* The cluster admins don't want separation of concern between the Storage and Compute parts of the cluster.
