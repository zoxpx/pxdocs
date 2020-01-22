---
title: Create and use cloud snapshots
weight: 2
linkTitle: Cloud snapshots
keywords: cloud snapshots, cloud snaps, stork, kubernetes, k8s
description: Learn to take a cloud snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!
---

This document will show you how to create cloud snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

## Prerequisites

* This requires that you already have [Stork](/portworx-install-with-kubernetes/storage-operations/stork) installed and running on your
Kubernetes cluster. If you fetched the Portworx specs from the Portworx spec generator in [PX-Central](https://central.portworx.com) and used the default options, Stork is already installed.
* Cloud snapshots using below method is supported in Portworx version 1.4 and above.
* Cloud snapshots (for aggregated volumes) using below method is supported in Portworx version 2.0 and above.

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-cloud-snap-creds-prereq.md" %}}

## Create cloud snapshots

With cloud snapshots, you can either snapshot individual PVCs one by one or snapshot a group of PVCs.

{{<homelist series="k8s-cloud-snap">}}

## Restore cloud snapshots

Once you've created a cloud snapshot, you can restore it to a new PVC or the original PVC.

### Restore a cloud snapshot to a new PVC

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-restore-pvc-from-snap.md" %}}

### Restore a cloud snapshot to the original PVC

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-in-place-restore-pvc-from-snap.md" %}}


## References

* To create PVCs from existing snapshots, read [Creating PVCs from cloud snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-cloud#creating-pvcs-from-cloud-snapshots).
* To create PVCs from group snapshots, read [Creating PVCs from group snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-group#restoring-from-group-snapshots).
