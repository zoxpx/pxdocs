---
title: "Maintenance Commands"
hidden: true
keywords: service, maintenance, drive removal, drive replacement, pool list, pool priority
description: Explore commands needed for maintenance operations using Portworx.  Try today!
---

Service level commands are related to maintenance of drives and drive pools.
The most common cases would be for Disk addition/replacement

Here are some of the commands that are needed for maintenance operations

## Some general maintenance commands

### Enter Maintenance Mode

Run the following command:

```text
pxctl service maintenance --enter
```

This takes Portworx out of an "Operational" state for a given node.  Perform whatever physical maintenance is needed.

### Restart Portworx
Run **"docker restart px-enterprise"**.
This restarts the Portworx fabric on a given node.

### Exit Maintenance Mode
Run `pxctl service maintenance --exit`.
This puts Portworx back in to "Operational" state for a given node.

### Drive management example

The drive management commands are organized under `pxctl service drive` command

```text
pxctl service drive
```

```output
NAME:
   pxctl service drive - Storage drive maintenance

USAGE:
   pxctl service drive command [command options] [arguments...]

COMMANDS:
     show           Show drives
     add            Add storage
     replace        Replace source drive with target drive
     rebalance, rs  Rebalance storage

OPTIONS:
   --help, -h  show help
```

Here is a typical workflow on how to identify and replace drives.

## Show the list of drives in the system

```text
pxctl service drive show
```

```output
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 7.3 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sde, 3.0 GiB allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

## Add drives to the cluster

### Step 1: Enter Maintenance Mode

```text
pxctl service  maintenance --enter
```

```output
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
Entering maintenance mode...
```

### Step 2: Add drive to the system

For e.g., Add drive /dev/sdb to PX cluster

```text
pxctl service drive add --drive /dev/sdb --operation start
```

```output
Adding device  /dev/sdb ...
"Drive add done: Storage rebalance is in progress"
```

### Step 3: Rebalance the storage pool

**Pool rebalance is a must. It spreads data across all available drives in the pool.**

Check the rebalance status and wait for completion.

```text
pxctl sv drive add --drive /dev/sdb --operation status
```

```output
"Drive add: Storage rebalance running: 1 out of about 9 chunks balanced (2 considered),  89% left"
```

```text
pxctl sv drive add --drive /dev/sdb --operation status
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

Check the rebalance status and wait for completion.

```text
pxctl service drive rebalance --poolID 0 --operation status
```

```output
Done: "Pool 0: Balance is not running"
```

### Step 4: Exit Maintenance mode

```text
pxctl service  maintenance --exit
```

```output
Exiting maintenance mode...
```

Check if the drive is added using drive show command:

```text
pxctl service drive show
```

```output
PX drive configuration:

Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
	1: /dev/sde, 3.0 GiB allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

## Replace a drive that is already part of the Portworx Cluster

### Step 1: Enter Maintenance mode

```text
pxctl service  maintenance --enter
```

```output
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
Entering maintenance mode...
```

### Step 2: Replace old drive with a new drive

Ensure the replacement drive is already available in the system.

For e.g., Replace drive /dev/sde with /dev/sdc

```text
pxctl service drive replace --source /dev/sde --target /dev/sdc --operation start
```

```output
"Replace operation is in progress"
```

Check the replace status

```text
pxctl service drive replace --source /dev/sde --target /dev/sdc --operation status
```

```output
"Started on 16.Dec 22:17:06, finished on 16.Dec 22:17:06, 0 write errs, 0 uncorr. read errs\n"
```

### Step 3: Exit Maintenance mode

```text
pxctl service  maintenance --exit
```

```output
Exiting maintenance mode...
```

### Step 4: Check if the drive has been successfully replaced

```text
pxctl service drive show
```

```output
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sdc, 3.0 GiB allocated of 7.3 TiB, Online
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

## Storage pool maintenance
Storage pools are automatically created by selected like disks in terms of capacity and capability. These pools are classified as High/Medium/Low based on IOPS and latency.

Help for storage pool commands is available as:

```text
pxctl service pool -h
```

```output
NAME:
   pxctl service pool - Storage pool maintenance

USAGE:
   pxctl service pool command [command options] [arguments...]

COMMANDS:
     show    Show pools
     update  Update pool properties

OPTIONS:
   --help, -h  show help
```

### List Storage pools

This is an alias for /opt/pwx/bin/pxctl service drive show

```text
pxctl service pool show
```

```output
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sdc, 3.0 GiB allocated of 7.3 TiB, Online
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```

### Update Storage pool

```text
pxctl service update -h
```

```output
NAME:
   pxctl service pool update - Update pool properties

USAGE:
   pxctl service pool update [command options] poolID

OPTIONS:
   --io_priority value  io_priority: low|medium|high
   --labels value       comma separated name=value pairs (default: "NoLabel")
   --resize             extend pool to maximum available physical storage
```

During create each pool is benchmarked and assigned an io_prioriy classification automatically - high/medium/low. However, sometimes it is desirable for the operator to explicity designate a classification.
To update pool 0 priority classification to 'MEDIUM'

```text
pxctl service pool update 0 --io_priority medium
```

```output
Pool properties updated
```

A pool can also be resized (extended) if the underlying physical storage (drive/partition/volumes) get resized. It can be extended to use all available physical storage.
To resize pool 0

### Step 1: Enter Maintenance mode

```text
pxctl service  maintenance --enter
```

```output
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
Entering maintenance mode...
```

### Step 2: Resize drive(s)

Use appropriate utility - fdisk, lvresize, aws cli etc. to resize the drive. If the pool is backed by more than one drive, each drive in the pool needs to be resized first before the pool can be resized.

### Step 3: Resize pool

```text
pxctl service pool update 0 --resize
```

```output
Pool properties updated
```

### Step 3: Exit Maintenance mode

```text
pxctl service  maintenance --exit
```

```output
Exiting maintenance mode...
```
