---
title: Internal Kvdb
description: Explanation on internal kvdb used by Portworx
keywords: portworx, kvdb
weight: 300
series: concepts
---

From version 2.0, Portworx can be installed with built-in internal kvdb. It removes the requirement of an external kvdb such as etcd or consul to be installed along side of Portworx. This document explains the different concepts associated with Portworx's internal kvdb.

## Setup

Portworx when installed with appropriate arguments, will automatically deploy an internal kvdb cluster on a set of 3 nodes within the Portworx cluster. Based on your scheduler provide the appropriate input argument to setup Portworx with internal kvdb

#### Kubernetes

On the Portworx [install](https://install.portworx.com/2.1) page, under the ETCD section select the **Built-in** option to deploy Portworx with internal kvdb.

#### Mesos (DCOS)

While deploying the Portworx framework provide the `-b` argument in the extra arguments section.

#### Other schedulers

For all other schedulers, Portworx requires an external etcd or consul, to bootstrap its internal kvdb. Portworx will use this external etcd or consul, to discover its own internal kvdb nodes. While installing Portworx provide the `-b` argument to instruct Portworx to setup internal kvdb. Along with `-b`, provide the `-k` argument with a list of external etcd or consul endpoints.


## Storage for internal kvdb

Internal kvdb metadata needs to be stored on a persistent disk. There are two ways in which internal kvdb can store this data

### Metadata Drive (Recommended)
Provide a separate drive to Portworx nodes through the `-metadata` argument.

This metadata drive will be used for storing  internal kvdb data as well as Portworx metadata such as journal or timestamp data.


{{<info>}}
The metadata drive needs to be at least 64Gi in size
{{</info>}}

This is the recommended method as the disk IO for internal kvdb is not shared with PX volume IO.

### Auto (Not recommended)
If a metadata drive is not provided Portworx will reserve some space in the same storage pool which is used for storing your volume data.

This method is not recommended as the disk will be shared between internal kvdb IO and Portworx volume IO causing degraded internal kvdb performance.

## Designating internal kvdb nodes (Only Kubernetes)

If your scheduler is kubernetes you can designate a set of nodes to run internal kvdb. Only those nodes which have the label `px/metadata-node=true` will be a part of the internal kvdb cluster.

Use the following command to label nodes in kubernetes

```text
kubectl label nodes <list of node-names> px/metadata-node=true
```

Depending upon the labels and their values a decision will be made

- If a node is labeled px/metadata-node=true then it will be a part of the internal kvdb cluster
- If node is labeled px/metadata-node=false then it will NOT be a part of the internal kvdb cluster
- If no node labels are found then all the nodes are potential metadata nodes.
- If an incorrect label is present on the node like px/metadata-node=blah then PX will not start on that node.
- If no node is labelled as px/metadata-node=true , but one node is labeled as px/metadata-node=false then that node will never be a part of kvdb cluster, but rest of the nodes are potential metadata nodes.

## Kvdb Node Failover

If a Portworx node which was a part of the internal kvdb cluster goes down for more than 3 minutes, then any other available storage nodes which are not part of the kvdb cluster will try to join it.

This are a set of actions that are taken on the node which tries to join the kvdb cluster

- The down member is removed from the internal kvdb cluster. (Note: The node will be still part of the Portworx cluster)
- Internal kvdb is started on the new node
- The new node adds itself to the internal kvdb cluster

The node label logic holds true even during failover, so if a node has a label set to false, then it will not try to join the kvdb cluster.

If the offline node comes back up, it will NOT rejoin the internal kvdb cluster, once another node replaces it.

{{<info>}}
Only storage nodes are a part of internal kvdb cluster.
{{</info>}}


## Backup

Portworx takes regular backup of its key value space and dumps it into a file on the host.
These internal kvdb backups are taken every 2 minutes and are dumped under the `/var/cores` directory on all the nodes. At a time only 10 backups are kept. These backups are also kept inside the storage drive provided for internal kvdb.

A typical backup file will look like this

```text
ls /var/cores/kvdb_backup
pwx_kvdb_schedule_153664_2019-02-06T22:30:39-08:00.dump
```

These backup files, can be used for recovering the internal kvdb cluster in case of a disaster.

## Recovery

In an event of a cluster failure such as:

- All the internal kvdb nodes and their corresponding drives where their data resides are lost and are unrecoverable
- Quorum no. of internal kvdb nodes are lost and are unrecoverable.

Portworx can recover its internal kvdb cluster from one of the backup files that are dumped on each of the nodes.

Follow these steps to recover.

### Step 1: Identify the latest and golden kvdb backup file

A timestamp is associated with each internal kvdb backup that is taken. Choose one latest backup file from all of the nodes. 

### Step 2: Rename the backup file

On the node where the latest backup exists, rename the backup file to `pwx_kvdb_disaster_recovery_golden.dump`.

```text
cp /var/cores/kvdb_backup/pwx_kvdb_schedule_153664_2019-02-06T22:30:39-08:00.dump /var/cores/kvdb_backup/pwx_kvdb_disaster_recovery_golden.dump
```

### Step 3: Restart Portworx

On the node where the golden dump exists, restart Portworx service.

Portworx will be able to recover the internal kvdb cluster from the golden dump only if

- Nodes from the existing (old) internal kvdb cluster are **NOT** healthy.
- There is only one node with the file `pwx_kvdb_disaster_recovery_golden.dump`

As soon as this node recovers the internal kvdb cluster, all other Portworx nodes will start coming back up one by one.




