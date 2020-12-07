---
title: "Check a pool's cache status"
keywords: storage pool, pool caching, px-cache
description:
weight: 7
hidden: true
---

Check a pool's cache status by entering the `pxctl service pool cache status` command with the id of the pool as a parameter to check if the new settings are applied:

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

{{<info>}}
**NOTE:** Unlike the other pool caching commands, you can run the `status` subcommand without being in cluster or pool maintenance mode. 
{{</info>}}