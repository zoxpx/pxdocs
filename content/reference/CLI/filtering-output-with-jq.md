---
title: Filtering pxctl output with jq
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, monitoring, prometheus, alertmanager, servicemonitor, grafana, lighthouse, px-central, px-kvdb, jq
description: Find out how to filter pxctl output using jq
---

The `pxctl` command line output displays a limited amount of information based on the context of the subcommand.

You can view all available output information using the `-j` option, which supplies the full output in JSON. To improve the output, you can further parse the JSON inline using the [jq command-line processor](https://stedolan.github.io/jq/). Using jq, you can filter the output to display only the information you want, which might not be available on the standard command line output, or would be difficult to find in the full JSON output.

This document provides instructions and examples for filtering pxctl's JSON output using jq for the following common use cases:

* List volumes which have a replica on a node
* List the nodes on which a volume is replicated
* List volumes with HA-Level 1
* List volumes which have a running HA-increase operation on a node
* List pools with SSD labels

## Find your node ID

In this document, you'll perform all of your filtering at the node level, and so you must retrieve the node ID for the node you want to inspect.

Retrieve your node names by entering the `pxctl cluster provision-status` command:

```text
pxctl cluster provision-status
```

The cluster in this example comprises 3 worker nodes:

```output
NODE					NODE STATUS	POOL	POOL STATUS	IO_PRIORITY	SIZE	AVAILABLE	USED	PROVISIONED	RESERVEFACTOR	ZONE	REGION	RACK
598b4c37-459f-45f6-9fbe-14ea0fdd31df	Up		0	Online		LOW		30 GiB	26 GiB		3.5 GiB	7.0 GiB		0		default	default	default
9a58c096-5085-4e9f-8094-8f341ebaab7a	Up		0	Online 		LOW		3.0 TiB	3.0 TiB		10 GiB	1.0 GiB		0		default	default	default
4397b1d4-652a-4081-bdb6-994ce0e649d6	Up		0	Online		LOW		3.0 TiB	3.0 TiB		10 GiB	1.0 GiB		0		default	default	default
```

The examples in this document use the first node: `598b4c37-459f-45f6-9fbe-14ea0fdd31df`

## List volumes which have a replica on a node

You can see information about volumes that have a replica on a given node. This is useful if you want to do node maintenance and you want to know ahead of time which volumes would be affected.

Enter the following `pxctl volume list` command, specifying your own node ID, to list all volumes with a replica on that node:

```text
pxctl --json volume list | jq '.[] | select(.replica_sets[].nodes | tostring | contains("598b4c37-459f-45f6-9fbe-14ea0fdd31df"))'
```
```output
{
  "id": "441341669046881893",
  "source": {
    "parent": "",
    "seed": ""
  },
  "readonly": false,
  "locator": {
    "name": "pvc-ffcbbb12-d369-11e9-8d47-000c29cceb36",
    "volume_labels": {
      "namespace": "default",
      "pvc": "postgres-data",
      "repl": "2"
    }
  },
  "ctime": "2019-09-10T21:16:12Z",
  "spec": {
    "ephemeral": false,
    "size": "1073741824",
    "format": "ext4",
    "block_size": "4096",
    "ha_level": "2",
    "cos": "high",
    "io_profile": "sequential",
    "dedupe": false,
    "snapshot_interval": 0,
    "volume_labels": {
      "namespace": "default",
      "pvc": "postgres-data",
      "repl": "2"
    },
    "shared": false,
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
    "sharedv4": false,
    "queue_depth": 128,
    "force_unsupported_fs_type": false,
    "nodiscard": false,
    "storage_policy": ""
  },
  "usage": "0",
  "last_scan": "2019-09-10T21:16:12Z",
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
        "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
        "4397b1d4-652a-4081-bdb6-994ce0e649d6"
      ]
    }
  ],
  "runtime_state": [
    {
      "runtime_state": {
        "ID": "0",
        "PXReplReAddNodeMid": "",
        "PXReplReAddPools": "",
        "ReplNodePools": "0,0",
        "ReplRemoveMids": "",
        "ReplicaSetCreateMid": "598b4c37-459f-45f6-9fbe-14ea0fdd31df,4397b1d4-652a-4081-bdb6-994ce0e649d6",
        "ReplicaSetCurr": "[0 1]",
        "ReplicaSetCurrMid": "598b4c37-459f-45f6-9fbe-14ea0fdd31df,4397b1d4-652a-4081-bdb6-994ce0e649d6",
        "RuntimeState": "clean"
      }
    }
  ],
  "error": "",
  "fs_resize_required": false
}
```

## List the nodes on which a volume is replicated

You can use `jq` to query for the nodes on which a volume is replicated. This is useful if you need to perform maintenance on your cluster and want to make sure at least one replica of the volume is available during this operation.

To list the nodes on which a volume is replicated, enter the following `pxctl volume inspect` command, specifying the name of your volume, and pipe the output through `jq`:

```text
pxctl --json volume inspect v1 | jq  '.[] | .id, .replica_sets[].nodes'
```

```output
"387822627247234229"
[
  "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
  "9a58c096-5085-4e9f-8094-8f341ebaab7a"
]
```

In our example, the id of the `v1` volume is `387822627247234229` and the following nodes hold a replica of the `v1` volume - `598b4c37-459f-45f6-9fbe-14ea0fdd31df` and `9a58c096-5085-4e9f-8094-8f341ebaab7a`.

## List volumes with HA-Level 1

Consider the following scenario: you have a new company policy that no users should run unreplicated volumes. Since this is a new policy, your users have been creating volumes that have a mixture of HA-levels: some of only 1, some of 2. You don't know what volumes these are, and you need to make sure there are no volumes that are none with an HA-level of 1. You want to show the volume ID for any volume with an HA-level of 1.

Enter the following `pxctl volume list` command, specifying your own node ID, to list all volumes attached to that node:

```text
pxctl --json volume list | jq '.[] | select(.spec.ha_level == "1") | .id '
```
```output
"691032050799382541"
"805235027212928385"
"201039385825583139"
"561319682036807475"
"717554070245575305"
"84742544577966432"
```

## List volumes which have a running HA-increase operation on a node

Consider the following scenario: your cluster, containing 2 nodes, experiences a node failure while an HA-increase operation is running. If a node is offline, the ha-increase operation will not progress. You can use jq to display which volumes on your node have a running ha-increase operation in order to take corrective action.

Enter the following `pxctl volume list` command, specifying your own node ID, to list all volumes attached to that node with a running ha-increase operation:

```text
pxctl --json volume list | jq '.[] | select(.runtime_state[].runtime_state | select(.ReplNewNodeMid == "9a58c096-5085-4e9f-8094-8f341ebaab7a")) '
```
```output
{
  "id": "313310790209155406",
  "source": {
    "parent": "",
    "seed": ""
  },
  "readonly": false,
  "locator": {
    "name": "x1"
  },
  "ctime": "2019-09-23T17:33:49Z",
  "spec": {
    "ephemeral": false,
    "size": "1073741824",
    "format": "ext4",
    "block_size": "4096",
    "ha_level": "1",
    "cos": "low",
    "io_profile": "sequential",
    "dedupe": false,
    "snapshot_interval": 0,
    "shared": false,
    "replica_set": {},
    "aggregation_level": 1,
    "encrypted": false,
    "passphrase": "",
    "snapshot_schedule": "",
    "scale": 1,
    "sticky": false,
    "group_enforced": false,
    "compressed": false,
    "cascaded": false,
    "journal": false,
    "sharedv4": false,
    "queue_depth": 128,
    "force_unsupported_fs_type": true,
    "nodiscard": false,
    "io_strategy": {
      "async_io": false,
      "early_ack": false
    },
    "storage_policy": ""
  },
  "usage": "348160",
  "last_scan": "2019-09-23T17:33:49Z",
  "format": "ext4",
  "status": "up",
  "state": "attached",
  "attached_on": "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
  "attached_state": "ATTACH_STATE_EXTERNAL",
  "device_path": "/dev/pxd/pxd313310790209155406",
  "secure_device_path": "",
  "replica_sets": [
    {
      "nodes": [
        "598b4c37-459f-45f6-9fbe-14ea0fdd31df"
      ]
    }
  ],
  "runtime_state": [
    {
      "runtime_state": {
        "FullResyncBlocks": "[{0 0} {-1 0} {-1 0} {-1 0} {-1 0}]",
        "ID": "0",
        "PXReplReAddNodeMid": "",
        "PXReplReAddPools": "",
        "ReadQuorum": "1",
        "ReadSet": "[0]",
        "ReplNewNodeMid": "9a58c096-5085-4e9f-8094-8f341ebaab7a",
        "ReplNewNodePools": "0",
        "ReplNodePools": "0",
        "ReplRemoveMids": "",
        "ReplicaSetCreateMid": "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
        "ReplicaSetCurr": "[0]",
        "ReplicaSetCurrMid": "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
        "ReplicaSetNext": "[0]",
        "ReplicaSetNextMid": "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
        "ResyncBlocks": "[{0 0} {-1 0} {-1 0} {-1 0} {-1 0}]",
        "RuntimeState": "resync",
        "TimestampBlocksPerNode": "[0 0 0 0 0]",
        "TimestampBlocksTotal": "0",
        "WriteQuorum": "1",
        "WriteSet": "[0]"
      }
    }
  ],
  "error": "",
  "fs_resize_required": false
}
root@70-0-39-241:/home/ub# /opt/pwx/bin/pxctl volume inspect x1
Volume	:  313310790209155406
	Name            	 :  x1
	Size            	 :  1.0 GiB
	Format          	 :  ext4
	HA              	 :  1
	IO Priority     	 :  LOW
	Creation time   	 :  Sep 23 17:33:49 UTC 2019
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: 598b4c37-459f-45f6-9fbe-14ea0fdd31df (70.0.71.214)
	Device Path     	 :  /dev/pxd/pxd313310790209155406
	Reads           	 :  26
	Reads MS        	 :  4
	Bytes Read      	 :  327680
	Writes          	 :  0
	Writes MS       	 :  0
	Bytes Written   	 :  0
	IOs in progress 	 :  0
	Bytes used      	 :  340 KiB
	Replica sets on nodes:
		Set 0
		  Node 		 : 70.0.71.214 (Pool 0)
		  HA-Increase on : 70.0.39.118 (Pool 0)
	Replication Status	 :  Resync
```

## List pools with SSD labels

In many clusters, different nodes have pools with a unique collection of drive types. In sufficiently large clusters, this may even be hundreds of pools. You may have trouble keeping track of the available pools and their properties. You can use jq to query for the available pools on a node with a certain label. This helps you find pools that meet your application requirements. This example queries for pools using SSD storage media.

Enter the following `pxctl cluster provision-status` command, specifying your own node ID, to list all pools using SSDs in the cluster:

```text
pxctl --json cluster provision-status | jq '.provisionInfo | to_entries | .[] | select(.value.Provision[].Pool.labels.ssd == "true")'
```

In this example, the node contains a single pool with SSD storage.

```output
{
  "key": "598b4c37-459f-45f6-9fbe-14ea0fdd31df",
  "value": {
    "Status": "Up",
    "Geo": {
      "Provider": "local",
      "Region": "default",
      "Zone": "default",
      "Datacenter": "default",
      "Row": "default",
      "Rack": "default",
      "Chassis": "default",
      "Hypervisor": "default",
      "Node": "default"
    },
    "Provision": [
      {
        "Pool": {
          "Cos": 1,
          "RaidLevel": "raid0",
          "labels": {
            "iopriority": "LOW",
            "medium": "STORAGE_MEDIUM_MAGNETIC",
            "ssd": "true"
          },
          "CosAdmin": 1,
          "Info": {
            "Resources": {
              "1": {
                "id": "1",
                "path": "/dev/sdb",
                "online": true,
                "seq_write": 1538000,
                "size": 32212254720,
                "used": 4316442132,
                "rotation_speed": "Unknown",
                "last_scan": {
                  "seconds": 1569261247,
                  "nanos": 897671019
                }
              }
            },
            "ResourcesLastScan": "Resources Scan OK",
            "ResourcesCount": 1,
            "ResourceUUID": "9cfba43e-aeec-4da7-acb6-a44883265537",
            "ResourceJournal": {},
            "ResourceJournalUUID": "",
            "ResourceSystemMetadata": {},
            "ResourceSystemMetadataUUID": "",
            "ReadThroughput": 0,
            "WriteThroughput": 1538000,
            "Random4KIops": 0,
            "Status": "Up",
            "TotalSize": 32212254720,
            "Used": 4316442132,
            "LastError": "",
            "Cache": {
              "Pool": 0,
              "Members": null,
              "Enabled": false,
              "CacheTotalBlocks": 0,
              "CacheUsedBlocks": 0,
              "CacheDirtyBlocks": 0,
              "CacheReadHits": 0,
              "CacheReadMisses": 0,
              "CacheWriteHits": 0,
              "CacheWriteMisses": 0,
              "CacheChunkSize": 0,
              "Cachemode": "",
              "CachePolicy": "",
              "CacheSettings": ""
            }
          },
          "Status": "Up",
          "ReserveFactor": 0,
          "SnapReserveFactor": 0
        },
        "ProvisionedSpace": 7516192768
      }
    ]
  }
}
```
