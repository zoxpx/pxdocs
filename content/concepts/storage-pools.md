---
title: Storage pools
description: Understand what Portworx storage pools are.
keywords: portworx, storage pool,
weight: 700
series: concepts
---

A storage pool is a logical grouping of a node's physical drives. Portworx uses the space in a storage pool to dynamically create virtual volumes on containers.

![Diagram showing a storage pool](/img/storagePool.png)

## Storage pool composition

Storage pools are composed of a collection of drives of the same capacity and type. When you create a pool, Portworx categorizes it according to its latency and performance in random and sequential IOPS. These performance categories are the following:

* Low
* Medium
* High

## Interacting with storage pools

You can form and manage storage pools using the `pxctl` command-line utility. You can also assign them labels, which allow you to specify them in provisioning rules you write. A storage pool's performance category is one such label.

You can form a maximum of 32 storage pools on a single node. You may also have nodes with no storage at all in your cluster; nodes with no storage are **storageless**.

You can monitor your storage pools using Prometheus or the `pxctl` command-line utility. Refer to the [Portworx integration with Prometheus](/install-with-other/operate-and-maintain/monitoring/prometheus) for details on how to monitor your Portworx cluster with Prometheus. The [Alerts using pxctl](/reference/cli/alerts) page provides details about monitoring the status of your cluster with the `pxctl` command-line utility.

## Related topics

* [Storage pool caching](/concepts/pool-caching)
