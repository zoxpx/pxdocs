---
title: Topology awareness
description: Learn how to inform your Portworx nodes where they are placed in order to influence replication decisions and performance.
keywords: portworx, pxctl, command-line tool, cli, reference, geography, locality, rack, zone, region
weight: 600
series: concepts
---

Portworx nodes can be made aware of the rack on which they are a placed as well as the zone and region in which they are present. Portworx can use this information to influence the volume replica placement decisions. The way Portworx reacts to rack, zone and region information is different and is explained below.

**Rack**

If Portworx nodes are provided with the information about their racks then they can use this information to honor the rack placement strategy provided during volume creation. If Portworx nodes are aware of their racks, and a volume is instructed to be created on specific racks, Portworx will make a best effort to place the replicas on those racks. The placement is user driven and has to be provided during volume creation.

**Zone**

If Portworx nodes are provided with the information about their zones then they can influence the `default`replica placement. In case of replicated volumes Portworx will always try to keep the replicas of a volume in different zones. This placement is not `strictly` user driven and if zones are provided, Portworx will automatically default to placing replicas in different zones for a volume.

**Region**

If Portworx nodes are provided with the information about their region then they can influence the `default`replica placement. In case of replicated volumes Portworx will always try to keep the replicas of a volume in the same region. This placement is not `strictly` user driven and if regions are provided, Portworx will automatically default to placing replicas in same region for a volume.

## Providing topology for Kubernetes

To update the topology information (zone, region and rack) on Kubernetes, follow the steps on [Cluster Topology awareness for Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/cluster-topology).

## Providing topology for non-Kubernetes clusters

Portworx can be made aware of the cluster topology by exposing specific environment variables. Following is a list of environment variables you can expose.

|**Environment Variable Name** |**Purpose**|
|-------------------------|------------|
|     PWX_RACK | Rack in which the node resides|
|     PWX_ZONE | Zone in which the node resides|
|     PWX_REGION | Region in which the node resides|

One needs to add these variables through the `/etc/pwx/px_env` file. A sample file looks like this:

```text
# PX Environment File
# Add variables in the following format to automatically export them into PX container
PWX_RACK=rack-1
```

Add the `PWX_RACK=<rack-id>` entry to the end of this file and restart the Portworx using

  ```text
systemctl restart portworx
  ```

On every Portworx restart, all the variables defined in `/etc/pwx/px_env` will be exported as environment variables in the Portworx container. Please make sure the label is a string not starting with a special character or a number.
