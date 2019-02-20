---
title: Snapshot group of PVCs
hidden: true
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
description: Instructions on taking snapshots of a group of PVCs and restoring PVCs from the snapshots
series: k8s-local-snap
weight: 9
---

This document will show you how to create group snapshots of Portworx volumes and how you can restore those snapshots to use them in pods.

## Pre-requisites

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-group-snap-v2-prereqs.md" %}}

### Portworx and Stork Version

This page describes the steps for group snapshots for Portworx version 2.0.2 or above. The Stork version also needs to be above 2.0.2.

If you have a lower Stork and Portworx version, refer to legacy method [Create group snapshots using VolumeSnapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-group-legacy).

### Kubernetes Version

Group snapshots are supported in following Kubernetes versions:

* 1.10 and above
* 1.9.4 and above
* 1.8.9 and above

## Creating group snapshots

To take group snapshots, you need use the GroupVolumeSnapshot CRD object. Here is a simple example:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: cassandra-groupsnapshot
spec:
  pvcSelector:
    matchLabels:
      app: cassandra
```

Above spec will take a group snapshot of all PVCs that match labels `app=cassandra`.

The [Examples](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-group#examples) section has a more detailed end-to-end example.

{{<info>}}Above spec will keep all the snapshots local to the Portworx cluster. If you intend on backing up the group snapshots to cloud (S3 endpoint), refer to [Create group cloud snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-group-cloud).{{</info>}}

The `GroupVolumeSnapshot` object also supports specifying pre and post rules that are run on the application pods using the volumes being snapshotted. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. Refer to [3D Snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-3d) for more detailed documentation on that.

### Checking status of group snapshots

A new VolumeSnapshot object will get created for each PVC that matches the given `pvcSelector`. For example, if the label selector `app: cassandra` matches 3 PVCs, you will have 3 volumesnapshot objects.

You can track the status of the group volume snapshots using:

```bash
kubectl describe groupvolumesnapshot <group-snapshot-name>
```

This will show the latest status and will also list the VolumeSnapshot objects once it's complete. Below is an example of the status section of the cassandra group snapshot.

```
Status:
  Stage:   Final
  Status:  Successful
  Volume Snapshots:
    Conditions:
      Last Transition Time:  2019-01-14T18:02:47Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       1015874155818710382
    Parent Volume ID:      763613271174793816
    Task ID:
    Volume Snapshot Name:  cassandra-group-snapshot-cassandra-data-cassandra-2-86ce35eb-1826-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T18:02:47Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       1130064992705573378
    Parent Volume ID:      1081147806034223862
    Task ID:
    Volume Snapshot Name:  cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T18:02:47Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       175241555565145805
    Parent Volume ID:      237262101530372284
    Task ID:
    Volume Snapshot Name:  cassandra-group-snapshot-cassandra-data-cassandra-1-86ce35eb-1826-11e9-a9a4-080027ee1df7
  ```

You can see 3 VolumeSnapshots which are part of the group snapshot. The name of the VolumeSnapshot is in the _Volume Snapshot Name_ field. For more details on the VolumeSnapshot, you can do:

```text
kubectl get volumesnapshot <volume-snapshot-name> -o yaml
```

### Snapshots across namespaces

When creating a group snapshot, you can specify a list of namespaces to which the group snapshot can be restored. Below is an example of a group snapshot which can be restored into prod-01 and prod-02 namespaces.

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: cassandra-groupsnapshot
spec:
  pvcSelector:
    matchLabels:
      app: cassandra
  restoreNamespaces:
   - prod-01
   - prod-02
```

## Restoring from group snapshots

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-group-snap-restore.md" %}}

## Examples

### Group snapshot for all cassandra PVCs

In below example, we will take a group snapshot for all PVCs in the *default* namespace and that have labels *app: cassandra*.

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-group-snap-cassandra-step-1-2.md" %}}

#### Step 3: Take the group snapshot

Apply the following spec to take the cassandra group snapshot. Portworx will quiesce I/O on all volumes before triggering their snapshots.

```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: cassandra-group-snapshot
spec:
  pvcSelector:
    matchLabels:
      app: cassandra
```

Once you apply the above object you can check the status of the snapshots using `kubectl`:

```bash
kubectl describe groupvolumesnapshot cassandra-group-snapshot
```

While the group snapshot is in progress, the status will reflect as _InProgress_. Once complete, you should see a status stage as _Final_ and status as _Successful_.

```
Name:         cassandra-group-snapshot
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"GroupVolumeSnapshot","metadata":{"annotations":{},"name":"cassandra-group-snapshot"
,"namespac...
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         GroupVolumeSnapshot
Metadata:
  Cluster Name:
  Creation Timestamp:  2019-01-14T18:02:16Z
  Generation:          0
  Resource Version:    18184467
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/namespaces/default/groupvolumesnapshots/cassandra-group-snapshot
  UID:                 86ce35eb-1826-11e9-a9a4-080027ee1df7
Spec:
  Options:             <nil>
  Post Snapshot Rule:
  Pre Snapshot Rule:
  Pvc Selector:
    Match Labels:
      App:  cassandra
Status:
  Stage:   Final
  Status:  Successful
  Volume Snapshots:
    Conditions:
      Last Transition Time:  2019-01-14T18:02:47Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       1015874155818710382
    Parent Volume ID:      763613271174793816
    Task ID:
    Volume Snapshot Name:  cassandra-group-snapshot-cassandra-data-cassandra-2-86ce35eb-1826-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T18:02:47Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       1130064992705573378
    Parent Volume ID:      1081147806034223862
    Task ID:
    Volume Snapshot Name:  cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T18:02:47Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       175241555565145805
    Parent Volume ID:      237262101530372284
    Task ID:
    Volume Snapshot Name:  cassandra-group-snapshot-cassandra-data-cassandra-1-86ce35eb-1826-11e9-a9a4-080027ee1df7                  16s
```

Above we can see that creation of _cassandra-group-snapshot_ created 3 volumesnapshots:

1. cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
2. cassandra-group-snapshot-cassandra-data-cassandra-1-86ce35eb-1826-11e9-a9a4-080027ee1df7
3. cassandra-group-snapshot-cassandra-data-cassandra-2-86ce35eb-1826-11e9-a9a4-080027ee1df7

These correspond to the PVCs _cassandra-data-cassandra-0_, _cassandra-data-cassandra-1_ and _cassandra-data-cassandra-2_ respectively.

You can also describe these individual volume snapshots using

```bash
 kubectl describe volumesnapshot cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
```
 
```
Name:         cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshot
Metadata:
  Cluster Name:
  Creation Timestamp:  2019-01-14T18:02:47Z
  Owner References:
    API Version:     stork.libopenstorage.org/v1alpha1
    Kind:            GroupVolumeSnapshot
    Name:            cassandra-group-snapshot
    UID:             86ce35eb-1826-11e9-a9a4-080027ee1df7
  Resource Version:  18184459
  Self Link:         /apis/volumesnapshot.external-storage.k8s.io/v1/namespaces/default/volumesnapshots/cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
  UID:               99748065-1826-11e9-a9a4-080027ee1df7
Spec:
  Persistent Volume Claim Name:  cassandra-data-cassandra-0
  Snapshot Data Name:            cassandra-group-snapshot-cassandra-data-cassandra-0-86ce35eb-1826-11e9-a9a4-080027ee1df7
Status:
  Conditions:
    Last Transition Time:  2019-01-14T18:02:47Z
    Message:               Snapshot created successfully and it is ready
    Reason:
    Status:                True
    Type:                  Ready
  Creation Timestamp:      <nil>
Events:                    <none>
```

## Deleting group snapshots

To delete group snapshots, you need to delete the `GroupVolumeSnapshot` that was used to create the group snapshots. STORK will delete all other volumesnapshots that were created for this group snapshot.

```text
kubectl delete groupvolumesnapshot cassandra-group-snapshot
```