---
title: DR and multi-data center HA architectures
linkTitle: DR and multi-DC HA
description: DR and multi-data center HA architectures
keywords: Portworx, stateful applications, Kubernetes, k8s, deployment, architecture, HA, high-availability, DR, disaster recovery
weight: 2
---

Portworx offers multiple options for DR and multi-data center HA beyond what is provided with the single data center/multiple AZ deployment options. For more on why you cannot simply use your traditional DR system for Kubernetes applications, see the [Limits of traditional DR for Kubernetes applications](/portworx-install-with-kubernetes/application-install-with-kubernetes/deployment-arch/limits-of-traditional-dr) section.

## Option 1- Synchronous DR over a MAN using multiple Kubernetes clusters with a single Portworx stretch cluster

**Solves for these primary needs:**

* Container- or Namespace-granular DR.  
* RPO zero data protection and low RTO in the case of losing an entire data center.
* Data and Kubernetes objects are replicated across both sites, simplifying and speeding up application failover

**Key constraints:**

* Requires two data centers.
* Round trip latency between data centers must be < 10 ms. This can usually be accomplished using different cloud providers in the same geographical region, colocating an on-premises data center in the same region as a cloud provider or operating a campus or metropolitan area network.

![Synchronous Disaster Recovery over a metro area network using multiple Kubernetes clusters with a single Portworx stretch cluster](/img/deployment-architectures-synchronous-disaster-recovery-over-man-mulitple-k8s-clusters.png)


## Option 2- Asynchronous DR over a WAN using multiple Kubernetes clusters with multiple Portworx clusters

**Solves for these primary needs:**

* Container- or Namespace-granular Disaster Recovery.  
* RPO levels are as low as 15 minutes and RTO under one minute in the case of losing an entire data center.
* Data and Kubernetes objects are replicated across both sites, simplifying and speeding up application failover

**Key constraints:**

* Requires two data centers.
* S3-compatible object store is available to move data.

![Asynchronous DR of a wide-area network (WAN) using multiple Kubernetes clusters with multiple Portworx clusters](/img/deployment-architectures-asynch-dr-over-wan-multiple-k8s-clusters-multiple-portworx clusters.png)

### Summary of Synchronous vs. Asynchronous PX-DR Options

| Application and infrastructure requirements| Synchronous PX-DR | Asynchronous PD-DR  |
| --- | :---: | :---: |
| Number of Portworx clusters| 1 | 2 |
| Needs an S3-compatible object store to move data | No | Yes |
| Max round trip latency between data centers | 10 ms | No limit |
| Data guaranteed to be available at both sites (zero RPO) | Yes | No |
| Kubernetes objects replicated between data centers | Yes | Yes |
| Low RTO | Yes | Yes |

## Option 3- Multi-site data center stretch cluster for HA

**Solves for these primary needs:**

* High availability of data services across multiple data centers.
* Zero RPO data protection.

**Key constraints:**

* Requires three data centers.
* Max round trip latency between data centers of under 10 ms.

![Multi-site data center stretch cluster for HA](/img/deployment-architectures-multi-site-dc-stretch-cluster-for-ha.png)
