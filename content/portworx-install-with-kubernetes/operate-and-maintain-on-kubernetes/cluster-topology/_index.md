---
title: Cluster Topology awareness
weight: 4
keywords: portworx, pxctl, command-line tool, cli, reference, kubernetes, geography, locality, rack, zone, region
description: Learn how Portworx nodes can detect where they are placed in the Kubernetes cluster to influence replicas and performance.
noicon: true
series: k8s-op-maintain
---

You can provide your cluster topology information to Portworx using Kubernetes node labels. To understand how Portworx uses these for volumes, refer to [this page](/concepts/update-geography-info/).

## Region and Zone information

### Cloud

For Kubernetes clusters on well-known cloud providers (AWS, GCP, Azure, IBM, VMware etc), the Kubernetes nodes are prepopulated well-known failure domain labels.

Portworx parses these labels to update it's understanding of the cluster topology. Users don't need to perform any additional steps.

|**Label Name** |**Purpose**|
|-------------------------|------------|
|     failure-domain.beta.kubernetes.io/region | Region in which the node resides|
|     failure-domain.beta.kubernetes.io/zone | Zone in which the node resides|

### On-premise

You can label Kubernetes nodes with following labels to inform Portworx about region and zone of the nodes.

|**Label Name** |**Purpose**|
|-------------------------|------------|
|     px/region | Region in which the node resides|
|     px/zone | Zone in which the node resides|

## Rack information

To provide rack information to Portworx, you need to label Kubernetes nodes with `px/rack=rack1`, where *px/rack* is the key and *rack1* is the value identifying the rack of which the node is a part of. Make sure the label is a string not starting with a special character or a number.

#### Example

Following example updates rack information for a node.

Run the following command to list the existing nodes and their labels.

```text
kubectl get nodes --show-labels
```

```output
NAME      STATUS    AGE       VERSION   LABELS
vm-1      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-1,node-role.kubernetes.io/master=
vm-2      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-2
vm-3      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-3
```

To indicate node `vm-2` is placed on `rack1` update the node label in the following way:

```text
kubectl label nodes vm-2 px/rack=rack1
```

Now let's check your updated node labels.

```text
kubectl get nodes --show-labels
```

```output
NAME      STATUS    AGE       VERSION   LABELS
vm-1      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-1,node-role.kubernetes.io/master=
vm-2      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-2,px/rack=rack1
vm-3      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-3
```

This verifies that node vm-2 has the new `px/rack` label.

Double check if the rack information is reflected in the PX cluster.

```text
pxctl cluster provision-status
```

```output
NODE        NODE STATUS        POOL        POOL STATUS .....   ZONE           REGION        RACK
vm-2        Online                0        Online      .....   default        default       rack1
vm-3        Online                0        Online      .....   default        default       default
```

The node vm-2 which was labelled `rack1` is reflected on the PX node while the unlabelled node vm-3 is still using the `default` rack info.

All the subsequent updates to the node labels will be automatically picked up by the PX nodes. A deletion of a `px/rack` label will also be reflected.

## Specifying replica placement for volumes

Once the nodes are updated with rack info you can specify how the volume data can spread across your different racks.

Following is an example of a storage class that replicates its volume data across racks `rack1` and `rack2`

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: px-postgres-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   shared: "true"
   racks: "rack1,rack2"
```

Any PVC created using the above storage class will have a replication factor of 2 and will have one copy of its data on `rack1` and the other copy on `rack2`

To do the same for regions and zones, you can use `regions` and `zones` as paramters in the StorageClass respectively.
