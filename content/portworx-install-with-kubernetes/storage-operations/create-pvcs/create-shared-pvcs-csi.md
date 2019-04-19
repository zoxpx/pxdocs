---
title: Create shared PVCs using CSI
weight: 12
keywords: portworx, container, kubernetes, storage, k8s, pv, persistent disk, pvc
description: Learn how to use portworx shared volumes (ReadWriteMany) in your Kubernetes cluster using CSI
hidden: true
---

This document describes how to create shared Portworx volumes using the [CSI](https://kubernetes-csi.github.io/) provisioner.

### Prerequisite

Ensure that your Portworx installation supports CSI. When [Generating the Portworx specs](https://install.portworx.com/2.1) select CSI under Customize->Advanced Settings. This will add the CSI components to the Portworx DaemonSet.

### Step 1 : Create a CSI StorageClass

Apply the below spec.

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-csi-shared-sc
provisioner: com.openstorage.pxd
parameters:
  repl: "3"
  shared: "true"
```

{{<info>}}Notice the **com.openstorage.pxd** provisioner above. This is the Portworx CSI provisioner.{{</info>}}

### Step 2 : Create a PVC

Apply the below spec.

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
   name: px-shared-pvc
spec:
   storageClassName: portworx-csi-shared-sc
   accessModes:
     - ReadWriteMany
   resources:
     requests:
       storage: 2Gi
```

### Step 3 : Deploy your application

Now start your application which references the above PVC.

```text
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        securityContext:
          privileged: true
        volumeMounts:
        - name: nginx-persistent-storage
          mountPath: /usr/share/nginx/html
          readOnly: true
      volumes:
      - name: nginx-persistent-storage
        persistentVolumeClaim:
          claimName: px-shared-pvc
```
