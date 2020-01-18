---
title: Kafka with Zookeeper on Portworx
linkTitle: Kafka with Zookeeper
keywords: apache kafka, zookeeper, install, kubernetes, k8s, scaling, failover
description: See how you can deploy Apache Kafka with Zookeeper on Kubernetes with state using Portworx.
weight: 3
noicon: true
---

This page provides instructions for deploying Apache Kafka and Zookeeper with Portworx on Kubernetes.

## The Portworx StorageClass for volume provisioning
Portworx provides volume(s) to Zookeeper as well as Kafka. Create `portworx-sc.yaml` with Portworx as the provisioner.

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  priority_io: "high"
  group: "zk_vg"
  fg: "true"
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc-rep2
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "2"
  priority_io: "high"
  group: "kafka_vg"
  fg: "true"
---
```

Then apply the configuration:

```text
kubectl apply -f portworx-sc.yaml
```

## Install Zookeeper

A StatefulSet in Kubernetes requires a headless service to provide network identity to the pods it creates. A headless service is also needed when Kafka is deployed. A headless service does not use a cluster IP. For information on headless services, read this [article](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/).

This is also important for the later stages of the deployment of Kafka, since, we would need to access Zookeeper via the DNS records that are created by this headless service.

Create a file called `zookeeper-all.yaml` with the following content:

```text
apiVersion: v1
kind: Service
metadata:
  name: zk-headless
  labels:
    app: zk-headless
spec:
  ports:
  - port: 2888
    name: server
  - port: 3888
    name: leader-election
  clusterIP: None
  selector:
    app: zk
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: zk-config
data:
  ensemble: "zk-0;zk-1;zk-2"
  jvm.heap: "2G"
  tick: "2000"
  init: "10"
  sync: "5"
  client.cnxns: "60"
  snap.retain: "3"
  purge.interval: "1"
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: zk-budget
spec:
  selector:
    matchLabels:
      app: zk
  minAvailable: 2
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: zk
spec:
  selector:
    matchLabels:
      app: zk
  serviceName: zk-headless
  replicas: 3
  template:
    metadata:
      labels:
        app: zk
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
      schedulerName: stork
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/running
                operator: NotIn
                values:
                - "false"
              - key: px/enabled
                operator: NotIn
                values:
                - "false"
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "app"
                    operator: In
                    values:
                    - zk-headless
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: k8szk
        imagePullPolicy: Always
        image: gcr.io/google_samples/k8szk:v1
        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
        env:
        - name : ZK_ENSEMBLE
          valueFrom:
            configMapKeyRef:
              name: zk-config
              key: ensemble
        - name : ZK_HEAP_SIZE
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: jvm.heap
        - name : ZK_TICK_TIME
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: tick
        - name : ZK_INIT_LIMIT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: init
        - name : ZK_SYNC_LIMIT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: tick
        - name : ZK_MAX_CLIENT_CNXNS
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: client.cnxns
        - name: ZK_SNAP_RETAIN_COUNT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: snap.retain
        - name: ZK_PURGE_INTERVAL
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: purge.interval
        - name: ZK_CLIENT_PORT
          value: "2181"
        - name: ZK_SERVER_PORT
          value: "2888"
        - name: ZK_ELECTION_PORT
          value: "3888"
        command:
        - sh
        - -c
        - zkGenConfig.sh && zkServer.sh start-foreground
        readinessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        volumeMounts:
        - name: datadir
          mountPath: /var/lib/zookeeper
      securityContext:
        runAsUser: 1000
        fsGroup: 1000
  volumeClaimTemplates:
  - metadata:
      name: datadir
    spec:
      storageClassName: portworx-sc
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 2Gi
```

Apply this configuration

```text
kubectl apply -f zookeeper-all.yaml
```

### Post Install Status - Zookeeper

Verify that the Zookeeper pods are running with provisioned Portworx volumes.

```text
kubectl get pods
```

```output
NAME      READY     STATUS    RESTARTS   AGE
zk-0      1/1       Running   0          23h
zk-1      1/1       Running   0          23h
zk-2      1/1       Running   0          23h
```

```text
kubectl get pvc
```

```output
NAME        STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
data-zk-0   Bound     pvc-b79e96e9-7b79-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc    23h
data-zk-1   Bound     pvc-faaedef8-7b7a-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc    23h
data-zk-2   Bound     pvc-0e7a636d-7b7b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc    23h
```

```text
kubectl get sts
```

```output
NAME      DESIRED   CURRENT   AGE
zk        3         3         1d
```

```text
pxctl volume inspect pvc-b79e96e9-7b79-11e7-a940-42010a8c0002
```

```output
Volume  :  816480848884203913
        Name                     :  pvc-b79e96e9-7b79-11e7-a940-42010a8c0002
        Size                     :  3.0 GiB
        Format                   :  ext4
        HA                       :  1
        IO Priority              :  LOW
        Creation time            :  Aug 7 14:07:16 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: k8s-0
        Device Path              :  /dev/pxd/pxd816480848884203913
        Labels                   :  pvc=data-zk-0
        Reads                    :  59
        Reads MS                 :  252
        Bytes Read               :  466944
        Writes                   :  816
        Writes MS                :  3608
        Bytes Written            :  53018624
        IOs in progress          :  0
        Bytes used               :  65 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  10.140.0.5

```

Verify that the Zookeeper ensemble is working.

```text
kubectl exec zk-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar
```

```output
WATCHER::
WatchedEvent state:SyncConnected type:None path:null
Created /foo
```

```text
kubectl exec zk-2 -- /opt/zookeeper/bin/zkCli.sh get /foo
```

```output
WATCHER::
WatchedEvent state:SyncConnected type:None path:null
cZxid = 0x10000004d
bar
ctime = Tue Aug 08 14:18:11 UTC 2017
mZxid = 0x10000004d
mtime = Tue Aug 08 14:18:11 UTC 2017
pZxid = 0x10000004d
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0

```

## Install Kafka

1. Retrieve the FQDN of each Zookeeper Pod by entering the following command:

    ```text
    for i in 0 1 2; do kubectl exec zk-$i -- hostname -f; done
    ```

    ```output
    zk-0.zk-headless.default.svc.cluster.local
    zk-1.zk-headless.default.svc.cluster.local
    zk-2.zk-headless.default.svc.cluster.local
    ```

2. Download the {{< direct-download url="/samples/k8s/kafka-all.yaml" name="kafka-all.yaml" >}} file and use the `zookeeper.connect` property to specify your Zookeeper hosts as a comma-separated list.

3. Apply the spec by entering the following command:

    ```text
    kubectl apply -f kafka-all.yaml
    ```

4. This step is optional. Run the following `kubectl apply` command if you are installing Kafka with Zookeeper on AWS EKS:

    ```text
    kubectl apply -f https://raw.githubusercontent.com/Yolean/kubernetes-kafka/master/rbac-namespace-default/node-reader.yml
    ```

    ```output
    clusterrole.rbac.authorization.k8s.io/node-reader created
    clusterrolebinding.rbac.authorization.k8s.io/kafka-node-reader created
    ```


### Post Install Status - Kafka

Verify Kafka resources created on the cluster.

```text
kubectl get pods -l "app=kafka" -n kafka -w
```

```output
NAME      READY     STATUS     RESTARTS   AGE
kafka-0   1/1       Running    0          17s
kafka-1   0/1       Init:0/1   0          3s
kafka-1   0/1       Init:0/1   0         4s
kafka-1   0/1       PodInitializing   0         5s
kafka-1   0/1       Running   0         6s
kafka-1   1/1       Running   0         9s
kafka-2   0/1       Pending   0         0s
kafka-2   0/1       Pending   0         1s
kafka-2   0/1       Pending   0         3s
kafka-2   0/1       Init:0/1   0         4s
kafka-2   0/1       Init:0/1   0         6s
kafka-2   0/1       PodInitializing   0         8s
kafka-2   0/1       Running   0         9s
kafka-2   1/1       Running   0         15s
```

```text
kubectl get pvc -n kafka
```

```output
NAME           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS       AGE
data-kafka-0   Bound     pvc-c405b033-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   1m
data-kafka-1   Bound     pvc-cc70447a-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   57s
data-kafka-2   Bound     pvc-d2388861-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   48s
```

```text
pxctl volume list
```

```output
ID                      NAME                                            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
523341158152507227      pvc-0e7a636d-7b7b-11e7-a940-42010a8c0002        3 GiB   1       no      no              LOW             0       up - attached on 10.140.0.4
816480848884203913      pvc-b79e96e9-7b79-11e7-a940-42010a8c0002        3 GiB   1       no      no              LOW             0       up - attached on 10.140.0.5
262949240358217536      pvc-c405b033-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.3
733731201475618092      pvc-cc70447a-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.5
360663112422496357      pvc-d2388861-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.4
168733173797215691      pvc-faaedef8-7b7a-11e7-a940-42010a8c0002        3 GiB   1       no      no              LOW             0       up - attached on 10.140.0.3
```

```text
pxctl volume inspect pvc-c405b033-7c4b-11e7-a940-42010a8c0002
```

```output
Volume  :  262949240358217536
        Name                     :  pvc-c405b033-7c4b-11e7-a940-42010a8c0002
        Size                     :  3.0 GiB
        Format                   :  ext4
        HA                       :  2
        IO Priority              :  LOW
        Creation time            :  Aug 8 15:10:51 UTC 2017
        Shared                   :  no
        Status                   :  up
        State                    :  Attached: k8s-2
        Device Path              :  /dev/pxd/pxd262949240358217536
        Labels                   :  pvc=data-kafka-0
        Reads                    :  37
        Reads MS                 :  8
        Bytes Read               :  372736
        Writes                   :  354
        Writes MS                :  3096
        Bytes Written            :  53641216
        IOs in progress          :  0
        Bytes used               :  65 MiB
        Replica sets on nodes:
                Set  0
                        Node     :  10.140.0.5
                        Node     :  10.140.0.3

```

**Verifying the Kafka installation**

Find the Kafka brokers

```text
for i in 0 1 2; do kubectl exec -n kafka kafka-$i -- hostname -f; done
```

```output
kafka-0.broker.kafka.svc.cluster.local
kafka-1.broker.kafka.svc.cluster.local
kafka-2.broker.kafka.svc.cluster.local
```

Create a topic with 3 partitions and which has a replication factor of 3

```text
kubectl exec -n kafka -it kafka-0 -- bash
```

```text
bin/kafka-topics.sh --zookeeper zk-headless.default.svc.cluster.local:2181 --create --if-not-exists --topic px-kafka-topic --partitions 3 --replication-factor 3
```

```output
Created topic "px-kafka-topic".
```

```text
bin/kafka-topics.sh --list --zookeeper zk-headless.default.svc.cluster.local:2181
```

```output
px-kafka-topic
```

```text
bin/kafka-topics.sh --describe --zookeeper zk-headless.default.svc.cluster.local:2181 --topic px-kafka-topic
```

```output
Topic:px-kafka-topic    PartitionCount:3        ReplicationFactor:3     Configs:
Topic: px-kafka-topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
Topic: px-kafka-topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
Topic: px-kafka-topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
```

Publish messages on the topic

```text
bin/kafka-console-producer.sh --broker-list kafka-0.broker.kafka.svc.cluster.local:9092,kafka-1.broker.kafka.svc.cluster.local:9092,kafka-2.broker.kafka.svc.cluster.local:9092 --topic px-kafka-topic
```

```output
>Hello Kubernetes!
>This is Portworx saying hello
>Kafka says, I am just a messenger
```

Consume messages from the topic

```text
bin/kafka-console-consumer.sh --zookeeper zk-headless.default.svc.cluster.local:2181 —topic px-kafka-topic --from-beginning
```

```output
This is Portworx saying hello
Hello Kubernetes!
Kafka says, I am just a messenger
```

## Scaling

Portworx runs as a DaemonSet in Kubernetes. Hence when you add a new node to your kuberentes cluster you do not need to explicitly run Portworx on it.

If you did use the [Terraform scripts](https://github.com/portworx/terraporx) to create a kubernetes cluster, you would need to update the minion count and apply the changes via Terraform to add a new Node.

The Portworx cluster before scaling the Kubernetes nodes.

```text
pxctl cluster list
```

```output
Cluster ID: px-kafka-cluster
Cluster UUID: 99c0fa42-03f5-4d05-a2fe-52d914ff39d2
Status: OK

Nodes in the cluster:
ID      DATA IP         CPU             MEM TOTAL       MEM FREE        CONTAINERS      VERSION         STATUS
k8s-0   10.140.0.5      8.717949        3.9 GB          2.3 GB          N/A             1.2.9-17d16e4   Online
k8s-1   10.140.0.3      4.081633        3.9 GB          2.2 GB          N/A             1.2.9-17d16e4   Online
k8s-2   10.140.0.4      9.5             3.9 GB          2.2 GB          N/A             1.2.9-17d16e4   Online

```

```text
kubectl get nodes -o wide
```

```output
NAME         STATUS    AGE       VERSION   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION
k8s-0        Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-1        Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-2        Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-3        Ready     19h       v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
k8s-master   Ready     2d        v1.7.0    <none>        Ubuntu 16.10   4.8.0-56-generic
```

Portworx scales along with your cluster.

```text
pxctl status
```

```output
Status: PX is operational
License: Trial (expires in 28 days)
Node ID: k8s-1
        IP: 10.140.0.4
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       MEDIUM          raid0           10 GiB  594 MiB Online  default default
        Local Storage Devices: 1 device
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/sdb        STORAGE_MEDIUM_SSD      10 GiB          07 Aug 17 12:48 UTC
        total                   -                       10 GiB
Cluster Summary
        Cluster ID: px-kafka-cluster
        Cluster UUID: 819e722c-cb51-4f5f-9ac6-f99420435a90
        IP              ID      Used    Capacity        Status
        10.140.0.4      k8s-1   594 MiB 10 GiB          Online (This node)
        10.140.0.3      k8s-2   594 MiB 10 GiB          Online
        10.140.0.5      k8s-0   655 MiB 10 GiB          Online
        10.140.0.6      k8s-3   338 MiB 10 GiB          Online
Global Storage Pool
        Total Used      :  2.1 GiB
        Total Capacity  :  40 GiB
```

```text
pxctl cluster list
```

```output
Cluster ID: px-kafka-cluster
Cluster UUID: 99c0fa42-03f5-4d05-a2fe-52d914ff39d2
Status: OK

Nodes in the cluster:
ID      DATA IP         CPU             MEM TOTAL       MEM FREE        CONTAINERS      VERSION         STATUS
k8s-1   10.140.0.4      8.163265        3.9 GB          2.2 GB          N/A             1.2.9-17d16e4   Online
k8s-2   10.140.0.3      6.565657        3.9 GB          2.2 GB          N/A             1.2.9-17d16e4   Online
k8s-0   10.140.0.5      4.102564        3.9 GB          2.3 GB          N/A             1.2.9-17d16e4   Online
k8s-3   10.140.0.6      4.040404        3.9 GB          3.4 GB          N/A             1.2.9-17d16e4   Online
```

Scale the Kafka cluster.

```text
kubectl scale -n kafka sts kafka --replicas=4
```

```output
statefulset "kafka" scaled
```

```text
kubectl get pods -n kafka -l "app=kafka" -w
```

```output
NAME      READY     STATUS            RESTARTS   AGE
kafka-0   1/1       Running           0          3h
kafka-1   1/1       Running           0          3h
kafka-2   1/1       Running           0          3h
kafka-3   0/1       PodInitializing   0          24s
kafka-3   0/1       Running           0          32s
kafka-3   1/1       Running           0          34s
```

```text
kubectl get pvc -n kafka
```

```output
NAME           STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS       AGE
data-kafka-0   Bound     pvc-c405b033-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   3h
data-kafka-1   Bound     pvc-cc70447a-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   3h
data-kafka-2   Bound     pvc-d2388861-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   3h
data-kafka-3   Bound     pvc-df82a9b0-7c68-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   6m

```

Verify that the newly created kafka broker is part of the cluster.

```text
kubectl exec -n kafka -it kafka-0 -- bash
```

```text
zkCli.sh
```

You'll see a prompt similar to this:

```
[zk: localhost:2181(CONNECTED) 0]
```

Next, type:

```text
ls /brokers/ids
```

```output
[0, 1, 2, 3]
```

```text
ls /brokers/topics
```

```output
[px-kafka-topic]
```

```text
get /brokers/ids/3
```

```output
{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://kafka-3.broker.kafka.svc.cluster.local:9092"],"jmx_port":-1,"host":"kafka-3.broker.kafka.svc.cluster.local","timestamp":"1502217586002","port":9092,"version":4}
cZxid = 0x1000000e9
ctime = Tue Aug 08 18:39:46 UTC 2017
mZxid = 0x1000000e9
mtime = Tue Aug 08 18:39:46 UTC 2017
pZxid = 0x1000000e9
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x25dbd0e499e000b
dataLength = 246
numChildren = 0

```

## Failover

### Pod Failover for Zookeeper

Killing the Zookeeper Java process in the container terminates the pod. You could alternatively delete the pod as well. The Portworx volumes provide durable storage to the Zookeeper pods which are run as a StatefulSet. Get the earlier inserted value from Zookeeper to verify the same.

```text
kubectl exec zk-0 -- pkill java
```

```text
kubectl get pod -w -l "app=zk"
```

```output
NAME      READY     STATUS    RESTARTS   AGE
zk-0      1/1       Running   0          1d
zk-1      1/1       Running   0          1d
zk-2      1/1       Running   0          1d
zk-0      0/1       Error     0          1d
zk-0      0/1       Running   1          1d
zk-0      1/1       Running   1          1d
```

```text
kubectl exec zk-0 -- zkCli.sh get /foo
```

```output
WATCHER::
WatchedEvent state:SyncConnected type:None path:null
bar
cZxid = 0x10000004d
ctime = Tue Aug 08 14:18:11 UTC 2017
mZxid = 0x10000004d
mtime = Tue Aug 08 14:18:11 UTC 2017
pZxid = 0x10000004d
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0

```

### Pod Failover for Kafka

Find the hosts of the running kafka cluster, cordon a node so that pods are scheduled on it. Kill a kafka pod and notice that it is scheduled on a newer node, joining the cluster back again with durable storage which is backed by the Portworx volume.

```text
kubectl get pods -n kafka -o wide
```

```output
NAME      READY     STATUS    RESTARTS   AGE       IP           NODE
kafka-0   1/1       Running   0          21h       10.0.160.3   k8s-2
kafka-1   1/1       Running   0          21h       10.0.192.3   k8s-0
kafka-2   1/1       Running   0          21h       10.0.64.4    k8s-1
kafka-3   1/1       Running   0          18h       10.0.112.1   k8s-3
```

```text
kubectl cordon k8s-0
```

```output
node "k8s-0" cordoned
```

```text
kubectl get nodes
```

```output
NAME         STATUS                     AGE       VERSION
k8s-0        Ready,SchedulingDisabled   2d        v1.7.0
k8s-1        Ready                      2d        v1.7.0
k8s-2        Ready                      2d        v1.7.0
k8s-3        Ready                      19h       v1.7.0
k8s-master   Ready                      2d        v1.7.0
```

```text
kubectl get pvc -n kafka | grep data-kafka-1
```

```output
data-kafka-1   Bound     pvc-cc70447a-7c4b-11e7-a940-42010a8c0002   3Gi        RWO           portworx-sc-rep2   22h
```

```text
/opt/pwx/bin/pxctl volume list | grep pvc-cc70447a-7c4b-11e7-a940-42010a8c0002
```

```output
733731201475618092      pvc-cc70447a-7c4b-11e7-a940-42010a8c0002        3 GiB   2       no      no              LOW             0       up - attached on 10.140.0.5
```

```text
kubectl exec -n kafka -it kafka-0 -- bash
```

```text
bin/kafka-topics.sh --describe --zookeeper zk-headless.default.svc.cluster.local:2181 --topic px-kafka-topic
```

```output
Topic:px-kafka-topic    PartitionCount:3        ReplicationFactor:3     Configs:
        Topic: px-kafka-topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,1,2
        Topic: px-kafka-topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
        Topic: px-kafka-topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
```

```text
kubectl delete po/kafka-1 -n kafka
```

```output
pod "kafka-1" deleted
```

```text
kubectl get pods -n kafka -w
```

```output
NAME      READY     STATUS        RESTARTS   AGE
kafka-0   1/1       Running           0         22h
kafka-1   0/1       Terminating       0         22h
kafka-2   1/1       Running           0         22h
kafka-3   1/1       Running           0         18h
kafka-1   0/1       Terminating       0         22h
kafka-1   0/1       Terminating       0         22h
kafka-1   0/1       Pending           0         0s
kafka-1   0/1       Pending           0         0s
kafka-1   0/1       Init:0/1          0         0s
kafka-1   0/1       Init:0/1          0         2s
kafka-1   0/1       PodInitializing   0         3s
kafka-1   0/1       Running           0         5s
kafka-1   1/1       Running           0         11s
```

```text
kubectl get pods -n kafka -o wide
```

```output
NAME      READY     STATUS    RESTARTS   AGE       IP           NODE
kafka-0   1/1       Running   0          22h       10.0.160.3   k8s-2
kafka-1   1/1       Running   0          1m        10.0.112.2   k8s-3
kafka-2   1/1       Running   0          22h       10.0.64.4    k8s-1
kafka-3   1/1       Running   0          18h       10.0.112.1   k8s-3
```

```text
bin/kafka-topics.sh --describe --zookeeper zk-headless.default.svc.cluster.local:2181 --topic px-kafka-topic
```

```output
Topic:px-kafka-topic    PartitionCount:3        ReplicationFactor:3     Configs:
Topic: px-kafka-topic   Partition: 0    Leader: 0       Replicas: 0,1,2 Isr: 0,2,1
Topic: px-kafka-topic   Partition: 1    Leader: 1       Replicas: 1,2,0 Isr: 2,0,1
Topic: px-kafka-topic   Partition: 2    Leader: 2       Replicas: 2,0,1 Isr: 2,0,1
```

### Node Failover

In the case of a statefulset if the node is unreachable, which could happen in either of two cases

* The node is down for maintenance
* There has been a network partition.

There is no way for kubernetes to know which of the case is it. Hence Kubernetes would not schedule the Statefulset and the pods running on those nodes would enter the ‘Terminating’ or ‘Unknown’ state after a timeout. If there was a network partition and when the partition heals, kubernetes will complete the deletion of the Pod and remove it from the API server. It would subsequently schedule a new pod to honor the replication requirements mentioned in the Podspec.

For further information : [Statefulset Pod Deletion](https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/)

Decomissioning a kubernetes node deletes the node object form the APIServer. Before that you would want to decomission your Portworx node from the cluster. Follow the steps mentioned in [Decommision a Portworx node](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node) Once done, delete the Kubernetes node if it requires to be deleted permanently.

{{% content "shared/portworx-install-with-kubernetes-application-install-with-kubernetes-discussion-forum.md" %}}
