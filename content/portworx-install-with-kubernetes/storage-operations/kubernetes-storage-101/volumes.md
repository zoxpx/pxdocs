---
title: Persistent volumes
weight: 2
keywords: portworx, kubernetes, PVCs
description: Learn essential concepts about creating persistent volumes on Kubernetes
series: k8s-101
---

When dealing with persistent storage in Kubernetes, 3 key objects are important:

1. [StorageClass](/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/volumes/#storageclass)
2. [PersistentVolumeClaim](/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/volumes/#persistentvolumeclaim-pvc)
3. [PersistentVolume](/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/volumes/#persistentvolume-pv)

## StorageClass

A `StorageClass` provides a way for administrators to describe the “classes” of storage they offer. Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by the cluster administrators. This concept is sometimes called “profiles” in other storage systems.

A user would first create a bunch of StorageClass's in the cluster and then create volumes (PVCs) that reference the StorageClass.

Let's take an example.

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc-db
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  io_profile: "db"
```

In above StorageClass,

* **provisioner: kubernetes.io/portworx-volume** indicates that volumes should be provisioned by the Portworx driver
* **parameters** provide driver specific parameters. The Kubernetes controller simply passes these parameters as-is to the underlying driver (Portworx in this example).
* **repl: "3"** indicates that the Portworx volume needs to have 3 replicas
* **io_profile: "db"** indicates that the Portworx volume needs to have [IO profile optimized for DB workloads](/install-with-other/operate-and-maintain/performance-and-tuning/tuning/#db).

[This table](/portworx-install-with-kubernetes/storage-operations/create-pvcs/dynamic-provisioning/#using-dynamic-provisioning) lists all parameters that are supported by the Portworx driver.

## PersistentVolumeClaim (PVC)

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., can be mounted once read/write or many times read-only).

Let's take an example.

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgres-db
spec:
  storageClassName: portworx-sc-db
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

In above PVC,

* **name: postgres-db** gives the name of the PVC.
* **storageClassName: portworx-sc-db** indicates that this PVC should be creating using the provisioner and paramters specified in the *portworx-sc-db* StorageClass.
* **ReadWriteOnce** indicates that only one pod is allowed to read and write to the volume.
* **storage: 10Gi** indicates this is a 10GiB PVC.

## PersistentVolume (PV)

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator.

When you create a PVC, behind the scenes, either a new PV is created (dynamic provisioning) or an existing PV is bound to the PVC. In other words, there is a one-one mapping between a PVC and a PV.

To find the PV that is being used by a PVC, you can do

```text
kubectl get pvc <pvc-name>
```

An end user needs to interact with a PV only when using [pre-provisioned volumes](/portworx-install-with-kubernetes/storage-operations/create-pvcs/using-preprovisioned-volumes). For dynamically provisioned volumes, end users only create PVCs and the backing storage provider creates the PV.

## ReadWriteMany and ReadWriteOnce

A PVC can be

* ReadWriteMany: In the mode, multiple pods can mount and volume and access it at the same time.
  * This should be used by applications like web servers (nginx, wordpress etc) that can handle multiple instances writing to the same volume. It is not recommended to use for databases.
* ReadWriteOnce: In the mode, only a single pod can access the volume at a given time

{{<info>}}For ReadWriteMany Portworx volumes, specify `shared: true` in the StorageClass for the PVC.{{</info>}}


## Useful References

* [Interactive tutorial - Resize Kubernetes volumes using kubectl](https://www.katacoda.com/portworx/scenarios/px-k8s-kubectl-resize-volume)
* [Interactive tutorial - Persistent volumes on Kubernetes using Portworx](https://www.katacoda.com/portworx/scenarios/px-k8s-vol-basic)
* [Interactive tutorial - Using Portworx Shared Volumes](https://www.katacoda.com/portworx/scenarios/px-k8s-vol-shared)
* [Interactive tutorial - Encrypting volumes on Kubernetes](https://www.katacoda.com/portworx/scenarios/px-k8s-encryption)
* [Kubernetes Storage documentation](https://kubernetes.io/docs/concepts/storage/volumes/)