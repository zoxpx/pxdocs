---
title: Create and use local snapshots
weight: 1
linkTitle: "Local snapshots"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
description: Learn to take a snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod.
---

This document will show you how to create snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

{{<info>}}
The suggested way to manage snapshots on Kuberenetes is to use STORK. If you are looking to create Portworx snapshots using PVC annotations, you will find [instructions here](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-annotations).
{{</info>}}

## Pre-requisites

**Installing STORK**

This requires that you already have [STORK](/portworx-install-with-kubernetes/storage-operations/stork) installed and running on your
Kubernetes cluster. If you fetched the Portworx specs from [https://install.portworx.com](https://install.portworx.com) and used the default options, STORK is already installed.

## Creating snapshots

With local snapshots, you can either snapshot individual PVCs one by one or snapshot a group of PVCs by using a label selector.

{{<homelist series="k8s-local-snap">}}

<a name="pvc-from-snap"></a>
## Creating PVCs from snapshots

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-restore-pvc-from-snap.md" %}}