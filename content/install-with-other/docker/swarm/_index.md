---
title: Install on Docker Swarm
keywords: portworx, container, storage, Docker, swarm
description: Learn how to use Portworx to provide storage for your stateful services running on Docker Swarm.
weight: 2
noicon: true
series: px-docker-install
---

This section describes installing Portworx on Docker Swarm.

## Identify storage

Portworx pools the storage devices on your server and creates a global capacity for containers.

{{<info>}}Back up any data on storage devices that will be pooled. Storage devices will be reformatted!
{{</info>}}

To view the storage devices on your server, use the `lsblk` command.

For example:

```text
lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    xvda                      202:0    0     8G  0 disk
    └─xvda1                   202:1    0     8G  0 part /
    xvdb                      202:16   0    64G  0 disk
    xvdc                      202:32   0    64G  0 disk
```

Note that devices without the partition are shown under the **TYPE** column as **part**. This example has two non-root storage devices \(/dev/xvdb, /dev/xvdc\) that are candidates for storage devices.

Identify the storage devices you will be allocating to PX. PX can run in a heterogeneous environment, so you can mix and match drives of different types. Different servers in the cluster can also have different drive configurations.

## Install {#install}

PX runs as a container directly via OCI runC. This ensures that there are no cyclical dependencies between Docker and PX.

On each swarm node, perform the following steps to install PX.

### Step 1: Install the PX OCI bundle

{{% content "install-with-other/docker/shared/runc-install-bundle.md" %}}

### Step 2: Configure PX under runC

{{<info>}}Specifiy `-x swarm` in the px-runc install command below to select Docker Swarm as your scheduler.{{</info>}}

{{% content "install-with-other/docker/shared/runc-configure-portworx.md" %}}

### Step 3: Starting PX runC

{{% content "install-with-other/docker/shared/runc-enable-portworx.md" %}}


### Adding Nodes {#adding-nodes}

To add nodes to increase capacity and enable high availability, simply repeat these steps on other servers. As long as PX is started with the same cluster ID, they will form a cluster.

### Access the pxctl CLI {#access-the-pxctl-cli}

After Portworx is running, you can create and delete storage volumes through the Docker volume commands or the **pxctl** command line tool.

With **pxctl**, you can also inspect volumes, the volume relationships with containers, and nodes. For more on using **pxctl**, see the [CLI Reference](/reference/cli).

To view the global storage capacity, run:

```text
sudo /opt/pwx/bin/pxctl status
```

The following sample output of `pxctl status` shows that the global capacity for Docker containers is 128 GB.

```text
/opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: 0a0f1f22-374c-4082-8040-5528686b42be
	IP: 172.31.50.10
 	Local Storage Pool: 2 pools
	POOL	IO_PRIORITY	SIZE	USED	STATUS	ZONE	REGION
	0	LOW		64 GiB	1.1 GiB	Online	b	us-east-1
	1	LOW		128 GiB	1.1 GiB	Online	b	us-east-1
	Local Storage Devices: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/xvdf	STORAGE_MEDIUM_SSD	64 GiB		10 Dec 16 20:07 UTC
	1:1	/dev/xvdi	STORAGE_MEDIUM_SSD	128 GiB		10 Dec 16 20:07 UTC
	total			-			192 GiB
Cluster Summary
	Cluster ID: 55f8a8c6-3883-4797-8c34-0cfe783d9890
	IP		ID					Used	Capacity	Status
	172.31.50.10	0a0f1f22-374c-4082-8040-5528686b42be	2.2 GiB	192 GiB		Online (This node)
Global Storage Pool
	Total Used    	:  2.2 GiB
	Total Capacity	:  192 GiB
```

## Post-Install

Once you have Portworx up, take a look below at an example of running stateful Jenkins with Portworx and Swarm!
