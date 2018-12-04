---
title: Portworx on the Packet.net Hosted Platform
keywords: portworx, packet.net, PaaS, IaaS, docker, converged, bare metal
description: Portworx can help you run stateful workloads with Docker. Find out how to deploy upon Packet.net servers!
weight: 3
linkTitle: Packet.net
noicon: true
---

This guide shows you how you can easily deploy Portworx on the [**packet.net** hosting service](http://packet.net)

Other supported bare metal cloud providers are

* Scaleway Use this image: https://www.scaleway.com/imagehub/docker/
* Digital Ocean
* Rackspace


{{<info>}}
**NB:**<br/> For quick/easy deployment of Portworx on Packet.net, please refer to the [Terraporx Repo](https://github.com/portworx/terraporx/tree/master/packet) of Terraform deployment scripts.
{{</info>}}

### Step 1: Provision Server
When chosing an instance, verify that you meet the [minimum requirements](/#minimum-requirements)

Portworx recommends a minimum cluster size of 3 nodes.

### Step 2: Install Docker for the appropriate OS Version
Portworx recommends Docker 1.12 with [Device Mapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper).

### Step 3: Deploy and Attach Block Storage Volume to Packet Server
Follow the instuctions on Packet's instructions for [installing and attaching to block storage](https://github.com/packethost/packet-block-storage).

Your deployment will look something like following:


![Attach Block Storage Volume](/img/block-storage-on-packet.png "Attach Block Storage Volume")

### Step 4: Install and Run the Packet host utilities for block storage
On each host, download and install the [Packet block-storage utilities](https://github.com/packethost/packet-block-storage)
Use **packet-block-storage-attach** to attach the block storage to your local node.

### Step 5: Determine the local multi-path devices
The attached local block storage will automatically be configured for multipath access, using standard Linux **dm-multipath**.

Use the following command to identify the multipath devices:

```bash
   multipath -ll|more
```

**NB:**  In the case where multiple block devices have been configured for services other than Portworx, pay special attention to identifying
which block devices (and which corresponding multipath devices) are assocated with each service.

### Step 6: Determine the appropriate network interfaces
Run the standard **ifconfig** utility to determine which network interface corresponds to your public and private IP address.  
For CentOS7, your likely public interface will be "team0" and private interface will be "team0:0".   Use "team0" as the Portworx management interface, and "team0:0" as the Portworx data interface.
For Ubuntu16, your likely public interface will be "bond0" and private interface will be "bond0:0".   Use "bond0" as the Portworx management interface, and "bond0:0" as the Portworx data interface.

### Step 7: Launch PX-Enterprise
[Follow the instructions to launch PX-Enterprise](/#install-with-a-container-orchestrator)

Use the docker run command to launch PX-Enterprise, substituting the appropriate multipath devices and network interfaces, as identified from the previous steps.

Alternatively, you can either run the 'px_bootstrap' script from curl, or construct your own [config.json](/install-with-other/docker/shared/config-json) file.

From the server node running px-enterprise container, you should see the following status:
![PX-Cluster on Packet](/img/px-cluster-on-packet.png "PX-Cluster on Packet")


You should also be able to monitor cluster from PX-Enterprise console:
![Packet-Cluster on Lighthouse](/img/packet-cluster-on-lighthouse.png "Packet-Cluster on Lighthouse")
