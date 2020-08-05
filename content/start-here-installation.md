---
title: "Prerequisites"
weight: 1
disableprevnext: true
equalizeTableWidths: "50%"
description: Start your installation.
keywords: Portworx, containers, storage
---

## Installation Prerequisites

The minimum supported size for a Portworx cluster is three nodes. Each node must meet the following hardware, software, and network requirements:

|**Hardware** ||
|-------------------------|------------|
|     CPU | 4 cores|
|     RAM | 4GB|
| Disk <ul><li>`/var`</li><li>`/opt`</li></ul> | <ul><li>2GB free</li><li>3GB free</li></ul> |
|Backing drive | 8GB (minimum required)<br/>128 GB (minimum recommended)|
|Storage drives | Storage drives must be unmounted block storage: raw disks, drive partitions, LVM, or cloud block storage. |
|Ethernet NIC card | 10 GB (recommended)|

|**Network** ||
|--- | ---|
|Open needed ports | Portworx requires different open ports depending on how it's installed:<ul><li>Spec-based installations require all Portworx nodes to have open TCP ports at 9001-9022 and an open UDP port at 9002.</li><li>Portworx on OpenShift 4+ requires open TCP ports at 17001-17020 and an open UDP port at 17002.</li></ul>Portworx also requires an open KVDB port. For example, if you're using `etcd` externally, open port 2379.<br/><br/>If you intend to use Portworx with sharedv4 volumes, you may need to [open your NFS ports](/portworx-install-with-kubernetes/storage-operations/create-pvcs/open-nfs-ports).|
| Lighthouse | If installing the Portworx Lighthouse management UI please open ports 32678 and 32679 |

|**Software** ||
|--- | ---|
|Linux kernel | Version 3.10 or greater.|
|Docker | Version 1.13.1 or greater.|
|Key-value store | Portworx needs a key-value store to perform its operations. As such, install a clustered key-value database \(`etcd` or `consul`\) with a three node cluster.<br><br>With Portworx 2.0, you can use Internal KVDB during installation. In this mode, Portworx will create and manage an internal key-value store (kvdb) cluster.<br><br>If you plan of using your own etcd, refer to [Etcd for Portworx](/reference/knowledge-base/etcd) for details on recommendations for installing and tuning etcd.|
|Disable swap|Please disable swap on all nodes that will run the Portworx software.  Ensure that the swap device is not automatically mounted on server reboot.|

## Installation

For Kubernetes, continue below,
{{< widelink url="/portworx-install-with-kubernetes" >}}Portworx on Kubernetes{{</widelink>}}

For all other environments, continue below,
{{< widelink url="/install-with-other" >}}Portworx on other orchestrators{{</widelink>}}
