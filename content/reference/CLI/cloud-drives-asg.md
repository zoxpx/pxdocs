---
title: Cloud Drives (ASG) using pxctl
description: General reference for CLI Cloud Drives on ASG.
keywords: pxctl, command-line tool, cli, reference, cloud drives, ASG, auto-scaling group
weight: 10
linkTitle: Cloud Drives (ASG)
---

## Cloud Drive operations

If Portworx is managing your cloud drives, the CLI provides a set of commands that display information about your EBS volumes.

### Cloud Drive Help

Run the `pxctl clouddrive` command with the `--help` flag to display the list of the available subcommands and flags.

```text
pxctl clouddrive --help
```

```output
NAME:
   pxctl clouddrive - Manage cloud drives

USAGE:
   pxctl clouddrive command [command options] [arguments...]

COMMANDS:
     list, l       List all the cloud drives currently being used
     inspect, i    Inspect and view all the drives of a DriveSet

OPTIONS:
   --help, -h  show help
```

### Listing all Cloud Drives

Enter the following command to display all the cloud drives used by Portworx:

```text
pxctl clouddrive list
```

```output
Cloud Drives Summary
        Number of nodes in the cluster:  3
        Number of drive sets in use:  3
        List of storage nodes:  [ip-172-20-52-178.ec2.internal ip-172-20-53-168.ec2.internal ip-172-20-33-108.ec2.internal]
        List of storage less nodes:  []

Drive Set List
        NodeIndex        NodeID                                InstanceID                Zone                Drive IDs
        0                ip-172-20-53-168.ec2.internal        i-0347f50a091716c66        us-east-1a        vol-0a3ff5863c7b2c2e4, vol-0f821f3e3a884e275
        1                ip-172-20-33-108.ec2.internal        i-089b22fc89bb11a92        us-east-1a        vol-048dd9c1fd5ed421d, vol-012a4ed30013590ef
        2                ip-172-20-52-178.ec2.internal        i-09169ceb37b251bac        us-east-1a        vol-0bd9aaab0fb615351, vol-0c9f027d111844227
```

### Inspecting Cloud Drives

To display more detailed information about the drives attached to a node, run the `pxctl clouddrive inspect` with the `--nodeid` id flag and pass it the id of the node.


```text
pxctl clouddrive inspect --nodeid ip-172-20-53-168.ec2.internal
```

```output
Drive Set Configuration
        Number of drives in the Drive Set:  2
        NodeID:  ip-172-20-53-168.ec2.internal
        NodeIndex:  0
        InstanceID:  i-0347f50a091716c66
        Zone:  us-east-1a

        Drive  0
                ID:  vol-0a3ff5863c7b2c2e4
                Type:  io1
                Size:  16 Gi
                Iops:  100
                Path:  /dev/xvdf

        Drive  1
                ID:  vol-0f821f3e3a884e275
                Type:  gp2
                Size:  8 Gi
                Iops:  100
                Path:  /dev/xvdg
```
