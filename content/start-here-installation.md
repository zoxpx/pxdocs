---
title: "Prerequisites"
weight: 1
disableprevnext: true
equalizeTableWidths: "50%"
description: Start your installation.
keywords: Portworx, containers, storage
---

## Installation Prerequisites

Prior to installing Portworx, your system needs to meet the hardware, software and network requirements listed below.

|**Hardware** ||
|-------------------------|------------|
|     CPU | 4 cores|
|     RAM | 4GB|
| Disk (/var) | 2GB free |
|Backing drive size | 8GB (minimum required)<br><br>128 GB (minimum recommended)|
|Ethernet NIC card | 10 GB (recommended)|

|**Network** ||
|--- | ---|
|Open needed ports | Open ports 9001-9016 on all Portworx nodes. Also open the KVDB port. \(As an example, `etcd` typically runs on port 2379\)|
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
