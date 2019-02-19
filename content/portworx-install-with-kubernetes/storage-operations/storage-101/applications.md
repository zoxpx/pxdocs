---
title: Stateful applications
weight: 3
keywords: portworx, kubernetes, PVCs
description: Learn essential concepts about running stateful applications using persistent volumes on Kubernetes
series: k8s-101
---

When working on stateful applications on Kubernetes, users typically deal with Deployments and Statefulsets. In theory, any [Kubernetes workload type](https://kubernetes.io/docs/concepts/workloads/) that can mount a volume can use a PersistentVolumeClaim.

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

### Example

Let's take an example.

```text
apiVersion: "apps/v1"
kind: StatefulSet
metadata:
  name: cassandra
spec:
  serviceName: cassandra
  replicas: 3
  template:
    metadata:
      labels:
        app: cassandra
    spec:
      schedulerName: stork
      containers:
      - name: cassandra
        image: gcr.io/google-samples/cassandra:v12
        imagePullPolicy: Always
        ports:
        - containerPort: 7000
          name: intra-node
        - containerPort: 7001
          name: tls-intra-node
        - containerPort: 7199
          name: jmx
        - containerPort: 9042
          name: cql
        resources:
          limits:
            cpu: "500m"
            memory: 1Gi
          requests:
           cpu: "500m"
           memory: 1Gi
        securityContext:
          capabilities:
            add:
              - IPC_LOCK
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "PID=$(pidof java) && kill $PID && while ps -p $PID > /dev/null; do sleep 1; done"]
        env:
          - name: MAX_HEAP_SIZE
            value: 512M
          - name: HEAP_NEWSIZE
            value: 100M
          - name: CASSANDRA_SEEDS
            value: "cassandra-0.cassandra.default.svc.cluster.local"
          - name: CASSANDRA_CLUSTER_NAME
            value: "K8Demo"
          - name: CASSANDRA_DC
            value: "DC1-K8Demo"
          - name: CASSANDRA_RACK
            value: "Rack1-K8Demo"
          - name: CASSANDRA_AUTO_BOOTSTRAP
            value: "false"
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        readinessProbe:
          exec:
            command:
            - /bin/bash
            - -c
            - /ready-probe.sh
          initialDelaySeconds: 15
          timeoutSeconds: 5
        # These volume mounts are persistent. They are like inline claims,
        # but not exactly because the names need to match exactly one of
        # the stateful pod volumes.
        volumeMounts:
        - name: cassandra-data
          mountPath: /var/lib/cassandra
  # These are converted to volume claims by the controller
  # and mounted at the paths mentioned above.
  volumeClaimTemplates:
  - metadata:
      name: cassandra-data
      annotations:
        volume.beta.kubernetes.io/storage-class: px-storageclass
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

In the above spec,

* **replicas: 3** declares that you want 3 replicas for your cassandra cluster.
* **schedulerName: stork** enables to use [STORK](https://github.com/libopenstorage/stork) scheduler to enable more efficient placement of the pods and faster recovery for failed nodes.
* **volumeClaimTemplates** declares the template to use for the PVC that will be created for each replica pod. The names of the dynamically created PVCs will be cassandra-data-cassandra-0, cassandra-data-cassandra-1 and cassandra-data-cassandra-2.

{{<info>}}[The Cassandra on Kubernetes
page](/portworx-install-with-kubernetes/application-install-with-kubernetes/cassandra) has a detailed end-to-end example.{{</info>}}

## Useful References

* [Interactive tutorial - Cassandra Stateful Set on Portworx](https://www.katacoda.com/portworx/scenarios/px-cassandra)
* [Interactive tutorial - HA PostgreSQL on Kubernetes with Portworx](https://www.katacoda.com/portworx/scenarios/px-k8s-postgres-all-in-one)
* [Interactive tutorial - Deploy Kafka and Zookeeper on Kubernetes using Portworx volumes] (https://www.katacoda.com/portworx/scenarios/px-kafka)
* [Interactive tutorial - Deploy Mongo on Portworx volumes using Helm](https://www.katacoda.com/portworx/scenarios/px-helm-mongo)