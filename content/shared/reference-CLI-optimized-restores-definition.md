---
title: Optimized Restores- Definition
hidden: true
keywords: portworx, pxctl, command-line tool, cli, reference, optimized restores
description: Explains what is an optimized restore
---

With {{< pxEnterprise >}} 2.1.0, users can choose to do optimized restores.  The way this works is that every successful restore creates a snapshot that will be used for the next incremental restore of the same volume.  Hence, for an incremental restore, only the last incremental backup will be downloaded instead of downloading all the dependent backups. Optimized restores are especially useful for workflows that involve frequent restores from a different cluster.
However, this works only if dependent backups were downloaded previously.

Currently, to enable or disable optimized restores, you must use the `pxctl cluster options` command.
