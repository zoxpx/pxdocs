---
title: Portworx Essentials
weight: 1
hidesections: true
description: Learn about the Portworx Essential free product offering
series: concepts
keywords: portworx, essentials
---

{{< pxEssentials >}} is a free Portworx license with limited functionality that allows you to run small production or proof-of-concept workloads. Essentials limits capacity and advanced features, but otherwise functions the same way as the fully-featured {{< pxEnterprise >}} version of Portworx.

The {{< pxEssentials >}} license requires that your clusters be connected to the internet and send usage data to PX-Central. {{< pxEssentials >}} clusters connect with PX-Central once per hour to renew license leases. Lease periods last for 24 hours, ensuring that any temporary interruptions to your connectivity do not impact your cluster.

To get started with {{< pxEssentials >}}, sign up and generate a spec on [PX-Central](https://central.portworx.com/). Licenses for Essentials are generated automatically and activate when your cluster connects to PX-Central.

## {{< pxEssentials >}} available features and limitations

The following tables list what features {{< pxEssentials >}} supports and any limitations it may have:

### {{< pxEssentials >}}

| **Feature** | **Support** |
|----|----|
| Maximum {{< pxEssentials >}} licenses per user  | 1 |
| Maximum clusters per {{< pxEssentials >}} license | 1 |
| Maximum nodes per cluster | 5 |
| Host type supported | VMs and bare metal servers |
| Max containers mounting volumes per host | 30 |
| Host storage capacity limits | 1TB per host |
| Cluster storage capacity limits | 5TB per cluster |
| Support (includes updates, upgrades) | [Online Support](https://forums.portworx.com) |
| Telemetry requirement (install/operate) | Users must have telemetry enabled in order to use {{< pxEssentials >}}.|
| Licensing | Users must have a {{< pxEssentials >}} license (available for free at PX-Central)|

### PX-Store

| **Feature** | **Support** |
|----|----|
| Container-optimized volumes with elastic scaling (no application downtime) | Supported |
| Maximum number of volumes per cluster | 500 |
| Maximum volume size | 1TB |
| Storage performance tiers (high, medium, low) | Supported |
| Application-aware I/O tuning | Supported |
| Read/Write many across multiple containers | Supported |
| Failover across nodes, racks, and availability zones | Supported |
| Form storage pools from aggregated volumes across hosts | Supported |
| Synchronous Replication <!-- what about async? --> | Supported |
| Volume Consistency Groups <!-- not sure what this is --> | Supported |

<!-- make columns on the left the same as from the website -->

### Data Management

| **Feature** | **Support** |
|----|----|
|PX-Migrate: Migrate volumes and Kubernetes applications across clusters. | Not supported |
| Snapshots of stateful applications | Limited to 5 snapshots per volume|
| Cloudsnap backups to cloud storage | Limited to 1 cloudsnap per day per volume |
| Auto-scaling groups (ASG) with support for AWS, GCP, Azure. | Supported |

### PX-Central

| **Feature** | **Support** |
|----|----|
| Cluster management UI | Single user, single cluster |
| Proactive centralized monitoring | Supported |
| Cluster management CLI | Supported |
| PX-Central on-premises with license server | Not Supported |

### Advanced Functionality

| **Feature** | **Support** |
|----|----|
| Security and identity integrated with Kubernetes namespace and OIDC providers | Not Supported |
| Encryption with bring-your-own-encryption | Limited to cluster-wide encryption |
| Disaster Recovery for campus and WAN deployments | Not supported |
| Capacity Management with Autopilot | Not supported |

### Orchestrator

| **Feature** | **Support** |
|----|----|
| Scheduler integration: Kubernetes, Mesos, Docker Swarm, Hashicorp Nomad, Openshift | Supported |
| Integration with Managed K8S services: EKS, AKS, GKE, PKS, IKS, RKE | Supported |

## Related Topics

Get started with {{< pxEssentials >}} now:

* [Install Portworx](/portworx-install-with-kubernetes/)
* [Deploy stateful applications on on Kubernetes with Portworx](/portworx-install-with-kubernetes/application-install-with-kubernetes/)

Find answers to common questions on the {{< pxEssentials >}} FAQ:

* [Portworx FAQ](https://forums.portworx.com/t/portworx-essentials-faq/346)
