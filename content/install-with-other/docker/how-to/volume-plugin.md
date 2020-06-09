---
title: Docker interaction with Portworx
description: Learn how Portworx Volumes work with Docker
keywords: Portworx volumes, Docker, integration, how to
weight: 1
linkTitle: How Portworx Volumes work with Docker
---

## Docker interaction with Portworx

Portworx implements the Docker Volume Plugin Specification.

The plugin API allows creation, instantiation, and lifecycle management of Portworx volumes. This allows direct use by Docker, Docker swarm, and DCOS via [dvdi](https://mesosphere.github.io/marathon/docs/external-volumes.html).

### Discovery

Docker scans the plugin directory (`/run/docker/plugins`) on startup and whenever a user or a container requests a plugin by name.
When the Portworx container is run, a unix domain socket `pxd.sock` is exported under `/var/run/docker/plugins` directory.  Portworx volumes are shown as owned by volume driver `pxd`.

### Create

See https://docs.docker.com/engine/reference/commandline/volume_create/

Portworx volumes are created by specifying volume driver as `pxd`.

Here is an example of how to create a 10GB volume with replication factor set to 3:

```text
docker volume create --driver pxd \
           --opt size=10G \
           --opt repl = 3 \
           --name my_portworx_vol

```

Docker looks in its cache before sending the request to create to Portworx. For this reason, we recommend to not mix-and-match create and delete operations with pxctl and docker. If a volume with the same name is created again, it is a No-op.

#### Use of options in docker volume create

You can include any desired volume options with the `volume create` command:

```text
--opt io_priority=high
```

The following table lists what options you can include:

{{% content "shared/portworx-install-with-kubernetes-volume-options.md" %}}

#### Replicaset

**Specify replica nodes**

Multiple nodes through docker volume create is supported from 1.3.0.1.

Use the _nodes_ option to specify the nodes you wish the replicas to reside on.

Some valid examples of this are:

* nodes="4c4b3f62-3d23-43fb-9fa0-3b95b3236efc;7adc01d2-7c96-4446-8d2d-8f5e1035ec1e"
* nodes="4c4b3f62-3d23-43fb-9fa0-3b95b3236efc"
* nodes='4c4b3f62-3d23-43fb-9fa0-3b95b3236efc;7adc01d2-7c96-4446-8d2d-8f5e1035ec1e'
* nodes='4c4b3f62-3d23-43fb-9fa0-3b95b3236efc'
* nodes=4c4b3f62-3d23-43fb-9fa0-3b95b3236efc

It is important to note that the number of nodes should equal the _repl_ option otherwise Portworx will pick a node for the remaining requested replica's.

#### Snapshot

**Scheduled snapshots**

Scheduled snapshots are only available in Portworx 1.3 and higher.

Use the _snap_schedule_ option to specify the snapshot schedule.

Following are the accepted formats:<br><br>periodic=_mins_,_snaps-to-keep_ <br>daily=_hh:mm_,_snaps-to-keep_ <br>weekly=_weekday@hh:mm_,_snaps-to-keep_  <br>monthly=_day@hh:mm_,_snaps-to-keep_<br><br> _snaps-to-keep_ is optional. Periodic, Daily, Weekly and Monthly keep last 5, 7, 5 and 12 snapshots by default respectively.

Some examples of snapshots schedules are:

* snap_schedule="periodic=60,10"
* snap_schedule="daily=12:00,4"
* snap_schedule="weekly=sunday@12:00,2"
* snap_schedule="monthly=15@12:00"

{{<info>}}
Note that scheduled snapshots do not occur if the volume you are trying to snapshot is not attached to a container.
{{</info>}}

**On-demand snapshots**

There is no explicit Snapshot operation via Docker plugin API. However, this can be achieved via the create operation. Specifying a `parent` operation will create a snapshot.

The following command creates the volume `snap_of_my_portworx_vol` by taking a snapshot of `my_portworx_vol`

```text
docker volume create --driver pxd \
           --opt parent=my_portworx_vol  \
           --name snap_of_my_portworx_vol
```

The snapshot can then be used as a regular Portworx volume.

### Mount

Mount operation mounts the Portworx volume in the propagated mount location. If the device is un-attached, `Mount` will implicitly perform an attach as well. Mounts are reference counted and are idempotent. The same volume can be mounted at muliple locations on the same node. The same device can be mounted at the same location multiple times.

#### Attach

The docker plugin API does not have an Attach call. The Attach call is called internally via Mount on the first mount call for the volume.

Portworx exports virtual block devices in the host namespace. This is done via the Portworx container running on the system and does *not* rely on an external protocol such as iSCSI or NBD. Portworx virtual block devices only exist in host kernel memory. Two interesting consequences of this architecture are:
1) volumes can be unmounted from dead/disconnected nodes
2) IOs on porworx can survive a Portworx restart.

Portworx volume can be attached to any participating node in the cluster, although it can be attached to only one node at any given point in time. The node where the Portworx volume is attached is deemed the transaction coordinator and all I/O access to the volume is arbitrated by that node.

Attach is idempotent - multiple attach calls of a volume on the same node will return success. Attach on a node will return a failure, if the device is attached on a different node.

The following command will instantiate a virtual block device in the host namespace and mount it under propagated mount location. The mounted volume  is then bind mounted under /data in the busybox container.

```text
docker run -it -v my_portworx_vol:/data busybox c
```

Running it again will create a second instance of busybox, another bind mount and the Portworx volume reference count will be at 2. Both containers need to exit for the Portworx volume to be unmounted (and detached).

### Unmount

Umount operation unmounts the Portworx volume from the propagated mount location. If this is the last surviving mount on a volume, then the volume is detached as well. Once succesfully unmounted the volume can be mounted on any other node in the system.

#### Detach

The docker plugin API does not have an Detach call. The Detach call is called internally via Unmount on the last unmount call for the volume.

Detach operation involves unexporting the virtual block device from the host namespace. Similar to attach, this is again accomplished via the Portworx container and does not require any external protocol. Detach is idempotent, multiple calls to detach on the same device will return success.  Detach is not allowed if the device is mounted on the system.


### Remove

Remove will delete the underlying Portworx volume and all associated data. The operation will fail if the volume is mounted.

The following command will remove the volume `my_portworx_vol`:

```text
docker volume rm my_portworx_vol
```

### Capabilities

The Portworx volume driver identifies itself as a `global` driver.  Portworx operations can be executed on any node in the cluster. Portworx volumes can be used and managed from any node in the cluster.
