---
title: Create and use cloud snapshots
weight: 2
linkTitle: "Cloud snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones, cloud, cloudsnap
description: Learn to take a cloud snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!
---

This document will show you how to create cloud snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

## Pre-requisites

### Installing STORK

This requires that you already have [STORK] (/portworx-install-with-kubernetes/storage-operations/stork) installed and running on your
Kubernetes cluster. If you fetched the Portworx specs from [https://install.portworx.com](https://install.portworx.com) and used the default options, STORK is already installed.

### PX Version

Cloud snapshots using below method is supported in Portworx version 1.4 and above.
Cloud snapshots (for aggregated volumes) using below method is supported in Portworx version 2.0 and above.

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-cloud-snap-creds-prereq.md" %}}

## Creating cloud snapshots

With cloud snapshots, you can either snapshot individual PVCs one by one or snapshot a group of PVCs.

{{<homelist series="k8s-cloud-snap">}}

## Creating PVCs from  cloud snapshots

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-restore-pvc-from-snap.md" %}}

## References

* To create PVCs from existing snapshots, read [Creating PVCs from cloud snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-cloud#creating-pvcs-from-cloud-snapshots).
* To create PVCs from group snapshots, read [Creating PVCs from group snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-group#restoring-from-group-snapshots).