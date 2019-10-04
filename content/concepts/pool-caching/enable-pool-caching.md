---
title: Enable pool caching
keywords: storage pool, pool caching, px-cache
description:
weight: 100
hidden: true
---

## Prerequisites

Before you can enable pool caching, you must have a storage pool with caching configured but currently disabled.

You can use the following commands to check if caching is disabled:

1. Run the `pxctl status` command the get the id of your pool:

	```text
	pxctl status
	```

	```output
	Status: PX is operational
	License: Trial (expires in 29 days)
	Node ID: abb4723e-efa3-432d-ad27-f929bc658862
		IP: 70.0.79.28
		Local Storage Pool: 1 pool
		POOL	IO_PRIORITY	RAID_LEVEL	USABLE	USED	STATUS	ZONE	REGION
		0	HIGH		raid0		128 GiB	8.4 GiB	Online	default	default
		Local Storage Devices: 2 devices
		Device	Path		Media Type		Size		Last-Scan
		0:0	/dev/sdf	STORAGE_MEDIUM_MAGNETIC	128 GiB		22 Sep 19 14:48 UTC
		total			-			128 GiB
		Cache Devices:
		Device	Path		Media Type		Size		Last-Scan
		0:1	/dev/sdc	STORAGE_MEDIUM_SSD	70 GiB		22 Sep 19 14:48 UTC
	Cluster Summary
		Cluster ID: doc-cluster-caching-2.2.0
		Cluster UUID: e5d79039-1333-4ac9-adf4-70019d925a4a
		Scheduler: none
		Nodes: 3 node(s) with storage (3 online)
		IP		ID					SchedulerNodeName	StorageNode	UseCapacity	Status	StorageStatus	Version		Kernel				OS
		70.0.79.28	abb4723e-efa3-432d-ad27-f929bc658862	N/A			Yes		8.4 GiB	128 GiB		Online	Up (This node)	2.2.0.0-328a043	4.20.13-1.el7.elrepo.x86_64	CentOS Linux 7 (Core)
		70.0.78.240	9ddf713b-0dbc-4e7b-bd6e-2ae648891072	N/A			Yes		8.4 GiB	128 GiB		Online	Up		2.2.0.0-328a043	4.20.13-1.el7.elrepo.x86_64	CentOS Linux 7 (Core)
		70.0.79.32	0e466c6a-fef0-4752-b133-9bf257e9973a	N/A			Yes		8.4 GiB	128 GiB		Online	Up		2.2.0.0-328a043	4.20.13-1.el7.elrepo.x86_64	CentOS Linux 7 (Core)
	Global Storage Pool
		Total Used    	:  25 GiB
		Total Capacity	:  384 GiB
	```

2. Run the `pxctl service pool cache status` command with the id of your storage pool as a parameter:

	```text
	pxctl service pool cache status 0
	```

	```output
	PX Cache Configuration and Status:
	Pool ID:  0
		Enabled:  false
		Members:  [/dev/sdc]
		TotalBlocks: 0
		UsedBlocks: 0
		DirtyBlocks: 0
		ReadHits: 0
		ReadMisses: 0
		WriteHits: 0
		WriteMisses: 0
		BlockSize: 1048576
		Mode: writeback
		Policy: smq
		Tunables: migration_threshold=20480
	```


## Enable pool caching

1. Enter maintenance mode:

	```text
	pxctl service maintenance --enter
	```
	```output
	This is a disruptive operation, PX will restart in maintenance mode.
	Are you sure you want to proceed ? (Y/N): y
	Entering Maintenance mode...
	```


2.  Enter the `pxctl service pool cache enable` command, specifying the `<pool_id>` of the pool you want to disable caching for:

    `pxctl service pool cache enable <pool_id>`

    The following example enables caching for a pool with an ID of `0`:

    ```text
    pxctl service pool cache enable 0
    ```

    ```output
    Pool 0 attached cache successfully
    ```

3. Exit maintenance mode:

	```text
	pxctl service maintenance --exit
	```

4. At this point you can run the `pxctl service pool cache status` command to see if caching is enabled:

	```text
	PX Cache Configuration and Status:
	Pool ID:  0
		Enabled:  true
		Members:  [/dev/sdc]
		TotalBlocks: 71660
		UsedBlocks: 10
		DirtyBlocks: 6
		ReadHits: 13
		ReadMisses: 10
		WriteHits: 14
		WriteMisses: 8
		BlockSize: 1048576
		Mode: writeback
		Policy: smq
		Tunables: migration_threshold=20480
	```
