---
title: "Expand every Portworx storage pool in your cluster"
linkTitle: "Expand all storage pools"
keywords: autopilot, storage pool
description: "Auto-expand storage pools"
weight: 200
---

You can use Autopilot to expand Portworx every storage pool in your cluster until they reach a certain capacity.

Autopilot uses Portworx APIs to expand storage pools, and these APIs currently support the following cloud providers:

* Azure
* AWS
* VMware vSphere

## Prerequisites

* **Portworx version**: Autopilot uses Portworx APIs to expand storage pools which is available only in PX 2.3.1 and above
* **Portworx cloud drives**: Your Portworx installation must use one of the supported cloud drives where Portworx provisions the backing drives using the cloud provider
* **Autopilot version**: 1.0.0 and above

## Example

The following example Autopilot rule uses the `add-disk` scale type to resize all Portworx storage pools in the cluster until all of them exceed 400GiB:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: pool-expand-till-400
spec:
  enforcement: required
  ##### conditions are the symptoms to evaluate.
  conditions:
    expressions:
    # pool size is less than 400 GiB
    - key: "px_pool_stats_total_bytes/(1024*1024*1024)"
      operator: Lt
      values:
        - "400"
  ##### action to perform when condition is true
  actions:
    - name: "openstorage.io.action.storagepool/expand"
      params:
        # resize pool by scalepercentage of current size. The 100% shown below will double the current pool size.
        scalepercentage: "100"
        # when scaling, add disks to the pool
        scaletype: "add-disk"
```

Consider the key sections in this spec: `conditions` and `actions`.

The `conditions` section establishes threshold criteria dictating when the rule must perform its action. In this example, that criteria contains a single formula:

* The `px_pool_stats_total_bytes/(1024*1024*1024)` key calculates the total pool capacity in GiB
* The `Lt` operator sets the threshold criteria at the `400GiB` value

The `actions` section specifies what action Portworx performs when the conditions are met. Action parameters modify action behavior, and different actions contain different action parameters. In this example, the actions section directs Portworx to do 2 things:

* Double the size of the pool by adding 100 percent of the `scaleprecentage` to the pool
* Scale the pool by adding disks to it

{{<info>}}
**NOTE:** Autopilot expands the pools such that no volume in the system will go out of quorum. For example, if `volume1` has replicas on `pool1` and `pool2`, Autopilot first expands `pool1`, waits for completion, and then expands `pool2`.
{{</info>}}
