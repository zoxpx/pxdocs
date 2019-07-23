---
title: Portworx vSphere storage operations guide
linkTitle: Operations guide
description: This section describes common storage operational and maintenance procedures when using Portworx in a vSphere environment
keywords: portworx, VMware, vSphere ASG
---

## Installation

During installation, user provides following parameters which are used to create disks (VMDKs) for the Portworx storage pools. The sum total of disks will be the starting storage capacity of your Portworx cluster.

1. Prefix for names of ESXi Datastore(s) or Datastore cluster(s)
2. Specification of type and size of disks to create. 
3. Access details for vCenter server

The [Portworx VMware installation](/cloud-references/auto-disk-provisioning/vsphere/#installation) covers this in detail.

## Monitoring

### Listing disks created by Portworx

Portworx ships with the [pxctl](/reference/cli/) CLI out of the box that users can use to perform management operations.

{{<info>}} Where are Portworx VMDKs located?

_Portworx creates disks in a folder called *osd-provisioned-disks* in the ESXi datastore. The names of the VMDK created by Portworx will have a prefix *PX-DO-NOT-DELETE-*._{{</info>}}

The [Cloud Drives (ASG) using pxctl](/reference/cli/cloud-drives-asg/) CLI command is particularly useful in getting more insight into the disks provisioned by Portworx in a vSphere environment. Follow command gives details on all VMware disks (VMDKs) created by Portworx in your cluster.

```text
pxctl clouddrive list
```
```output
Cloud Drives Summary
        Number of nodes in the cluster:  3
        Number of drive sets in use:  3
        List of storage nodes:  [4267f9b3-5785-463e-8358-62ab1195b839 731ec7dc-e581-4dd2-b5dd-ad3ef62255f5 cb9762d6-29e8-4bd1-8228-3cb9c9a42ff8]
        List of storage less nodes:  []

Drive Set List
        NodeIndex       NodeID                                  InstanceID                              Zone    Drive IDs
        0               4267f9b3-5785-463e-8358-62ab1195b839    422387fd-00c7-58b0-f275-63bad5b6e6d8    AZ1     [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-ca2a2eed-78cb-4ebd-a173-e094ba6210ad.vmdk(data)
        1               731ec7dc-e581-4dd2-b5dd-ad3ef62255f5    4223719d-c9c7-c8a9-0fb9-25f4f2a66fd4    AZ1     [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-b54e705b-d14a-4069-8277-3c82ece5131b.vmdk(data)
        2               cb9762d6-29e8-4bd1-8228-3cb9c9a42ff8    4223fa3d-5eca-00a1-0744-8295a8c69374    AZ1     [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-2eb48140-d5e1-4a4c-8e6a-99c7a8d697fd.vmdk(data)
```

{{<info>}} Where do I run pxctl?

_You can run pxctl by ssh'ing to any worker node in cluster or by `kubectl exec` on any Portworx pod._{{</info>}}

### Prometheus and Grafana

Portworx exposes many useful metrics out of the box. These metrics are listed on [this page](/install-with-other/operate-and-maintain/monitoring/prometheus/#storage-and-network-stats).

Portworx also alerts users on a predefined set of alerts that are listed on the [Portworx Alerts](/install-with-other/operate-and-maintain/monitoring/portworx-alerts/) page.

The [Prometheus and Grafana on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) page describes how to use Prometheus and Grafana to monitor Portworx in a Kubernetes cluster and extract the metrics and alerts.

## Capacity Management

As storage usage increases, you will need to increase the backing storage capacity for Portworx. Increasing capacity falls into 2 primary buckets:

### a. Increase storage capacity for a single node

To expand the storage capacity of a single node, you have 2 options 

1. [Add new disk to a node](/cloud-references/auto-disk-provisioning/vsphere/operations-guide/#add-new-disk)
2. [Resize existing disk on a node](/cloud-references/auto-disk-provisioning/vsphere/operations-guide/#resize-disk)

<a name="add-new-disk"></a>
#### 1. Add new disk to a node

1. Identify the Portworx node where you want to add the disk.
2. Drain all apps using Portworx volumes from this node. You can either use `kubectl drain` or `kubectl cordon` and `kubectl delete pod` for this.
3. SSH to the node.
4. Enter Portworx maintenance mode.

    ```text
    pxctl service maintenance --enter
    ```

    Wait for about 2 minutes until `pxctl status` says *PX is in maintenance Mode*.
5. List Portworx pools and save the output.

    ```text
    pxctl sv pool show
    ```
6. Use pxctl to add a new disk. This command will provision a new VMDK as per the given spec. Below example creates a 20GB VMDK of type eagerzeroedthick. Change the size as per your needs. It is recommended to use a size that's same as the current disks in your storage pools. This will allow us to expand the existing storage pool.

    ```text
    pxctl sv drive add --spec size=20,type=eagerzeroedthick
    ```
    ```output
    Drive add done: Storage rebalance is in progress
    ```
7. List Portworx pools again and you will see one of the pools now has a new drive added.

    ```text
    pxctl sv pool show
    ```
8. Resize the pool to account for this newly added disk. `<pool-id>` here is the ID of the pool where you see the newly added disk in the previous step.

    ```text
    pxctl sv pool update --resize <pool-id>
    ```
9. Exit maintenance mode.

    ```text
    pxctl service maintenance --exit
    ```

    Wait for about 2 minutes until `pxctl status` says *PX is operational*.
10. List Portworx pools again and you will now see the pool has the expanded size.

    ```text
    pxctl sv pool show
    ```
11. Uncordon the node from Kubernetes.

<a name="resize-disk"></a>
#### 2. Resize existing disk on a node

{{<info>}} Portworx 2.2 will have an improved resize workflow that will automate below steps.{{</info>}}

1. Use pxctl to list disks created by Portworx as shown [previously on this page](/cloud-references/auto-disk-provisioning/vsphere/operations-guide/#listing-disks-created-by-portworx)
2. Identify the VMDK to resize from this list.
3. Identify the Portworx node where this VMDK is being used. This is shown in the `NodeID` column. 
4. Inspect the Portworx node where the VMDK is being used.

    ```text
    pxctl cluster inspect <node-id>
    ```
5. Using vSphere web client, expand the VMDK on the VM for the above node.
6. Drain all apps using Portworx volumes from this node. You can either use `kubectl drain` or `kubectl cordon` and `kubectl delete pod` for this.
7. SSH to the Portworx node identified in step 3.
8. Enter Portworx maintenance mode.

    ```text
    pxctl service maintenance --enter
    ```

    Wait for about 2 minutes until `pxctl status` says *PX is in maintenance Mode*.
9. List Portworx pools and find the pool that’s affected by the resized vol

    ```text
    pxctl sv pool show
    ```
10. Resize the pool to account for the expanded VMDK.

    ```text
    pxctl sv pool update --resize <pool-id>
    ```
11. Exit maintenance mode.

    ```text
    pxctl service maintenance --exit
    ```

    Wait for about 2 minutes until `pxctl status` says *PX is operational*.
12. List Portworx pools again and you will now see the pool has the expanded size.

    ```text
    pxctl sv pool show
    ```
13. Uncordon the node from Kubernetes.

### b. Increase storage of the backing ESXi datastore(s)/datastore cluster(s)

{{<info>}}When do I need this? You would need this when the existing datastores being used by Portworx are filling up and there is no space left to increase storage capacity of individual nodes.{{</info>}}

This can be done in one of 2 ways. Once the datastore(s) or datastore cluster(s) are expanded, Portworx can use the increased capacity to provision new VMDKs or resize existing VMDKs.

#### 1. Resize existing ESXi datatores

You can expand the drives backing the datastore in your storage array and then increase datastore capacity from the vSphere web client.

#### 2. Add new datastore(s) to the Datastore cluster

If you provided the prefix of a datastore cluster names to Portworx during installation, you can dynamically add new datastores to the datastore cluster. This will increase the capacity of the datastore cluster.
  
