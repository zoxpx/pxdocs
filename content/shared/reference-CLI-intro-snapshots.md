---
title: Creating Snapshots- Intro
hidden: true
keywords: portworx, pxctl, command-line tool, cli, reference, create snapshot
description: Learn how to create snapshots with pxctl- Intro
---

Snapshots are efficient point-in-time read-only copies of volumes. Once created, you can use a snapshot to read data, restore data, and to make clones from a given snapshot.

Under the hood, snapshots are using a **copy-on-write** technique, so that they store only the modified data. This way, snapshots significantly reduce the consumption of resources.

Snapshots can be created **explicitly** by running the `pxctl volume snapshot create` command (called henceforth _user created snapshots_) or through a **schedule** that is set on the volume.
