---
title: Stateful applications
weight: 3
keywords: portworx, kubernetes, PVCs
description: Learn essential concepts about running stateful applications using persistent volumes on Kubernetes
series: k8s-101
---

When working on stateful applications on Kubernetes, users typically deal with Deployments and Statefulsets.

## Deployments

A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)) is the most common controller provides declarative way to manage your pods.

You describe a desired state in a Deployment object, and the Deployment controller changes the actual state to the desired state at a controlled rate.

### Example

Let's take an example.

```text
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:9.5
        imagePullPolicy: "IfNotPresent"
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_USER
          value: pgbench
        - name: POSTGRES_PASSWORD
          value: superpostgres
        - name: PGBENCH_PASSWORD
          value: superpostgres
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - mountPath: /var/lib/postgresql/data
          name: postgredb
      volumes:
      - name: postgredb
        persistentVolumeClaim:
          claimName: postgres-data
```

In above spec,

* **replicas: 1** declares that you want to have one instance/replica of postgres running for this deployment.
* **image: postgres:9.5** is the docker image used for the deployment.
* **claimName: postgres-data** under the *volumes* section defines a (PersistentVolumeClaim) PVC that can be used by this deployment.
* **name: postgredb** under *volumeMounts* mounts the PVC at */var/lib/postgresql/data*.

## Statefulsets

A [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

A StatefulSet operates under the same pattern as any other Controller. You define your desired state in a StatefulSet object, and the StatefulSet controller makes any necessary updates to get there from the current state.

Elasticsearch, Kafka, Cassandra etc are examples of distributed systems that can take advantage of StatefulSets.

### Things to watch out for when using Statefulsets

StatefulSets favor consistency over availability. This results in certain behaviors which may not be very obvious if you have been using Deployments.

* Each pod in a statefulset has a storage identity. So each replica pod in a statefulset will remember the PVC it's using. This mapping is done using the [ordinal index](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-identity) of the pod.
* When a worker node goes down and a statefulset pod was running on that worker, Kubernetes scheduler will not spin up a new replacement pod if the node stays down. A new pod is spun up only if the worker node goes in NodeLost state and then comes up online later on.
* Scaling up and down in statefulsets is [ordered](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#deployment-and-scaling-guarantees). When scaling up, pods are created sequentially, in order from {0..N-1}. When Pods are being deleted, they are terminated in reverse order, from {N-1..0}.
