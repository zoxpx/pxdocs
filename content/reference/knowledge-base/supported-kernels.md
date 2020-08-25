---
title: Supported Kernels
keywords: Supported kernels, Install, Configure, Prerequisites
description: Various kernels that are supported by Portworx and steps to install headers
weight: 5
linkTitle: Supported Kernels
series: kb
---

Portworx runs as a Docker or OCI container, available on the DockerHub. Portworx has a dependency on the kernel module, which must be installed on hosts. Portworx is distributed with pre-built kernel modules for select Centos and Ubuntu Linux distributions. If your kernel version is not listed in the table below, Portworx attempts to download kernel headers to compile it’s kernel module. This can fail if the host sits behind a proxy.  If you already have the kernel-headers and kernel-devel packages installed the module will compile successfully.  If you do not have the packages you will need to first install them before restarting Portworx.  

To install the kernel headers and kernel development packages for kernels not listed in the table below.

#### CentOS

```text
yum install kernel-headers-`uname -r`
yum install kernel-devel-`uname -r`

```

#### Ubuntu

```text
apt install linux-headers-$(uname -r)

```

## Qualified distros and kernel versions

### 2.6

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
| CentOS 7.5 | 5.4.12-1.el7.elrepo.x86_64 |
| CentOS 7.8-vanilla | 3.10.0-1127.el7.x86_64 |
| CentOS 8.2-vanilla | 4.18.0-193.el8.x86_64 |
| Ubuntu 16.04	| Up to 4.4.0-116-generic |
| Ubuntu 2004 | 5.4.0-42-generic |
| Fedora 27	| Up to 4.13.9-300.fc27.x86_64 |
| Fedora 28	| Up to 5.0.16-100.fc28.x86_64 |
| RHEL 7.5	| Up to 3.10.0-1127.el7.x86_64 |
| RHEL 7.6	| Up to 3.10.0-1127.el7.x86_64 |
| RHEL 7.8	| Up to 3.10.0-1127.el7.x86_64 |
| RHEL 8.2	| 4.18.0-193.14.3.el8_2.x86_64 |
| Debian 9	| Up to 4.9.0-12-amd64 |

| **Cloud Distro** | **Kernel Version** |
| --- | --- |
| CoreOS Alpha	| 4.9.123-coreos |
| CoreOS Beta 2411.1.0 (Rhyolite)	| 4.9.123-coreos |
| CoreOS Stable 2345.3.0 (Rhyolite)	| 4.9.123-coreos |
| Amazon Linux v2	| 4.14.186-146.268.amzn2.x86_64 |

<!-- 
| RHEL 8.1 (Ootpa)	|  |
| Ubuntu19.04	|  |
| Ubuntu18.04.4 LTS	|  |
-->


### 2.5.3

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
| Ubuntu 16.04	| Up to 4.4.0-116-generic #140-Ubuntu |
| Fedora 27	| Up to 4.18.18-100.fc27.x86_64 |
| Fedora 28	| Up to 4.18.10-200.fc28.x86_64 |
| RHEL 7.5	| Up to 3.10.0-1127.el7.x86_64 |
| RHEL 7.8	| Up to 3.10.0-1127.el7.x86_64 |
| Debian 9	| Up to 4.9.0-12-amd64 #1 SMP Debian 4.9.210-1 |

| **Cloud Distro** | **Kernel Version** |
| --- | --- |
| CoreOS Alpha	| Up to 4.19.106-coreos |
| CoreOS Beta 2411.1.0 (Rhyolite)	| Up to 4.19.106-coreos |
| CoreOS Stable 2345.3.0 (Rhyolite)	| Up to 4.19.106-coreos |
| RHEL 8.1 (Ootpa)	| Up to 4.18.0-80.4.2.el8_0.x86_64 |
| Ubuntu19.04	| Up to 5.0.0-1017-gcp |
| Ubuntu18.04.4 LTS	| Up to 5.0.0-1033-gcp |
| Amazon Linux v2	| Up to 4.14.77-81.59.amzn2.x86_64 |


### 2.0.0

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL | Up to 3.10.0-957.el7.x86_64 |
|Ubuntu | Up to 4.19.5-041905-generic |

### 1.7.2

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
| CentOS/RHEL| Up to 3.10.0-957.el7.x86_64 |

### 1.7.1.1

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
| CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu | Up to 4.19.1-041901-generic |

### 1.7.1

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu| Up to 4.19.0-041900-generic |

### 1.7.0

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu| Up to 4.19.0-041900-generic |

### 1.6.1.4 and 1.6.1.3

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu| Up to 4.19.0-041900-generic |

### 1.6.1.2

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu| Up to 4.18.16-041816-generic |

### 1.6.1.1

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu| Up to 4.18.12-041812-generic |

### 1.6.1

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.14.4.el7.x86_64 |
|Ubuntu|Up to 4.18.11-041811-generic |

### 1.6.0

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.11.6.el7.x86_64 |
|Ubuntu|Up to 4.18.8-041808-generic |

### 1.5.1

| **Linux Distro**	| **Kernel Version** |
| --- | --- |
|CentOS/RHEL| Up to 3.10.0-862.11.6.el7.x86_64 |
|Ubuntu|Up to 4.18.7-041807-generic |
