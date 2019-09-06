---
title: "Automatically grow PVCs"
linkTitle: "Automatically grow PVCs"
keywords: install, autopilot
description: "Autogrow PVCs"
---

## Using Autopilot to Autogrow PVCs

You can use Autopilot to expand PVCs automatically when they begin to run out of space. Autopilot monitors the metrics in your cluster (e.g., via Prometheus) and detects high usage conditions. Once high usage conditions occur, Autopilot talks with Kubernetes to resize the PVC.

An AutopilotRule that has 4 main parts:

1. **PVC Selector** Matches labels on the PVCs.
2. **Namespace Selector** Matches labels on the Kubernetes namespaces the rule should monitor. This is optional, and the default is all namespaces.
3. **Metric conditions** on the PVC to monitor.
4. **PVC resize action** to perform once the metric conditions are met.

The following example section shows the actual YAML for this.

## Example

The following example Autopilot rule expands Postgres PVCs by **100%** whenever their usage exceeds **50%** up to a maximum size of **400GiB**:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
 name: volume-resize
spec:
  ##### selector filters the objects affected by this rule given labels
  selector:
    matchLabels:
      app: postgres
  ##### namespaceSelector selects the namespaces of the objects affected by this rule
  namespaceSelector:
    matchLabels:
      type: db
  ##### conditions are the symptoms to evaluate. All conditions are AND'ed
  conditions:
    # volume usage should be less than 50%
    expressions:
    - key: "100 * (px_volume_usage_bytes / px_volume_capacity_bytes)"
      operator: Gt
      values:
        - "50"
    # volume capacity should not exceed 400GiB
    - key: "px_volume_capacity_bytes / 1000000000"
      operator: Lt
      values:
       - "400"
  ##### action to perform when condition is true
  actions:
  - name: openstorage.io.action.volume/resize
    params:
      # resize volume by scalepercentage of current size
      scalepercentage: "100"
```

Consider the key sections in this spec.

* `selector` and `namespaceSelector`
* `conditions`
* `action`

The `selector` determines what objects are acted on by the Autopilot rule by looking for PVCs with the `app: postgres` label. Similarly, the `namespaceSelector` filters PVCs by namespaces and only includes PVCs from namespaces that contain the `type: db` label. Hence, this rule applies only to PVCs running Postgres in the DB namespaces.

The `conditions` section determines the threshold criteria dictating when the rule has to perform its action. In this example, that criteria has 2 formulas:

1. `100 * (px_volume_usage_bytes / px_volume_capacity_bytes)` gives the volume usage percentage and the `Gt` operator puts a condition that volume usage percentage has exceeded 50%.
2. `px_volume_capacity_bytes / 1000000000` gives the total volume capacity in GiB, and the `Lt` operator to caps it to 400GiB.

Conditions are combined using AND logic, requiring all conditions to be true for the rule to trigger.

The `actions` section specifies what action Portworx performs when the conditions are met. Action parameters modify action behavior, and different actions contain different action parameters.

Perform the following steps to deploy this example.

### Create specs

#### Application and PVC specs

First, create the storage and application spec files:

1. Create `namespaces.yaml` and place the following content inside it.

    ```text
    apiVersion: v1
    kind: Namespace
    metadata:
      name: pg1
      labels:
        type: db
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: pg2
      labels:
        type: db
    ```

2. Create `postgres-sc.yaml` and place the following content inside it.

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

3. Create `postgres-vol.yaml` and place the following content inside it.

    ```text
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: pgbench-data
      labels:
        app: postgres
    spec:
      storageClassName: postgres-pgbench-sc
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
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

4. Create`postgres-app.yaml` and place the following content inside it.

    The application in this example is a [PostgreSQL](https://www.postgresql.org/) database with a [pgbench](https://www.postgresql.org/docs/10/pgbench.html) sidecar. The `SIZE` environment variable in this spec tells pgbench to write 70GiB of data to the volume. Since the PVC is only 10GiB in size, Autopilot must resize the PVC when needed.


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
                  value: "70"
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

Create a YAML spec for the autopilot rule named `autopilotrule-example.yaml` and place the following content inside it:


```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: volume-resize
spec:
  ##### selector filters the objects affected by this rule given labels
  selector:
    matchLabels:
      app: postgres
  ##### namespaceSelector selects the namespaces of the objects affected by this rule
  namespaceSelector:
    matchLabels:
      type: db
  ##### conditions are the symptoms to evaluate. All conditions are AND'ed
  conditions:
    # volume usage should be less than 50%
    expressions:
    - key: "100 * (px_volume_usage_bytes / px_volume_capacity_bytes)"
      operator: Gt
      values:
        - "50"
    # volume capacity should not exceed 400GiB
    - key: "px_volume_capacity_bytes / 1000000000"
      operator: Lt
      values:
      - "400"
  ##### action to perform when condition is true
  actions:
  - name: openstorage.io.action.volume/resize
    params:
      # resize volume by scalepercentage of current size
      scalepercentage: "100"
```

### Apply specs

Once you've designed your specs, deploy them.

```text
kubectl apply -f autopilotrule-example.yaml
kubectl apply -f namespaces.yaml
kubectl apply -f postgres-sc.yaml
kubectl apply -f postgres-vol.yaml -n pg1
kubectl apply -f postgres-vol.yaml -n pg2
kubectl apply -f postgres-app.yaml -n pg1
kubectl apply -f postgres-app.yaml -n pg2
```

### Monitor

Notice that the pgbench pods in the `pg1` and `pg2` namespace will start filing up the pgbench-data PVCs. As the PVC usage starts exceeding 50%, Autopilot will resize the PVCs.

You can use the following command to get all the events generated for the `volume-resize` rule:


```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=volume-resize --all-namespaces
```
```output
NAMESPACE   LAST SEEN   TYPE     REASON       KIND            MESSAGE
default     21m         Normal   Transition   AutopilotRule   rule: pvc-5bfcabfd-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
default     21m         Normal   Transition   AutopilotRule   rule: pvc-5c9a6451-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
default     9m52s       Normal   Transition   AutopilotRule   rule: pvc-5bfcabfd-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
default     9m48s       Normal   Transition   AutopilotRule   rule: pvc-5c9a6451-d017-11e9-bcdf-aa931955114b transition from Initializing => Normal
```
