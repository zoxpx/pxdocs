---
title: Portworx on Rackspace
description: Follow these steps to easily install Portworx on Rackspace.  Try it today!
keywords: portworx, rackspace, PaaS, IaaS, docker, converged, cloud
weight: 5
linkTitle: Rackspace
noicon: true
---

This guide show you how you can easily deploy Portworx on [**Rackspace**](https://www.rackspace.com/login)


### Step 1: Provision Cloud Server
When chosing an instance, verify that you meet the [minimum requirements](/#minimum-requirements)

Detailed Rackspace steps to build a [cloud server](https://support.rackspace.com/how-to/create-a-cloud-server/)
Portworx recommends a minimum cluster of 3 nodes



### Step 2. Create a volume and attach it to a Rackspace VM
Follow the instuctions from Rackspace documentation [Create and attach a Cloud Block Storage volume](https://support.rackspace.com/how-to/create-and-attach-a-cloud-block-storage-volume/)

Your deployment will look something like the following:

![Rackspace Add Block Storage Volumes](/img/rackspace-add-disk.png "Add Block Storage")


Note: Volume cannot not be attached until the server is available


### Step 3: Install Docker for the appropriate OS Version
Portworx recommends Docker 1.12 with [Device Mapper](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper).

### Step 4: Launch PX-Enterprise
Note: Before installing Portworx you will need to open ports as per [minimum requirements](/#minimum-requirements) on the local firewall.  You can view Rackspaces [firewall documentation](https://support.rackspace.com/how-to/open-ports-in-the-linux-firewall-to-access-pop-and-imap-mail-servers/)

[Follow the instructions to launch PX-Enterprise](/#install-with-a-container-orchestrator)

Use the docker run command to launch PX-Enterprise, substituting the appropriate multipath devices and network interfaces, as identified from the previous steps.

Alternatively, you can either run the 'px_bootstrap' script from curl, or construct your own [config.json](/install-with-other/docker/shared/config-json) file.

From the server node running px-enterprise container, you should see the following status:

![PX-Cluster on Rackspace](/img/rackspace-pxctl-status.png "PX-Cluster on Azure")


You should also be able to monitor cluster from PX-Enterprise console:

![Rackspace-Cluster on Lighthouse](/img/rackspace-cluster-on-lighthouse-updated.png "Rackspace-Cluster on Lighthouse")
