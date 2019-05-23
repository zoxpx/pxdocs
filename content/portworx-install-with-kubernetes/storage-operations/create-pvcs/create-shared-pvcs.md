---
title: Create shared PVCs
weight: 11
keywords: portworx, container, kubernetes, storage, k8s, pv, persistent disk, pvc
description: Learn how to use portworx shared volumes (ReadWriteMany) in your Kubernetes cluster.
series: k8s-vol
---

This document describes how to use portworx **shared** (ReadWriteMany) volumes in your Kubernetes cluster. If you wish to create **sharedv4** volumes refer [here](/portworx-install-with-kubernetes/storage-operations/create-pvcs/create-sharedv4-pvcs)

## Provision a Shared Volume

Shared volumes are useful when you want multiple PODs to access the same PVC \(volume\) at the same time. They can use the same volume even if they are running on different hosts. They provide a global namespace and the semantics are POSIX compliant.

{{<info>}}**Openshift users**:

Below procedure describes creating shared PVCs using the native in-tree Portworx driver in Kubernetes. There is a known issue in Openshift 3.9, 3.10 and 3.11 preventing mounts of shared PVCs.

Use instructions at [Shared PVCs using CSI](/portworx-install-with-kubernetes/storage-operations/create-pvcs/create-shared-pvcs-csi) to create shared Portworx PVCs.
{{</info>}}

### Step 1: Create Storage Class

Create the storageclass:

```text
kubectl create -f examples/volumes/portworx/portworx-shared-sc.yaml
```

Example:

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: px-shared-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "1"
   shared: "true"
```

Note the `shared` field in the list of parameters is set to true. Verifying storage class is created:

```text
kubectl describe storageclass px-shared-sc
```

```output
Name:	  	   px-shared-sc
IsDefaultClass:	   No
Annotations:	   <none>
Provisioner:	   kubernetes.io/portworx-volume
Parameters:	   repl=1,shared=true
Events:			<none>
```

### Step 2: Create Persistent Volume Claim

Creating a ReadWriteMany persistent volume claim:

```text
kubectl create -f examples/volumes/portworx/portworx-volume-shared-pvc.yaml
```

Example:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
   name: px-shared-pvc
   annotations:
     volume.beta.kubernetes.io/storage-class: px-shared-sc
spec:
   accessModes:
     - ReadWriteMany
   resources:
     requests:
       storage: 10Gi
```

Note the accessMode for this PVC is set to `ReadWriteMany` so the Kubernetes allows mounting this PVC on multiple pods.

Verifying persistent volume claim is created:

```text
kubectl get pvc
```

```output
NAME            STATUS    VOLUME                                   CAPACITY   ACCESSMODES   STORAGECLASS   AGE
px-shared-pvc   Bound     pvc-a38996b3-76e9-11e7-9d47-080027b25cdf 10Gi       RWX           px-shared-sc   12m
```

### Step 3: Create Pods which uses Persistent Volume Claim

We will start two pods which use the same shared volume.

Starting pod-1

```text
kubectl create -f examples/volumes/portworx/portworx-volume-shared-pod-1.yaml
```

Example:

```text
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  containers:
  - name: test-container
    image: gcr.io/google_containers/test-webserver
    volumeMounts:
    - name: test-volume
      mountPath: /test-portworx-volume
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: px-shared-pvc
```

Starting pod-2

```text
kubectl create -f examples/volumes/portworx/portworx-volume-shared-pod-2.yaml
```

Example:

```text
apiVersion: v1
kind: Pod
metadata:
  name: pod2
spec:
  containers:
  - name: test-container
    image: gcr.io/google_containers/test-webserver
    volumeMounts:
    - name: test-volume
      mountPath: /test-portworx-volume
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: px-shared-pvc
```

Verifying pods are running:

```text
kubectl get pods
```

```output
NAME      READY     STATUS    RESTARTS   AGE
pod1      1/1       Running   0          2m
pod2      1/1       Running   0          1m
```

{{<info>}}To access PV/PVCs with a non-root user refer [here](/portworx-install-with-kubernetes/storage-operations/create-pvcs/access-via-non-root-users)
{{</info>}}

