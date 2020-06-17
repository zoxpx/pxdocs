---
title: Performance Tuning
keywords: performance tuning, container level optimization, volume level optimization, px-enterprise,
description: Create, manage and inspect storage volumes with pxctl CLI. Discover how to use Docker together with Portworx!
weight: 1
---

Portworx has best practices for both global container level optimization, as well as volume granular optimization.

## Global performance tuning

As of Portworx version 1.3, it is recommended to use a journal device to absorb Portworx metadata writes. Journal writes are small with frequent syncs and therefore only SSD/NVME should be configured as a journal device.

In 1.x, the journal device should be 2GB, and in 2.x it should be 3GB. Using a larger device will not help, since Portworx  will only use these amounts of storage. The journal device can be specified via the `-j` option during installation, documented [here](/install-with-other/docker/standalone).

{{<info>}}
You **must** ensure that the journal device is faster than your storage device allocated for Portworx. If the journal device is slower than the actual storage drive, your overall performance will be lower and match the lower of two devices.
{{</info>}}

{{<info>}}
Cloud providers match the drive's performance based on it's size.  So if you select a small sized journal device, your performance will be worse.  For a cloud drive, provide a partition from the larger storage drive as your journal device.
{{</info>}}

{{<info>}}
As of Portworx 1.4, we recommend using the `-j auto` option.  This allows Portworx to create its own journal partition on the best drive.
{{</info>}}

If you are upgrading to 1.3 and want to add a journal device to an existing node, follow [these instructions](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/add-journal-dev).

## Volume granular performance tuning

Portworx optimizes performance for specific application access patterns. These can be set by specifying an `io_profile` while creating the volume. For example:

```text
pxctl volume create --size=10 --repl=3 --io_profile=sequential demovolume
```

or

```text
docker volume create -d pxd io_priority=high,size=10G,repl=3,io_profile=random,name=demovolume
```

### The sequential profile

This optimizes the read ahead algorithm for sequential access.  Use `io_profile=sequential`.

### The random profile

This records the IO pattern of recent access and optimizes the read ahead and data layout algorithms for short term random patterns.  Use `io_profile=random`.

### CMS
This is useful for content management systems, like WordPress.  This option applies to a Portworx shared (global namespace) volume.  It implements an attribute cache and supports async writes.  This increases the Portworx memory footprint by 100MB.  Use `io_profile=cms`.

### The db_remote profile

This implements a write-back flush coalescing algorithm.  This algorithm attempts to coalesce multiple `syncs` that occur within a 50ms window into a single sync. Coalesced syncs are acknowledged only after copying to all replicas. In order to do this, the algorithm requires a minimum replication (HA factor) of 3. This mode assumes all replicas do not fail (kernel panic or power loss) simultaneously in a 50 ms window. Use `io_profile=db_remote`.

{{<info>}}
If there are not enough nodes online, Portworx will automatically disable this algorithm.
{{</info>}}

### The sync_shared profile

Use this profile to set up the mount settings of your `sharedV4` volumes. This profile sets the following options:

* `sync`
    
    This option synchronizes all the write operations with your backend storage. If you specify this option, the server and the clients will be able to access modified data immediately.

* `noac` 
    
    This option disables the caching for the file system and metadata (file and directory attributes) on the client-side.

