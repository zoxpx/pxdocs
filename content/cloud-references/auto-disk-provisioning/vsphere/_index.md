---
title: Disk Provisioning on VMware vSphere
description: Learn to scale a Portworx cluster up or down on VMware vSphere with Auto Scaling.
keywords: portworx, VMware, vSphere ASG
linkTitle: VMware
weight: 3
noicon: true
---

This guide explains how the Portworx Dynamic Disk Provisioning feature works on VMware and the requirements for it.

{{<info>}}Disk provisioning on VMware is only supported if you are running with Kubernetes.{{</info>}}

## Architecture

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-shared-arch.md" %}}

## Disk templates

A disk template defines the VMDK properties that Portworx will use as a reference for creating the actual disks out of which Portworx will create the virtual volumes for your PVCs. These templates are given to Portworx during installation as arguments to the Daemonset.

The template follows the following format:
```
"type=<vmdk type>,size=<size of the vmdk>"
```
* __type__: Following two types are supported
    * _thin_
    * _zeroedthick_
    * _eagerzeroedthick_
* __size__: This is the size of the VMDK

## Limiting storage nodes

{{% content "cloud-references/auto-disk-provisioning/shared/asg-limit-storage-nodes.md" %}}

{{% content "cloud-references/auto-disk-provisioning/shared/asg-examples-vsphere.md" %}}

## Availability across failure domains

Since PX is a storage overlay that automatically replicates your data, we recommend using multiple availability zones when creating your VMware vSphere based cluster. Portworx automatically detects regions and zones that are populated using known Kubernetes node labels. You can also label nodes with custom labels to inform Portworx about region, zones and racks. The page [Cluster Topology awareness
](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/cluster-topology/) explains this in more detail.

## Installation

### Step 1: Create a Kubernetes secret with your vCenter user and password

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-secret.md" %}}

### Step 2: Download rest of the specs

Continue to [Install on-premise](/portworx-install-with-kubernetes/on-premise/) for details instructions on installing Portworx.

### Step 3: Add env variables in the DaemonSet spec

You will need to change the following sections in the downloaded spec to match your environment:

1. **VSPHERE_VCENTER**: Hostname of the vCenter server.
2. **VSPHERE_DATASTORE_PREFIX**: Prefix of the ESXi datastore(s) that Portworx will use for storage.

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}
{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
