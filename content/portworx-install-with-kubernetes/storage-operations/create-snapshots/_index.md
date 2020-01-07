---
title: Create and use snapshots
weight: 2
hidesections: true
keywords: snapshots, on-demand, scheduled, 3DSnaps, consistent snapshots, kubernetes, k8s
description: Learn how to create application consistent snapshots/backups and restore them.
series: k8s-storage
---

Portworx provides two methods of taking snapshots of your volumes: On-demand and Scheduled. Check out below for more on which might serve you better.

{{<homelist series="k8s-storage-snapshots">}}

### 3DSnaps
{{<info>}}
3DSnaps are supported in Portworx version 1.4 and above and Stork version 1.2 and above. 3DSnaps are not supported on Kubernetes on DC/OS.
{{</info>}}

3DSnaps is the umbrella term that covers PX-Enterprise's capability to provide app-consistent cluster wide snapshots whether they are local or cloud.

For each of the snapshot types, Portworx supports specifying pre and post rules that are run on the application pods using the volumes. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. The commands will be run in pods which are using the PVC being snapshotted.

Read [Configuring 3DSnaps](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-3d) for further details on 3DSnaps.

### Related topics

* [Storage 101: Snapshots](/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/snapshots/#snapshots)
