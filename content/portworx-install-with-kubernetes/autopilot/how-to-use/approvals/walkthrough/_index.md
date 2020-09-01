---
title: "Action approvals using kubectl"
linkTitle: "Approvals using kubectl"
keywords: autopilot
description: Instructions on how to enable approvals for actions resulting from autopilot rules using kubectl and the ActionApproval CRD
series: aut-approval-walkthroughs
noicon: true
weight: 100
---

## Prerequisites

* Autopilot 1.3.0 and above

## Overview 

The general workflow of using an AutopilotRule with approvals enabled consists of the following:

1. Create AutopilotRule with approvals enabled
2. Approve or Decline the action by using the ActionApproval CRD

The general workflow expands to the following steps. The Example section later will cover a detailed working example.

1. Create an AutopilotRule with `enforcement: approvalRequired`  in the spec
2. Wait until the objects meet the conditions specified in the rule. For example, if the rule is to expand a volume when it's usage is greater than 50%, wait for this condition.
3. Once the conditions are met, list of the action approvals in the namespace. Identity the item in the list for the concerned object.
4. Update the `approvalState` field in the ActionApproval object spec to `approved` or `declined`.
5. Based on whether you approved or declined in the previous step, the action will either proceed or get declined respectively.

## Example

The example below demonstrates an AutopilotRule that expands Postgres PVCs whose usage increases more than 50%. The rule will require approvals before any action to expand the PVC can take place.

### Create specs

#### Application and PVC specs

Create the storage and application spec files:

1. Create `namespace.yaml` and place the following content inside it:

    ```text
    apiVersion: v1
    kind: Namespace
    metadata:
      name: pg1
      labels:
        type: db
    ```

2. Create `postgres-sc.yaml` and place the following content inside it:

    ```text
    ##### Portworx storage class
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: postgres-pgbench-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "2"
    allowVolumeExpansion: true
    ```

3. Create `postgres-vol.yaml` and place the following content inside it:

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

4. Create`postgres-app.yaml` and place the following content inside it. Note the following:

    * The application in this example is a [PostgreSQL](https://www.postgresql.org/) database with a [pgbench](https://www.postgresql.org/docs/10/pgbench.html) sidecar. 
    
    * The `SIZE` environment variable in this spec instructs pgbench to write 8GiB of data to the volume. Since the PVC is only 10GiB in size, Autopilot will resize the PVC when needed.

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
                  value: "8"
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

Create a YAML spec for the autopilot rule named `autopilotrule-approval-example.yaml` and place the following content inside it:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: volume-resize
spec:
  #### enforcement indicates that actions from this rule need approval
  enforcement: approvalRequired
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
  ##### action to perform when condition is true
  actions:
  - name: openstorage.io.action.volume/resize
    params:
      # resize volume by scalepercentage of current size
      scalepercentage: "100"
      # volume capacity should not exceed 400GiB
      maxsize: "400Gi"
```

### Apply specs

Once you've designed your specs, deploy them:

```text
kubectl apply -f autopilotrule-approval-example.yaml
kubectl apply -f namespace.yaml
kubectl apply -f postgres-sc.yaml
kubectl apply -f postgres-vol.yaml -n pg1
kubectl apply -f postgres-app.yaml -n pg1
```

### Approve or decline the action

#### Wait until conditions are triggered

After you apply the specs above, Postgres will start populating data to the PVC. Once Autopilot detects that the volume usage is greater than 50%, it will create an ActionApproval object in the pg1 namespace. 

List the Kubernetes events for this rule and wait until your rule is in the _ActionAwaitingApproval_ state.

```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=volume-resize -n default -w
```
```output
LAST SEEN   TYPE     REASON       OBJECT                        MESSAGE
10m         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Initializing => Normal
67s         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Normal => Triggered
34s         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Triggered => ActionAwaitingApproval
```

If you only see `Initializing => Normal` as the event, this means postgres is still writing data to your volume and usage has not crossed 50%.

#### Approve the action

1. List the `actionapproval` for this object:

    ```text
    kubectl get actionapproval -n pg1
    ```
    ```output
    NAME                                                     APPROVAL-STATE
    volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e   pending
    ```

2. Patch and approve the actionapproval:

    ```text
    kubectl patch actionapproval -n pg1 volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e --type=merge -p '{"spec":{"approvalState":"approved"}}' 
    ```
    ```output
    actionapproval.autopilot.libopenstorage.org/volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e patched
    ```

3. Once approved, you will see that the actions will progress. List the events again:

    ```text
    kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=volume-resize -n default -w
    ```
    ```output
    LAST SEEN   TYPE     REASON       OBJECT                        MESSAGE
    19m         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Initializing => Normal
    10m         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Normal => Triggered
    9m47s       Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Triggered => ActionAwaitingApproval
    8m52s       Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from ActionAwaitingApproval => ActiveActionsPending
    7m51s       Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from ActiveActionsPending => ActiveActionsInProgress
    7m20s       Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from ActiveActionsInProgress => ActiveActionsTaken
    ```
 
#### Decline the action

To decline, you should use _declined_ instead of _approved_ in the patch command.

Actions for the object will continue to stay in declined state until the `actionapproval` object is present and has approval state as declined. When you want Autopilot to resume monitoring this object, delete the actionapproval object.

For e.g for the above case,

```text
kubectl delete actionapproval -n pg1 volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e
```
