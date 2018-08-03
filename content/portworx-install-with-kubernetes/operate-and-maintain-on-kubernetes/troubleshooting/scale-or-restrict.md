---
title: Scale or Restrict
weight: 6
---

#### Scaling {#scaling}

Portworx is deployed as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Therefore it automatically scales as you grow your Kubernetes cluster. There are no additional requirements to install Portworx on the new nodes in your Kubernetes cluster.

#### Restricting PX to certain nodes {#restricting-px-to-certain-nodes}

Choose either of the below options based on current state of Portworx in the cluster.

**Portworx is not yet deployed in your cluster**

To restrict Portworx to run on only a subset of nodes in the Kubernetes cluster, we can use the _px/enabled_ Kubernetes label on the minion nodes you _do not_ wish to install Portworx on.

Below are examples to prevent Portworx from installing and starting on _minion2_ and _minion5_ nodes.

```text
kubectl label nodes minion2 minion5 px/enabled=false --overwrite
```

**Portworx has already been deployed in your cluster**

If Portworx is already deployed in your cluster, follow [Decommission a Portworx node in Kubernetes](https://docs.portworx.com/scheduler/kubernetes/k8s-node-decommission.html) to decommision Portworx from your cluster.

