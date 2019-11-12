---
title: Control volume provisioning
weight: 4
linkTitle: Control volume provisioning
keywords: portworx, storage, pv, persistent disk, provisioning, thin-provisioning, thick-provisioning, over-provisioning
description: Learn different strategies for controlling volume provisioning
---

# Control volume provisioning

Portworx provisions volumes with little configuration from you. By default, Portworx thin provisions volumes and balances them according to current usage and load within the cluster.

An advantage to this approach is that your apps can provision volumes uninterrupted for as long as your pools have enough backing storage for volume usage. However, if the volume usage exceeds your available backing storage, your apps will encounter capacity problems.

Your use-case may dictate a stricter allocation of resources than thin-provisioning, or you may wish to stop new volumes from being provisioned onto a node or pool without removing existing pools and risking disruption to apps and users.

In each of these cases, you can modify how Portworx provisions volumes with the `--provisioning-commit-labels ""` flag in the `pxctl cluster options update` command.

<!-- call out how to select pool labels in the command

select a specific node: {"LabelSelector": {"node": "<node_id>"}}

select a specific pool label: {"LabelSelector": {"medium": "STORAGE_MEDIUM_SSD"}}
                              {"LabelSelector": {"iopriority": "MEDIUM"}}


-->

## Disable thin provisioning for your cluster

If you want to ensure that each volume in your cluster has enough backing storage when it's provisioned, enter the `pxctl cluster options update` command with the `--provisioning-commit-labels` flag, specifying the following fields in JSON:

* `OverCommitPercent` with the maximum storage percentage volumes can provision against backing storage set to `100`
* `SnapReservePercent` with the percent of the previously specified maximum storage storage percent that is reserved for snapshots

```text
pxctl cluster options update  --provisioning-commit-labels '[{"OverCommitPercent": 100, "SnapReservePercent": 30 ]'
```

### Example



## Disable thin provisioning for portions of your cluster

If you want to disable thin provisioning for portions of your cluster, enter the `pxctl cluster options update` command with the `--provisioning-commit-labels` flag, specifying the following fields in JSON:

* `LabelSelector` with the key values for labels and the `node` key with a comma separated list of the node IDs you wish to apply this rule to
* `OverCommitPercent` with the maximum storage percentage volumes can provision against backing storage set to `100`
* `SnapReservePercent` with the percent of the previously specified maximum storage storage percent that is reserved for snapshots

```text
pxctl cluster options update  --provisioning-commit-labels '[{"LabelSelector": {"a": "b"}},{"OverCommitPercent": 100, "SnapReservePercent":30} }]'
```

### Example

```text
pxctl cluster options update  --provisioning-commit-labels '[{"OverCommitPercent": 200, "SnapReservePercent": 30, "LabelSelector": {"medium": "STORAGE_MEDIUM_MAGNETIC"}} ]'
```

## Configure thin provisioning for your cluster

If you want to limit thin provisioning for your cluster, as well as set different limits for portions of your cluster, enter the `pxctl cluster options update` command with the `--provisioning-commit-labels` flag, specifying the following fields in JSON:

* `OverCommitPercent` with the maximum storage percentage volumes can provision against backing storage
* `SnapReservePercent` with the percent of the previously specified maximum storage storage percent that is reserved for snapshots
* `LabelSelector` with the key values for labels or node IDs you wish to apply this rule to

Set the `OverCommitPercent` and `SnapReservePercent` limits for each label:

```text
pxctl cluster options update  --provisioning-commit-labels '[{"OverCommitPercent": 200, "SnapReservePercent": 30, "LabelSelector": {"a": "b"}},{"OverCommitPercent": 1500, "SnapReservePercent":0} ]'
```

### Example

sets overcommit etc to 200 for pools using magnetic, and sets overcommit etc to 1500 for the whole cluster

```text
pxctl cluster options update  --provisioning-commit-labels '[{"OverCommitPercent": 200, "SnapReservePercent": 30, "LabelSelector": {"medium": "STORAGE_MEDIUM_MAGNETIC"},{"OverCommitPercent": 1500, "SnapReservePercent":0}]'
```

## Reset thin provisining for your cluster

You can reset thin provisioning entirely for your cluster by entering the `pxctl cluster options update` command with the `--provisioning-commit-labels` flag with empty brackets:

```text
pxctl cluster options update  --provisioning-commit-labels '[]'
```

## Disable provisioning entirely



```text
pxctl cluster options update  --disable-provisioning-labels "a=b1;c=d"
```

### Example

```text
pxctl cluster options update  --disable-provisioning-labels "node=064366b7-3702-45ef-aa55-19a2e71fed14"
```
