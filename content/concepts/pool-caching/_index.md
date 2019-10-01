---
title: Storage pool caching
keywords: storage pool, pool caching
description: Perform pool caching operations.
series: concepts
---

PX-cache improves storage pool performance by using a cache drive and attaching it to the storage pool. The additional cache drive can improve both the latency and IOPS of the pool to which it's attached. The cache drive must be either an SSD or NVMe drive, and the storage pool must be composed of magnetic drives.

![Diagram showing a cache drive attached to a pool of magnetic drives](/img/poolCache.png)

<!--
hiding this given the new scope of doc for this feature:

Storage pool caching can help you achieve the following goals:

* Reduce costs by improving the performance of pools of lower-cost magnetic drives.
* Increase the capacity of pools while maintaining acceptable performance.
-->

Consider your workload characteristics and your host resources. Are your reads and writes random or sequential? Do you have enough pool bandwidth or ram? To determine if pool caching is right for you, consider the following properties:

* Caching is intended to absorb IO bursts by offloading the storage pool
* Workloads requiring sustained IO bandwidth may see a performance degradation if the cache is always full

{{<info>}}
**IMPORTANT:** You must enable pool caching at installation, and migration is **not** currently supported.
{{</info>}}

Once configured, storage pools with cache drives behave just like any other storage pool. Storage pools retain the same performance category regardless of whether or not they're cached.

Once you enable pool caching on a cluster, you can do the following from the CLI:

* Enable and disable caching on pools
* Add caching drives
* Configure caching settings to fine-tune cache performance with the `pxctl` command

## Prerequisites

Before you can enable pool caching, you must meet the following prerequisites:

* An NVMe or SSD drive must be attached to the same node as your storage pool
* Linux kernel 4.20.13
* The following packages must be installed on your node:
  * `thin-provisioning-tools`
  * `device mapper`
  * `lvm2`
  * `mdadm`

## Install Portworx with caching enabled

To use caching on Portworx, you must enable it when you first install Portworx on your cluster by running `px-runc` with the `-cache` option, specifying the storage device you want to use for caching. Do not provide the same storage device as both a cache and a data storage device.

<!-- Hiding currently unsupported options:

following parameters:

- `-T lmv` to specify `lvm` as the backend storage type.
- (optional) `-cache` with the storage device you want to use for caching. Do not provide the same storage device as both a cache and a data storage device.
- (optional) `-dedicated_cache` to constrain Portworx to use only the drives specified with the `cache` parameter for caching. The default value is `false`.

There are two ways in which you can specify the storage drives you want to use for caching:
-->

Pass the drives as parameters to the `px-runc` installer. The following example sets `/dev/sdc` as the caching drive and restrains Portworx to use only this drive for caching:

```text
 px-runc install -name portworx -c doc-cluster-caching -k etcd:http://127.0.0.1:4001 -s /dev/sdf -cache /dev/sdc -v /mnt:/mnt:shared
```

{{<info>}}
**NOTE:**

* Your cache drive must be either SSD or NVMe, and the storage pool must be composed of magnetic drives.
* If you run `px-runc` with the `-A` argument, Portworx forms storage pools on all of the unmounted drives or partitions except for the drives specified using the `-cache` argument; these drives become cache drives instead.
{{</info>}}

<!-- Hiding currently unsupported method:

2. Run the installer with the `-T lmv` and, at a later point, specify the drives you want to use for caching by running the `pxctl sv drive add` . Refer to the [Add caching drive](/concepts/pool-caching/add-caching-drive) page for more details.

Support may be added and documented later -->

## Related topics

* [Storage Pools](/concepts/storage-pools/)
