---
title: Using Velero with Portworx
keywords: velero, disaster recovery, snapshots, persisten volumes, kubernetes, k8s, heptio ark,
description: Learn how the Portworx plugin for Velero can help with disaster recovery in your Kubernetes clusters
weight: 7
noicon: true
series: k8s-storage
aliases:
  - portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/disaster-recovery
---

Velero is a utility for managing disaster recovery, specifically for your
Kubernetes cluster resources and persistent volumes. To take snapshots of
Portworx volumes through Velero you need to install and configure the Portworx
plugin.

{{<info>}}These instructions are for Velero v1.0 and higher. For older versions of Ark (previous name for the Velero project), please [click here.](ark-pre-1.0) {{</info>}}

## Install Velero Plugin

Run the following command to install the Portworx plugin for Velero:
```text
velero plugin add portworx/velero-plugin:1.0.0
```

This should add an init container to your Velero deployment to install the
plugin.

## Configure Velero to use Portworx snapshots

Once the plugin is installed, you need to create VolumeSnapshotLocation objects for Velero to use when
taking volume snapshots. These specify whether you want to take local or cloud snapshots.

```text
velero snapshot-location create portworx-local --provider portworx.io/portworx

# credId is optional, required only if Portworx is configured with more than one credential.
velero snapshot-location create portworx-cloud --provider portworx.io/portworx --config type=cloud,credId=<UUID>
```

After applying the above specs you should see them when you list the VolumeSnapshotLocaions
```text
kubectl get volumesnapshotlocation -n velero
```

```output
NAME             AGE
portworx-cloud   54m
portworx-local   54m
```

## Creating backups

Once the plugin has been installed and configured, everytime you take backups
using Velero and include PVCs, it will also take Portworx snapshots of your volumes.

### Local Backups

To backup all your apps in the default namespace and also create local snapshots
of the volumes, you would use `portworx-local` for the snapshot location:

```text
velero backup create default-ns-local-backup --include-namespaces=default --snapshot-volumes \
     --volume-snapshot-locations portworx-local
```

```output
Backup request "default-ns-local-backup" submitted successfully.
Run `velero backup describe default-ns-local-backup` for more details.
```

### Cloud Backups

To backup all your apps in the default namespace and also create cloud backups
of the volumes, you would use `portworx-cloud` for the snapshot location:

```text
velero backup create default-ns-cloud-backup --include-namespaces=default --snapshot-volumes \
     --volume-snapshot-locations portworx-cloud
```

```output
Backup request "default-ns-cloud-backup" submitted successfully.
Run `velero backup describe default-ns-cloud-backup` for more details.
```

## Listing backups

Once the specs and volumes have been backed up you should see the backup marked
as `Completed` in velero.

```text
velero get backup
```

```output
NAME                      STATUS      CREATED                         EXPIRES   STORAGE LOCATION    SELECTOR
default-ns-local-backup   Completed   2018-11-11 20:10:45 +0000 UTC   29d       default             <none>
default-ns-cloud-backup   Completed   2018-11-11 20:15:45 +0000 UTC   29d       default             <none>
```

## Restoring from backups

When restoring from backups, a clone volume will be created from the snapshot and
bound to the restored PVC. To restore from the backup created above you can run
the following command:

```text
velero restore create --from-backup default-ns-local-backup
```

```output
Restore request "default-ns-local-backup-20181111201245" submitted successfully.
Run `velero restore describe default-ns-local-backup-20181111201245` for more details.
```
