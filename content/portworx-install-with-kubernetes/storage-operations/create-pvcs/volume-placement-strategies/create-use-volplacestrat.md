---
title: Create and use VolumePlacementStrategies
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets, volume placement
description: Instructions for creating and using VolumePlacementStrategies.
---

Create your VolumePlacementStrategy along with your other storage resources:

### Prerequisities

* **Portworx version**: 2.1.2 and above

### Ensure the VolumePlacementStrategy CRD is the correct version

1. Enter the following `kubectl delete` command to unregister the existing CustomResourceDefinition:

      ```text
      kubectl delete crd volumeplacementstrategies.portworx.io
      ```

2. Create a yaml file containing the following content:

      ```text
      apiVersion: apiextensions.k8s.io/v1beta1
      kind: CustomResourceDefinition
      metadata:
        name: volumeplacementstrategies.portworx.io
      spec:
        group: portworx.io
        version: v1beta2
        scope: Cluster
        names:
          plural: volumeplacementstrategies
          singular: volumeplacementstrategy
          kind: VolumePlacementStrategy
          shortNames:
          - vps
          - vp
      ```
3. Enter the `kubectl apply` command to register the CustomResourceDefinition you created above:

      ```text
      kubectl apply -f volPlaceStrat.yaml
      ```

### Construct a VolumePlacementStrategy spec

1. Create a YAML file containing the following common fields. All VolumePlacementStrategy CRDs use these fields:

      * `apiVersion` as `portworx.io/v1beta2`
      * `kind` as `VolumePlacementStrategy`
      * `metadata.name` with the name of your strategy

      Add any of the following affinity or antiaffinity sections to the spec:

      * [replicaAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placement-strategies/crd-reference#replicaaffinity)
      * [replicaAntiAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placement-strategies/crd-reference#replicaantiaffinity)
      * [volumeAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placement-strategies/crd-reference#volumeaffinity)
      * [volumeAntiAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placement-strategies/crd-reference#volumeantiaffinity)

      This example adds a volumeAffinity rule to colocate Postgres volumes for performance:

      ```text
      apiVersion: portworx.io/v1beta2
      kind: VolumePlacementStrategy
      metadata:
      name: postgres-volume-affinity
      spec:
      volumeAffinity:
        - matchExpressions:
          - key: app
            operator: In
            values:
              - postgres
      ```

3. Save and apply your spec with the `kubectl apply` command:

      ```text
      kubectl apply -f yourVolumePlacementStrategy.yaml
      ```

### Create other storage specs

1. Create a StorageClass that references the VolumePlacementStrategy you created in the **Construct a VolumePlacementStrategy spec** steps above by specifying the `placement_strategy` parameter with the name of your VolumePlacementStrategy:

      ```text
      kind: StorageClass
      apiVersion: storage.k8s.io/v1beta1
      metadata:
        name: postgres-storage-class
      provisioner: kubernetes.io/portworx-volume
      parameters:
        placement_strategy: "postgres-volume-affinity"
      ```
2. Save and apply your StorageClass with the `kubectl apply` command:

      ```text
      kubectl apply -f yourVolumePlacementStrategy.yaml
      ```
3. Create a PVC which references the StorageClass you created above, specifying the `storageClass`

      ```text
      kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
         name: postgres-pvc
      spec:
         storageClassName: postgres-storage-class
         accessModes:
           - ReadWriteOnce
         resources:
           requests:
             storage: 2Gi
      ```
4. Save and apply your PVC with the `kubectl apply` command:

      ```text
      kubectl apply -f yourPVC.yaml
      ```

Once you've applied your volumePlacementStrategy, StorageClass, and PVC, Portworx deploys volumes according to the rules you defined. Portworx also follows VolumePlacementStrategies when it restores volumes.
