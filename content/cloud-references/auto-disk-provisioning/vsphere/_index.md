---
title: Disk Provisioning on VMware vSphere
description: Learn to scale a Portworx cluster up or down on VMware vSphere with Auto Scaling.
keywords: portworx, VMware, vSphere ASG
linkTitle: VMware
weight: 3
noicon: true
---

This guide explains how the Portworx Dynamic Disk Provisioning feature works within Kubernetes on VMware and the requirements for it.

{{<info>}}Installation steps below are only supported if you are running with Kubernetes.{{</info>}}

## Architecture

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-shared-arch.md" %}}


## Limiting storage nodes

{{% content "cloud-references/auto-disk-provisioning/shared/asg-limit-storage-nodes.md" %}}

{{% content "cloud-references/auto-disk-provisioning/shared/asg-examples-vsphere.md" %}}

## Availability across failure domains

Since PX is a storage overlay that automatically replicates your data, we recommend using multiple availability zones when creating your VMware vSphere based cluster. Portworx automatically detects regions and zones that are populated using known Kubernetes node labels. You can also label nodes with custom labels to inform Portworx about region, zones and racks. The page [Cluster Topology awareness
](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/cluster-topology/) explains this in more detail.

## Installation

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-px-install.md" %}}
