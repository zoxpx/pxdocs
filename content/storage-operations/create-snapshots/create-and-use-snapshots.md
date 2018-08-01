---
title: Create and Use Snapshots
weight: 1
---

This page will show you how to create snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

> **Note:** The suggested way to manage snapshots on Kuberenetes is to use STORK. If you are looking to create Portworx snapshots using PVC annotations, you will find [instructions here](https://docs.portworx.com/scheduler/kubernetes/snaps-annotations.html).

### Snapshot types {#snapshot-types}

Using STORK, you can take 2 types of snapshots:

1. [Local](https://docs.portworx.com/scheduler/kubernetes/snaps-local.html): These are per volume snapshots where the snapshots are stored locally in the current Portworx cluster’s storage pools.
2. [Cloud](https://docs.portworx.com/scheduler/kubernetes/snaps-cloud.html): These snapshots are uploaded to the configured S3-compliant endpoint \(e.g AWS S3\).

3DSnaps is the umbrella term that covers PX-Enterprise’s capability to provide app-consistent cluster wide snapshots whether they are local or cloud. 3DSnaps support for local volumes will be in 1.4 release.

### Pre-snap and Post-snap commands {#pre-snap-and-post-snap-commands}

> **Note:** Pre-snap and Post-snap commands are supported in upcoming Portworx version 1.4 and above.

For each of the above types, Portworx supports specifying pre and post commands that are run on the application pods using the volumes.

This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. The commands will be run in pods which are using the PVC being snapshotted.

Specify following annotations in the `VolumeSnapshot` spec that you use to create the corresponding snapshot type.

* **portworx/pre-snap-command**: STORK will run the command which is given in the value of this annotation before taking the snapshot.
* **portworx/post-snap-command**: STORK will run the command which is given in the value of this annotation after taking the snapshot.
* **portworx/pre-snap-command-run-once**: If “true”, STORK will run the pre-snap command on just the first pod using the parent PVC. The default is “false” and the command will be run on all pods.
* **portworx/post-snap-command-run-once**: If “true”, STORK will run the post-snap command on just the first pod using the parent PVC. The default is “false” and the command will be run on all pods.

**Examples**

Follow is an example of a cassandra volume snapshot where we run the `nodetool flush` command before triggering the snapshot.

```text
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: cassandra-snapshot
  annotations:
    portworx/pre-snap-command: "nodetool flush"
spec:
  persistentVolumeClaimName: cassandra-data
```

