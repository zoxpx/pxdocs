---
title: Configure a storage pool's caching properties
keywords: storage pool, pool caching, px-cache
description:
weight: 300
hidden: true
---

## Prerequisites

Before you can configure a storage pool's cache, pool caching must be **disabled** on your cluster. Refer to the [Disable pool caching](/concepts/pool-caching/disable-pool-caching/) page for more details.

## Configure a storage pool's cache

1. Enter maintenance mode:

    ```text
    pxctl service maintenance -e
    ```

    ```output
    This is a disruptive operation, PX will restart in maintenance mode.
    Are you sure you want to proceed ? (Y/N): y
    Entering Maintenance mode...
    ```

2. Enter the `pxctl service pool cache configure` command, specifying:

  * The `--mode` option with the caching `<mode>`
  * The `--blocksize` option with the `<block_size>` the cache uses
  * The `--policy` option with the caching `<policy>`
  * The `--tunables` option with the comma delimited `<tunable>` parameters
  * The `<pool_id>` of the pool you're updating

    ```
    pxctl service pool cache configure \
    --mode [ writeback | writethrough] \
    --blocksize [ cache block size, "auto"]\
    --policy [ smq | mq \]\
    --tunables [ one or more comma separated parameters from below ]\
    <pool ID>
    ```

    The following example configures a pool with an ID of `0`:

    ```text
    pxctl service pool cache configure --mode writeback --blocksize "auto" --policy smq --tunables migration_threshold=2048000 0
    ```

    ```output
    Cache parameters updated, check using 'pxctl service pool cache status 0'
    ```

    The `migration_threshold` parameter represents the number of 512-byte sectors allowed at any time to migrate data from either cache to origin or the other way round. Portworx automatically computes the default value of this parameter based on the assigned cache capacity for a given pool. If it's 1MB, then the default migration bandwidth is set to 100 times the cache block size at 100MB. This translates to 204800 512 byte sectors.

    {{<info>}}
    **Note:** Use caution when running this command. If you misconfigure the `tunable` arguments, Portworx may behave unexpectedly or perform poorly.
    {{</info>}}

3. Run the `pxctl service pool cache status` command  with the id of the pool as a parameter to check if the new settings are applied:

    ```text
    pxctl service pool cache status 0
    ```

    ```output
    PX Cache Configuration and Status:
    Pool ID:  0
      Enabled:  false
      Members:  [/dev/sdc]
      TotalBlocks: 0
      UsedBlocks: 0
      DirtyBlocks: 0
      ReadHits: 0
      ReadMisses: 0
      WriteHits: 0
      WriteMisses: 0
      BlockSize: 1048576
      Mode: writeback
      Policy: smq
      Tunables: migration_threshold=2048000
    ```

4. Exit maintenance mode:

    ```text
    pxctl service maintenance -x
    ```

    ```output
    Exiting Maintenance mode...
    ```
