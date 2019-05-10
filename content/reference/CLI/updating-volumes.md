---
title: Updating Volumes
keywords: portworx, pxctl, command-line tool, cli, reference
description: Updating volumes is done simply with Portworx. Use the pxctl volume update  command to update a specific parameters. Try today!
weight: 13
---

#### pxctl volume update {#pxctl-volume-update}

`pxctl volume update` is used to update a specific parameter of the volume

It has the following options.

```text
sudo /opt/pwx/bin/pxctl volume update --help
NAME:
   pxctl volume update - Update volume settings

```output
Update volume settings

Usage:
  pxctl volume update [flags]

Examples:
pxctl volume update [flags] volName

Flags:
  -l, --label string        list of comma-separated name=value pairs to update (use empty label value to remove label)
      --shared string       set shared setting (Valid Values: [on off]) (default "off")
      --sticky string       set sticky setting (Valid Values: [on off]) (default "off")
      --journal string      Journal data for this volume (Valid Values: [on off]) (default "off")
      --early_ack string    Reply to async write requests after it is copied to shared memory (Valid Values: [on off]) (default "off")
      --async_io string     Enable async IO to backing storage (Valid Values: [on off]) (default "off")
      --nodiscard string    Disable discard support for this volume (Valid Values: [on off]) (default "off")
      --io_profile string   IO Profile (Valid Values: [sequential cms db]) (default "sequential")
      --sharedv4 string     set sharedv4 setting (Valid Values: [on off]) (default "off")
      --queue_depth uint    block device queue depth (Valid Range: [1 256]) (default 128)
      --scale uint          New scale factor (Valid Range: [1 1024]) (default 1)
  -s, --size uint           New size for the volume (GiB) (default 1)
  -h, --help                help for update

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

**Change Shared Option**

Using the `--shared` flag, the volume namespace sharing across multiple volumes can be turned on or off.

For e.g., for the volume clitest, here is the output of volume inpsect.

```text
pxctl volume inspect clitest
```

```output
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
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
```

The `shared` field is shown as ‘no’ indicating that this is not a shared volume

```text
pxctl volume update clitest --shared=on
```

Let’s do a `pxctl volume inspect` on the volume again.

```text
pxctl volume inspect clitest
```

```output
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Shared          	 :  yes
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
```

As shown above, the volume is shown as `shared=yes` indicating that this is a shared volume

For adding the `--sticky` attribute to a volume, use the following command.

**Change Volume Sticky Option**

```text
pxctl volume update clitest --sticky=on
```

Doing a subsequent inspect on the volume shows the `attributes` field set to `sticky`

```text
pxctl volume inspect clitest
```

```output
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 08:17:20 UTC 2017
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Attributes      	 :  sticky
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
```

**Increase Volume Size**

Here is an example of how to update size of an existing volume. Let’s create a volume with default parameters. This will create a volume of size 1 GB. We can verify this with volume inspect.

```text
pxctl volume create vol_resize_test
```

```output
Volume successfully created: 485002114762355071
```

Next, we would want inspect our new volume:

```text
pxctl volume inspect vol_resize_test
```

```output
Volume	:  485002114762355071
	Name            	 :  vol_resize_test
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Apr 10 18:53:11 UTC 2017
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
	Bytes used      	 :  32 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  172.31.55.104
```

In order to update the size of the volume, a non-shared volume needs to be mounted on one of PX nodes. If it’s a shared volume, then this operation can be done from any of the nodes where the volume is attached.

```text
pxctl host attach vol_resize_test
```

```output
Volume successfully attached at: /dev/pxd/pxd485002114762355071


```text
sudo mkdir /var/lib/osd/mounts/voldir
```

and then mount the volume:

```text
pxctl host mount vol_resize_test /var/lib/osd/mounts/voldir
```

```output
Volume vol_resize_test successfully mounted at /var/lib/osd/mounts/voldir
```

Let’s update size of this volume to 5 GB.

```text
pxctl volume update vol_resize_test --size=5
```

```output
Update Volume: Volume update successful for volume vol_resize_test
```

We can verify this with volume inspect command.

```text
pxctl volume inspect vol_resize_test
```

```output
Volume	:  485002114762355071
	Name            	 :  vol_resize_test
	Size            	 :  5.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Apr 10 18:53:11 UTC 2017
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: 43109685-e98a-448f-9805-293128e2d78b
	Device Path     	 :  /dev/pxd/pxd485002114762355071
	Reads           	 :  138
	Reads MS        	 :  108
	Bytes Read      	 :  974848
	Writes          	 :  161
	Writes MS       	 :  1667
	Bytes Written   	 :  68653056
	IOs in progress 	 :  0
	Bytes used      	 :  97 MiB
	Replica sets on nodes:
		Set  0
			Node 	 :  172.31.55.104
```

**Update the Volume Replication Level**

`pxctl volume ha-update` can be used to increase or decrease the replication factor for a given portworx volume.

The volume `clitest` shown in the previous example is a volume with replication factor set to 1.

Here are the nodes in the cluster.

```text
sudo /opt/pwx/bin/pxctl cluster list

```output
Cluster ID: MY_CLUSTER_ID
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
fa18451d-9091-45b4-a241-d816357f634b	10.99.117.133	0.5		8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8	10.99.117.137	0.250313	8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
bb605ca6-c014-4e6c-8a23-55c967d1a963	10.99.117.135	0.625782	8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
```

Using `pxctl volume ha-update`, here is how to increase the replication factor. Note, the command below sets the volume to replicate to the node with NodeID b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8

```text
sudo /opt/pwx/bin/pxctl volume ha-update --repl=2 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8 clitest
```

Once the replication completes and the new node is added to the replication set, the `pxctl volume inspect`shows both the nodes.

```text
pxctl volume inspect clitest
```

```output
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  2
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 08:17:20 UTC 2017
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Attributes      	 :  sticky
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
			Node 	 :  10.99.117.137
```

`pxctl volume alerts` will show when the replication is complete

```text
pxctl alerts show --type volume
```

```output
AlertID	VolumeID		Timestamp			Severity	AlertType			Description
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
```

The ha-update command can also be used to reduce the replication factor as well.

```text
pxctl volume ha-update  --repl=1 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8 clitest
```

```output
Update Volume Replication: Replication update started successfully for volume clitest
```

Here is the output of the volume inspect command after the replication factor has been reduced to 1

```text
pxctl volume inspect clitest
```

```output
Volume	:  970758537931791410
	Name            	 :  clitest
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Feb 26 08:17:20 UTC 2017
	Shared          	 :  yes
	Status          	 :  up
	State           	 :  detached
	Attributes      	 :  sticky
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
```

Here is the output of the volume alerts.

```text
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
26	970758537931791410	Feb 26 22:58:17 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated
```
