---
title: Snapshots and Backups
weight: 5
keywords: portworx, kubernetes, PVCs
description: Learn essential concepts about snaphots and backups of volumes on Kubernetes
series: k8s-101
---

## Snapshots

Snapshots can be used to capture the state of a PVC at a given point of time. Following objects are important when working with snapshots:

### VolumeSnapshot

A VolumeSnapshot defines a users request to snapshot a PVC. Let's take an example:

```text
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snapshot
  namespace: default
spec:
  persistentVolumeClaimName: mysql-data
```

In above spec,

* **persistentVolumeClaimName: mysql-data** indicates that user wants to snapshot the *mysql-data* PVC.

### GroupVolumeSnapshot

A GroupVolumeSnapshot defines a users request to snapshot a group of PVCs. Portworx will quiesce IO on all volumes in the group and then trigger the snapshot.

Let's take an example:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: mysql-group-snap
spec:
  pvcSelector:
    matchLabels:
      app: mysql
```

In above spec,

* **pvcSelector** specifies a label selector which will match all PVCs that have the label *app=mysql*.

The [Create snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/) page has details on taking snapshots of Portworx volumes.

## Migration

Portworx uses [STORK](https://github.com/libopenstorage/stork) to migrate application workloads and their volumes across Kubernetes clusters.

Common use cases for this would be:

* Augment capacity: Free capacity on critical clusters by evacuating lower priority applications to secondary clusters.
* Blue-green test: Validate new versions of Kubernetes and/or Portworx using both application and its data. This is the same blue-green approach used by cloud-native application teams– now available for your infrastructure.
* Dev/test: Promote workloads from dev to staging clusters in an automated manner. Thereby, eliminate the manual steps for data preparation that hurt fidelity of tests.
* Lift/Shift: Move applications and data from an on-prem cluster to a hosted AWS EKS or Google GKE. The reverse is also supported to repatriate, move applications on-prem.
* Maintenance: Decommission a cluster in order to perform hardware-level upgrades.

The [Migration](/concepts/migration) page detailed documentation on this.