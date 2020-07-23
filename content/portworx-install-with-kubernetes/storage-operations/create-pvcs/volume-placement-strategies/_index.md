---
title: Volume Placement Strategies
weight: 2
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets, volume placement
description: Learn how to use Portworx Volume Placement Strategies to control how volumes are placed across your cluster
series: k8s-vol
---
When you provision volumes, Portworx places them throughout the cluster and across configured failure domains to provide fault tolerance. While this default manner of operation works well in many scenarios, you may wish to control how Portworx handles volume and replica provisioning more explicitly. You can do this by creating VolumePlacementStrategy CRDs.

Within a VolumePlacementStrategy CRD, you can specify a series of rules which control volume and volume replica provisioning on nodes and pools in the cluster based on the labels they have.

<!--
how the volume replicas are allocated with respect to other volumes in the cluster
how the replicas are allocated with respect to each other.
-->

## Understand the VolumePlacementStrategy spec

You can define your VolumePlacementStrategy by creating a spec containing affinity rule sections. Affinity rules instruct Portworx on where to place volumes and volume replicas within your cluster and come in two flavors: affinity and antiaffinity.

### replicaAffinity

The `replicaAffinity` section allows you to specify rules relating replicas within a volume. You can use these rules to place replicas of a volume on nodes or pools which match the specified labels in the rule. You can constrain the replicas to be allocated in a certain failure domain by specifying the topology key used to define the failure domain.

### replicaAntiAffinity

The `replicaAntiAffinity` section allows you to specify a dissociation rule for replicas within a volume. You can use this to allocate replicas across failure domains by specifying the topology key of the failure domain.

### volumeAffinity

The `volumeAffinity` section allows you to colocate volumes by specifying rules that place replicas of a volume together with those of another volume for which the specified labels match.

### volumeAntiAffinity

The `volumeAntiAffinity` section allows you to specify dissociation rules between 2 or more volumes that match the given labels. Use this when you want to exclude failure domains, nodes or storage pools that match the given labels for one or more volumes.

<!--
For more information on specific rules, see the following sections of the CRD reference guide:

* [replicaAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placementp-strategies/crd-reference#replicaaffinity)
* [replicaAntiAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placementp-strategies/crd-reference#replicaantiaffinity)
* [volumeAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placementp-strategies/crd-reference#volumeaffinity)
* [volumeAntiAffinity](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placementp-strategies/crd-reference#volumeantiaffinity)
-->

### Example

```text
apiVersion: portworx.io/v1beta2
kind: VolumePlacementStrategy
metadata:
  name: <your_strategy_name>
spec:
    replicaAffinity:         <1>
      key: media_type        <2>
      operator: In           <3>
      values:
        - "SSD"              <4>
```

The example above instructs Portworx to perform the following:

1. `replicaAffinity` directs Portworx to create replicas under the preferred conditions defined beneath it
2. `key` specifies the `media_type` label, directing Portworx to create replicas on pools which have the "media_type" label
3. `operator` specifies the `In` operator, directing Portworx to create replicas in the media type
4. `values` specifies the `SSD` label, directing Portworx to create replicas on SSD pools

## Understand the VolumePlacementStrategy CRD's place within your cluster

Portworx links a VolumePlacementStrategy to a StorageClass through the StorageClass `placement_strategy` parameter. All PVCs that refer to that StorageClass adhere to the linked VolumePlacementStrategy rules. Volumes that are provisioned from the PVCs place, and have their replicas placed, according to the rules defined in the placement strategy.

![Diagram showing VPS linking to SC with PVC and volume linked underneath](/img/volumePlacementStrat.png)

## Understand common use-cases

How you choose to place and distribute your volumes and replicas depends on the kinds of apps you're using on your cluster, your cluster topology, and your goals. The following examples illustrate some common uses of VolumePlacementStrategies:

### Volume placement use-cases

Consider the following example: assume you have an application that relies on multiple volumes, such as a webserver. If your volumes are distributed over multiple nodes, your app may be subject to latency, and your cluster may become congested with unnecessary network activity. You can avoid this by creating a VolumePlacementStrategy, which colocates your app's volumes on the same set of nodes and pools:

```text
apiVersion: portworx.io/v1beta2
kind: VolumePlacementStrategy
metadata:
  name: webserver-volume-affinity
spec:
  volumeAffinity:
    - matchExpressions:
      - key: app
        operator: In
        values:
          - webserver
```

Consider another example: Assume you're running an app that performs replication internally, such as Cassandra. If you don't distribute volumes across failure zones, a node failure may disrupt services. You can avoid this by creating a VolumePlacementStrategy, which distributes your app's volumes over multiple failure zones:

```text
apiVersion: portworx.io/v1beta2
kind: VolumePlacementStrategy
metadata:
  name: webserver-volume-affinity
spec:
  volumeAntiAffinity:
  - topologyKey: failure-domain.beta.kubernetes.io/zone
```

### Replica placement use-cases

Consider the following example: Assume you're running an app with a replication factor of 2. If you don't distribute replicas across failure zones, a node failure may disrupt services. You can avoid this by creating a VolumePlacementStrategy, which distributes your app's replicas over multiple failure zones:
<!-- this is the default behavior, probably want to remove -->
```text
spec:
  replicaAntiAffinity:
    - topologyKey: failure-domain.beta.kubernetes.io/zone
```

Consider another example: Assume you're running an app on a cloud cluster. Some cloud providers' zones can more expensive, depending on demand. You can avoid this by creating a VolumePlacementStrategy, which restricts your app's replicas to a cheaper zone:

```text
spec:
  replicaAffinity:
    - matchExpressions:
      - key: failure-domain.beta.kubernetes.io/zone
        operator: NotIn
        values:
        - "us-east-1a"
```
