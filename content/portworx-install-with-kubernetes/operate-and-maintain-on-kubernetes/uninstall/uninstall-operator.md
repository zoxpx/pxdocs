---
title: Uninstall Portworx from a Kubernetes cluster using the Operator
linkTitle: Uninstall using the Operator
keywords: portworx, container, kubernetes, storage, k8s, uninstall, wipe, cleanup
description: Learn how to uninstall Portworx using the Operator.
weight: 2
aliases:
  - /portworx-install-with-kubernetes/on-premise/openshift/operator/uninstall/
  - /portworx-install-with-kubernetes/openshift/operator/uninstall
series: k8s-uninstall
---

If you're using the Portworx Operator, you can uninstall Portworx by adding a delete strategy to your `StorageCluster` object, then deleting it. When uninstalling, you may choose to either keep the the data on your drives, or wipe them completely.

## Prerequisites

* You must already be running Portworx through the Operator, this method will not work for other Portworx deployments

## Uninstall Portworx

1. Enter the `kubectl edit` command to modify your storage cluster:

      ```text
      kubectl edit -n kube-system storagecluster <storagecluster_name>
      ```

2. Modify your `StorageCluster` object, adding the `deleteStrategy` field with either the `Uninstall` or `UninstallAndWipe` type:

    * Uninstall Portworx only:

        ```text
        apiVersion: core.libopenstorage.org/v1
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
        apiVersion: core.libopenstorage.org/v1
        kind: StorageCluster
        metadata:
          name: portworx
          namespace: kube-system
        spec:       
          deleteStrategy:
            type: UninstallAndWipe
        ```

3. Enter the `kubectl delete` command, specifying the name of your `StorageCluster` object:

```text
kubectl delete <your-storagecluster>
```
