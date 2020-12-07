---
title: Create and manage volumes using pxctl
keywords: pxctl, command-line tool, cli, reference, create volume, manage volumes, import volume, inspect volume, list volumes, locate volume, restore volume, clone volume, snapshot volume
description: This guide shows you how to create and manage volumes with pxctl.
linkTitle: Create and Manage Volumes
weight: 1
hidesections: true
---

In this document, we are going to show you how to create and manage volumes with the `pxctl` command-line tool. Note that you can use the new volumes directly in Docker with the `-v` option.

To view a list of the available commands, run the following command:

```text
/opt/pwx/bin/pxctl volume -h
```

```output
Manage volumes

Usage:
  pxctl volume [flags]
  pxctl volume [command]

Aliases:
  volume, v

Examples:
pxctl volume create -s 100 myVolName

Available Commands:
  access               Manage volume access by users or groups
  clone                Create a clone volume
  create               Create a volume
  delete               Delete a volume
  ha-update            Update volume HA level
  import               Import data into a volume
  inspect              Inspect a volume
  list                 List volumes in the cluster
  locate               Locate volume
  requests             Show all pending requests
  restore              Restore volume from snapshot
  snap-interval-update Update volume configuration
  snapshot             Manage volume snapshots
  stats                Volume Statistics
  update               Update volume settings
  usage                Show volume usage information

Flags:
  -h, --help   help for volume

Global Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx

Use "pxctl volume [command] --help" for more information about a command.
```

In the next sections, we will take a look at these commands individually.

## Create volumes

Portworx creates volumes from the global capacity of a cluster. You can expand the capacity and throughput of your cluster by adding new nodes to the cluster. Portworx protects your volumes from hardware and node failures through automatic replication.

Here are a few things you should consider when creating a new volume with the `pxctl` command-line tool:

* Durability: Set the replication level through policy, using the `High Availability` setting. See the [storage policy](/reference/cli/storagepolicy) page for more details.
* Portworx synchronously replicates each write operation to a quorum set of nodes.
* Portworx uses an elastic architecture. This allows you to add capacity and throughput at every layer, at any time.
* Volumes are thinly provisioned. They only use as much storage as needed by the container.
* You can expand and contract the maximum size of a volume, even after you write data to the volume.

You can create a volume before being used by its container. Also, the container can create the volume at runtime. When you create a volume, the `pxctl` command-line tool returns the ID of the volume. You can see the same volume if ID if you run a Docker command such as `docker volume ls`.


To create a volume, run the `pxctl volume create` and pass it the name of the volume. The following example creates a volume called `myVol`:

```text
pxctl volume create myVol
```

```output
3903386035533561360
```

{{<info>}}
Portworx controls the throughput at per-container level and can be shared. Volumes have fine-grained control, set through policy.
{{</info>}}

Before you move on, take a bit of time to make sure you understand the following points:

* Throughput is set by the IO Priority setting. Throughput capacity is pooled.
* If you add a node to the cluster, you expand the available throughput for read and write operations.
* Portworx selects the best node to service read operations, no matter that the operation is from local storage devices or the storage devices attached to another node.
* Read throughput is aggregated, where multiple nodes can service one read request in parallel streams.
* Fine-grained controls: Policies are specified per volume and give full control to storage.
* Policies enforce how the volume is replicated across the cluster, IOPs priority, filesystem, blocksize, and additional parameters described below.
* Policies are specified at create time and can be applied to existing volumes.


The `pxctl` command-line utility provides a multitude of options for setting the policies on a volume. Let’s get a feel for the available options by running the `pxctl volume create ` with the `-h` flag:

```text
pxctl volume create -h
```

```output
Create a volume

Usage:
  pxctl volume create [flags]

Aliases:
  create, c

Examples:
pxctl volume create [flags] volume-name

Flags:
      --shared                              make this a globally shared namespace volume
      --secure                              encrypt this volume using AES-256
      --use_cluster_secret                  Use cluster wide secret key to fetch secret_data
      --journal                             Journal data for this volume
      --early_ack                           Reply to async write requests after it is copied to shared memory
      --async_io                            Enable async IO to backing storage
      --nodiscard                           Disable discard support for this volume
      --sticky                              sticky volumes cannot be deleted until the flag is disabled
      --sharedv4                            export this volume via Sharedv4 at /var/lib/osd/exports
      --enforce_cg                          enforce group during provision
      --best_effort_location_provisioning   requested nodes, zones, racks are optional
      --secret_key string                   secret_key to use to fetch secret_data for the PBKDF2 function
  -l, --label pairs                         list of comma-separated name=value pairs
      --io_priority string                  IO Priority (Valid Values: [high medium low]) (default "low")
      --io_profile string                   IO Profile (Valid Values: [sequential cms db db_remote]) (default "sequential")
  -a, --aggregation_level string            aggregation level (Valid Values: [1 2 3 auto]) (default "1")
      --nodes string                        comma-separated Node Ids
      --zones string                        comma-separated Zone names
      --racks string                        comma-separated Rack names
  -g, --group string                        group
  -p, --periodic mins,k                     periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
      --policy string                       policy names separated by comma
      --storagepolicy string                storage policy name
  -s, --size uint                           volume size in GB (default 1)
  -b, --block_size uint                     block size in Bytes (default 32768)
  -q, --queue_depth uint                    block device queue depth (Valid Range: [1 256]) (default 128)
  -r, --repl uint                           replication factor (Valid Range: [1 3]) (default 1)
      --scale uint                          auto scale to max number (Valid Range: [1 1024]) (default 1)
  -d, --daily hh:mm,k                       daily snapshot at specified hh:mm,k (keeps 7 by default)
  -w, --weekly weekday@hh:mm,k              weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
  -m, --monthly day@hh:mm,k                 monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
  -h, --help                                help for create

Global Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx
```

{{<info>}}
These options can also be passed in through the scheduler or using the inline volume spec. See the [inline volume spec] (#inline-volume-spec) section below for more details.
{{</info>}}

### Place a replica on a specific volume

Use the `--nodes=LocalNode` flag to create a volume and place at least one replica of the volume on the node where the command is run. This is useful when you use a script to create a volume locally on a node.

{{<info>}}
**NOTE:** You can provide a node ID, node IP address, or pool UUID to the `--nodes` flag.
{{</info>}}

As an example, here's how you can create a volume named `localVolume` and place a replica of the volume on the local node:

```text
pxctl volume create --nodes=LocalNode localVolume
```

```output
Volume successfully created: 756818650657204847
```

Now, you can check that the replica of the volume is on the node where the command was run:

```text
pxctl volume inspect localVolume
```

```output
Volume  :  756818650657204847
        Name                     :  localVolume
        Size                     :  1.0 GiB
        Format                   :  ext4
        HA                       :  1
        IO Priority              :  LOW
        Creation time            :  Mar 20 00:30:05 UTC 2019
        Shared                   :  no
        Status                   :  up
        State                    :  detached
        Reads                    :  0
        Reads MS                 :  0
        Bytes Read               :  0
        Writes                   :  0
        Writes MS                :  0
        Bytes Written            :  0
        IOs in progress          :  0
        Bytes used               :  340 KiB
        Replica sets on nodes:
                Set 0
                  Node           : 70.0.29.90 (Pool 1)
        Replication Status       :  Detached
```

{{<info>}}
The replicas are visible in the `Replica sets on nodes` section.
{{</info>}}

### Create volumes with Docker

All `docker volume` commands are reflected in Portworx. For example, a `docker volume create` command provisions a storage volume in a Portworx storage cluster.

Use the following command to create a volume named `testVol`:

```text
docker volume create -d pxd --name testVol
```

```output
testVol
```

To make sure the command is reflected into Portworx, run:

```text
pxctl volume list --name testVol
```

```output
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS		SNAP-ENABLED
426544812542612832	testVol	1 GiB	1	no	no		LOW		up - detached	no
```

### Add optional parameters with the --opt flag

As part of the `docker volume` command, you can add optional parameters through the `--opt` flag. The parameters are the same, whether you use Portworx storage through the Docker volume or the `pxctl` command.

The following command uses the `--opt` flag to specify the filesystem of the container and the size of the volume:

```text
docker volume create -d pxd --name opt_example --opt fs=ext4 --opt size=1G
```

```output
opt_example
```

Now, let's check the setting of our newly created volume. Run the `pxctl volume list` command and pass it the `--name` flag with the name of the volume:

```text
pxctl volume list --name opt_example
```

```output
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS		SNAP-ENABLED
282820401509248281	opt_example	1 GiB	1	no	no		LOW		up - detached	no
```

## Inline volume spec

With Portworx, you can pass the volume spec inline along with the volume name. This is useful if you want to create a volume with your scheduler application template inline instead of creating it beforehand.

For example, the following command creates volume called `demovolume` with:

- IO priority level = high
- initial size = 10G
- replication factor = 3
- periodic and daily snapshots

```text
docker volume create -d pxd io_priority=high,size=10G,repl=3,snap_schedule="periodic=60#4;daily=12:00#3",name=demovolume
```

You can make it so that Docker starts a specific container dynamically. Use the following command to create a volume dynamically and start the `busybox` container:

```text
docker run --volume-driver pxd -it -v io_priority=high,size=10G,repl=3,snap_schedule="periodic=60#4;daily=12:00#3",name=demovolume:/data busybox sh
```

{{<info>}}
The spec keys must be comma separated.
{{</info>}}

The `pxctl` command-line utility provides support for the following key-value pairs:

```
IO priority      - io_priority=[high|medium|low]
Volume size      - size=[1..9][G|M|T]
HA factor        - repl=[1,2,3]
Block size       - bs=[4096...]
Shared volume    - shared=true
File System      - fs=[xfs|ext4]
Encryption       - passphrase=secret
snap_schedule    - "periodic=mins#k;daily=hh:mm#k;weekly=weekday@hh:mm#k;monthly=day@hh:mm#k" where k is the number of snapshots to retain.
```

The inline specs can be passed in through the scheduler application template. For example, below is a snippet from a marathon configuration file:

```text
"parameters": [
	{
		"key": "volume-driver",
		"value": "pxd"
	},
	{
		"key": "volume",
		"value": "size=100G,repl=3,io_priority=high,name=mysql_vol:/var/lib/mysql"
	}],
```

## The global namespace

{{% content "shared/concepts-shared-volumes.md" %}}


### Related topics

* For information about creating shared Portworx volumes through Kubernetes, refer to the [ReadWriteMany and ReadWriteOnce](/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/volumes/#readwritemany-and-readwriteonce) section.


## Delete volumes

You can delete a volume by running the `pxctl volume delete ` with the name of the volume you want to delete:

```text
pxctl volume delete myOldVol
```

```output
Delete volume 'myOldVol', proceed ? (Y/N): y
Volume myOldVol successfully deleted.
```

## Import volumes

You can import files from a directory into an existing volume. Files already existing on the volume will be retained or overwritten.

As an example, to import the files from `/path/to/files` into `myVol`, run the `pxctl volume import` and pass it the `--src` flag as in the following example:

```text
pxctl volume import --src /path/to/files myVol
```

```output
Starting import of  data from /path/to/files into volume myVol...Beginning data transfer from /path/to/files myVol
Imported Bytes :   0% [>---------------------------------------------------------------------------------------------------------------------------------------] 14ms
Imported Files :   0% [>---------------------------------------------------------------------------------------------------------------------------------------] 16ms

Volume imported successfully
```

## Inspect volumes

Click on the section below for instructions on how to inspect your Portworx volumes.

{{< widelink url="/reference/cli/create-and-manage-volumes/inspect-volumes" >}}Inspect volumes{{</widelink>}}

## List volumes

To list all volumes within a cluster, use this command:

```text
pxctl volume list
```

```output
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS				SNAP-ENABLED
951679824907051932	objectstorevol	10 GiB	1	no	no		LOW		up - attached on 192.168.99.101	no
810987143668394709	testvol		1 GiB	1	no	no		LOW		up - detached			no
1047941676033657203	testvol2	1 GiB	1	no	no		LOW		up - detached			no
800735594334174869	testvol3	1 GiB	1	no	no		LOW		up - detached			no
```

## Locate volumes

The `pxctl volume locate` command shows where a given volume is mounted in the containers running on the node:

```text
pxctl volume locate 794896567744466024
```

```output
host mounted:
  /directory1
  /directory2
```

In this example, the volume is mounted in two containers via the `/directory1` and `/directory2` mount points.

## Create volume snapshots

{{% content "shared/reference-CLI-intro-snapshots.md" %}}

{{% content "shared/reference-CLI-creating-snapshots.md" %}}

Snapshots are read-only. To restore a volume from a snapshot, use the `pxctl volume restore` command.


### Related topics

* For information about creating snapshots of your Portworx volumes through Kubernetes, refer to the [Create and use snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/) page.

## Clone volumes

Use the `pxctl volume clone` command to create a volume clone from a volume or snapshot. You can refer to the in-built help, by running the `pxctl volume clone` command with  the `--help` flag:


```text
pxctl volume clone --help
```

```output
Create a clone volume

Usage:
  pxctl volume clone [flags]

Aliases:
  clone, cl

Examples:
pxctl volume clone [flags] volName

Flags:
      --name string    clone name
  -l, --label string   list of comma-separated name=value pairs
  -h, --help           help for clone

Global Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx
```


As an example, here's how you can make a clone named `myvol_clone` from the parent volume `myvol:


```text
pxctl volume clone -name myvol_clone myvol
```

```output
Volume clone successful: 55898055774694370
```

### Related topics

* For information about creating a clone from a snapshot through Kubernetes, refer to the [On-demand snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/) page.

## Restore a volume

{{% content "shared/reference-CLI-restore-volume-from-snapshot.md" %}}


### Related topics

* For information about restoring a Portworx volume with data from a snapshot through Kubernetes, refer to the [Restore snapshots](/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/snapshots/#restore-snapshots) page.


## Update the snap interval of a volume

Please see the documentation for [snapshots] (/reference/cli/snapshots) for more details.

### Related topics

* For information about creating scheduled snapshots of a Portworx volume through Kubernetes, refer to the [Scheduled snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/scheduled/) page.

## Show volume stats

The `pxctl volume stat` command shows the real-time read/write IO throughput:

```text
pxctl volume stats mvVol
```

```output
TS			Bytes Read	Num Reads	Bytes Written	Num Writes	IOPS		IODepth		Read Tput	Write Tput	Read Lat(usec)	Write Lat(usec)
2019-3-4:11 Hrs		0 B		0		0 B		0		0		0		0 B/s		0 B/s		0		0
```

## Manage volume access rules

With `pxctl`, you can manage your volume access rules. See the [volume access](/reference/cli/volume-access) page for more details.

## Update the replication factor of a volume

You can use the `pxctl volume ha-update` to increase or decrease the replication factor of a Portworx volume. Consult the [update volumes](/reference/cli/updating-volumes#update-a-volume-s-replication-factor) page for more details.

## Volume pending requests

Run the following command to show all pending requests:

```text
pxctl volume requests
```

```output
Only support getting requests for all volumes.
Active requests for all volumes: count = 0
```

## Update the settings of a volume

With the `pxctl volume update` command, you can update the settings of your Portworx volumes. Consult the [updating volumes](/reference/cli/updating-volumes) page for additional details.

## Volume usage

To get extended info about the usage of your Portworx volumes, run the `pxctl volume usage` command with the name or the ID of your volume:

```text
pxctl volume usage 13417687767517527
```

## Understand copy-on-write features

By default, Portworx uses features present in the underlying file system to take snapshots through copy-on-write and checksum storage blocks.

When using the copy-on-write feature to take snapshots, overwriting a block does not update it in place. Instead, every overwrite allocates or updates a new block, and the filesystem metadata is updated to point to this new block. This technique is called redirect-on-write. When using this feature, a block overwrite almost always involves block updates in multiple areas: the target block, any linked indirect file blocks, filesystem metadata blocks, and filesystem metadata indirect file blocks. In a background process separate from the overwrite operation, the old block is freed only if it's not being referenced by a snapshot/clone.

Alongside copy-on-write, the file system checksums all blocks to detect lost writes and stores the checksum values in a different location away from their associated data. 

While these combined features increase the integrity of the data stored on the filesystem, they also increase the read and write overhead on the drives that use them, slowing down performance and increasing latency during file operations. 

Depending on your use-case, you may wish to trade off the integrity copy-on-write features offer for increased performance and lower latency. You can do so on a per-volume basis through the `pxctl` command.

### Disable copy-on-write features for a volume

Enter the `pxctl volume update` command with the `--cow_ondemand off` flag, followed by the ID of the volume you want to disable copy-on-write features for:

  ```text
  pxctl volume update  --cow_ondemand off <volume-ID>
  ```
  ```output
  Update Volume: Volume update successful for volume 850767800314736346
  ```