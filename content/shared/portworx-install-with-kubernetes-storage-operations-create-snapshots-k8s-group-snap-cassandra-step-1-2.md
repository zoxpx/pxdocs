---
title: Shared content for Kubernetes snapshots - cassandra steps 1 & 2
description: Shared content for Kubernetes snapshots - cassandra steps 1 & 2
keywords: snapshots, cassandra, kubernetes, k8s
hidden: true
---

#### Step 1: Deploy cassandra statefulset and PVCs

Following spec creates a replica 3 cassandra statefulset. Each replica pod will use its own PVC.

```text
##### Portworx storage class
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-repl2
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "2"
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cassandra
  name: cassandra
spec:
  clusterIP: None
  ports:
    - port: 9042
  selector:
    app: cassandra

---

apiVersion: "apps/v1"
kind: StatefulSet
metadata:
  name: cassandra
spec:
  selector:
    matchLabels:
      app: cassandra
  serviceName: cassandra
  replicas: 3
  template:
    metadata:
      labels:
        app: cassandra
    spec:
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
          mountPath: /cassandra_data
  # These are converted to volume claims by the controller
  # and mounted at the paths mentioned above.
  volumeClaimTemplates:
  - metadata:
      name: cassandra-data
      labels:
        app: cassandra
      annotations:
        volume.beta.kubernetes.io/storage-class: portworx-repl2
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 2Gi
```

#### Step 2: Wait for all cassandra pods to be running

List the cassandra pods:

```text
kubectl get pods -l app=cassandra
```

```output
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          3m
cassandra-1   1/1       Running   0          2m
cassandra-2   1/1       Running   0          1m
```

Once you see all the 3 pods, you can also list the cassandra PVCs.

```text
kubectl get pvc -l app=cassandra
```

```output
NAME                         STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
cassandra-data-cassandra-0   Bound     pvc-ff752ad9-1607-11e9-a9a4-080027ee1df7   2Gi        RWO            stork-snapshot-sc   3m
cassandra-data-cassandra-1   Bound     pvc-ff767dcf-1607-11e9-a9a4-080027ee1df7   2Gi        RWO            stork-snapshot-sc   2m
cassandra-data-cassandra-2   Bound     pvc-ff78173c-1607-11e9-a9a4-080027ee1df7   2Gi        RWO            stork-snapshot-sc   1m
```
