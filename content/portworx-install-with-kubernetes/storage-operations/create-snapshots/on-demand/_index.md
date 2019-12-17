---
title: On-demand snapshots
weight: 2
hidesections: true
linkTitle: On-demand snapshots
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
description: Learn how to create on-demand consistent snapshots/backups and restore them.
series: k8s-storage-snapshots
---

This document will show you how to create snapshots of Portworx volumes and how you can clone those snapshots to PVCs and use them with your applications.

{{<info>}}
The suggested way to manage snapshots on Kuberenetes is to use Stork. If you are looking to create Portworx snapshots using PVC annotations, you will find [instructions here](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-annotations).
{{</info>}}

## Snapshot types

Using Stork, you can take 2 types of snapshots:

1. [Local](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-local): These are per volume snapshots where the snapshots are stored locally in the current Portworx cluster's storage pools.
2. [Cloud](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-cloud): These snapshots are uploaded to the configured S3-compliant endpoint (e.g AWS S3).
