---
title: Rejoin a decommissioned Portworx node back to the cluster in Kubernetes
hidden: true
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
description: This guide shows the recommended workflow for decommissioned node to rejoin the same cluster.
---

This guide describes a recommended workflow for a previously decommissioned node to rejoin the same cluster.

1. Cleanup Portworx metadata on the node
  * Portworx 1.3 and higher:

      ```text
      pxctl sv node-wipe --all
      ```

  * Portworx 1.2:

      ```text
      rm -rf /etc/pwx
      ```

2. Restart Portworx pod on the node by cleaning up labels:

    ```text
    kubectl label nodes <node> px/service- --overwrite
    ```

    ```text
    kubectl label nodes <node> px/enabled- --overwrite
    ```

In above command, _\<node\>_ is the node which is rejoining the cluster.
After above steps, Portworx will start on this node and will join the cluster back as a new node.
