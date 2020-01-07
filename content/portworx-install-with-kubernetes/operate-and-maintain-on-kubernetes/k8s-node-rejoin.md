---
title: Rejoin a decommissioned Portworx node back to the cluster in Kubernetes
hidden: true
keywords: rejoin decomissioned node, Kubernetes, k8s
description: This guide provides a recommended workflow for rejoining a decommissioned node with its original cluster.
---

This document provides instructions for rejoining a previously decommissioned node with its original cluster.

## Ensure the node is decommissioned from Portworx

If the node was previously part of a Portworx cluster, you must first ensure you followed steps to decommission it from the cluster. The [Decommission a Node](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node/) page has detailed steps for this.

## Ensure the Portworx services are no longer running

You must ensure that the Portworx services are completely disabled from your system. You can check the status of the portworx `systemd` service using the following `systemctl` command:

```text
sudo systemctl status portworx
```

If the `systemd` service is still running, enter the following commands to stop and disable it:

```text
sudo systemctl stop portworx
sudo systemctl disable portworx
sudo rm -f /etc/systemd/system/portworx*
grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci
```

## Clean up Portworx metadata on the node

Portworx also stores local metadata on the node to fingerprint its identity. The method you used to decommission the node determines the steps you must follow to clean up local Portworx metadata.

### Remove metadata using pxctl

If pxctl is still on your node, enter the following `pxctl service` command to remove local metadata using pxctl:

```text
pxctl service node-wipe --all
```

### Remove metadata using wipefs

If pxctl has already been removed from your node, you must manually find and wipe Portworx disks:

1. Enter the following `blkid` and `grep` command to list the disks that Portworx was using:

    ```text
    blkid | grep pxpool
    ```

2. For each of the disks output in step one, enter the `wipefs` command with the `-af` options and the `<disk-name>` to wipe the Portworx metadata:

    ```text
    wipefs -af <disk-name>
    ```

    **Example**

    ```text
    wipefs -af /dev/sdf
    ```

## Restart the Portworx pod on your node by cleaning up labels

Once you have completely decommissioned your node and wiped it of Portworx data, you're ready to re-add it to your cluster. Enter the following `kubectl label nodes` commands, replacing `<node>` with the Kubernetes node name of this node:

```text
kubectl label nodes <node> px/service- --overwrite
kubectl label nodes <node> px/enabled- --overwrite
```

Once you've entered these commands, Portworx will start on this node and rejoin the cluster as a new node.
