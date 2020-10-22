---
title: Advanced installation parameters
keywords: installation, parameters, Kubernetes, k8s, raid 0, raid10, PX-Central, Portworx DaemonSet
description: Advanced installation parameters
---

With Portworx, you can specify additional parameters at installation.

## Specify the RAID level for local storage

Portworx supports two RAID level configurations for local storage: RAID 0, and RAID 10.

Follow these steps to specify the RAID level Portworx should use at installation.

1. Use the steps from the [Generate the specs](/portworx-install-with-kubernetes/on-premise/other/daemonset/#generate-the-specs) section to generate a Kubernetes manifest.

2. Download the manifest and use the `args` section of the Portworx `DaemonSet` to specify the RAID level.

  * The following example specifies RAID 0:

    ```text
    args:
      ["-k", "etcd:http://70.0.0.65:2379", "-c", "kockica-11", "-d", "eth1", "-m", "eth1", "-s", "/dev/sdb", "-secret_type", "k8s", "-raid", "0",  
      "-x", "kubernetes"]
    ```

    {{<info>}}
**Note**: All other arguments, apart from the ones that specify the RAID level, are examples. Be sure to use values that match your environment.
    {{</info>}}

  * The following example specifies RAID 10:

    ```text
    args:
      ["-k", "etcd:http://70.0.0.65:2379", "-c", "kockica-11", "-d", "eth1", "-m", "eth1", "-s", "/dev/sdb", "-secret_type", "k8s", "-raid", "10",  
      "-x", "kubernetes"]
    ```

3. Continue with the steps from the [Apply the specs](/portworx-install-with-kubernetes/on-premise/other/daemonset/#apply-the-specs) section.
