---
title: Create PVCs using the ReadOnlyMany access mode
weight: 12
keywords: Portworx, container, Kubernetes, storage, k8s, PV, persistent disk, PVC, ReadOnlyMany
description: Learn how to create PVCs using the ReadOnlyMany access mode
series: k8s-vol
---

This guide provides steps for mounting a disk in the `ReadOnlyMany`(ROM) access mode. The in-tree Portworx driver for Kubernetes does not support creating PVCs with the `ReadOnlyMany(ROM)` access mode. To achieve this functionality, follow the steps below:

1. Create a `sharedv4` volume. Note that you can access a `sharedv4` volume from multiple pods at the same time. For details about creating a `sharedv4` volume, refer to the [Create sharedv4 PVCs](/portworx-install-with-kubernetes/storage-operations/create-pvcs/create-sharedv4-pvcs/) page. 

2. Add a `persistentVolumeClaim` subsection to the `volumes` section of your Pod, specifying the following fields and values: 

    * **readOnly:** with the `true` value
    * **claimName:** with the name of the PVC you created in the step above

    ```text
    apiVersion: v1
    kind: Pod
    metadata:
      name: pvpod
    spec:
      containers:
      - name: test-container
        image: gcr.io/google_containers/test-webserver
        volumeMounts:
        - name: test-vol
          mountPath: /test-portworx-volume
      volumes:
      - name: test-vol
        persistentVolumeClaim:
          claimName: pvcsc001
          readOnly: true
    ```
