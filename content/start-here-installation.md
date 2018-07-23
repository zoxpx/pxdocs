---
title: "Start Here: Installation"
weight: 1
disableprevnext: true
nextpage: platform-install-with-kubernetes/index.md
---

## Installation Prerequisites

Prior to installing Portworx, your system needs to meet the hardware, software and network requirements listed below.

**Hardware Requirement** | **Details**
-------------------------|------------
     Number of CPU cores | 4
     Number of GB of RAM | 4
Hard drive space \(recommended\) | 128 GB
Ethernet NIC card \(recommended\) | 10 GB

**Network Requirement** | **Details**
--- | ---
Open needed ports | See Note 1 below.

**Software Requirement** | **Details**
--- | ---
Linux kernel | Version 3.10 or greater.
Docker | Version 1.13.1 or greater.
Key-value store | See Note 2 below.
Shared mounts | See Note 3 below.
Portworx nodes | See Note 4 below.

**Note 1**: Open ports 9001-9016 on all Protworx nodes. Also open the KVDB port. \(As an example, `etcd` typically runs on port 2379\).

**Note 2**:  Portworx needs a key-value store to perform its operations. As such, install a clustered key-value database \(`etcd` or `consul`\) with a three node cluster. Refer to this [article](https://coreos.com/etcd/docs/latest/op-guide/clustering.html) about `etcd` clustering and this [article](https://www.consul.io/intro/getting-started/join.html) about `consul` clustering.

**Note 3:**  If you are installing Portworx 1.2, you must configure Docker to use shared mounts propagation. To do this, run `sudo mount –make-shared /` in your SSH window.  Portworx 1.3 and higher automatically enables shared mounts.

**Note 4**: Portworx installations require a minimum of 3 nodes to be used on a cluster. The Portworx Enterprise edition supports up to 1000 nodes per cluster. The Portworx Developer edition does not allow more than 3 nodes per cluster.  All nodes running a Portworx container must be synchronized and NTP must be set up.

### Install Portworx

{{< widelink url="/platform-install-with-kubernetes" >}}Preparing your Kubernetes Platform{{</widelink>}}