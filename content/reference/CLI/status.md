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

The following example outputs the status of an operational cluster with 384 GB of total storage capacity:

```text
pxctl status
```

```output
	Status: PX is operational
	License: Trial (expires in 29 days)
	Node ID: abb4723e-efa3-432d-ad27-f929bc658862
		IP: 70.0.79.28
		Local Storage Pool: 1 pool
		POOL	IO_PRIORITY	RAID_LEVEL	USABLE	USED	STATUS	ZONE	REGION
		0	HIGH		raid0		128 GiB	8.4 GiB	Online	default	default
		Local Storage Devices: 2 devices
		Device	Path		Media Type		Size		Last-Scan
		0:0	/dev/sdf	STORAGE_MEDIUM_MAGNETIC	128 GiB		22 Sep 19 14:48 UTC
		total			-			128 GiB
		Cache Devices:
		Device	Path		Media Type		Size		Last-Scan
		0:1	/dev/sdc	STORAGE_MEDIUM_SSD	70 GiB		22 Sep 19 14:48 UTC
	Cluster Summary
		Cluster ID: doc-cluster-caching-2.2.0
		Cluster UUID: e5d79039-1333-4ac9-adf4-70019d925a4a
		Scheduler: none
		Nodes: 3 node(s) with storage (3 online)
		IP		ID					SchedulerNodeName	StorageNode	Used    Capacity	Status	StorageStatus	Version		Kernel				OS
		70.0.79.28	abb4723e-efa3-432d-ad27-f929bc658862	N/A			Yes		8.4 GiB 128 GiB		Online	Up (This node)	2.2.0.0-328a043	4.20.13-1.el7.elrepo.x86_64	CentOS Linux 7 (Core)
		70.0.78.240	9ddf713b-0dbc-4e7b-bd6e-2ae648891072	N/A			Yes		8.4 GiB 128 GiB		Online	Up		2.2.0.0-328a043	4.20.13-1.el7.elrepo.x86_64	CentOS Linux 7 (Core)
		70.0.79.32	0e466c6a-fef0-4752-b133-9bf257e9973a	N/A			Yes		8.4 GiB 128 GiB		Online	Up		2.2.0.0-328a043	4.20.13-1.el7.elrepo.x86_64	CentOS Linux 7 (Core)
	Global Storage Pool
		Total Used    	:  25 GiB
		Total Capacity	:  384 GiB
```

Note the following about this example output:

* The `Node ID` field displays the identification string of the node on which you ran the `pxctl status` command. In this example, it's `abb4723e-efa3-432d-ad27-f929bc658862`. Beneath the `Node ID`, you can see local node and storage pool information.
* The `Local Storage Pool` field lists the number of storage pools on the node
* Pools are listed by their number, `0` in this example, and information is displayed in columns to the right. The capacity of the local storage pool is 128 GiB, and the amount of used storage space is 8.4 GiB.
* Under the `Cluster Summary` section, you can see information about the nodes in your cluster. This example cluster contains three nodes:
  * `abb4723e-efa3-432d-ad27-f929bc658862` (the local node)
  * `9ddf713b-0dbc-4e7b-bd6e-2ae648891072`
  * `0e466c6a-fef0-4752-b133-9bf257e9973a`
* The amount of storage space available on the `9ddf713b-0dbc-4e7b-bd6e-2ae648891072` node is 128 GiB, and the amount of used storage space is 8.4 GiB
* The amount of storage space  on the `0e466c6a-fef0-4752-b133-9bf257e9973a` node is 128 GiB, and the amount of used storage space is 8.4 GiB
* The total amount of storage space available across your cluster is 384 GiB, and the amount of used storage space is 25 GiB

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
Portworx recommends setting up monitoring with Prometheus and AlertsManager. If you are using Portworx with Kubernetes, refer to the [Monitoring with Prometheus and Grafana](https://2.1.docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) article. If you are using Portworx with other orchestrators, refer to the [Alerting With Portworx](/install-with-other/operate-and-maintain/monitoring/alerting/) article.
{{</info>}}
