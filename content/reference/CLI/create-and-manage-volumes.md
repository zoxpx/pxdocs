---
title: Create and manage volumes using pxctl
keywords: portworx, pxctl, command-line tool, cli, reference
description: This guide shows you how to create and manage volumes with pxctl.
linkTitle: Create and Manage Volumes
weight: 12
---

In this section, we are going to focus on creating and managing volumes with `pxctl`. You can use the created volumes directly in Docker with the `-v` option.

To view a list of the available commands, run the following:

```text
/opt/pwx/bin/pxctl volume -h
```

```
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

## Creating volumes with pxctl

_Portworx_ creates volumes from the global capacity of a cluster. You can expand the capacity and throughput by adding new nodes to the cluster. _Portworx_ protects storage volumes from hardware and node failures through automatic replication.

Things to consider when creating a new volume with `pxctl`:

* Durability: Set the replication level through policy, using the High Availability setting.
* Each write is synchronously replicated to a quorum set of nodes.
* Any hardware failure means that the replicated volume has the latest acknowledged writes.
* Elastic: Add capacity and throughput at each layer, at any time.
* Volumes are thinly provisioned, only using capacity as needed by the container.
* You can expand and contract the volume’s maximum size, even after data has been written to the volume.

A volume can be created before being used by its container or by the container directly at runtime. Creating a volume returns the volume’s ID. The same volume ID shown by `pxctl` is returned by Docker commands \(such as `Docker volume ls`\).


To create a volume named `myVol`, type:

```text
pxctl volume create myVol
```

`pxctl` will create the volume and will print its `id`:

```
3903386035533561360
```

Throughput is controlled per container and can be shared. Volumes have fine-grained control, set through policy.

Before you move on, take a bit of time to make sure you understand the following points:

* Throughput is set by the IO Priority setting. Throughput capacity is pooled.
* Adding a node to the cluster expands the available throughput for reads and writes.
* The best node is selected to service reads, whether that read is from local storage devices or another node’s storage devices.
* Read throughput is aggregated, where multiple nodes can service one read request in parallel streams.
* Fine-grained controls: Policies are specified per volume and give full control to storage.
* Policies enforce how the volume is replicated across the cluster, IOPs priority, filesystem, blocksize, and additional parameters described below.
* Policies are specified at create time and can be applied to existing volumes.


`pxctl` provides a multitude of options for setting the policies on a volume. Let’s get a feel for the available options by running:

```text
pxctl volume create -h
```

You should see something like:

```
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

{{<info>}}These options can also be passed in through the scheduler or using the inline volume spec. See the section [Inline volume spec] (#inline-volume-spec) below for more details.
{{</info>}}

### Using the --nodes Argument

Adding the `--nodes=LocalNode` argument while creating a volume with `pxctl` will place at least one replica of the volume on the node where the command is run.

This is useful when using a script to create a volume locally on a node.

Let's look at a simple example. Say you want to create a volume named `localVolume` and place a replica of the volume on the local node. If so, you should run something like the following:

```text
pxctl volume create --nodes=LocalNode localVolume
```

```
Volume successfully created: 756818650657204847
```

Now, let's quickly check that the volume's replica is on the node where the command was run:

```text
pxctl volume inspect localVolume
```

```
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
The replicas are visible in the _"Replica sets on nodes"_ section.
{{</info>}}

### Creating volumes with Docker

All `docker volume` commands are reflected in _Portworx_. For example, a `docker volume create` command provisions a storage volume in a _Portworx_ storage cluster.

The following `docker volume` command creates a volume named `testVol`:

```text
docker volume create -d pxd --name testVol
```

```
testVol
```

Just to make sure the command is reflected into _Portworx_, try running this command:


```text
pxctl volume list --name testVol
```

You should see something like:

```
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS		SNAP-ENABLED
426544812542612832	testVol	1 GiB	1	no	no		LOW		up - detached	no
```

### The --opt flag

As part of the `docker volume` command, you can add optional parameters through the `--opt` flag. The parameters are the same, whether you use _Portworx_ storage through the Docker volume or the `pxctl` command.

The command below uses the `--opt` flag to set the container's filesystem and volume size:

```text
docker volume create -d pxd --name opt_example --opt fs=ext4 --opt size=1G
```

```
opt_example
```

Now, let's check by running this command:

```
pxctl volume list --name opt_example
```

```
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS		SNAP-ENABLED
282820401509248281	opt_example	1 GiB	1	no	no		LOW		up - detached	no
```

We're all set.

## Inline volume spec

_PX_ supports passing the volume spec inline along with the volume name. This is useful if you want to create a volume with your scheduler application template inline and do not want to create volumes beforehand.

For example, a _PX_ inline spec looks like this:

```text
docker volume create -d pxd io_priority=high,size=10G,repl=3,snap_schedule="periodic=60#4;daily=12:00#3",name=demovolume
```

Let's look at another example that uses `docker run` to create a volume dynamically:

```text
docker run --volume-driver pxd -it -v io_priority=high,size=10G,repl=3,snap_schedule="periodic=60#4;daily=12:00#3",name=demovolume:/data busybox sh
```
The above command will create a volume called `demovolume` with an initial size of 10G, HA factor of 3, snap schedule with periodic and daily snapshot creation, and a high IO priority level. Next, it will start the busybox container dynamically.

{{<info>}}
The spec keys must be comma separated.
{{</info>}}

`pxctl` provides support for the following key value pairs:

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

```
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

## Global Namespace \(Shared Volumes\)

{{% content "concepts/shared/shared-volumes.md" %}}

## Deleting volumes

Volumes can be deleted like so:

```text
pxctl volume delete myOldVol
```

```
Delete volume 'myOldVol', proceed ? (Y/N): y
Volume myOldVol successfully deleted.
```

## Importing volumes

Files can be imported from a directory into an existing volume. Files already existing on the volume will be retained or overwritten.

As an example, you can import files from `/path/to/files` into `myVol` with the following:


```text
pxctl volume import --src /path/to/files myVol
```

```
Starting import of  data from /path/to/files into volume myVol...Beginning data transfer from /path/to/files myVol
Imported Bytes :   0% [>---------------------------------------------------------------------------------------------------------------------------------------] 14ms
Imported Files :   0% [>---------------------------------------------------------------------------------------------------------------------------------------] 16ms

Volume imported successfully
```

## Inspecting volumes

To find out more information about a volume's settings and its usage, run:

```text
pxctl volume inspect clitest
```

```
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 16:29:53 UTC 2019
	Shared          	 :  no
	Status          	 :  up
	State           	 :  detached
	Reads           	 :  0
	Reads MS        	 :  0
	Bytes Read      	 :  0
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  33 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  10.99.117.133
	Replication Status	 :  Detached
```

{{<info>}}
You can also inspect multiple volumes in one command.
{{</info>}}

To inspect the volume in `json` format, run `pxctl volume inspect` with the `-j` flag:

```text
pxctl -j volume inspect 486256711004992211
```

```
[{
 "id": "486256711004992211",
 "source": {
  "parent": "",
  "seed": ""
 },
 "readonly": false,
 "locator": {
  "name": "pvc-2910e5ab-1b5e-11e8-97a3-0269077ba1bd",
  "volume_labels": {
   "namespace": "default",
   "pvc": "px-nginx-shared-pvc"
  }
 },
 "ctime": "2018-02-27T01:33:16Z",
 "spec": {
  "ephemeral": false,
  "size": "1073741824",
  "format": "ext4",
  "block_size": "65536",
  "ha_level": "2",
  "cos": "low",
  "io_profile": "sequential",
  "dedupe": false,
  "snapshot_interval": 0,
  "volume_labels": {
   "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"PersistentVolumeClaim\",\"metadata\":{\"annotations\":{\"volume.beta.kubernetes.io/storage-class\":\"px-nginx-shared-sc\"},\"name\":\"px-nginx-shared-pvc\",\"namespace\":\"default\"},\"spec\":{\"accessModes\":[\"ReadWriteOnce\"],\"resources\":{\"requests\":{\"storage\":\"1Gi\"}}}}\n",
   "repl": "2",
   "shared": "true",
   "volume.beta.kubernetes.io/storage-class": "px-nginx-shared-sc",
   "volume.beta.kubernetes.io/storage-provisioner": "kubernetes.io/portworx-volume"
  },
  "shared": true,
  "aggregation_level": 1,
  "encrypted": false,
  "passphrase": "",
  "snapshot_schedule": "",
  "scale": 0,
  "sticky": false,
  "group_enforced": false,
  "compressed": false,
  "cascaded": false,
  "journal": false,
  "nfs": false
 },
 "usage": "33964032",
 "last_scan": "2018-02-27T01:33:16Z",
 "format": "ext4",
 "status": "up",
 "state": "detached",
 "attached_on": "",
 "attached_state": "ATTACH_STATE_INTERNAL_SWITCH",
 "device_path": "",
 "secure_device_path": "",
 "replica_sets": [
  {
   "nodes": [
    "k2n3",
    "k2n1"
   ]
  }
 ],
 "runtime_state": [
  {
   "runtime_state": {
    "FullResyncBlocks": "[{0 0} {1 0} {-1 0} {-1 0} {-1 0}]",
    "ID": "0",
    "ReadQuorum": "1",
    "ReadSet": "[0 1]",
    "ReplNodePools": "1,1",
    "ReplRemoveMids": "",
    "ReplicaSetCurr": "[0 1]",
    "ReplicaSetCurrMid": "k2n3,k2n1",
    "ReplicaSetNext": "[0 1]",
    "ReplicaSetNextMid": "k2n3,k2n1",
    "ResyncBlocks": "[{0 0} {1 0} {-1 0} {-1 0} {-1 0}]",
    "RuntimeState": "clean",
    "TimestampBlocksPerNode": "[0 0 0 0 0]",
    "TimestampBlocksTotal": "0",
    "WriteQuorum": "2",
    "WriteSet": "[0 1]"
   }
  }
 ],
 "error": ""
}]
```

{{<info>}}
The above command can be abbreviated as `pxctl -j volume inspect 486256711004992211`
{{</info>}}

## Listing volumes

To list all volumes within a cluster, use this command:

```text
pxctl volume list
```

```
ID			NAME		SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS				SNAP-ENABLED
951679824907051932	objectstorevol	10 GiB	1	no	no		LOW		up - attached on 192.168.99.101	no
810987143668394709	testvol		1 GiB	1	no	no		LOW		up - detached			no
1047941676033657203	testvol2	1 GiB	1	no	no		LOW		up - detached			no
800735594334174869	testvol3	1 GiB	1	no	no		LOW		up - detached			no
```

## Locating volumes

`pxctl` shows where a given volume is mounted in the containers running on the node:

```text
pxctl volume locate 794896567744466024
```

```
host mounted:
  /directory1
  /directory2
```

In this example, the volume is mounted in two containers via the `/directory1` and `/directory2` mount points.

## Volume snapshots

{{% content "reference/CLI/shared/intro-snapshots.md" %}}

{{% content "reference/CLI/shared/creating-snapshots.md" %}}

Snapshots are read-only. To restore a volume from a snapshot, use the `pxctl volume restore` command.

## Volume Clone

In order to create a volume clone from a volume or snapshot, use the `pxctl volume clone` command.

Let's first refer to the in-built help, which can be accessed by giving the `--help` argument:


```text
pxctl volume clone --help
```

```
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


As an example, if we want to make a clone named `myvol_clone` from the parent volume `myvol`, we can run:


```text
pxctl volume clone -name myvol_clone myvol
```

```
Volume clone successful: 55898055774694370
```

## Volume Restore

{{% content "reference/CLI/shared/restore-volume-from-snapshot.md" %}}

## Update the snap interval of a volume

Please see the documentation for [snapshots] (/reference/cli/snapshots) for more details.

## Volume stats

`pxctl` shows the realtime read/write IO throughput:

```text
pxctl volume stats mvVol
```

```
TS			Bytes Read	Num Reads	Bytes Written	Num Writes	IOPS		IODepth		Read Tput	Write Tput	Read Lat(usec)	Write Lat(usec)
2019-3-4:11 Hrs		0 B		0		0 B		0		0		0		0 B/s		0 B/s		0		0
```
