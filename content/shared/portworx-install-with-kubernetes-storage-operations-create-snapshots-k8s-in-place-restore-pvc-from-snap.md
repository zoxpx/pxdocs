---
title: Shared content for Kubernetes snapshots - in-place restore PVC from snap
description: Shared content for Kubernetes snapshots - restore PVC from snap
keywords: snapshots, kubernetes, k8s
hidden: true
---

When you perform an in-place restore to a PVC, Stork takes the pods using that PVC offline, restores the volume from the snapshot, then brings the pods back online.

1. Create a `VolumeSnapshotRestore` YAML file specifying the following:

     * **apiVersion** as `stork.libopenstorage.org/v1alpha1`
     * **kind** as `VolumeSnapshotRestore`
     * **metadata.name** with the name of the object that performs the restore
     * **metadata.namespace** with the name of the target namespace
     * **spec.sourceName** with the name of the snapshot you want to restore
     * **spec.sourceNamespace** with the namespace in which the snapshot resides

     The following example restores data from a snapshot called `mysql-snapshot` which was created in the `mysql-snap-restore-splocal` namespace to a PVC called `mysql-snap-inrestore` in the `default` namespace:

     ```text
     apiVersion: stork.libopenstorage.org/v1alpha1
     kind: VolumeSnapshotRestore
     metadata:
       name: mysql-snap-inrestore
       namespace: default
     spec:
       sourceName: mysql-snapshot
       sourceNamespace: mysql-snap-restore-splocal
     ```

2. Place the spec into a file called `mysql-cloud-snapshot-restore.yaml` and apply it:

     ```text
     kubectl apply -f mysql-cloud-snapshot-restore.yaml
     ```

3. You can enter the following command to see the status of the restore process:

     ```text
     storkctl get volumesnapshotrestore
     ```

     ```output
     NAME                   SOURCE-SNAPSHOT   SOURCE-SNAPSHOT-NAMESPACE   STATUS          VOLUMES   CREATED
     mysql-snap-inrestore   mysql-snapshot    default                     Successful      1         23 Sep 19 21:55 EDT  
     ```

     You can also use the `kubectl describe` command to retrieve more detailed information about the status of the restore process.

      Example:

      ```text
      kubectl describe volumesnapshotrestore mysql-snap-inrestore
      ```

      ```output
      Name:         mysql-snap-inrestore
      Namespace:    default
      Labels:       <none>
      Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                      {"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"VolumeSnapshotRestore","metadata":{"annotations":{},"name":"mysql-snap-inrestore...
      API Version:  stork.libopenstorage.org/v1alpha1
      Kind:         VolumeSnapshotRestore
      Metadata:
        Creation Timestamp:  2019-09-23T17:24:30Z
        Generation:          5
        Resource Version:    904014
        Self Link:           /apis/stork.libopenstorage.org/v1alpha1/namespaces/default/volumesnapshotrestores/mysql-snap-inrestore
        UID:                 00474a5c-de27-11e9-986b-000c295d6364
      Spec:
        Group Snapshot:    false
        Source Name:       mysql-snapshot
        Source Namespace:  default
      Status:
        Status:  Successful
        Volumes:
          Namespace:  default
          Pvc:        mysql-data
          Reason:     Restore is successful
          Snapshot:   k8s-volume-snapshot-cb909cf9-de26-11e9-ad56-320ff611f4ca
          Status:     Successful
          Volume:     pvc-8b996a17-de26-11e9-986b-000c295d6364
      Events:
        Type    Reason      Age   From   Message
        ----    ------      ----  ----   -------
        Normal  Successful  0s    stork  Snapshot in-Place  Restore completed
      ```
