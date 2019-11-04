---
title: "Automatically expand Portworx storage pools"
linkTitle: "Automatically expand storage pools"
keywords: autopilot, storage pool
description: "Auto-expand storage pools"
weight: 200
---

You can use Autopilot to expand Portworx storage pools automatically when they begin to run out of space. Autopilot monitors the metrics in your cluster (e.g., via Prometheus) and detects high usage conditions. Once high usage conditions occur, Autopilot talks with Portworx to resize the pool.

Autopilot uses Portworx APIs to expand storage pools, and these APIs currently support the following cloud providers:

* Azure
* VMware vSphere

## Prerequisites

* **Portworx version**: Autopilot uses Portworx APIs to expand storage pools which is available only in PX 2.3.0 and above
* **Portworx cloud drives**: Your Portworx installation must use one of the supported cloud drives where Portworx provisions the backing drives using the cloud provider
* **Autopilot version**: 1.0.0 and above

## Example

The following example Autopilot rule expands a **250GiB** Portworx storage pool composed of a single **250GiB** drive by **100%** whenever its available capacity is lower than **50%** up to a maximum volume size of **2TB**:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: pool-expand
spec:
  enforcement: required
  ##### conditions are the symptoms to evaluate. All conditions are AND'ed
  conditions:
    expressions:
    # pool available capacity less than 50%
    - key: "100 * ( px_pool_stats_available_bytes/ px_pool_stats_total_bytes)"
      operator: Lt
      values:
        - "50"
    # pool total capacity should not exceed 2TB
    - key: "px_pool_stats_total_bytes/(1024*1024*1024)"
      operator: Lt
      values:
       - "2000"
  ##### action to perform when condition is true
  actions:
    - name: "openstorage.io.action.storagepool/expand"
      params:
        # resize pool by scalepercentage of current size
        scalepercentage: "50"
        # when scaling, resize existing disks in the pool
        scaletype: "add-disk"
```

Consider the key sections in this spec: `conditions` and `actions`.

The `conditions` section establishes threshold criteria dictating when the rule must perform its action. In this example, that criteria contains 2 formulas:

* `100 * ( px_pool_stats_available_bytes/ px_pool_stats_total_bytes)` gives the pool available percentage and the `Lt` operator puts a condition that pool available capacity percentage should be lower 50%.
* `px_pool_stats_total_bytes/(1024*1024*1024)` gives the total pool capacity in GiB, and the `Lt` operator to caps it to 400GiB.`

Conditions are combined using AND logic, requiring all conditions to be true for the rule to trigger.

The `actions` section specifies what action Portworx performs when the conditions are met. Action parameters modify action behavior, and different actions contain different action parameters.

Perform the following steps to deploy this example:

### Create specs

{{<info>}}**NOTE:** The specs below create an application that writes 300 GiB of data to a 400 GiB volume. If your Storage pools are larger than that, you must change these numbers to ensure the capacity condition triggers. {{</info>}}

#### Application and PVC specs

First, create the storage and application spec files:

1. Create `postgres-sc.yaml` and place the following content inside it.

    ```text
    ##### Portworx storage class
    kind: StorageClass
    apiVersion: storage.k8s.io/v1beta1
    metadata:
      name: postgres-pgbench-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "2"
    allowVolumeExpansion: true
    ```

2. Create `postgres-vol.yaml` and place the following content inside it.

    ```text
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: pgbench-data
    spec:
      storageClassName: postgres-pgbench-sc
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 400Gi
    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: pgbench-state
    spec:
      storageClassName: postgres-pgbench-sc
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ```

3. Create `postgres-app.yaml` and place the following content inside it.

    The application in this example is a [PostgreSQL](https://www.postgresql.org/) database with a [pgbench](https://www.postgresql.org/docs/10/pgbench.html) sidecar. The `SIZE` environment variable in this spec instructs pgbench to write 300GiB of data to the volume. Since the volume is 400GiB in size, Autopilot will resize the storage pool when the `conditions` threshold is crossed.

    ```text
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: pgbench
      labels:
        app: pgbench
    spec:
      selector:
        matchLabels:
          app: pgbench
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 1
        type: RollingUpdate
      replicas: 1
      template:
        metadata:
          labels:
            app: pgbench
        spec:
          schedulerName: stork
          containers:
            - image: postgres:9.5
              name: postgres
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
                name: pgbenchdb
            - name: pgbench
              image: portworx/torpedo-pgbench:latest
              imagePullPolicy: "Always"
              env:
                - name: PG_HOST
                  value: 127.0.0.1
                - name: PG_USER
                  value: pgbench
                - name: SIZE
                  value: "300"
              volumeMounts:
              - mountPath: /var/lib/postgresql/data
                name: pgbenchdb
              - mountPath: /pgbench
                name: pgbenchstate
          volumes:
          - name: pgbenchdb
            persistentVolumeClaim:
              claimName: pgbench-data
          - name: pgbenchstate
            persistentVolumeClaim:
              claimName: pgbench-state
    ```

####  AutopilotRule spec

Once you've created your storage and application specs, you can create an AutopilotRule that controls them.

Create a YAML spec for the autopilot rule named `autopilotrule-pool-expand-example.yaml` and place the following content inside it:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: pool-expand
spec:
  enforcement: required
  ##### conditions are the symptoms to evaluate. All conditions are AND'ed
  conditions:
    expressions:
    # pool available capacity less than 40%
    - key: "100 * ( px_pool_stats_available_bytes/ px_pool_stats_total_bytes)"
      operator: Lt
      values:
        - "50"
    # volume total capacity should not exceed 400GiB
    - key: "px_pool_stats_total_bytes/(1024*1024*1024)"
      operator: Lt
      values:
       - "400"
  ##### action to perform when condition is true
  actions:
    - name: "openstorage.io.action.storagepool/expand"
      params:
        # resize pool by scalepercentage of current size
        scalepercentage: "50"
        # when scaling, resize existing disks in the pool
        scaletype: "add-disk"
```

### Apply specs

Once you've designed your specs, deploy them.

```text
kubectl apply -f autopilotrule-pool-expand-example.yaml
kubectl apply -f postgres-sc.yaml
kubectl apply -f postgres-vol.yaml
kubectl apply -f postgres-app.yaml
```

### Monitor

Observe how the pgbench pod starts filling up the pgbench-data PVCs and, by extension, the underlying Portworx storage pools. As the pool usage exceeds 50%, Autopilot resizes the storage pools.

You can enter the following command to retrieve all the events generated for the `pool-expand` rule:

```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=pool-expand --all-namespaces --sort-by .lastTimestamp
```

### Known issues

Portworx is aware of the following known issues:

* When an autopilot pod restarts, it does not save previous state of resizing pools. This causes autopilot to trigger resize operations again for the same pools.
* If Portworx or Portworx storage nodes restart while pool resize operations are underway, affected nodes will mark resize as done, and Autopilot will trigger another resize operation in the queue.
