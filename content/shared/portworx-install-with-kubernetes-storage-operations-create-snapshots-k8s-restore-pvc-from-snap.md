---
title: Shared content for Kubernetes snapshots - restore PVC from snap
description: Shared content for Kubernetes snapshots - restore PVC from snap
keywords: snapshots, kubernetes, k8s
hidden: true
---

When you install Stork, it also creates a storage class called _stork-snapshot-sc_. This storage class can be used to create PVCs from snapshots.

To create a PVC from a snapshot, you would add the `snapshot.alpha.kubernetes.io/snapshot` annotation to refer to the snapshot name. If the snapshot exists in another namespace, the snapshot namespace should be specified with the `stork.libopenstorage.org/snapshot-source-namespace` annotation in the PVC.

Note that the storageClassName needs to be the Stork StorageClass `stork-snapshot-sc` as in the example below.

The following spec restores a PVC from the snapshot in the example above:

```text
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-snap-clone
  annotations:
    snapshot.alpha.kubernetes.io/snapshot: mysql-snapshot
spec:
  accessModes:
     - ReadWriteOnce
  storageClassName: stork-snapshot-sc
  resources:
    requests:
      storage: 2Gi
```

Once you apply the above spec, you will see a PVC created by Stork. This PVC will be backed by a Portworx volume clone of the snapshot created above.

```text
kubectl get pvc
```

```output
NAMESPACE   NAME                                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                AGE
default     mysql-data                             Bound     pvc-f782bf5c-20e7-11e8-931d-0214683e8447   2Gi        RWO            px-mysql-sc                 2d
default     mysql-snap-clone                       Bound     pvc-05d3ce48-2280-11e8-98cc-0214683e8447   2Gi        RWO            stork-snapshot-sc           2s
```
