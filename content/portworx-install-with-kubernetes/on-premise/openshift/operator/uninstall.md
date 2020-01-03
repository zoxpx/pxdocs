---
title: Uninstall Portworx using the Operator
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Learn how to uninstall Portworx on Openshift using the Operator.
weight: 5
---

If you're using the Portworx Operator, you can uninstall Portworx by adding a delete strategy to your `StorageCluster` object, then deleting it. When uninstalling, you may choose to either keep the the data on your drives, or wipe them completely.

## Prerequisites

* You must already be running Portworx through the Operator, this method will not work for other Portworx deployments

## Uninstall Portworx

1. Enter the `oc edit` command to modify your storage cluster:

      ```text
      oc edit -n kube-system <storagecluster_name>
      ```

2. Modify your `StorageCluster` object, adding the `deleteStrategy` field with either the `Uninstall` or `UninstallAndWipe` type:

    * Uninstall Portworx only:

        ```text
        apiVersion: core.libopenstorage.org/v1alpha1
        kind: StorageCluster
        metadata:
          name: portworx
          namespace: kube-system
        spec:       
          deleteStrategy:
            type: Uninstall
        ```
    * Uninstall Portworx and wipe all drives:

        {{<info>}}
**WARNING:** Wipe operations remove all data from your disks permanently including the Portworx metadata, use caution when applying the DeleteStrategy spec.
        {{</info>}}

        ```text
        apiVersion: core.libopenstorage.org/v1alpha1
        kind: StorageCluster
        metadata:
          name: portworx
          namespace: kube-system
        spec:       
          deleteStrategy:
            type: UninstallAndWipe
        ```

3. Enter the `oc delete` command, specifying the name of your `StorageCluster` object:

```text
oc delete <your-storagecluster>
```
