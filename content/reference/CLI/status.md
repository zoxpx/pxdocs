---
title: Find cluster status using the `pxctl status` command
description: Get a summary of your cluster's status
keywords: portworx, pxctl, command-line tool, cli, reference
linkTitle: Cluster status
weight: 4
---

The `pxctl status` command provides an overview of your cluster, including:

- Cluster status
- Information on attached nodes
- Cluster summary
- Global storage capacity and usage
- Reported alerts

You can use the `pxctl status` command to view general information, check for alerts, and assist with cluster debugging.

The following example outputs the status of an operational cluster with 192 GB of total storage capacity:

```text
pxctl status
```

```output
Status: PX is operational
Node ID: 0a0f1f22-374c-4082-8040-5528686b42be
    IP: 172.31.50.10
     Local Storage Pool: 2 pools
    POOL    IO_PRIORITY    SIZE    USED    STATUS    ZONE    REGION
    0    LOW        64 GiB    1.1 GiB    Online    b    us-east-1
    1    LOW        128 GiB    1.1 GiB    Online    b    us-east-1
    Local Storage Devices: 2 devices
    Device    Path        Media Type        Size        Last-Scan
    0:1    /dev/xvdf    STORAGE_MEDIUM_SSD    64 GiB        10 Dec 16 20:07 UTC
    1:1    /dev/xvdi    STORAGE_MEDIUM_SSD    128 GiB        10 Dec 16 20:07 UTC
    total            -            192 GiB
Cluster Summary
    Cluster ID: 55f8a8c6-3883-4797-8c34-0cfe783d9890
    IP        ID                    Used    Capacity    Status
    172.31.50.10    0a0f1f22-374c-4082-8040-5528686b42be    2.2 GiB    192 GiB        Online (This node)
Global Storage Pool
    Total Used        :  2.2 GiB
    Total Capacity    :  192 GiB
```

The following example displays the status of a cluster that is in maintenance mode. Note that the status line has changed to `PX is in maintenance mode`.


```text
PX is in maintenance mode.  Use the service mode option to exit maintenance mode.
Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668
    IP: 147.75.104.185
     Local Storage Pool: 0 pool
    Pool    IO_Priority    Size    Used    Status    Zone    Region
    No storage pool
    Local Storage Devices: 0 device
    Device    Path    Media Type    Size        Last-Scan
    No storage device
    total        -    0 B
Cluster Summary
    Cluster ID: bb4bcf13-d394-11e6-afae-0242ac110002
    Node IP: 147.75.104.185 - Node ID: a0b87836-f115-4aa2-adbb-c9d0eb597668 In Maintenance
Global Storage Pool
    Total Used        :  0 B
    Total Capacity    :  0 B

AlertID    Resource    ResourceID                Timestamp    Severity    AlertType        Description
39    CLUSTER        a56a4821-6f17-474d-b2c0-3e2b01cd0bc3    Jan 8 06:01:22 UTC 2017    ALARM        Node state change    Node a56a4821-6f17-474d-b2c0-3e2b01cd0bc3 has an Operational Status: Down
48    NODE        a0b87836-f115-4aa2-adbb-c9d0eb597668    Jan 8 21:45:25 UTC 2017    ALARM        Cluster manager failure    Cluster Manager Failure: Entering Maintenance Mode because of Storage Maintenance Mode
```

Note that the command shows the list of alerts that have been reported.

For more details, please see the [alerts page](/install-with-other/operate-and-maintain/monitoring/portworx-alerts).

{{<info>}}
Portworx, Inc. recommends setting up monitoring with Prometheus and AlertsManager. If you are using Portworx with Kubernetes, refer to the [Monitoring with Prometheus and Grafana](https://2.1.docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) article. If you are using Portworx with other orchestrators, refer to the [Alerting With Portworx](/install-with-other/operate-and-maintain/monitoring/alerting/) article.
{{</info>}}
