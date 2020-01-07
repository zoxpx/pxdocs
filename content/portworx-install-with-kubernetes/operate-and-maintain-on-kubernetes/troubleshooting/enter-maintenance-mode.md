---
title: Enter Maintenance Mode
weight: 7
keywords: Troubleshoot, maintenance mode, Kubernetes, k8s, drive removal, drive replacement, pool list, pool priority
description: Steps needed to put Portworx into maintenance mode in a Kubernetes cluster
---

This guide describes a recommended workflow for putting a Portworx node in maintenance mode in your Kubernetes cluster.

### Step 1. Migrate application pods using Portworx volumes that are running on this node

Before putting Portworx in maintenance mode on a node, applications running on that node using Portworx need to be migrated. If Portworx is in maintenance mode, existing application pods will end up with read-only volumes and new pods will fail to start.

You have 2 options for migrating applications.

**Migrate all pods**

* Drain the node using: `kubectl drain <node>`

**Migrate selected pods**

1. Cordon the node using:

    ```text
    kubectl cordon <node>
    ```

2. Delete the application pods using Portworx volumes using:

    ```text
    kubectl delete pod <pod-name>
    ```

* Since application pods are expected to be managed by a controller like `Deployement` or `StatefulSet`, Kubernetes will spin up a new replacement pod on another node.

### Step 2. Enter maintenance mode

```text
pxctl service maintenance --enter
```

This takes Portworx out of an “Operational” state for a given node. Perform whatever maintenance tasks are needed.

### Step 3. Exit maintenance mode

Once you are done with maintenance tasks, run:

```text
pxctl service maintenance --exit
```

This puts Portworx back in to “Operational” state for a given node.

###  Step 4. Uncordon the node

You can now uncordon the node using:

```text
kubectl uncordon <node>
```
