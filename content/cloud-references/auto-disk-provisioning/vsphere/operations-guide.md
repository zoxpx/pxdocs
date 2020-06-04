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

Portworx ships with the [pxctl](/reference/cli/) CLI out of the box that users can use to perform management operations.

{{<info>}} Where do I run `pxctl`?

_You can run `pxctl` by accessing any worker node in your cluster with `ssh` or by running the `kubectl exec` command on any Portworx pod._{{</info>}}

### Listing Portworx storage pools

{{<info>}}What are *Storage pools*?

Storage pools are logical groupings of your cluster's physical drives. You can create storage pools by grouping together drives of the same size and same type. A single node with different drive sizes and/or types will have multiple pools.

Within a pool, by default, the drives are written to in a RAID-0 configuration. You can configure RAID-10 for pools with at least 4 drives. When a pool is constructed, Portworx benchmarks individual drives and categorizes them as high, medium, or low based on random/sequential IOPS and latencies.
{{</info>}}

The following `pxctl` command lists all the Portworx storage pools in your cluster:

```text
pxctl cluster provision-status
```
```output
NODE                                    NODE STATUS     POOL                                            POOL STATUS     IO_PRIORITY     SIZE    AVAILABLE       USED    PROVISIONED     ZONE    REGION  RACK
1e24c031-112a-4e9d-a29a-299df278b7d5    Up              0 ( 92e24158-c603-419b-be58-55b59ddd8f2b )      Online          HIGH            100 GiB 86 GiB          14 GiB  28 GiB          AZ1     default default
2d10e356-d919-4396-bb4c-6e8e9a0e00fb    Up              0 ( 97a0c13b-671e-44c5-824c-00393d023fe1 )      Online          HIGH            100 GiB 93 GiB          7.0 GiB 1.0 GiB         AZ1     default default
6d73be65-b2fc-43e6-a588-135ef03cfa34    Up              0 ( faa3243f-5748-4328-ba00-596c0ceab709 )      Online          HIGH            100 GiB 93 GiB          7.0 GiB 0 B             AZ1     default default
d0e24758-8344-4547-9f27-fa69c643d7bf    Up              0 ( 9e4e525e-c133-46f0-b6b3-1c560f914963 )      Online          HIGH            100 GiB 93 GiB          7.0 GiB 0 B             AZ1     default default
```

### Listing Portworx disks (VMDKs)

{{<info>}} Where are Portworx VMDKs located?

_Portworx creates disks in a folder called *osd-provisioned-disks* in the ESXi datastore. The names of the VMDK created by Portworx will have a prefix *PX-DO-NOT-DELETE-*._{{</info>}}

The [Cloud Drives (ASG) using pxctl](/reference/cli/cloud-drives-asg/) CLI command is useful for getting more insight into the disks provisioned by Portworx in a vSphere environment. The following command provides details on all VMware disks (VMDKs) created by Portworx in your cluster:

```text
pxctl clouddrive list
```
```output
Cloud Drives Summary
        Number of nodes in the cluster:  4
        Number of drive sets in use:  4
        List of storage nodes:  [1e24c031-112a-4e9d-a29a-299df278b7d5 2d10e356-d919-4396-bb4c-6e8e9a0e00fb 6d73be65-b2fc-43e6-a588-135ef03cfa34 d0e24758-8344-4547-9f27-fa69c643d7bf]
        List of storage less nodes:  []

Drive Set List
        NodeIndex       NodeID                                  InstanceID                              Zone    State   Drive IDs
        2               6d73be65-b2fc-43e6-a588-135ef03cfa34    4223353e-5fa7-f025-3126-c7a9708ae56d    AZ1     In Use  [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-60f5bf86-f491-4b9e-b45a-2dee113fa334.vmdk(metadata), [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-a88ad6d3-3ec8-4e53-85a6-102ec24e44ab.vmdk(data)
        3               d0e24758-8344-4547-9f27-fa69c643d7bf    42237049-acea-5aca-918a-58a3ea11ce8e    AZ1     In Use  [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-94d3ebcf-a3e9-4a33-8776-2f0dd2e5a3a4.vmdk(metadata), [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-b54bd6ea-b8f7-451c-9568-abcb04ce8ffa.vmdk(data)
        0               1e24c031-112a-4e9d-a29a-299df278b7d5    42237e5f-9856-a1b6-16ed-85910785c40f    AZ1     In Use  [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-0050aea9-339f-4aa2-b746-a7b1aa11dad1.vmdk(data), [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-0fde78de-2dbf-4b9b-a8a8-3903b92659de.vmdk(metadata)
        1               2d10e356-d919-4396-bb4c-6e8e9a0e00fb    42230aee-29a8-c07b-f3b9-d40a2a02b391    AZ1     In Use  [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-2902a0c2-743f-44e8-a4e2-24ddc46fef0a.vmdk(metadata), [datastore-589] 260f0d5d-207e-2372-3d57-ac1f6b204d08/PX-DO-NOT-DELETE-22831713-16ed-410e-a816-762c6de09f19.vmdk(data)
```

### Prometheus and Grafana

Portworx exposes many useful metrics out of the box. Refer to the [Portworx Metrics for monitoring](/reference/metrics/) page for the full list of metrics.

Portworx also alerts users on a predefined set of alerts that are listed on the [Portworx Alerts](/install-with-other/operate-and-maintain/monitoring/portworx-alerts/) page.

The [Prometheus and Grafana on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) page describes how to use Prometheus and Grafana to monitor Portworx in a Kubernetes cluster and extract the metrics and alerts.

## Capacity Management

You can increase capacity in one of two ways:

### A. Increase storage capacity for a storage pool

As storage usage increases, you must expand the Portworx storage pools:

1. Identify the Portworx storage pool you want to expand by [listing them](#listing-portworx-storage-pools).
2. Enter the `pxctl service pool expand` command specifying the following:

     * UUID: The UUID of the pool you want to expand. This is found the **POOL** column when you listed the pools.
     * SIZE: The minimum new required size of the storage pool in GiB.
     * OPERATION-TYPE: The type of disk operation that will be performed to expand the pool. You have 2 options:
         * **resize-disk**: Portworx will resize existing VMDKs in the storage pool. This is the recommended operation as this does not require data movement on the backing drives in the pool.
         * **add-disk**: Portworx will create one or more VMDKs based on the required new size of the pool. After the drive is added to the pool, Portworx will rebalance the volumes onto the new VMDKs. As a result, this operation can take a while to complete.

    ```text
    pxctl service pool expand -u <UUID> -s <SIZE> -o <OPERATION-TYPE>
    ```


3. Once you submit the command, Portworx will expand the storage pool in the background. You can [list the storage pools](#listing-portworx-storage-pools) periodically to check if they have finished expansion.
    ```text
    pxctl cluster provision-status
    ```
4. When invoked on the Portworx node where the storage pool resides, the following command  provides detailed information about the status of the pool expand process.
    ```text
    pxctl service pool show
    ```

### B. Increase storage of the backing ESXi datastore(s)/datastore cluster(s)

{{<info>}}When do I need this? You would need this when the existing datastores being used by Portworx are filling up and there is no space left to increase storage capacity of individual nodes.{{</info>}}

This can be done in one of 2 ways. Once the datastore(s) or datastore cluster(s) are expanded, Portworx can use the increased capacity to provision new VMDKs or resize existing VMDKs.

#### 1. Resize existing ESXi datatores

You can expand the drives backing the datastore in your storage array and then increase datastore capacity from the vSphere web client.

#### 2. Add new datastore(s) to the Datastore cluster

If you provided the prefix of a datastore cluster names to Portworx during installation, you can dynamically add new datastores to the datastore cluster. This will increase the capacity of the datastore cluster.

## FAQs

### Which datastore does Portworx select when creating VMDKs?

The [Portworx VMware installation](/cloud-references/auto-disk-provisioning/vsphere/#installation) takes in a prefix for the datastores or datastore clusters you want to use for Portworx using the environment variable `VSPHERE_DATASTORE_PREFIX`.

* When the provided prefix is for datastores, Portworx will pick the datastore with the most free available space to create it's VMDK.
* When the provided prefix is for datastore clusters, Portworx will use vSphere storage resource manager APIs to get recommendation on the datastore to use within the datastore cluster. From the provided recommendations, Portworx uses the first datastore in the list.
