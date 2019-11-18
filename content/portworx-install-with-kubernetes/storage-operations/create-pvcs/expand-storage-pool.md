---
title: Expand your storage pool size
weight: 4
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets, volume placement
description: Explore different methods for expanding your storage pool size.
---

As your cluster usage increases and the data on your storage pools grows, you may start to run out of capacity. In order to correct this, you must determine the best way to expand your storage pool size.

You can expand your storage pools horizontally by adding drives or vertically by increasing the size of the drives you have. Which method you choose depends on the following factors:

* How many drives your pool contains already
* How large the drives in your pool currently are
* The difficulty or cost associated with each method
* The environment you're operating in: cloud or on-prem

If you're operating on the cloud, you may choose to expand your pools to avoid potentially disruptive restriping operations associated with adding drives. If you're operating on-premises, you may not be able to increase the size of your disks if you don't have any remaining physical capacity.

Once you've considered your options and chosen the best approach for your cluster, perform the resizing operation:

## Expand a pool automatically on the cloud

If you're running on the cloud, factor automation into your decision for which pool resize approach you use. The `pxctl service pool expand` command allows you to perform resize operations without manually adding new drives or increasing drive capacity on your cluster.

When you enter the `pxctl service pool expand` command, Portworx uses your cloud provider's API to create new drives and attach them or to expand the existing drives with no further input from you.

You can control the pool expand operation by specifying which operation you want to use: `resize-disk` or `add-disk`, or you can specify `auto` to let Portworx determine the best way to resize your storage pools based on your cloud provider.

Perform the following steps expand a pool using the `pxctl service pool expand` command:

### Prerequisites

* You must be running Portworx on one of the following cloud providers:
  * AWS
  * Azure
  * GCP

To expand a pool  the `pxctl service pool expand` command with the following options:
* The `--operation` option with the operation you wish to perform
* The `--size` option with the minimum new size of the pool in GiB
* The `--uid` option with the ID of the pool you wish to resize

```text
pxctl service pool expand --operation auto --size 1000 --uid 3
```

## Expand a pool manually

If you're running Portworx on-prem or want to resize a pool manually using a certain drive, you must use different `pxctl service` commands.

### Add drives

You can add more capacity to your storage pools by adding drives to them. When you add drives to your node, Portworx determines what pool to add them to by comparing the drive properties with those of the pool. Ensure that the drives you add are as closely related to the pool in size, type, and performance as possible.

1. Identify a storage pool that's running low on capacity
<!-- What is some guidance we can provide here? -->
2. Add drives to your node similar in kind to the drives comprising the pool you need to expand
3. Add the drive by entering the `pxctl service drive add` command, specifying the following:

      * The `--drive` flag and the name of the drive you want to add
      * The `--operation start` flag

      ```text
      pxctl sv drive add --drive /dev/sde --operation start
      ```
      ```output
      Adding drives may make storage offline for the duration of the operation.
      Are you sure you want to proceed ? (Y/N): y
      Drive add done: Storage rebalance is in progress
      ```

      Once you've added the drive, Portworx begins restriping the pool to include the new drive.

4. Monitor the drive add operation status by entering the `pxctl service drive add` command, specifying the following:

      * The `--drive` flag and the name of the drive you added
      * The `--operation status` flag

      ```text
      pxctl service drive add --drive /dev/sde --operation status
      ```

      When the status shows as `Drive /dev/sde already in use by PX.`, storage will be brought online automatically when this operation completes.

### Expand a pool to consume all drive capacity

If you can create extra capacity on your drives, you can expand a pool to consume all of its available capacity.

1. Identify a storage pool that's in need of expansion
<!-- What is some guidance we can provide here? -->
2. Resize your drive and drive partition, if required
3. On the node containing your target drive, enter the `pxctl service pool update` command, specifying the `--resize` option and the ID of the pool you want to resize:

    ```text
    pxctl service pool update --resize 4
    ```
    ```output
    Pool properties updated
    ```
