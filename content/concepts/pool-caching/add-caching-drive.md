---
title: Add a caching drive to a storage pool
keywords: storage pool, pool caching, px-cache
description:
weight: 200
hidden: true
---

## Prerequisites

Before you can add a caching drive to a storage pool, pool caching must have been configured when you installed Portworx on your cluster. Refer to the [Install Portworx with caching enabled](/concepts/pool-caching/#install-portworx-with-caching-enabled) section for more details.

## Add a caching drive to a storage pool

Perform the following steps to add a caching drive to a storage pool:

1. Enter maintenance mode:

    ```text
    pxctl service maintenance --enter
    ```

    ```output
    This is a disruptive operation, PX will restart in maintenance mode.
    Are you sure you want to proceed ? (Y/N): y
    Entering Maintenance mode...
    ```

2. Enter the `pxctl service drive add` command, specifying:

  * The `--drive` option with the `<drive_path>` of your caching drive
  * The `--cache` option with the `<pool_id>` of the pool you want to add the caching drive to

    `pxctl service drive add --drive <drive_path> --cache <pool_id>`

    The following example adds a caching drive at the `/dev/sdc` path to a pool with an ID of `0`:

    ```text
    pxctl service drive add --drive /dev/sdc --cache 0
    ```

3. Adding a drive is a long-running operation, and Portworx won't exit from the maintenance mode while the operation is still running. Therefore, you must verify that the drive has been added successfully by entering the `pxctl service drive add` command with the following parameters:

  * The `--drive` option with the `<drive_path>` of your caching drive
  * The `--cache` option with the `<pool_id>` of the pool you want to verify
  * The `--operation` option with the `status` value

    `pxctl service drive add --drive <drive_path> --cache <pool_id> --operation status`

    The following example verifies that a caching drive `/dev/sdc` has been added to pool `0`:
    ```terminal
    pxctl service drive add --drive /dev/sdc --cache 0 --operation status
    ```
    <!--
      Need sample output
    -->

4. Exit maintenance mode:

    ```text
    pxctl service maintenance --exit
    ```

    ```output
    Exiting Maintenance mode...
    ```
