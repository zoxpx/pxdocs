---
title: Maintain volumes using Filesystem Trim
linkTitle: Volume trim
keywords: portworx, pxctl, command-line tool, cli, reference, volume trim, discard
description: Maintain volumes using filesystem trim
weight: 17
---

A typical Portworx volume is formatted with either ext4 or xfs and then used by a container application to store its content files and directories. Over time, your application might create and delete files and directories. On the volume, the space which was previous used by a deleted file gets freed in the filesystem metadata and the underlying block device is unaware of this fact. This can lead to the following inefficiencies:

* On thin provisioned volumes, the freed space in the volume does not translate into free space in the pool. This means that other volumes in the pool that require space might not be able to get it from the pool.
* On SSDs, the block device performs better when it has knowledge of all the freed blocks that the user no longer requires. This information is used by the SSD firmware to perform wear-leveling more efficiently to improve the service life of the storage device and also provide better I/O performance. When the information about the blocks freed in the filesystem is not available to the block device, it creates hot spots in the device that cause it to wear more than rest of the blocks in the device.

To address these inefficiencies, you can instruct the filesystem to inform the block device of all the unused blocks which were previously used by issuing a `FITRIM` ioctl to the mounted filesystem. The filesystem in turn issues a DISCARD request for the freed blocks to the block device.

{{<info>}}
**NOTE:** 
* Filesystem trim operations can sometimes take a very long time to complete, so the service runs as a background operation
* You can only perform filesystem trim operations on a mounted volume
* If you unmount a volume while filesystem trim operations are running on it, those filesystem trim operations will stop
* You can only run 1 instance of filesystem trim at-a-time on a volume
* You can only run 1 instance of filesystem trim on a system. This limitation reduces the impact on IO performance for user workloads running on that node
* You must start filesystem trim operations from the node on which the volume's storage is mounted
{{</info>}}

### Perform a filesystem trim operation

1. Open a shell session with the Portworx node on which the volume you intend to run the filesystem trim operation on is mounted. 

2. Enter the `pxctl volume trim start` command with the `--path` flag and your mount path and volume name to start the filesystem trim operation on a volume:
        
        ```text
        pxctl volume trim start --path <mount_path> <volume_name>
        ```

3. Monitor the filesystem trim operation running on a volume by entering the `pxctl volume trim status` command with the `--path` flag and your mount path and volume name:

        ```text
        pxctl volume trim status --path <mount_path> <volume_name>
        ```

### Stop a filesystem trim operation

Stop a running filesystem trim operation by entering the `pxctl volume trim status` command with the `--path` flag and your mount path and volume name:

    ```text
    pxctl volume trim stop --path <mount_path> <volume_name> 
    ```

## pxctl volume trim reference

### pxctl volume trim start

`pxctl volume trim start --path <mount_path> <volume_name>`

#### Description 

Start a filesystem trim operation on the block device and volume you specify

#### Arguments

| `<volume_name>` | The name of the volume on which you want to perform a filesystem trim operation |

#### Flags

| `--path`  | Use this flag to provide the mount path where the volume/device is mounted `<mount_path>` |

#### Examples

* Start a filesystem trim operation on an example volume:

        ```text
        pxctl volume trim start --path /mnt/pxd/mount/path exampleVolume
        ```

### pxctl volume trim status

`pxctl volume trim status --path <mount_path> <volume_name>`

#### Description 

Display the status of a currently running filesystem trim operation on the block device and volume you specify

#### Arguments

| `<volume_name>` | The name of the volume you want to see the currently running filesystem trim operation status for |

#### Flags

| `--path`  | Use this flag and specify the path reference to the mount point or mount directory where the volume is mounted. |

#### Examples

* Show the status for a running filesystem trim operation on an example volume:

        ```text
        pxctl volume trim status --path /mnt/pxd/mount/path exampleVolume
        ```

### pxctl volume trim stop

`pxctl volume trim stop --path <mount_path> <volume_name>`

#### Description 

Stop a currently running filesystem trim operation on the block device and volume you specify

#### Arguments

| `<volume_name>` | The name of the volume for which you want to stop a filesystem trim operation |

#### Flags

| `--path`  | Use this flag and specify the path reference to the mount point or mount directory where the volume is mounted, for example: `/var/lib/osd/examplevolume`. |

#### Examples

* Stop the running filesystem trim operation on an example volume:

        ```text
        pxctl volume trim stop --path /mnt/pxd/mount/path exampleVolume
        ```
