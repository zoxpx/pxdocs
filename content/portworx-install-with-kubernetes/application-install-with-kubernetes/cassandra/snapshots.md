---
title: Snapshots
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
description: Cassandra snapshots
linkTitle: Snapshots
weight: 5
---

When you create a snapshot, Cassandra first flushes the application's memory. Then, it creates a hard-link to the `SSTable` files. This means that the snapshots are application-consistent, but the data stored on the underlying volume can be corrupted. Thus, if a failure occurs on the underlying volume, the data will be corrupted.

A Portworx snapshot is a distinct volume from the one Cassandra is using, meaning that you can run a second instance of Cassandra in parallel using that volume. You can also use a Portworx snapshots to go back to a point in time where the issue is not present.

<!--
I don't understand this:
However, PX snaps are crash consistent \(Cassandra’s memory is not flushed\)
-->

Portworx, Inc. recommends you use 3DSnaps for Cassandra as they are application-consistent

###  Related topics

Refer to the [Configuring 3DSnaps](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-3d) page for more details about how you can create 3DSnaps.
