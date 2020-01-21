---
title: Placing volumes based on IO priority or latency
linkTitle: Using IO priority, latency or IOPS
weight: 1
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets, volume placement
description: Learn how to use Portworx Volume Placement Strategies to control how volumes are placed across your cluster
series: k8s-vol
---

Portworx QoS is specified with Kubernetes storage classes and provides a way to configure IOPS performance tiers for applications. 
Portworx QoS eliminates noisy neighbors and provides performance isolation at the volume granularity.


## Provisioning

At the time of pool construction, individual drives are benchmarked and are categorized as high, medium, or low based on random/sequential IOPS and latencies. 
These are applied as individual labels on the pools and can be used in provisioning rules. Provisioning rules can be specified in terms of 'High, medium, low' or a an IOPS level. 
For example, a provision rule can be written to provision volumes on pools that have random I/O latencies less than 2 ms or io_priority high.

## Runtime

At Runtime, Portworx provides different QoS levels to different volumes based on weighted queuing at the client side and time slicing at the target.
The virtual block device created for every volume at the client has an associated queue both at the kernel level as well as in the Portworx stack. 
This is a weighted queue and the IOs are dispatched at the relative weights associated with each volume. 
The same algorithm applies at the target where the IOs are scheduled to the backing target device based on the combined IOPS the target is capable of delivering and the the configured IOPS per volume.

## Configuration

Below steps provide an example of using a VolumePlacementStrategy for creating a PVC (PersistentVolumeClaim).
 
### Step 1: Create VolumePlacementStrategy

Below are some of the example VolumePlacementStrategies. Copy the spec to a file and use kubectl to apply it.

##### Example A: VolumePlacementStrategy to place volumes in storage pools classified with HIGH ioprioriy

```text
apiVersion: portworx.io/v1beta2
kind: VolumePlacementStrategy
metadata:
  name: postgres-placement-strategy 
spec:
  replicaAffinity:
  - matchExpressions:
    - key: "iopriority"
      operator: "In"
      values:
      - "HIGH"
```

##### Example B: VolumePlacementStrategy to place volumes in storage pools with random I/O latencies less than 2 ms

```text
apiVersion: portworx.io/v1beta2
kind: VolumePlacementStrategy
metadata:
  name: postgres-placement-strategy 
spec:
  replicaAffinity:
  - matchExpressions:
    - key: "iolatency"
      operator: "Lt"
      values:
      - "2ms"
```

##### Example C: VolumePlacementStrategy to place volumes in storage pools with IOPS greater than 2000

```text
apiVersion: portworx.io/v1beta2
kind: VolumePlacementStrategy
metadata:
  name: postgres-placement-strategy 
spec:
  replicaAffinity:
  - matchExpressions:
    - key: "iops"
      operator: "Gt"
      values:
      - "2000"
```

### Step 2: Reference the VolumePlacementStrategy in your StorageClass

Reference the VolumePlacementStrategy in your StorageClass using the key `placement_strategy` in the parameters section. 
Alternately, you can also use the same key in the PVC annotations.

```text
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: postgres-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  placement_strategy: "postgres-placement-strategy"
```

### Step 3: Create PVC using the StorageClass

Create the PVC that references the StorageClass. When creating the volume, Portworx will fetch the VolumePlacementStrategy spec that's referenced in the StorageClass and use that to pick storage pools for the volume.

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgres-pvc
spec:
  storageClassName: postgres-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```



