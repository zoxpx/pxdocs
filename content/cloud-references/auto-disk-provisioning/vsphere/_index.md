---
title: Disk Provisioning on VMware vSphere
description: Learn to scale a Portworx cluster up or down on VMware vSphere with Auto Scaling.
keywords: portworx, VMware, vSphere ASG
linkTitle: VMware
weight: 3
noicon: true
---

This guide explains how the Portworx Dynamic Disk Provisioning feature works within Kubernetes on VMware and the requirements for it.
It is _not_ a requirement to have [VMWare cloud provider](https://github.com/kubernetes/cloud-provider-vsphere) plugin, nor [VCP](https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/) nor [PKS](/portworx-install-with-kubernetes/on-premise/install-pks/install-pks-vsphere-shared/) for the below setup to work (e.g. a vanilla/upstream Kubernetes setup will work as well).

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

You will need to change (or add) the following sections in the Portworx DaemonSet section of the downloaded spec to match your environment:

1. **VSPHERE_VCENTER**: Hostname of the vCenter server.
2. **VSPHERE_DATASTORE_PREFIX**: Prefix of the ESXi datastore(s) that Portworx will use for storage.
3. **VSPHERE_INSTALL_MODE**: "shared"
4. **VSPHERE_USER**: should be a `valueFrom` with a secretKeyRef of `VSPHERE_USER` (referencing to the px-vsphere-secret defined above)
5. **VSPHERE_PASSWORD**: should be a `valueFrom` with a secretKeyRef of `VSPHERE_PASSWORD` (referencing to the px-vsphere-secret defined above)

Optionally, you may also need to specify these:

6. **VSPHERE_VCENTER_PORT**: with the port number, if your vsphere services are not on the default port 443
7. **VSPHERE_INSECURE**: if you are using self-signed certificates

### Step 4: Permission your vcenter-server-user appropriately

Your _vcenter-server-user_ will need to either have the full Admin role or, for increased security, a custom-created role with the following minimum [vsphere privileges](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-FEAB5DF5-F7A2-412D-BF3D-7420A355AE8F.html):

  - Datastore.Browse
  - Datastore.FileManagement
  - Host.Local.ReconfigVM
  - VirtualMachine.Config.AddExistingDisk
  - VirtualMachine.Config.AddNewDisk
  - VirtualMachine.Config.AddRemoveDevice
  - VirtualMachine.Config.EditDevice
  - VirtualMachine.Config.RemoveDisk
  - VirtualMachine.Config.Settings

The above permissions are in the format returned from the [govc utility](https://github.com/collabnix/govc) (which is in itself useful for troubleshooting your vcenter-server-user access as well).

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}
{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
