---
title: PostgreSQL
description: PostgreSQL Reference Architecture - Deploying Postgres with Portworx
keywords: portworx, postgres, database, reference
hidden: false
hidesections: true
disableprevnext: true
---

PostgreSQL, often called Postgres, is an open source object-relational database system. It is very popular, with a proven architecture and a robust feature set offering reliability and extensibility. It is often referred to as a cloud-native database, meaning it works very well in containerised environments. You can read more on the PostgreSQL website - [https://www.postgresql.org/about/](https://www.postgresql.org/about/).

When deployed in a container platform such as Kubernetes, it is often deployed as a statefulset, with each pod requiring a container volume. Postgres is often deployed using manifests or using a [Helm Chart](https://github.com/helm/charts/tree/master/stable/postgresql).

---

## Benefits of PostgreSQL with Portworx
Why do you need to run PostgreSQL with Portworx? There are two areas you should consider. Firstly, providing container volumes that meet enterprise storage requirements. Secondly, the lifecycle of PostgreSQL in multi-cluster / cloud / environment deployments.

#### Volume management benefits
- Portworx can **simplify your Postgres architecture** by providing rapid, in-cluster failover, without the need for many Postgres instances. 
- Portworx will **guarantee data locality** - that a pod and a volume replica are on the same host. This means you're getting near native disk performance.
- Portworx provides in-cluster and off-site snapshots allowing you to **protect your Postgres data** with container volume granularity.
- With Portworx you can encrypt your data at rest and in-flight allowing you to go into production, confident your solution **meets business security requirements**.
- You can resize Portworx volumes **without any disruption** to your PostgreSQL database or the data on disk.
- Portworx is completely automated and managed through native platform storage primitives. This means developers can **self-service Portworx container volumes** as part of a normal PostgreSQL deployment.

#### Multi-cluster / cloud benefits
- You can use the Portworx data migration capabilities to **rapidly migrate your PostgreSQL and data** to cloud or another data-centre.
- Portworx supports advanced deployment architectures allowing you to run **highly-resilient stretch or multi-cluster** deployments.
- Unblock your path to production by **meeting your business DR requirements** using Portworx data protection tooling for your PostgreSQL database. 

## Deployment Architecture
PostgreSQL can run in a single node configuration and in a clustered configuration using different alternative solutions for asynchronous or synchronous replication as of PostgreSQL 9.1. The prefered replication technique with PostgreSQL is the use of a Write Ahead Log (WAL). By writing the log of actions before applying them to the database the PostgreSQL master, state can be replicated on any secondary by replaying the set of actions.

With Portworx, each PostgreSQL Master and Secondary can have its PVC synchronously replicated. This makes recovering database instances a near zero cost operation which results in shorter recovery windows and higher total uptime. Our test also show the elimination of the degradation in performance during the PostgreSQL recovery process when the state has to be recovered from the other database instances. With Portworx and Kubernetes, database instance recovery can take less than 30 seconds.

For deployments where you require replication for data protection but where a single database instance is capable of handling the read requests, a single Postgres pod, with Portworx replicated volumes offers a simpler and more cost effective solution to running HA PostgreSQL on Kubernetes.

This is far less complex to manage and configure and requires ⅓ of the PostgreSQL Pods and therefore ⅓ of the CPU and Memory because Portworx is already running on your Kubernetes cluster and synchronously replicates data for all of your applications with great efficiency and scale.

### Single pod model
**DIAGRAM HERE**
This would be a repl 3 example with multiple, single Postgres instances, each with 3 replicated volumes.

### Stateful set model
**DIAGRAM HERE**
This would be a repl 2 example showing rapid recovery for cluster memebers.

## Deployment methods
The most common deployment methods for PostgreSQL are using a manifest (deployment or statefulset), or using a Helm chart. Prior to deployment the container platform should be prepared accordingly:

1. Ensure the Portworx pre-requisities are met - [https://docs.portworx.com/start-here-installation/](https://docs.portworx.com/start-here-installation/)

2. Install Portworx using a genertes manifest from our [installer tool](https://install.portworx.com/).

3. Create a storage class suitable for PostgreSQL.

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
name: px-ha-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  io_profile: "db"
  io_priority: "high"
```
**repl: "3"** - ensures that three volume replicas are present in the cluster.

**io_profile: "db"** - configures Portworx to handle small sync transactions to improve Postgres deployment.

**io_prority: "high"** - requests Portworx to provision the container volume on a high performance backing device.


### Manifest deployment
When deploying Postgres with a manifest the most common options are as a deployment type or a stateful set. We have covered the different deployment architectures above. Here follows an example deployment manifest for PostgreSQL making use of Portworx volumes. Note that this manifest requires that the storage-class above exists.

```yaml
##### Portworx persistent volume claim
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
   name: postgres-data
   annotations:
     volume.beta.kubernetes.io/storage-class: px-ha-sc
spec:
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 1Gi
---
##### Postgres deployment
apiVersion: extensions/v1beta1
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
      schedulerName: stork    
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/enabled
                operator: NotIn
                values:
                - "false"
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
Note: please use serets instead of plain text passwords. The above is an example only.

### Helm chart deployment
An alternative to manifest based deployment is to use a Helm chart. Again, this method assumes the storage class already exists.