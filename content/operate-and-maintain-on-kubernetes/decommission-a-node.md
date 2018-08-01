---
title: Decommission a Node
weight: 4
---

This guide describes a recommended workflow for decommissioning a Portworx node in your Kubernetes cluster.

#### 1. Migrate application pods using portworx volumes that are running on this node {#1-migrate-application-pods-using-portworx-volumes-that-are-running-on-this-node}

If you plan to remove Portworx from a node, applications running on that node using Portworx need to be migrated. If Portworx is not running, existing application containers will end up with read-only volumes and new ones will fail to start.

You have 2 options for migrating applications.

**Migrate all pods**

* Drain the node using: `kubectl drain <node>`

**Migrate selected pods**

1. Cordon the node using: `kubectl cordon <node>`
2. Delete the application pods using portworx volumes using: `kubectl delete pod <pod-name>`
   * Since application pods are expected to be managed by a controller like `Deployement` or `StatefulSet`, Kubernetes will spin up a new replacement pod on another node.

#### 2. Decommission Portworx {#2-decommission-portworx}

To decommission Portworx, perform the following steps:

**a\) Remove Portworx from the cluster**

Follow [this guide](https://docs.portworx.com/maintain/scale-down.html) to decommission the Portworx node from the cluster.

**b\) Remove Portworx installation from the node**

Apply the _px/enabled=remove_ label and it will remove the existing Portworx systemd service. It will also apply the _px/enabled=false_ label to stop Portworx from running in future.

For example, below command will remove existing Portworx installation from _minion2_ and also ensure that Portworx pod doesn’t run there in future.

```text
kubectl label nodes minion2 px/enabled=remove --overwrite
```

> **Decommission from Kubernetes:**  
>  If the plan is to decommission this node altogether from the Kubernetes cluster, no further steps are needed.

#### 3. Ensure application pods using Portworx don’t run on this node {#3-ensure-application-pods-using-portworx-dont-run-on-this-node}

If you need to continue using the Kubernetes node without Portworx, you will need to ensure your application pods using Porworx volumes don’t get scheduled here.

One way to achieve is this to use [inter-pod affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#inter-pod-affinity-and-anti-affinity-beta-feature)

* Basically we will define a pod affinity rule in your applications that ensure that application pods get scheduled only on nodes where the Portworx pod is running.
* Consider below nginx example:

  ```text
  apiVersion: apps/v1beta1
  kind: Deployment
  metadata:
  name: nginx-deployment
  spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        # Inter-pod affinity rule restricting nginx pods to run only on nodes where Portworx pods are running (Portworx pods have a label
        # name=portworx which is used in the rule)
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: name
                operator: In
                values:
                - "portworx"
            topologyKey: kubernetes.io/hostname
            namespaces:
            - "kube-system"
      hostNetwork: true
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-persistent-storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: nginx-persistent-storage
        persistentVolumeClaim:
          claimName: px-nginx-pvc
  ```

#### 4. Uncordon the node {#4-uncordon-the-node}

You can now uncordon the node using: `kubectl uncordon <node>`

If you want to have Portworx start on this node at a later point in time and join as a new node, follow the [node rejoin steps](https://docs.portworx.com/scheduler/kubernetes/k8s-node-rejoin.html).

