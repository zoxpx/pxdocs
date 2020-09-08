---
title: Create sharedv4 PVCs
weight: 3
keywords: sharedv4 volumes, ReadWriteMany, PVC, kubernetes, k8s
description: Learn how to use Portworx sharedv4 volumes (ReadWriteMany) in your Kubernetes cluster.
series: k8s-vol
---

This document describes how to use Portworx **sharedv4** (ReadWriteMany) volumes in your Kubernetes cluster.

## Prerequisites

* sharedv4 volumes must not be disabled on your cluster
* NFS ports between nodes [must be open](/portworx-install-with-kubernetes/storage-operations/create-pvcs/open-nfs-ports/)

## Provision a Sharedv4 Volume

Sharedv4 volumes are useful when you want multiple PODs to access the same PVC \(volume\) at the same time. They can use the same volume even if they are running on different hosts. They provide a global namespace and the semantics are POSIX compliant.

**Step1: Create Storage Class**

Create the storageclass:

```text
kubectl create -f examples/volumes/portworx/portworx-sharedv4-sc.yaml
```

Example:

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: px-sharedv4-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   sharedv4: "true"
```

Note the `sharedv4` field in the list of parameters is set to true. Verifying storage class is created:

```text
kubectl describe storageclass px-sharedv4-sc
```

```output
Name:	  	   px-sharedv4-sc
IsDefaultClass:	   No
Annotations:	   <none>
Provisioner:	   kubernetes.io/portworx-volume
Parameters:	   repl=2,sharedv4=true
Events:			<none>
```

**Step2: Create Persistent Volume Claim**

Creating a ReadWriteMany persistent volume claim:

```text
kubectl create -f examples/volumes/portworx/portworx-volume-sharedv4-pvc.yaml
```

Example:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: px-sharedv4-pvc
  annotations:
    volume.beta.kubernetes.io/storage-class: px-sharedv4-sc
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
px-sharedv4-pvc   Bound     pvc-a38996b3-76e9-11e7-9d47-080027b25cdf 10Gi       RWX           px-sharedv4-sc   12m

```

**Step3: Create Pods which uses Persistent Volume Claim**

We will start two pods which use the same shared volume.

Starting pod-1

```text
kubectl create -f examples/volumes/portworx/portworx-volume-sharedv4-pod-1.yaml
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
      claimName: px-sharedv4-pvc
```

Starting pod-2

```text
kubectl create -f examples/volumes/portworx/portworx-volume-sharedv4-pod-2.yaml
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
      claimName: px-sharedv4-pvc
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

## Updating a shared volume to sharedv4 volume

You can update an existing shared volume to use the new v4 protocol and convert it into a sharedv4 volume. Run the following pxctl command to update the volume setting

```text
pxctl volume update --sharedv4=on <vol-name>
```

{{<info>}}To access PV/PVCs with a non-root user refer [here](/portworx-install-with-kubernetes/storage-operations/create-pvcs/access-via-non-root-users)
{{</info>}}
