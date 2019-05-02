---
title: "Using Ark with Portworx"
keywords: portworx, container, Kubernetes, storage, k8s, pv, persistent disk, snapshot
description: Learn how the Portworx plugin for Heptio Ark can help with disaster recovery in your Kubernetes clusters
weight: 7
noicon: true
series: k8s-storage
aliases:
  - portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/disaster-recovery
---

Heptio Ark is a utility for managing disaster recovery, specifically for your
Kubernetes cluster resources and persistent volumes. To take snapshots of
Portworx volumes through Ark you need to install and configure the Portworx
plugin.

{{<info>}}*Note*:These instructions are for ark v0.10 and higher. For older versions, please [click here.](ark-pre-0.10) {{</info>}}

## Install Ark Plugin
Run the following command to install the Portworx plugin for Ark:
```text
ark plugin add portworx/ark-plugin:0.5
```
{{<info>}}*Note*: For PX-Enterprise pre v2.0, use `portworx/ark-plugin:0.4` {{</info>}}

This should add an init container to your Ark deployment to install the
plugin.

## Configure Ark to use Portworx snapshots

Once the plugin is installed, you need to create VolumeSnapshotLocation objects for ark to use when
taking volume snapshots. These specify whether you want to take local or cloud snapshots.

```text
apiVersion: ark.heptio.com/v1
kind: VolumeSnapshotLocation
metadata:
  name: portworx-local
  namespace: heptio-ark
spec:
  provider: portworx
  config:
---
apiVersion: ark.heptio.com/v1
kind: VolumeSnapshotLocation
metadata:
  name: portworx-cloud
  namespace: heptio-ark
spec:
  provider: portworx
  config:
    type: cloud
    # Optional, required only if Portworx is configured with more than one credential
    credId: <UUID>
```

After applying the above specs you should see them when you list the VolumeSnapshotLocaions
```text
kubectl get volumesnapshotlocation -n heptio-ark
```
```
NAME             AGE
portworx-cloud   54m
portworx-local   54m
```

## Creating backups
Once the plugin has been installed and configured, everytime you take backups
using Ark and include PVCs, it will also take Portworx snapshots of your volumes.

### Local Backups  
To backup all your apps in the default namespace and also create local snapshots
of the volumes, you would use `portworx-local` for the snapshot location:
```
$ ark backup create default-ns-local-backup --include-namespaces=default --snapshot-volumes \
     --volume-snapshot-locations portworx-local
Backup request "default-ns-local-backup" submitted successfully.
Run `ark backup describe default-ns-local-backup` for more details.
```

### Cloud Backups  
To backup all your apps in the default namespace and also create cloud backups
of the volumes, you would use `portworx-cloud` for the snapshot location:
```
$ ark backup create default-ns-cloud-backup --include-namespaces=default --snapshot-volumes \
     --volume-snapshot-locations portworx-cloud
Backup request "default-ns-cloud-backup" submitted successfully.
Run `ark backup describe default-ns-cloud-backup` for more details.
```

## Listing backups
Once the specs and volumes have been backed up you should see the backup marked
as `Completed` in ark.

```
$ ark get backup
NAME                      STATUS      CREATED                         EXPIRES   STORAGE LOCATION    SELECTOR
default-ns-local-backup   Completed   2018-11-11 20:10:45 +0000 UTC   29d       default             <none>
default-ns-cloud-backup   Completed   2018-11-11 20:15:45 +0000 UTC   29d       default             <none>
```

## Restoring from backups
When restoring from backups, a clone volume will be created from the snapshot and
bound to the restored PVC. To restore from the backup created above you can run
the following command:
```
$ ark restore create --from-backup default-ns-local-backup
Restore request "default-ns-local-backup-20181111201245" submitted successfully.
Run `ark restore describe default-ns-local-backup-20181111201245` for more details.
```
