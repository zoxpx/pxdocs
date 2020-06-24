---
title: Updating Volumes using pxctl
keywords: pxctl, command-line tool, cli, reference, share volume, unshare volume, replication factor, sticky option, increase replication factor, decrease replication factor, update replication factor
description: Updating volumes is done simply with Portworx. Use the pxctl volume update  command to update a specific parameters. Try today!
weight: 3
---

This section will walk you through the commands for updating your Portworx volumes.
First, let's use the built-in help that to discover the available commands:

```text
sudo /opt/pwx/bin/pxctl volume update --help
```

```output
Update volume settings
Usage:
  pxctl volume update [flags]
Examples:
pxctl volume update [flags] volName
Flags:
      --async_io string         Enable async IO to backing storage (Valid Values: [on off]) (default "off")
      --early_ack string        Reply to async write requests after it is copied to shared memory (Valid Values: [on off]) (default "off")
      --export_options string   set export options
  -g, --group string            Set/Reset the Group field on a Volume
  -h, --help                    help for update
      --io_profile string       IO Profile (Valid Values: [sequential cms db db_remote sync_shared auto]) (default "auto")
      --journal string          Journal data for this volume (Valid Values: [on off]) (default "off")
  -l, --label string            list of comma-separated name=value pairs to update (use empty label value to remove label)
      --nodiscard string        Disable discard support for this volume (Valid Values: [on off]) (default "off")
      --queue_depth uint        block device queue depth (Valid Range: [1 256]) (default 128)
      --scale uint              New scale factor (Valid Range: [1 1024]) (default 1)
      --shared string           set shared setting (Valid Values: [on off]) (default "off")
      --sharedv4 string         set sharedv4 setting (Valid Values: [on off]) (default "off")
  -s, --size uint               New size for the volume (GiB) (default 1)
      --sticky string           set sticky setting (Valid Values: [on off]) (default "off")
Global Flags:
      --ca string            path to root certificate for ssl usage
      --cert string          path to client certificate for ssl usage
      --color                output with color coding
      --config string        config file (default is $HOME/.pxctl.yaml)
      --context string       context name that overrides the current auth context
  -j, --json                 output in json
      --key string           path to client key for ssl usage
      --output-type string   use "wide" to show more details
      --raw                  raw CLI output for instrumentation
      --ssl                  ssl enabled for portworx
```

## Sharing and unsharing volumes

You can use the `--shared` flag to share or unshare a given volume across multiple namespaces.

Say we've created a volume named `clitest`. You can see its settings using this command:

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

Note that the `shared` field is shown as `no`, indicating that `clitest` is not a shared volume.

Next, let's turn on sharing:

```text
pxctl volume update clitest --shared=on
```

At this point, the volume's sharing settings should have been updated. We can easily check by running `pxctl volume inspect` on the volume again:

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

As shown above, the `shared` field is set to `yes` indicating that `clitest` is now a shared volume


### Related topics

* For more information about creating shared Portworx volumes through Kubernetes, refer to the [Create shared PVCs](/portworx-install-with-kubernetes/storage-operations/create-pvcs/create-shared-pvcs/) page.

## Changing a volume's sticky option

For adding the `--sticky` attribute to a volume, use the following command:


```text
pxctl volume update clitest --sticky=on
```

Doing a subsequent inspect on the volume shows the `attributes` field set to `sticky`:

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


## Increase volume size

Here is an example of how to increase the size of an existing volume.

First, let’s create a volume with the default parameters (1 GiB):

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

Note the default volume size - 1 GiB.

{{<info>}}
In order to update the size of a given volume, you should first mount it. If it’s a shared volume, then this operation can be done from any of the nodes where the volume is attached.
{{</info>}}


Now that we've created a new volume, let's attach it to resize it.

```text
pxctl host attach vol_resize_test
```

```output
Volume successfully attached at: /dev/pxd/pxd485002114762355071
```

With `vol_resize_test` attached, the next steps are to create a new directory:

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

Lastly, to update the size of this volume to 5 GB do:

```text
pxctl volume update vol_resize_test --size=5
```

```output
Update Volume: Volume update successful for volume vol_resize_test
```

Let's verify the size with the following command:

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

### Related topics

For more information about dynamically resizing a volume (PVC) using Kubernetes and Portworx, refer to the [Resize a Portworx PVC](/portworx-install-with-kubernetes/storage-operations/create-pvcs/resize-pvc/) page.

## Update a volume's replication factor

`pxctl volume ha-update` can be used to increase or decrease the replication factor for a given Portworx volume.

{{% content "shared/max-replication-factor.md" %}}

### Increasing the replication factor

Say there was a volume named `clitest` with the replication factor set to 1. Let's look at how to increase it.


Start by listing the nodes in the cluster:

```text
pxctl cluster list
```

```output
Cluster ID: MY_CLUSTER_ID
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
fa18451d-9091-45b4-a241-d816357f634b	10.99.117.133	0.5		8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8	10.99.117.137	0.250313	8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
bb605ca6-c014-4e6c-8a23-55c967d1a963	10.99.117.135	0.625782	8.4 GB	7.9 GB		N/A		1.1.6-a879596	Online
```


Next, make it so the volume is replicated to `NodeID b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8` by running:

```text
pxctl volume ha-update --repl=2 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8 clitest
```

Once the replication completes and the new node is added to the replication set, `pxctl volume inspect` will show both nodes:

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

`pxctl alerts show --type volume` will show when the replication is complete:

```text
pxctl alerts show --type volume
```

```output
AlertID	VolumeID		Timestamp			Severity	AlertType			Description
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
```

### Decreasing the replication factor

The `ha-update` command can be used to reduce the replication factor as well. Continuing our example with `clitest`, let's reduce the volume's replication factor:

```text
pxctl volume ha-update  --repl=1 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8 clitest
```

```output
Update Volume Replication: Replication update started successfully for volume clitest
```

Once the replication factor has been reduced to 1, the output of the `volume inspect` command would look something like this:

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

Here is the output of `pxctl alerts show --type volume`:

```text
25	970758537931791410	Feb 26 22:02:04 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated from 1 to 2
26	970758537931791410	Feb 26 22:58:17 UTC 2017	NOTIFY		Volume operation success	Volume (Id: 970758537931791410 Name: clitest) HA updated
```

## Update a volume's group ID

To update or a new group ID to a volume, enter the `pxctl volume update` command with the `--group` option and the new group name:

```text
pxctl volume update --group <groupName> <volumeName>
```
```output
Update Volume: Volume update successful for volume exampleVolume
Warning: Updating group field will not affect the replica placement of already provisioned volumes.
```

