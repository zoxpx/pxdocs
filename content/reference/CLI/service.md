---
title: Service operations using pxctl
linkTitle: Service
keywords: pxctl, command-line tool, cli, reference, service, troubleshooting, diagnostics, call-home, maintenance mode
description: How to use the pxctl service command.
weight: 16
---

The Portworx `pxctl` CLI tool allows you to run the following service operations:

- Perform a node audit
- Manage the call home feature
- Generate diagnostics package
- Get the version of the installed software
- Configure kvdb
- Place Portworx in maintenance mode
- Manage the physical storage drives

These commands are helpful when you want do debug issues related to your _Portworx_ cluster.

You can see an overview of the available service operations by running:

```text
/opt/pwx/bin/pxctl service --help
```

```output
NAME:
   pxctl service - Service mode utilities

USAGE:
   pxctl service command [command options] [arguments...]

COMMANDS:
     audit, a        Audit the PX node
     call-home       Enable or disable the call home feature
     diags, d        creates a new tgz package with minimal essential diagnostic information.
     drive           Storage drive maintenance
     email           Email setting commands
     exit, e         Stop the PX daemon
     info, i         Show PX module version information
     kvdb, k         PX Kvdb operations
     maintenance, m  Maintenance mode operations
     node-wipe, nw   Wipes PX configuration data on this node
     pool            Storage pool maintenance

OPTIONS:
   --help, -h  show help
```

## Perform a node audit

You can audit the node with:

```text
pxctl service audit
```

```output
AuditID		Error	Message
kvdb-limits	none	KV limits audit not yet available

kvdb-response	none	KV response audit not yet available
```

## Manage the call home feature

With `pxctl`, you can enable and disable the call home feature:

```text
pxctl service call-home enable
```

```output
Call home feature successfully enabled
```

If you want to disable this feature, just run:

```text
pxctl service call-home disable
```

```output
Call home feature successfully disabled
```

## Generate a complete diagnostics package

When there is an operational failure, you can use the `pxctl service diags <name-of-px-container>` command to generate a complete diagnostics package. This package will be automatically uploaded to Portworx if `--upload` is specified. Additionally, the service package can be mailed to Portworx at support@portworx.com. The package will be available at /var/cores/diags.tgz inside the Portworx container.

```text
pxctl service diags --help
```

```output
NAME:
   pxctl service diags - creates a new tgz package with minimal essential diagnostic information.

USAGE:
   pxctl service diags [command options] [arguments...]

OPTIONS:
   -l, --live                gets diags from running px
   -u, --upload              upload diags to cloud
   -p, --profile             only dump profile
   -a, --all                 creates a new tgz package with all the available diagnostic information.
   -c, --cluster             generate diags for all the nodes in the cluster.
   -f, --force               force overwrite existing diags.
   -o, --output string       output file name (default "/var/cores/diags.tar.gz")
       --dockerhost string   docker host daemon (default "unix:///var/run/docker.sock")
       --container string    PX container ID
   -n, --node string         generate diags for a specific remote node with the provided NodeIp or NodeID.
```

As an example, here's how to generate the diagnostics package for a container called `px-enterprise`:

```text
pxctl service diags --container px-enterprise
```

```output
PX container name provided:  px-enterprise
INFO[0000] Connected to Docker daemon.  unix:///var/run/docker.sock
Getting diags files...
Generated diags: /tmp/diags.tar.gz
```

## Get the version of the installed software

The following command displays the version of the installed software:

```text
pxctl service info
```

```output
PX (OCI) Version:  2.0.2.1-1d83ac2
PX (OCI) Build Version:  1d83ac2baeb27451222edcd543249dd2c2f941e4
PX Kernel Module Version:  72D3C244593F45167A6B49D
```

## Configure KVDB

You can configure the KVDB with the `pxctl service kvdb` command. To get an overview of the available subcommands, run:

```text
pxctl service kvdb --help
```

```output
NAME:
   pxctl service kvdb - PX Kvdb operations

USAGE:
   pxctl service kvdb [command options] [arguments...]

OPTIONS:
   endpoints    List the kvdb client endpoints
   members      List the kvdb cluster members
   restore      Restore keys and values into kvdb from a kvdb.dump file
```

## Place Portworx in maintenance mode

Use the `service maintenance` command to enter or exit maintenance mode. Once the node is in maintenance mode, you can add or replace drives, add memory, and so on.

To list the available subcommands, run the following:

```text
pxctl service maintenance --help
```

```output
NAME:
   pxctl service maintenance - Maintenance mode operations

USAGE:
   pxctl service maintenance [command options] [arguments...]

OPTIONS:
   -x, --exit   exit maintenance mode
   -e, --enter  enter maintenance mode
   -c, --cycle  cycle maintenance mode
```

Enter maintenance mode with:

```text
pxctl service maintenance --enter
```

```output
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y
```

Once you're done adding or replacing drives, or adding memory, you can exit maintenance mode by running:

```text
pxctl service maintenance --exit
```

## Manage the physical storage drives

You can manage the physical storage drives on a node using the `pxctl service drive` command:

```text
pxctl service drive --help
```

```output
NAME:
   pxctl service drive - Storage drive maintenance

USAGE:
   pxctl service drive command [command options] [arguments...]

COMMANDS:
     add            Add storage
     check          Check drives
     rebalance      Rebalance storage
     replace        Replace source drive with target drive
     show           Show drives

OPTIONS:
   --help, -h  show help
```

### Add a physical drive to a server

Use the `pxctl sv drive add` command to add a physical drive to a server. To see an overview of the available flags, run:

```text
pxctl sv drive add --help
```

```output
Add storage

Usage:
  pxctl service drive add [flags]

Flags:
      --journal            Use this drive as a journal device.
      --metadata           Use this drive as a system metadata device.
  -d, --drive string       comma-separated source drives
  -s, --spec string        Cloud drive spec in type=<>,size=<> format
  -o, --operation string   start|status (Valid Values: [start status]) (default "start")
  -h, --help               help for add

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

You can add physical drives to a server using the `pxctl service drive add` command. The following example shows how to add a physical drive:

```text
pxctl service drive add /dev/mapper/volume-3bfa72dd -o start
```

```output
Adding drives may make storage offline for the duration of the operation.
Are you sure you want to proceed ? (Y/N): y
Adding device  /dev/mapper/volume-3bfa72dd ...
Drive add  successful. Requires restart.
```
<!-- need to test this full operation to confirm the syntax -->

{{<info>}}
To add physical drives, you must place the server in [maintenance mode](#place-portworx-in-maintenance-mode) first.
{{</info>}}

To rebalance the storage across the drives, use the `pxctl service drive rebalance`. This is useful after prolonged operation of a node.

## Display drive information

You can use the `pxctl service drive show` command to display drive information on the server:

```text
pxctl service drive show
```

```output
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 100 GiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/mapper/volume-e85a42ca, 1.0 GiB allocated of 100 GiB, Online
```
<!-- need example output that includes caching -->

## Configure the email settings for alerts

You can use the `pxctl service email` command to list the available subcommands:

```text
pxctl service email
```

```output
NAME:
   pxctl service email

USAGE:
   pxctl service email command [command options] [arguments...]

COMMANDS:
     clear     Clear email settings for alerts.
     set       Configure email settings for alerts.
```

## Scan for bad blocks

You can use `pxctl service scan` to scan for bad blocks on a drive:

```text
pxctl service scan
```

```output
NAME:
   pxctl service scan - scan for bad blocks

USAGE:
   pxctl service scan command [command options] [arguments...]

COMMANDS:
     cancel    cancel running scan
     pause     pause running scan
     resume    resume paused scan
     schedule  examine or set schedule
     start     start scan
     status    scan status

```

## Delete all Portworx related data

With `pxctl service node-wipe`, you can delete all data related to Portworx from the node. It will also wipe the storage device that was provided to Portworx. This command can be run only when Portworx is stopped on the node. Run this command if a node needs to be re-initialized.

{{<info>}}
This is a disruptive command and could lead to data loss. Please use caution.
{{</info>}}

```text
pxctl service node-wipe --help
```

```output
NAME:
   pxctl service node-wipe - Wipes PX configuration data on this node

USAGE:
   pxctl service node-wipe [command options] [arguments...]

OPTIONS:
   --storage_devices value, -s value  comma-separated list of storage devices to be wiped.

```

Here is an example:

```text
pxctl service node-wipe
```

```output
This is a distruptive operation.
It will delete all PX configuration files from this node. Data on the storage disks attached on this node will be irrevocably deleted.
Are you sure you want to proceed ? (Y/N): y
This is a distruptive operation.
It will delete all PX configuration files from this node. Data on the storage disks attached on this node will be irrevocably deleted.
Failed to set pxd timeout. Wipe command might take more time to finish.
Are you sure you want to wipe data from the disk: ' /dev/sdb ' (Y/N): y
/dev/sdb: 8 bytes were erased at offset 0x00010040 (btrfs): 5f 42 48 52 66 53 5f 4d
Removed PX footprint from device /dev/sdb.
Wiped node successfully.
```

## Perform pool maintenance tasks

The `pxctl service pool` command allows you to run the following pool maintenance related tasks:

- list the available pools
- update the properties of a pool

You can list the available subcommands with:

```text
pxctl service pool
```

```output
NAME:
   pxctl service pool - Storage pool maintenance

USAGE:
   pxctl service pool command [command options] [arguments...]

COMMANDS:
   show      Show pools
   update    Update pool properties
```

## Update pool properties

You can use the `pxctl service pool update` command to perform the following operations:

- Resize a pool
- Set the IO priority
- Add labels

To see the list of the available subcommands, run:

```text
pxctl service pool update --help
```

```output
Update pool properties

Usage:
  pxctl service pool update [flags]

Flags:
      --resize               extend pool to maximum available physical storage
      --io_priority string   IO Priority (Valid Values: [high medium low]) (default "low")
      --labels string        comma separated name=value pairs (default "NoLabel")
  -h, --help                 help for update
```

#### Understand the --labels flag behavior

The `--labels` flag allows you to add, remove, and update labels for your storage pools.

##### Add a new label

Enter the `pxctl service pool update` command with the pool ID and the `--labels` flag with a comma separated list of labels you wish to add:

```text
pxctl service pool update 0 --labels  ioprofile=HIGH,media_type=SSD
```

##### Replace a label's value

Enter the `pxctl service pool update` command with the pool ID and the `--labels` flag with a comma separated list of the labels you wish to replace:

```text
pxctl service pool update 0 --labels  media_type=NVME
```

Updating a single label does not affect the other labels' stored values.

##### Delete a label's value

Enter the `pxctl service pool update` command with the pool ID and the `--labels` flag with a comma separated list of the labels you wish to delete containing no value:

```text
pxctl service pool update 0 --labels  ioprofile=,media_type=
```

### pxctl service pool show

Show storage pool information

```text
pxctl service pool show
```

```output
PX drive configuration:
Pool ID: 0
        IO Priority:  LOW
        Labels:
        Size: 5.5 TiB
        Status: Online
        Has metadata:  No
        Drives:
        0: /dev/sdb, 2.7 TiB allocated of 2.7 TiB, Online
        1: /dev/sdc, 2.7 TiB allocated of 2.7 TiB, Online
        Cache Drives:
        0:0: /dev/nvme0n1, capacity of 745 GiB, Online
                Status:  Active
                TotalBlocks:  762536
                UsedBlocks:  12
                DirtyBlocks:  0
                ReadHits:  487
                ReadMisses:  42
                WriteHits:  1134
                WriteMisses:  7
                BlockSize:  1048576
                Mode:  writethrough
Journal Device:
        1: /dev/sdg1, STORAGE_MEDIUM_MAGNETIC
Metadata  Device:
        1: /dev/sdg2, STORAGE_MEDIUM_MAGNETIC
```

### pxctl service pool cache

You can use the `pxct service pool cache command` command to:

* Disable caching on a pool
* Enable caching on a pool
* Force the cache to be flushed
* Check if pool caching is enabled for a pool

Refer to the [Pool caching](/concepts/pool-caching) section for more details.

### pxctl service pool delete

You can use the `pxctl service pool delete` command to delete storage pools which may be misconfigured or otherwise not functioning properly.

```text
pxctl service pool delete --help
```
```output
Delete pool
Usage:
  pxctl service pool delete [flags]
Flags:
  -h, --help   help for delete
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

Before you remove a pool, consider the following requirements:

* Your target pool for deletion must be empty and contain no replicas
* If your target pool for deletion is a metadata pool, it must be readable
* You must have more pools on the node than just your target pool for deletion
* You must place your node in maintenance mode to use this command

The following example deletes a storage pool from a node containing 2 storage pools:

```text
pxctl service pool delete 0
```
```output
This will permanently remove storage pool and cannot be undone.
Are you sure you want to proceed ? (Y/N): y
Pool 0 DELETED.
```

{{<info>}}
**NOTE:** New pools created after a pool deletion increment from the last pool ID. A new pool created after this example would have a pool ID of 2
{{</info>}}  
