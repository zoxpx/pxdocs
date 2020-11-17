---
title: Inspect Volumes
keywords: pxctl, command-line tool, cli, inspect volume,
description: This guide shows you how to inspect your volumes with pxctl.
linkTitle: Inspect Volumes
weight: 2
---

This document explains how you can get detailed information about the settings and the usage of your Portworx volumes. This can be used to investigate various aspects related to your Portworx cluster such as identifying bottlenecks or improving the overall performance.


## Inspect a volume

To inspect a volume, run the `pxctl volume inspect` command with the name of the volume as a parameter. The following example inspects a volume called `testVol`:

```text
pxctl volume inspect testVol
```

```output
Volume    :  970758537931791410
    Name                 :  testVol
    Size                 :  1.0 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Creation time        :  Feb 26 16:29:53 UTC 2019
    Shared               :  no
    Status               :  up
    State                :  detached
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  33 MiB
    Replica sets on nodes:
        Set  0
            Node      :  10.99.117.133
    Replication Status     :  Detached
```

By knowing what the fields from above mean, you can get a deeper insight into your volume's usage. Below, we take a closer look at these fields:

- __Volume__: represents the ID of the volume. Every time a new volume gets created, Portworx generates a unique ID and assigns it to the newly created volume.
- __Size__: the size of the volume expressed in binary Gigabytes (GiB)
- __Format__: the file system used to store data. Currently, Portworx supports `xfs` and `ext4`.
- __HA__: represents the replication factor for the volume. As an example, if a volume has a replication factor of 3, it means the data is protected on 3 separate nodes.

 You can set the replication factor while creating the volume, by running the  `pxctl volume create` command and passing it the `--repl` flag:

 ```text
 pxctl volume create testVol --repl=2
 ```

 For applications that require node level availability and read parallelism across nodes, {{<companyName>}} recommends setting a replication factor of 2 or 3. Note that the maximum replication factor is 3.

You can also modify the replication factor of a volume by running the `pxctl volume ha-update` and passing it the following flags:

  - `--repl` with the new replication factor
  - `--node` with the ID(s) of the new node(s) to which the data will be replicated. Use a comma-separated list to specify more than one ID.

 As an example, here's how you can update the replication factor of a volume called `testVol`:

 ```text
 pxctl volume ha-update --repl=3 --node b1aa39df-9cfd-4c21-b5d4-0dc1c09781d8 testVol
 ```

 See the [updating volumes](/reference/cli/updating-volumes) page for more details.

- __IO Priority__: Portworx classifies disks into three different performance levels:

  - High
  - Medium,
  - Low.

  Then, it groups the volumes into separate pools. To run a low latency transactional workload like a database, create the volume with the `--io_priority` flag set to `high` as in the following example:

 ```text
 pxctl volume create --io_priority high volume-name
 ```

 See the [class-of-service](/concepts/class-of-service) page to get a better understanding of how performance levels work in Portworx. Additionally, note that Portworx provides an easy way to [manage storage pools](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/maintenance-mode/#storage-pool-maintenance) through the `pxctl service pool` command.

- __Creation time__: indicates the creation date and time of the volume.
- __Shared__: this field tells whether the volume is `shared` or not. A shared volume is available to multiple containers running on different hosts at the same time. See the [shared volumes](/shared/concepts-shared-volumes) page for more details
- __Status__: indicates the status of the volume. Possible values are `Up` and `Pending`. `Up` means that Portworx created the volume successfully. `Pending` means that Portworx currently creates the volume. 
- __State__: shows whether the volume is `Attached` or `Detached`. `Attached` means that the volume is attached to a node and you can perform read and write operations on the volume. `Detached` means that the volume is not used and you can't perform read and write operation on the volume.
- __Reads__: the number of `read` operations served by the volume.
- __Reads MS__: the total amount of time spent doing reads, expressed in milliseconds.
- __Bytes Read__: measures the total number of bytes read from the volume.
- __Writes__: the number of `write` operations served by the volume.
- __Writes MS__: the total amount of time spent doing write operations, expressed in milliseconds.
- __Bytes Written__: represents the total amount of bytes written to the volume.
- __IOs in progress__: tells the number of IO operations currently in progress.
- __Bytes used__: indicates the amount of space used on the volume, expressed in KiB.
- __Replication Status__: tells whether the volume replication feature is disabled (`Detached`) or enabled (`Up`). 

## Inspect multiple volumes

With `pxctl`, you can also inspect multiple volumes in one command as in the following example:

```text
pxctl volume inspect testVol testVol2
```

```output
Volume    :  188586323847560484
    Name                 :  testVol
    Size                 :  1.0 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Creation time        :  Jul 2 14:57:11 UTC 2019
    Shared               :  no
    Status               :  up
    State                :  detached
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  340 KiB
    Replica sets on nodes:
        Set 0
          Node          : 70.0.29.70 (Pool 0)
    Replication Status     :  Detached
Volume    :  1089720565647069203
    Name                 :  testVol2
    Size                 :  1.0 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Creation time        :  Jul 4 16:37:02 UTC 2019
    Shared               :  no
    Status               :  up
    State                :  detached
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  340 KiB
    Replica sets on nodes:
        Set 0
          Node          : 70.0.29.70 (Pool 0)
    Replication Status     :  Detached
```

