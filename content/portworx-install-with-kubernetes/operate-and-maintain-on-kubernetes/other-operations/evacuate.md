---
title: Evacuating a Portworx node
keywords: evacuate, evacuation, drain, kubernetes, k8s
description: Evacuating a Portworx node.
---

Sometimes it is necessary to evacuate a node of both workloads and storage. You may want to do this before an upgrade or other maintenance, or you might be trying to rebalance your workloads across the cluster. Note that if you are decommisioning a node, then the steps to do this should be followed [here](https://docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node/). Also note that upgrades can be done with minimal downtime [as documented](https://docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/upgrade/), so this process not a prerequisite.

 * Disable Kubernetes provisioning - cordon the node to prevent any further pods from being scheduled

```text
kubectl cordon <oldNode>
```

 * Obtain a list of volumes on the node

```text
pxctl volume list --node-id <oldNodeID>
```

 * For each volume, reduce the number of replicas (in this example, from 3 to 2) - since there can be at most 3 replicas of a Portworx volume, the replication factor has to be reduced befored it can be increased

```text
pxctl volume ha-update --repl 2 <volume> --node <oldNodeID>
```

 * For each volume, recreate the replicas elsewhere - increase the replication factor and specify the node on which to place it

```text
pxctl volume ha-update --repl 3 <volume> --node <newNodeID>
```

 * Delete the pods - Kubernetes will ensure the pods are reprovisioned on another node, and Stork will try to ensure they land on the node with the new replicas

```text
kubectl get pods -o wide | grep <node>
kubectl delete pod <pod>
```
