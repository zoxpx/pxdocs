---
title: Fix volume errors using Filesystem Check
linkTitle: Volume check
keywords: portworx, pxctl, command-line tool, cli, reference, filesystem check, fsck,
description: Fix volume errors using Filesystem Check
weight: 17
---

Over the course of normal operation, the filesystems on volumes can accrue damage and errors. Filesystem Check or `fsck` is a tool that reports and fixes filesystem issues. This feature allows you to do the following:

* Report issues found on the filesystem
* Fix only issues that `fsck` deems safe to fix
* For expert users, fix all reported issues

In order to mitigate data loss due to incorrect `fsck` fixes to the filesystem, Portworx creates a snapshot of the volume before attempting any fixes. If unintended changes occur, you can use this snapshot to recover your volume to its original state. Portworx does not automatically delete this snapshot, you should manually validate your data in the filesystem and delete the snapshot only when you're sure everything is as expected.

In addition to running when manually requested, Portworx runs `fsck` transparently before mounting volumes and fixes safe-to-fix errors. This can happen when the volume has a deferred volume resize operation pending during mount or the previous volume resize failed due errors in the filesystem.

{{<info>}}
**WARNING:** When Filesystem Check fixes errors, it modifies the filesystem metadata and can sometimes lead to unexpected changes to the filesystem. Pay close attention to the issues reported by `fsck` and ensure you understand the impact of proceeding before letting it fix unsafe issues.
{{</info>}}

{{<info>}}
**NOTE:**

* This feature is currently available only for ext4 filesystems.
* Filesystem check can be performed only on unmounted volume
* You cannot detach a volume when filesystem check is running on it.
* You can only run 1 instance of Filesystem check on a volume at-a-time
* You can only run 1 instance of Filesystem check per system. This is to reduce the impact on IO performance for user workloads running on that node.
* You must start filesystem check operations from the node on which the volume's storage is mounted
{{</info>}}

You can use `fsck` by entering `pxctl` commands on the node which contains your volume and mounted block storage:

## Check a volume's health

1. Open a shell session with the Portworx node that contains the volume you intend to check the health of.

2. Unmount the volume.

3. Start the volume check operation by entering the `pxctl volume check start` command with the `--mode` flag set to `check_health` and specify the name of the volume you want to check:

    ```text
    pxctl volume check start --mode check_health <volume_name>
    ```

4. View the results of the volume check operation by entering the `pxctl volume check status` command, specifying the name of the volume you want to check:

    ```text
    pxctl volume check status <volume_name>
    ```

    The command will output any issues present on the volume and whether or not they're considered safe to fix by Filesystem Check.

5. Mount the volume.

## Fix issues

Once you've checked your volume's health and determined if the issues can be fixed by `fsck` safely, you can instruct Portworx to fix the issues. Before it performs a fix operation, Portworx creates a volume snapshot to help you recover your data in case something goes wrong.

1. Open a shell session with the Portworx node that contains the volume you intend to fix issues for.

2. Unmount the volume.

3. Enter the `pxctl volume check start` command with the `--mode` flag set to either `fix_safe` or `fix_all`, and specify the name of the volume you want to fix issues on:

    * To fix safe issues:

    ```text
    pxctl volume check start --mode fix_safe <volume_name>
    ```
    * To fix all issues:

    ```text
    pxctl volume check start --mode fix_all <volume_name>
    ```

    {{<info>}}
**WARNING:** `fix_all` is a risky operation and may result in data loss on the volume. Ensure you understand the impact of using this flag and make appropriate backups before attempting to run it.
    {{</info>}}

4. Verify the data on your volume has been fixed by entering the `pxctl volume check status` command with the name of your volume:

    ```text
    pxctl volume check status <volume_name>
    ```

5. Mount the volume.

6. (Optional) Once you're confident that the fix operation was successful, you can delete the backup snapshot:

    ```text
    pxctl volume delete <snapshot_name>
    ```

## pxctl volume check reference

### pxctl volume check start

`pxctl volume check start --mode [check_health | fix_all | fix_safe] <volume_name>`

| Description | Arguments | Flags |
| --- | --- | --- |
Start a filesystem check operation on the block device and volume you specify | `<volume_name>`: The name of the volume on which you want to perform a filesystem check operation | `--mode`: Determines which mode filesystem check operates in. <br/><br/>**Values:** `check_health`, `fix_all`, `fix_safe`<br/><br/>{{<info>}}**WARNING:** `fix_all` is a risky operation and may result in data loss on the volume. Ensure you understand the impact of using this flag and make appropriate backups before attempting to run it.{{</info>}} |

<!-- Do we consider any of these actual arguments issued to the `start`? or are they both args to the flag? We probably need to provide for "flag arguments" in our reference doc redesign. -->

#### Examples

* Check an example volume's health:

    ```text
    pxctl volume check start --mode check_health exampleVolume
    ```

* Fix an example volume's safe issues:

    ```text
    pxctl volume check start --mode fix_safe exampleVolume
    ```

### pxctl volume check status

`pxctl volume check status <volume_name>`

| Description | Arguments | Flags |
| --- | --- | --- |
| Show the status of a Filesystem Check operation currently running on a volume you specify. | `<volume_name>` : The name of the volume you want to check the status Filesystem Check operation status for | |

#### Examples

* Check an example volume's health:

    ```text
    pxctl volume check status exampleVolume
    ```

### pxctl volume check stop

`pxctl volume check stop <volume_name>`

{{<info>}}
**CAUTION:** This operation may lead to partially fixed filesystem errors and potentially cause further corruption.
{{</info>}}

| Description | Arguments | Flags |
| --- | --- | --- |
| Stop a Filesystem Check operation currently running on a volume you specify. | `<volume_name>`: The name of the volume you want to stop Filesystem Check operations on | |

#### Examples

* Stop Filesystem Check operations an example volume:

    ```text
    pxctl volume check stop exampleVolume
    ```