---
title: Creating Snapshots
hidden: true
keywords: portworx, pxctl, command-line tool, cli, reference, create snapsohts
description: Learn how to create snapshots with pxctl
---

Here's an example of how to create a snapshot:

```text
pxctl volume snapshot create --name mysnap --label color=blue,fabric=wool myvol
```

```output
Volume snap successful: 234835613696329810
```

The string of digits in the output is the volume ID of the new snapshot. You can use this ID\(`234835613696329810`\) or the name\(`mysnap`\), to refer to the snapshot in subsequent `pxctl` commands.

The label values allow you to tag the snapshot with descriptive information of your choosing. You can use them to filter the output of the `pxctl volume list` command.

There is an implementation limit of 64 snapshots per volume.
