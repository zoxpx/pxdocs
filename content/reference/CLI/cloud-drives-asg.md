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
Manage cloud drives

Usage:
  pxctl clouddrive [flags]
  pxctl clouddrive [command]

Aliases:
  clouddrive, cd

Available Commands:
  inspect       Inspect and view all the drives of a DriveSet
  list          List all the cloud drives currently being used
  list-drives   List all the cloud drives currently being used
  transfer      Transfers the cloud drive set from given source node to a destination node
  update-labels Updates the labels on the drive set for the provided node.

Flags:
  -h, --help   help for clouddrive
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

### Transfer cloud drives to a storageless node

The `pxctl clouddrive transfer` operation allows you to move your cloud drives from an existing node to a storageless node using a single command. Using this command, you can transfer cloud drives to new nodes more quickly and with fewer steps than manually detaching, then reattaching cloud drives.

The `pxctl clouddrive transfer` command works by:

1. Putting your storage pools in maintenance mode
2. Detaching the cloud drive from the source node 
3. Attaching it to the destination node
4. Ending maintenance mode

{{<info>}}
**NOTE:** 

* This command is only supported on Google cloud.
* This is not supported when Portworx is installed using an internal KVDB.
{{</info>}}

#### Initiate a cloud drive transfer to a storageless node

Perform the following steps to transfer cloud drives to a storageless node:

1. Create replacement nodes and add them to your cluster, or identify an existing storageless node you want to transfer your cloud storage drives to. 
2. Enter the `pxctl clouddrive transfer submit` command, specifying the following options:

     * The `-s` flag with the ID of the Portworx node that currently owns the drive set. This is the 'NodeID' displayed in the output of the 'pxctl clouddrive list' command.

     * **Optional:** The `-d` flag with the ID of the instance you want to transfer the drive set to. You can find the instance ID of your node by entering the `pxctl clouddrive list` command. The destination instance must be a storageless node (i.e. have no Drive IDs) and in the same zone, if your cluster has zones. 
     
     ```text
     pxctl clouddrive transfer submit -s <source-node-ID> -d <dest-node-ID>
     ```
     ```output
     Request to transfer clouddrive submitted, Check status using: pxctl cd transfer status -i 123456789
     ```

Once you start a cloud drive transfer, the operation will run in the background. 

#### View all running cloud drive transfer jobs

If you need to see a list of all running cloud drive transfer jobs, enter the `pxctl clouddrive transfer list` command:

```text
pxctl clouddrive transfer list
```
```output
JOB                     TYPE                    STATE   CREATE TIME                     SOURCE                                  DESTINATION                                STATUS
185053872653979650      CLOUD_DRIVE_TRANSFER    DONE    2020-12-01T11:32:36.476277607Z  c2a01375-25b6-431d-a3fa-5ee7eb9612f7    gke-user-cd-transfer-default-pool-bf423c1c-d7w5  cloud driveset transfer completed successfully
786018947866995085      CLOUD_DRIVE_TRANSFER    DONE    2020-12-01T10:49:33.507921219Z  320412b9-3ee4-40c4-b5b1-abcd12b5d661    gke-user-cd-transfer-default-pool-abcd11a5-5hb8  cloud driveset transfer completed successfully
```

#### Monitor the status of a cloud drive transfer

If you want to monitor the status of a specific running cloud drive transfer job, enter the `pxctl clouddrive transfer status` command with the `--job-id` flag and the ID of the job you want to see the status of:

```text
pxctl clouddrive transfer status --job-id 185053872653979650
```
```output
Cloud Transfer Job Status:

Job ID                   : 185053872653979650
Job State                : DONE
Last updated             : Tue, 01 Dec 2020 11:34:09 UTC
Transfer Source          : c2a01375-25b6-431d-a3fa-5ee7eb9612f7
Transfer Destination     : gke-user-cd-transfer-default-pool-abcd3c1c-d7w5
Status                   : cloud driveset transfer completed successfully
``` 

### Command reference: pxctl clouddrive transfer 

#### pxctl clouddrive transfer

##### Command syntax

```text
pxctl clouddrive transfer [FLAG]
pxctl clouddrive transfer [COMMAND]
```

##### Flags

| **Flag** | **Description** |
|----|----|
| `-h, --help` | Help for transfer |

#### pxctl clouddrive transfer list

##### Command syntax

```text
pxctl clouddrive transfer list [FLAG]
```

##### Flags

| **Flag** | **Description** |
|----|----|
| `-h, --help` | Help for list |

#### pxctl clouddrive transfer status

##### Command syntax

```text
pxctl clouddrive transfer status [FLAG]
```

##### Flags

| **Flag** | **Description** |
|----|----|
| `-h, --help`           | help for status
| `-i, --job-id` (string)  | The ID of the job you want to view the status for. (Required) |

#### pxctl clouddrive transfer submit

##### Command syntax

```text
pxctl clouddrive transfer submit [FLAG]
```

##### Flags

| **Flag** | **Description** |
|----|----|
|  `-d, --dest` (string) | ID of the instance who should own the drive set. This is the 'InstanceID' displayed in the output of the 'pxctl clouddrive list' command. The destination instance needs to be a storage less node (with no Drive IDs) and in the same zone (if your cluster has zones). This is optional and if not provided, an online storageless node will be used. |
| ` -h, --help`          | help for submit |
|  `-s, --src` (string)  | (Required) ID of the PX node who currently owns the drive set. This is the 'NodeID' displayed in the output of the 'pxctl clouddrive list' command. |