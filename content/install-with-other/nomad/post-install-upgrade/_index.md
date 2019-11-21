---
title: Upgrade Portworx using a Nomad job
linkTitle: Upgrade Portworx using a Nomad job
keywords: portworx, container, Nomad, storage,
description: Learn how to upgrade Portworx using a Nomad job.
weight: 1
series: px-as-a-nomad-job
series2: px-postinstall-nomad-job
noicon: true
hidden: true
---

{{<info>}}
This document presents the **Nomad** method of upgrading a Portworx cluster. Please refer to the [Upgrade Portworx on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/upgrade/) page if you want to upgrade Portworx on Kubernetes.
{{</info>}}

Upgrade _Portworx_ with Nomad by editing the `portworx.nomad` file you used for initial deployment and updating the container version.

Perform the following steps to update to _Portworx_ version 2.1.2:

1. Modify the `image` key value in your `portworx.nomad` file, changing the version to `2.1.2`:

```text
image = "portworx/oci-monitor:2.1.2"
```

2. Rerun the `portworx.nomad` file:

```text
nomad run portworx.nomad
```

Nomad will do a rolling upgrade, i.e., only one instance will be updated at a time, not causing an impact on any applications (assuming application are running with more than one volume replica).

During the upgrade, you may see two versions of _Portworx_ since we are doing a rolling upgrade:

```text
pxctl status
```

```output
Status: PX is operational
License: Trial (expires in 31 days)
Node ID: 6aab46fd-50dc-4df6-ab6e-e0aa8d74b458
    IP: 10.1.2.34
     Local Storage Pool: 1 pool
    POOL    IO_PRIORITY    RAID_LEVEL    USABLE    USED    STATUS    ZONE        REGION
    0    LOW        raid0        50 GiB    4.3 GiB    Online    us-east-2b    us-east-2
    Local Storage Devices: 1 device
    Device    Path        Media Type        Size        Last-Scan
    0:1    /dev/xvdd    STORAGE_MEDIUM_SSD    50 GiB        08 May 19 01:05 UTC
    total            -            50 GiB
    Cache Devices:
    No cache devices
Cluster Summary
    Cluster ID: px-cluster-nomadv8
    Cluster UUID: daea8eb0-c136-4201-a46e-3daa87d1272a
    Scheduler: none
    Nodes: 3 node(s) with storage (3 online)
    IP        ID                    SchedulerNodeName    StorageNode    Used    Capacity    Status    StorageStatus    Version        Kernel        OS
    10.1.2.34    6aab46fd-50dc-4df6-ab6e-e0aa8d74b458    N/A            Yes        4.3 GiB    50 GiB        Online    Up (This node)    2.1.1.0-9df38f7    4.4.0-1079-aws    Ubuntu 16.04.6 LTS
    10.1.1.111    4c128653-0569-4696-afea-063ddc7ef522    N/A            Yes        4.3 GiB    50 GiB        Online    Up        2.0.3.4-0c0bbe4    4.4.0-1079-aws    Ubuntu 16.04.6 LTS
    10.1.1.199    27e3c1b5-48bc-41f4-981e-25fc5d0ee7f4    N/A            Yes        4.3 GiB    50 GiB        Online    Up        2.0.3.4-0c0bbe4    4.4.0-1079-aws    Ubuntu 16.04.6 LTS
    Warnings:
         WARNING: Persistent journald logging is not enabled on this node.
Global Storage Pool
    Total Used        :  13 GiB
    Total Capacity    :  150 Gi
```

All instances should be healthy after the upgrade is complete:

```text
nomad status portworx
```

```output
ID            = portworx
Name          = portworx
Submit Date   = 2019-05-08T01:04:09Z
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
portworx    0       0         3        0       3         0

Latest Deployment
ID          = abc02ac3
Status      = successful
Description = Deployment completed successfully

Deployed
Task Group  Auto Revert  Desired  Placed  Healthy  Unhealthy  Progress Deadline
portworx    true         3        3       3        0          2019-05-08T01:18:53Z

Allocations
ID        Node ID   Task Group  Version  Desired  Status    Created     Modified
3a50ca69  e074a6b0  portworx    1        run      running   1m35s ago   2s ago
315b1c09  2299a3b6  portworx    1        run      running   3m11s ago   1m37s ago
97589e12  6138409d  portworx    1        run      running   4m46s ago   3m13s ago
20a20fd0  e074a6b0  portworx    0        stop     complete  20m15s ago  1m35s ago
54f759fa  2299a3b6  portworx    0        stop     complete  20m15s ago  3m11s ago
c44ee856  6138409d  portworx    0        stop     complete  20m15s ago  4m46s ago
```

{{% content "shared/upgrade/upgrade-to-2-1-2.md" %}}
