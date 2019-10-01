---
title: Volume Placement Strategies
weight: 4
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets, volume placement
description: Learn how to use Portworx Volume Placement Strategies to control how volumes are placed across your cluster
series: k8s-vol
---

When creating PersistentVolumeClaims (PVCs) in the cluster, Portworx allows you to specify placement strategies for the volume. Below are some of the use cases that can be satisfied by placement strategies:

* Distribute volumes across failure domains (This is the default Portworx behavior).
* Specify failure domains to include (affinity) or exclude (anti-affinity) when placing volume replicas.
* Specify storage pools to include (affinity) or exclude (anti-affinity) based on
  * Pool Cos (Class of Service): Select between high, medium or low pools
  * Pool media type: Use pools with SSD drives
  * Pool labels: Select pools based on custom user specified labels

<!--
* Spread different replicas of volumes across different pools. E.g place first replica is SSD pools, rest of them in other pools
* Specify affinity or anti-affinity between different volumes matched by labels. The labels here are labels on the PVC metadata.
* Specify affinity or anti-affinity between multiple replicas of the same volume
-->

## The VolumePlacementStrategy CRD

Portworx provides a [CustomResouceDefinition (CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions) called `VolumePlacementStrategy`. The specification for this CRD is composed of 4 main sections:

* [replicaAffinity](#replicaaffinity)
* [replicaAntiAffinity](#replicaantiaffinity)

<!-- * [volumeAffinity](#volumeaffinity) -->
<!-- * [volumeAntiAffinity](#volumeantiaffinity) -->


### replicaAffinity

The `replicaAffinity` section allows you to specify a rule which creates an affinity for replicas within a volume. You should use this to place one or more replicas of a volume on the same failure domain, on multiple failure domains, nodes, or storage pools that match the given labels.

##### Schema

| Field  	| Description    | Optional? | Default |
|---------|----------------|-----------|---------|
|**enforcement**|Specifies if the given rule is required (hard) or preferred (soft)|Yes|required|
|**matchExpressions**|matchExpressions is a list of label selector requirements. The requirements are ANDed.<br/><br/>The labels provided here are matched against the following:<ul><li>Kubernetes node labels</li><li>PVC labels</li><li>Portworx storage pool labels</li></ul>|Yes <!-- * <br/><br/>* required if topologyKey is empty -->| empty|

<!-- |**affectedReplicas**|Number indicating the number of volume replicas that are affected by this rule.|Yes|0 (Interpreted as all volume replicas)| -->
<!-- |**topologyKey** | Key for the node label that the system uses to denote a topology domain. The key can be for any node label that is present on the Kubernetes node. <br/><br/>Using topologyKey requires nodes to be consistently labelled, i.e. every node in the cluster must have an appropriate label matching topologyKey. If some or all nodes are missing the specified topologyKey label, it can lead to unintended behavior.|Yes* <br/><br/>* required if matchExpressions is empty|empty| -->

##### Example uses cases

* [Affinity to use SSD pools](/samples/k8s/volume-placement-ssd-pool-affinity.yaml)
* [Place volume on infra nodes](/samples/k8s/volume-infra-node-affinity.yaml)
* [Place volume only on racks 1, 2 and 3](/samples/k8s/volume-rack-1-2-3-affinity.yaml)

<!--
* [Affinity to use SSD and SATA and spread replicas evenly](/samples/k8s/volume-placement-ssd-sata-pool-spread-affinity.yaml)
  * First replica on SSD pools, second on SATA
* [First replica SSD, others SATA](/samples/k8s/volume-placement-one-ssd-other-sata-pool.yaml)
-->

By default, Portworx automatically adds the following labels to each of its storage pools. These can be used for replica affinity anti-affinity rules to target replicas on a specific storage pool type:

* `iopriority`
* `medium`

<!--
* `iops` (_coming soon_)
* `latency` (_coming soon_)
-->

### replicaAntiAffinity

The `replicaAntiAffinity` section allows you to specify a rule that creates an anti-affinity for replicas within a volume. You should use this to exclude failure domains, nodes or storage pools that match the given labels for one or more replicas of a volume.

##### Schema

| Field  	| Description    | Optional? | Default |
|---------|----------------|-----------|---------|
|**enforcement**|Specifies if the given rule is required (hard) or preferred (soft)|Yes|required|
|**matchExpressions**|matchExpressions is a list of label selector requirements. The requirements are ANDed. <br/><br/>The labels provided here are matched against the following: <ul><li>Kubernetes node labels</li><li>PVC labels</li><li>Portworx storage pool labels</li>| Yes <!-- * <br/><br/>* required if topologyKey is empty -->|empty|

<!-- |**affectedReplicas**|Number indicating the number of volume replicas that are affected by this rule.|Yes|0 (Interpreted as all volume replicas)| -->
<!-- |**topologyKey**|Key for the node label that the system uses to denote a topology domain. The key can be for any node label that is present on the Kubernetes node. Using topologyKey requires nodes to be consistently labelled, i.e. every node in the cluster must have an appropriate label matching topologyKey. If some or all nodes are missing the specified topologyKey label, it can lead to unintended behavior.|Yes* * required if matchExpressions is empty|empty| -->

##### Example uses cases

[Anti-affinity to not use SATA pools](/samples/k8s/volume-placement-sata-pool-anti-affinity.yaml)

<!--
### volumeAffinity

The `volumeAffinity` section allows specifying rules that create affinity between 2 or more volumes that match the given labels. This should be used when you want to establish an affinity relationship between different volumes.

##### Schema

| Field  	| Description    | Optional? | Default |
|---------|----------------|-----------|---------|
|enforcement|Specifies if the given rule is required (hard) or preferred (soft)|Yes|required|
|topologyKey|Key for the node label that the system uses to denote a topology domain. The key can be for any node label that is present on the Kubernetes node. <br/>Using topologyKey requires nodes to be consistently labelled, i.e. every node in the cluster must have an appropriate label matching topologyKey. If some or all nodes are missing the specified topologyKey label, it can lead to unintended behavior.|Yes|empty|
|matchExpressions|matchExpressions is a list of label selector requirements. The requirements are ANDed.<br/><br/>The labels provided here are matched against the following:<ul><li>Kubernetes node labels</li><li>PVC labels</li><li>Portworx</li> storage pool labels</li>|No|empty|

##### Example uses cases

* [Collocate postgres volumes](/samples/k8s/volume-placement-postgres-volume-affinity.yaml)
* [Place volume on DB type nodes or collocate with postgres volumes](/samples/k8s/volume-db-nodes-or-postgres-affinity.yaml)

### volumeAntiAffinity

The `volumeAntiAffinity` section allows you to specify rules that create anti affinity between 2 or more volumes that match the given labels. This should be used when you want to establish an anti affinity (repel) relationship between different volumes

##### Schema

Same as Schema for [volumeAffinity](#volumeaffinity).

##### Example uses cases

[Do not collocate with other cassandra volumes](/samples/k8s/volume-placement-cassandra-volume-anti-affinity.yaml)
-->

## How to use

### Pre-requisities

1. **Portworx version**: 2.1.2 and above
2. **CRD version**: Make sure the VolumePlacementStrategy CRD (CustomResourceDefinition) is at the right version:
  * Unregister existing CustomResourceDefinition

    ```text
    kubectl delete crd volumeplacementstrategies.portworx.io
    ```
  * Register the following CustomResourceDefinition

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

### End user workflow

1. User applies one or more VolumePlacementStrategy specs as per their requirements
2. User creates a StorageClass that references the VolumePlacementStrategy. [(Example)](/samples/k8s/sc-with-ssd-affinity.yaml)
3. Users creates a PVC from the StorageClass [(Example)](/samples/k8s/pvc-with-ssd-affinity.yaml)



<!--
The next section covers more detailed end-to-end examples.
## End-to-end examples

#### Example 1: Default storage class and PVC

If users don’t want to explicitly override the volume placement decisions, no changes are needed. Users create PVCs as [documented here](https://docs.portworx.com/scheduler/kubernetes/dynamic-provisioning.html).

#### Example 2: Place volumes on SSDs

This examples places volumes only on SSD storage pools.

1. User creates [this VolumePlacementStrategy](/samples/k8s/volume-placement-ssd-pool-affinity.yaml)
2. User creates [this StorageClass](/samples/k8s//sc-with-ssd-affinity.yaml)
3. User creates [this PVC](/samples/k8s/pvc-with-ssd-affinity.yaml)

#### Example 3: For statefulsets, place log and data volumes on same node but each volume for each replica should be on different nodes

Consider the following general guidance:

1. Create log volumes only on SSDs (required)
2. Don’t collocate log volumes (required)
3. Collocate data volumes with log volumes (required)
4. Don’t collocate data volumes (required)
5. If there is a 3rd or more types of volumes in the statefulset replica:
  * Collocate foo volumes with log volumes (required)
  * Don’t collocate foo volumes (required)

Below are the specs

1. User creates this [VolumePlacementStrategy](/samples/k8s/log-volume-placement.yaml) to place log volumes on SSD and not collocate 2 log volumes on same node
2. User creates this [VolumePlacementStrategy](/samples/k8s/data-volume-placement.yaml) to place data volumes on same node as log volumes and not collocate 2 data volumes on same node
3. User creates this [StorageClass](/samples/k8s/sc-log-volume.yaml) for log volumes
4. User creates this [StorageClass](/samples/k8s/sc-data-volume.yaml) for data volumes
-->
