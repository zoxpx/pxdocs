---
title: Internal KVDB
description: Explanation on internal KVDB used by Portworx
keywords: internal KVDB, built-in KVDB, Kubernetes, k8s, Mesos, DCOS, DC/OS, help, how to, explanation
weight: 300
series: concepts
---

Starting with version 2.0, you can install Portworx with a built-in internal KVDB. Portworx automatically deploys the internal KVDB cluster on a set of three nodes in your cluster and removes the requirement for an external KVDB such as etcd or Consul.

## Install

To install Portworx with a built-in internal KVDB, follow the instructions in the next sections, depending on your environment.


#### Kubernetes

On the Portworx spec generator page in [PX-Central](https://central.portworx.com), under the ETCD section select the **Built-in** option to deploy Portworx with internal KVDB.

#### Mesos (DCOS)

While deploying the Portworx framework, provide the `-b` argument in the extra arguments section.

#### Other schedulers

For all other schedulers, Portworx requires an external etcd or consul, to bootstrap its internal KVDB. Portworx will use this external etcd or consul, to discover its own internal KVDB nodes. While installing Portworx provide the `-b` argument to instruct Portworx to setup internal KVDB. Along with `-b`, provide the `-k` argument with a list of external etcd or consul endpoints.


## Storage for internal KVDB

Internal KVDB metadata needs to be stored on a persistent disk. There are two ways in which internal KVDB can store this data

### Metadata Drive (Recommended)

Provide a separate drive to Portworx nodes through the `-metadata` argument.

This metadata drive will be used for storing  internal KVDB data as well as Portworx metadata such as journal or timestamp data.


{{<info>}}
The metadata drive needs to be at least 64Gi in size
{{</info>}}

This is the recommended method as the disk IO for internal KVDB is not shared with Portworx volume IO.

### Auto (Not recommended)

If a metadata drive is not provided Portworx will reserve some space in the same storage pool which is used for storing your volume data.

This method is not recommended as the disk will be shared between internal KVDB IO and Portworx volume IO causing degraded internal KVDB performance.

{{<info>}}
**NOTE:** If you do not specify the `-metadata` argument, cloud deployments require a 150GB SSD disk for the internal KVDB.
{{</info>}}

## Designating internal KVDB nodes (Only Kubernetes)

If your scheduler is kubernetes, you can designate a set of nodes to run internal KVDB. Only those nodes which have the label `px/metadata-node=true` will be a part of the internal KVDB cluster.

Use the following command to label nodes in kubernetes

```text
kubectl label nodes <list of node-names> px/metadata-node=true
```

Depending upon the labels and their values a decision will be made

- If a node is labeled px/metadata-node=true then it will be a part of the internal KVDB cluster
- If node is labeled px/metadata-node=false then it will NOT be a part of the internal KVDB cluster
- If no node labels are found then all the nodes are potential metadata nodes.
- If an incorrect label is present on the node like px/metadata-node=blah then Portworx will not start on that node.
- If no node is labelled as px/metadata-node=true , but one node is labeled as px/metadata-node=false then that node will never be a part of KVDB cluster, but rest of the nodes are potential metadata nodes.

## KVDB Node Failover

If a Portworx node which was a part of the internal KVDB cluster goes down for more than 3 minutes, then any other available storage nodes which are not part of the KVDB cluster will try to join it.

This is a set of actions that are taken on the node which tries to join the KVDB cluster

- The down member is removed from the internal KVDB cluster. (Note: The node will be still part of the Portworx cluster)
- Internal KVDB is started on the new node
- The new node adds itself to the internal KVDB cluster

The node label logic holds true even during failover, so if a node has a label set to false, then it will not try to join the KVDB cluster.

If the offline node comes back up, it will NOT rejoin the internal KVDB cluster, once another node replaces it.

{{<info>}}
Only storage nodes are a part of internal KVDB cluster.
{{</info>}}


## Backup

Portworx takes regular internal backups of its key-value space and dumps them into a file on the host.
Portworx takes these internal KVDB backups every 2 minutes and places them into the `/var/lib/osd/kvdb_backup` directory on all nodes in your cluster. It also keeps a rolling count of 10 backups at a time within the internal KVDB storage drive.

A typical backup file will look like this

```text
ls /var/lib/osd/kvdb_backup
```

```output
pwx_kvdb_schedule_153664_2019-02-06T22:30:39-08:00.dump
```

These backup files can be used for recovering the internal KVDB cluster in case of a disaster.

## Recovery

In an event of a cluster failure such as:

- All the internal KVDB nodes and their corresponding drives where their data resides are lost and are unrecoverable
- Quorum no. of internal KVDB nodes are lost and are unrecoverable.

Portworx can recover its internal KVDB cluster from one of the backup files that are dumped on each of the nodes.

Follow these steps to recover.

### Step 1: Identify the latest and golden KVDB backup file

A timestamp is associated with each internal KVDB backup that is taken. Choose the latest backup file from all the nodes.

### Step 2: Rename the backup file

On the node where the latest backup exists, rename the backup file to `pwx_kvdb_disaster_recovery_golden.dump`.

```text
cp /var/lib/osd/kvdb_backup/pwx_kvdb_schedule_153664_2019-02-06T22:30:39-08:00.dump /var/lib/osd/kvdb_backup/pwx_kvdb_disaster_recovery_golden.dump
```

### Step 3: Restart Portworx

On the node where the golden dump exists, restart Portworx service.

Portworx will be able to recover the internal KVDB cluster from the golden dump only if

- Nodes from the existing (old) internal KVDB cluster are **NOT** healthy.
- There is only one node with the file `pwx_kvdb_disaster_recovery_golden.dump`

As soon as this node recovers the internal KVDB cluster, all other Portworx nodes will start coming back up one by one.
