---
title: Remove or replace a failed drive
description: Deal with a failed drive by either removing it or replacing it
keywords: Portworx, troubleshoot
series: troubleshoot-portworx
weight: 90
---

When a drive fails, Portworx continues to operate using available replicas on other nodes. To fully recover from a drive failure, you must replace or remove the failed drive from Portworx, and how you recover depends on the pool which contains the failed drive.

There are two possible scenarios for a failed drive:

* The drive belongs to a pool which hosts Portworx metadata
* The drive belongs to a non-metadata pool

{{<info>}}
**NOTE:**

* You cannot recover a completely failed drive from a RAID 0 drive.
* You can only recover volumes with a replication factor greater than 1. Refer to the [updating volumes](/reference/cli/updating-volumes#update-a-volume-s-replication-factor) page for information on increasing the replication factor of a volume.
{{</info>}}

Perform the procedures below to determine if your drive failed on a storage pool containing metadata and remove or replace a failed drive:

## Determine if the pool containing your failed drive hosts Portworx metadata

You must determine if your failed drive belongs to a storage pool containing metadata to choose the appropriate method for replacing it.

1. Identify a failed drive and `ssh` into the node containing that drive.

2. Determine if the pool containing that drive hosts metadata by entering the `pxctl service pool show` command and looking for the `Has metadata` field in the output:

    ```text
    pxctl service pool show
    ```
    ```output
    PX drive configuration:
    Pool ID: 1
    UUID: 86d5d105-2eff-4dfb-b842-eca86906c921
    IO Priority: LOW
    Labels: iopriority=LOW,medium=STORAGE_MEDIUM_MAGNETIC
    Size: 20 GiB
    Status: Online
    Has metadata: Yes
    Drives:
    1: /dev/sdc, 8.0 GiB allocated of 20 GiB, Online
    Cache Drives:
    ```

    In the output above, note the line that reads "Has metadata: Yes".

If your service pool has metadata, follow the procedure to **Replace a drive that belongs to a pool which hosts Portworx metadata**. If your service pool does not have metadata, follow the procedure to **Replace a drive that belongs to a non-metadata pool**.

## Remove or replace a drive that belongs to a pool which hosts Portworx metadata

If the drive belongs to a pool that hosts Portworx metadata, then you must remove the node from the cluster and remove or replace the failed drive.

Perform the following steps to remove or replace the failed drive:

1. Use the [Node decommission workflow](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node/#step-1-migrate-application-pods-using-portworx-volumes-that-are-running-on-this-node) to remove a node from the cluster. This reduces the HA level for all replicated volumes which reside on the node and restores the volumes if enough storage nodes are available in the cluster.

2. Remove or replace the failed drive and add the node back into the cluster. Note that Portworx runs as a `DaemonSet` in Kubernetes, so when you add a node or a worker to your Kubernetes cluster, you don't need to explicitly run Portworx on it.

## Remove or replace a drive that belongs to a non-metadata pool

If the drive belongs to a non-metadata pool, then you must delete the affected storage pool.

{{<info>}}
**NOTE:** The failed drive must belong to a node that contains more than one storage pool. You cannot transition to a storageless node using this procedure.
{{</info>}}

Perform the following steps to remove or replace a failed drive by deleting the storage pool:

1. Enter the `pxctl service pool show` command and note the UID for the next step:

    ```text
    pxctl service pool show
    ```
    ```output
    PX drive configuration:
    Pool ID: 0
        UUID: 63e528b8-bc2e-484e-a01e-91e5108ebba5
        IO Priority:  LOW
        Labels:  iopriority=LOW,medium=STORAGE_MEDIUM_MAGNETIC
        Size: 128 GiB
        Status: Online
        Has metadata:  Yes
        Drives:
        1: /dev/sdc, 38 GiB allocated of 128 GiB, Online
        Cache Drives:
        No Cache drives found in this pool
    ```

2. Enter the `pxctl volume list` command with the `--pool-uid` option and the pool UID you got from the step above to list the volumes. Look through the output to find the replica sets that match the pool identifier containing the failed drive.

    ```text
    pxctl volume list --pool-uid 63e528b8-bc2e-484e-a01e-91e5108ebba5
    ```
    ```output
    ID			            NAME					SIZE	   HA SHARED	ENCRYPTED IO_PRIORITY	 STATUS		      SNAP-ENABLED
    184362890321734385	exampleVolume	128 GiB  3  no	    no		    LOW		       up - detached	no
    ```

3. Manually remove all replicas of the volumes in this pool. Refer to the [Decreasing the replication factor](/reference/cli/updating-volumes/#decreasing-the-replication-factor) section for information on how to do this.

4. Delete the pool by entering the `pxctl service pool delete` command with the identifier of your pool as an argument:

    ```text
    pxctl service pool delete 0
    ```

5. Optionally, replace the failed drive, ensuring that it's the same capacity and type as the failed one. Note that you can also reform the pool without the failed drive, resulting in a functional pool with one less drive.

6. Re-add the drives by entering the `pxctl service drive add` command, specifying the `--drive` option with the paths to your drives. The following command adds three drives:

    ```text
    pxctl service drive add --drive /dev/sdc /dev/sdd /dev/sde
    ```
