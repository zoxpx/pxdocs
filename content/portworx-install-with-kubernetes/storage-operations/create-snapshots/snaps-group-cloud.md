---
title: Cloud backups for group of PVCs
hidden: true
keywords: portworx, container, Kubernetes, storage, k8s, pv, persistent disk, snapshots, stork, clones, cloud
description: Instructions for backing up a group of PVCs with consistency to cloud and restore PVCs from the backups
series: k8s-cloud-snap
---

This document will show you how to create group cloud snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

## Pre-requisites

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-group-snap-v2-prereqs.md" %}}

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-cloud-snap-creds-prereq.md" %}}

### Portworx and Stork Version

Group cloud snapshots using Stork are supported in Portworx and Stork 2.0.2 and above. If you are running a lower version, refer to [Upgrade on Kubernetes
](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/upgrade) to upgrade Portworx to 2.0.2 or above.

## Creating group cloud snapshots

To take group snapshots, you need use the GroupVolumeSnapshot CRD object and pass in _portworx/snapshot-type_ as _cloud_. Here is a simple example:

```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: cassandra-group-cloudsnapshot
spec:
  pvcSelector:
    matchLabels:
      app: cassandra
  options:
    portworx/snapshot-type: cloud
```

Above spec will take a group snapshot of all PVCs that match labels `app=cassandra`.

The [Examples](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-group-cloud#examples) section has a more detailed end-to-end example.

{{<info>}}Above spec backs up the snapshots to a cloud S3 endpoint. If you intend on taking snapshots just local tot he cluster, refer to [Create local group snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-group).{{</info>}}

The `GroupVolumeSnapshot` object also supports specifying pre and post rules that are run on the application pods using the volumes being snapshotted. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. Refer to [3D Snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-3d) for more detailed documentation on that.

### Checking status of group cloud snapshots

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
      Last Transition Time:  2019-01-14T20:30:49Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       a7843d0c-da4b-4f8c-974f-4b6f09463a98/763613271174793816-922960401583326548
        Snapshot Type:     cloud
    Parent Volume ID:      763613271174793816
    Task ID:               d0b4b798-319b-4c2e-a01c-66490f4172c7
    Volume Snapshot Name:  cassandra-group-cloudsnapshot-cassandra-data-cassandra-2-31d9e5df-183b-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T20:30:49Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       a7843d0c-da4b-4f8c-974f-4b6f09463a98/1081147806034223862-518034075073409747
        Snapshot Type:     cloud
    Parent Volume ID:      1081147806034223862
    Task ID:               44da0d6d-b33f-48da-82f6-b62951dcca0e
    Volume Snapshot Name:  cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T20:30:49Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       a7843d0c-da4b-4f8c-974f-4b6f09463a98/237262101530372284-299546281563771622
        Snapshot Type:     cloud
    Parent Volume ID:      237262101530372284
    Task ID:               915d08e1-c2fd-45a5-940f-ee3b13f7c03f
    Volume Snapshot Name:  cassandra-group-cloudsnapshot-cassandra-data-cassandra-1-31d9e5df-183b-11e9-a9a4-080027ee1df7
  ```

  * You can see 3 volume snapshots which are part of the group snapshot. The name of the volume snapshot is in the _Volume Snapshot Name_ field. For more details on the `volumesnapshot`, you can do:

    ```
    kubectl get volumesnapshot <volume-snapshot-name> -o yaml
    ```

### Snapshots across namespaces

When creating a group snapshot, you can specify a list of namespaces to which the group snapshot can be restored. Below is an example of a group cloud snapshot which can be restored into prod-01 and prod-02 namespaces.

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: cassandra-groupsnapshot
spec:
  pvcSelector:
    matchLabels:
      app: cassandra
  options:
    portworx/snapshot-type: cloud
  restoreNamespaces:
   - prod-01
   - prod-02
```

## Restoring from group cloud snapshots

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-group-snap-restore.md" %}}

## Examples

### Group cloud snapshot for all cassandra PVCs

In below example, we will take a group snapshot for all PVCs in the *default* namespace and that have labels *app: cassandra* and back it up to the configured cloud S3 endpoint in the Portworx cluster.

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-group-snap-cassandra-step-1-2.md" %}}

#### Step 3: Take the group cloud snapshot

Apply the following spec to take the cassandra group snapshot. Portworx will quiesce I/O on all volumes before triggering their snapshots.

```yaml
apiVersion: stork.libopenstorage.org/v1alpha1
kind: GroupVolumeSnapshot
metadata:
  name: cassandra-group-cloudsnapshot
spec:
  pvcSelector:
    matchLabels:
      app: cassandra
  options:
    portworx/snapshot-type: cloud
```

Once you apply the above object you can check the status of the snapshots using `kubectl`:

```bash
kubectl describe groupvolumesnapshot cassandra-group-cloudsnapshot
```

While the group snapshot is in progress, the status will reflect as _InProgress_. Once complete, you should see a status stage as _Final_ and status as _Successful_.

```
Name:         cassandra-group-cloudsnapshot
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"GroupVolumeSnapshot","metadata":{"annotations":{},"name":"cassandra-group-cloudsnapshot","nam...
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         GroupVolumeSnapshot
Metadata:
  Cluster Name:
  Creation Timestamp:  2019-01-14T20:30:13Z
  Generation:          0
  Resource Version:    18212101
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/namespaces/default/groupvolumesnapshots/cassandra-group-cloudsnapshot
  UID:                 31d9e5df-183b-11e9-a9a4-080027ee1df7
Spec:
  Options:
    Portworx / Snapshot - Type:  cloud
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
      Last Transition Time:  2019-01-14T20:30:49Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       a7843d0c-da4b-4f8c-974f-4b6f09463a98/763613271174793816-922960401583326548
        Snapshot Type:     cloud
    Parent Volume ID:      763613271174793816
    Task ID:               d0b4b798-319b-4c2e-a01c-66490f4172c7
    Volume Snapshot Name:  cassandra-group-cloudsnapshot-cassandra-data-cassandra-2-31d9e5df-183b-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T20:30:49Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       a7843d0c-da4b-4f8c-974f-4b6f09463a98/1081147806034223862-518034075073409747
        Snapshot Type:     cloud
    Parent Volume ID:      1081147806034223862
    Task ID:               44da0d6d-b33f-48da-82f6-b62951dcca0e
    Volume Snapshot Name:  cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
    Conditions:
      Last Transition Time:  2019-01-14T20:30:49Z
      Message:               Snapshot created successfully and it is ready
      Reason:
      Status:                True
      Type:                  Ready
    Data Source:
      Portworx Volume:
        Snapshot Id:       a7843d0c-da4b-4f8c-974f-4b6f09463a98/237262101530372284-299546281563771622
        Snapshot Type:     cloud
    Parent Volume ID:      237262101530372284
    Task ID:               915d08e1-c2fd-45a5-940f-ee3b13f7c03f
    Volume Snapshot Name:  cassandra-group-cloudsnapshot-cassandra-data-cassandra-1-31d9e5df-183b-11e9-a9a4-080027ee1df7
Events:                    <none>
```

Above we can see that creation of _cassandra-group-snapshot_ created 3 volumesnapshots:

1. cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
2. cassandra-group-cloudsnapshot-cassandra-data-cassandra-1-31d9e5df-183b-11e9-a9a4-080027ee1df7
3. cassandra-group-cloudsnapshot-cassandra-data-cassandra-2-31d9e5df-183b-11e9-a9a4-080027ee1df7

These correspond to the PVCs _cassandra-data-cassandra-0_, _cassandra-data-cassandra-1_ and _cassandra-data-cassandra-2_ respectively.

You can also describe these individual volume snapshots using

```text
kubectl describe volumesnapshot cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
```

```
Name:         cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  volumesnapshot.external-storage.k8s.io/v1
Kind:         VolumeSnapshot
Metadata:
  Cluster Name:
  Creation Timestamp:  2019-01-14T20:30:49Z
  Owner References:
    API Version:     stork.libopenstorage.org/v1alpha1
    Kind:            GroupVolumeSnapshot
    Name:            cassandra-group-cloudsnapshot
    UID:             31d9e5df-183b-11e9-a9a4-080027ee1df7
  Resource Version:  18212097
  Self Link:         /apis/volumesnapshot.external-storage.k8s.io/v1/namespaces/default/volumesnapshots/cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
  UID:               47949666-183b-11e9-a9a4-080027ee1df7
Spec:
  Persistent Volume Claim Name:  cassandra-data-cassandra-0
  Snapshot Data Name:            cassandra-group-cloudsnapshot-cassandra-data-cassandra-0-31d9e5df-183b-11e9-a9a4-080027ee1df7
Status:
  Conditions:
    Last Transition Time:  2019-01-14T20:30:49Z
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
kubectl delete groupvolumesnapshot cassandra-group-cloudsnapshot
```