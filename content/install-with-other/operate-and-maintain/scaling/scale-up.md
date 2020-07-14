---
title: "Adding storage to existing Portworx Cluster Nodes"
keywords: scale up, scaling
description: Discover how to add a new node to a Portworx cluster and how to add additional storage to the Portworx Cluster once a new node is added.  Try it for yourself today.
---

{{<info>}}
This document presents the **non-Kubernetes** method of scaling your Portworx cluster. Please refer to the [Scale or Restrict](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/troubleshooting/scale-or-restrict/) page if you are running Portworx on Kubernetes.
{{</info>}}

## Adding Storage to exising Portworx Cluster Nodes

This section illustrates how to add a new node to a Portworx cluster and how to add additional storage to the Portworx Cluster once a new node is added.

### Display current cluster status

```text
pxctl status
```

```output
Status: PX is operational
Node ID: a56a4821-6f17-474d-b2c0-3e2b01cd0bc3
	IP: 147.75.198.197
 	Local Storage Pool: 2 pools
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	0	LOW		200 GiB	1.0 GiB	Online	default	default
	1	LOW		120 GiB	1.0 GiB	Online	default	default
	Local Storage Devices: 2 devices
	Device	Path				Media Type		SizLast-Scan
	0:1	/dev/mapper/volume-27dbb728	STORAGE_MEDIUM_SSD	200 GiB		08 Jan 17 16:54 UTC
	1:1	/dev/mapper/volume-0a31ef46	STORAGE_MEDIUM_SSD	120 GiB		08 Jan 17 16:54 UTC
	total					-			320 GiB
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online (This node)
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  520 GiB
```

The above cluster has three nodes and 520GiB of total capacity.

### Add a new node to cluster

Below is an example of how to run Portworx in a new node so it joins an existing cluster. Note how docker run command is invoked with a cluster token token-bb4bcf4b-d394-11e6-afae-0242ac110002 that has a token- prefix to the cluster ID to which we want to add the new node.

```text
docker run --restart=always --name px-enterprise -d --net=host --privileged=true -v /run/docker/plugins:/run/docker/plugins -v /var/lib/osd:/var/lib/osd:shared -v /dev:/dev -v /etc/pwx:/etc/pwx -v /opt/pwx/bin:/export_bin:shared -v /var/run/docker.sock:/var/run/docker.sock -v /mnt:/mnt:shared -v /var/cores:/var/cores -v /usr/src:/usr/src portworx/px-enterprise -m team0:0 -d team0
```

Here is how the cluster would look like after a new node is added without any storage:

```text
pxctl status
```

```output
Status: PX is operational
Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668
	IP: 147.75.104.185
 	Local Storage Pool: 0 pool
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	No storage pool
	Local Storage Devices: 0 device
	Device	Path	Media Type	Size		Last-Scan
	No storage device
	total		-	0 B
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online
	Node IP: 147.75.104.185 - Capacity: 0 B/0 B Online (This node)
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  520 GiB
```

Note how the capacity of the cluster has remained unchanged.

### Add more storage to the new node

Added another 100G of storage to this node and the device is seen as `/dev/dm-1`:

```text
multipath -ll
```

```output
volume-a9e55549 (360014055671ce0d20184a619c27b31d0) dm-1   ,IBLOCK
size=100G features='0' hwhandler='1 alua' wp=rw
`-+- policy='round-robin 0' prio=1 status=active
  |- 2:0:0:0 sdb 8:16 active ready running
  `- 3:0:0:0 sdc 8:32 active ready running

```

### Add the new drive to cluster to increase the storage

```text
pxctl service drive add --drive /dev/dm-1 --operation start
```

```output
Adding device  /dev/dm-1 ...
"Drive add done: Storage rebalance is in progress"
```

### Rebalance the storage pool

{{<info>}}
Pool rebalance is a must. It spreads data across all available drives in the pool.
{{</info>}}

Check the rebalance status and wait for completion:

```text
pxctl service drive add --drive /dev/dm-1 --operation status
```

```output
"Drive add: Storage rebalance running: 1 out of about 9 chunks balanced (2 considered),  89% left"
```

```text
pxctl service drive add --drive /dev/dm-1 --operation status
```

```output
"Drive add: Storage rebalance complete"
```

In case drive add operation did not start a rebalance, start it manually.
For e.g., if the drive was added to pool 0:

```text
pxctl service drive rebalance --poolID 0 --operation start
```

```output
Done: "Pool 0: Balance is running"
```

Check the rebalance status and wait for completion:

```text
pxctl service drive rebalance --poolID 0 --operation status
```

```output
Done: "Pool 0: Balance is not running"
```

### Check cluster status

As seen below, the 100G of additional capacity is available with total capacity of the cluster going to 620GB

```text
pxctl status
```

```output
Status: PX is operational
Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668
	IP: 147.75.104.185
 	Local Storage Pool: 1 pool
	Pool	IO_Priority	Size	Used	Status	Zone	Region
	0	LOW		100 GiB	1.0 GiB	Online	default	default
	Local Storage Devices: 1 device
	Device	Path				Media Type		Size	Last-Scan
	0:1	/dev/mapper/volume-a9e55549	STORAGE_MEDIUM_SSD	100 GiB08 Jan 17 21:46 UTC
	total					-			100 GiB
Cluster Summary
	Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
	Node IP: 10.99.119.1 - Capacity: 1.2 GiB/100 GiB Online
	Node IP: 147.75.198.197 - Capacity: 2.0 GiB/320 GiB Online
	Node IP: 147.75.104.185 - Capacity: 0 B/100 GiB Online (This node)
	Node IP: 10.99.117.129 - Capacity: 1.2 GiB/100 GiB Online
Global Storage Pool
	Total Used    	:  4.3 GiB
	Total Capacity	:  620 GiB
```
