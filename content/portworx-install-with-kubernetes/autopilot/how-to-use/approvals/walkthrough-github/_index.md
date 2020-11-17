---
title: "Action approvals using GitOps and Github"
linkTitle: "Approvals using GitOps and Github"
keywords: autopilot
description: Instructions on how to enable approvals for actions resulting from autopilot rules using GitOps and Github
series: aut-approval-walkthroughs
noicon: true
weight: 200
---


## Prerequisites

{{<info>}}**NOTE:** This guide uses [Flux](https://fluxcd.io/) as your GitOps operator. However, the concepts will apply to other GitOps implementations as well.{{</info>}}

* Autopilot 1.3.0 and above
* {{<companyName>}} recommends you go through the [Action approvals using kubectl](/portworx-install-with-kubernetes/autopilot/how-to-use/approvals/walkthrough) guide first if you haven't done so already. It will make you familiar with basic approval concepts, which are applicable here.

## Overview 

You must perform the following steps to use GitOps-based approvals:

1. Setup GitOps in your cluster using [flux](https://fluxcd.io/). 
2. Configure Autopilot to provide access to your Github repository used for GitOps
3. Create AutopilotRule with approvals enabled
4. Approve or Decline the actions by approving or closing Github PRs respectively

Let's look at above 4 steps in detail. 

## Step 1: Setup GitOps using Flux

Perform the steps in the [Get started with Flux](https://docs.fluxcd.io/en/latest/tutorials/get-started/#get-started-with-flux) section of the Flux documentation to implement GitOps using Flux. 

* Before using Flux for Autopilot, {{<companyName>}} recommends you test if the GitOps integration works in general. Use the example specs provided in the get started guide above to verify it. 
* By default, Flux has a 5 minute git poll interval. To save time during testing, you can edit to `flux` deployment in the `flux` namespace and add `--git-poll-interval=30s` in the args to change this to 30 seconds.

## Step 2: Provide access to your Github repository used for GitOps

Autopilot needs access to the Github repository to create & manage PRs.

### Step 2a: Create a personal access token

1. Follow the instructions in the [Creating a personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) document to create a token Autopilot will use to access the Github repo.
     Select the **repo** scope when creating the token. That is the only permission Autopilot needs.
2. Base64 encode the token:
     ```text
     echo -n <enter-base64-token-here> | base64
     ```

3. Create a secret called `aut-github-secret.yaml` as follows in the namespace Autopilot is installed (by default _kube-system_):
  ```text
    apiVersion: v1
    kind: Secret
    metadata:
      name: aut-github
      namespace: kube-system
    type: Opaque
    data:
      GITHUB_TOKEN: <enter-base64-token-here>
  ```
  
  
    ```text
    kubectl apply -f aut-github-secret.yaml
    ```

### Step 2b: Provide repository details

1. Add a new GitHub provider in the Autopilot ConfigMap `autopilot-config`. You can find it using:

    ```text
    kubectl get configmap  --all-namespaces | grep autopilot-config
    ```

2. In the `providers` section, add a new item for the GitHub provider. In the example below, update the following values: 

    * `user` with the name of the Github user or organization for the repo.
    * `repo` with the name of the repo.
    * `folder` with the name of the folder where autopilot should create new manifests for approval purposes. This needs to be a folder that flux is syncing with your cluster.
    * `author` with the name of the Git author to use for the PRs Autopilot will create for approval purposes.
    * `email` with the email of the Git user to use for the PRs Autopilot will create for approval purposes.

    ```text
      providers:
       - name: github
         type: github-scm
         github:
           user: harsh-px
           repo: flux-get-started
           folder: workloads
           author: harsh-px
           email: harsh@portworx.com
    ```

    {{<info>}}**NOTE:** The sample ConfigMap above is written for the [harsh-px/flux-get-started](https://github.com/harsh-px/flux-get-started) repo.{{</info>}}

3. Once the ConfigMap is updated, restart Autopilot pod for changes to take effect:

    ```text
    kubectl delete pod --all-namespaces -l name=autopilot
    ```

## Step 3: Create AutopilotRule

Before creating the AutopilotRule, you must deploy a sample stateful application.

### Step 3a: Application and PVC specs

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
   
### Step 3b: AutopilotRule with approvals enabled

Create an AutopilotRule with `enforcement: approvalRequired` in the spec.

* Create a YAML spec for the autopilot rule named `autopilotrule-approval-example.yaml` and place the following content inside it:

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

* Wait until the objects meet the conditions specified in the rule. For example, if the rule is to expand a volume when it's usage is greater than 50%, wait for this condition.

* Once the conditions are met, list of the action approvals in the namespace. Identity the item in the list for the concerned object.

* Update the `approvalState` field in the ActionApproval object spec to `approved` or `declined`.

* Based on whether you approved or declined in the previous step, the action will either proceed or get declined respectively.


### Step 3c: Apply specs

Once you've designed your specs, deploy them:

```text
kubectl apply -f autopilotrule-approval-example.yaml
kubectl apply -f namespace.yaml
kubectl apply -f postgres-sc.yaml
kubectl apply -f postgres-vol.yaml -n pg1
kubectl apply -f postgres-app.yaml -n pg1
```

## Step 4: Approve or Decline actions

### Step 4a: Wait until conditions are triggered

After you apply the specs above, Postgres will start populating data to the PVC. Once Autopilot detects that the volume usage is greater than 50%, it will create an ActionApproval object in the pg1 namespace. 

List the Kubernetes events for this rule and wait until your rule is in the _ActionAwaitingApproval_ state:

```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=volume-resize -n default -w
```
```output
LAST SEEN   TYPE     REASON       OBJECT                        MESSAGE
10m         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Initializing => Normal
67s         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Normal => Triggered
34s         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Triggered => ActionAwaitingApproval
```

{{<info>}}**NOTE:** If you only see `Initializing => Normal` as the event, Postgres is still writing data to your volume and usage has not crossed 50%. {{</info>}}

You should see a PR in the Github repository you configured in [Step 2](#) to approve the action. 

You will also see an `actionapproval` object in the cluster. However, you will not directly update it.

```text
kubectl get actionapproval -n pg1
```
```output
NAME                                                     APPROVAL-STATE
volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e   pending
```

### Step 4b: Approve or decline the PR
 
#### Approve the PR

1. Approve and merge the PR in Github. Once approved, Flux (or other GitOps provider) will sync the GitHub changes in your cluster. 

    Once Autopilot sees the approved actionapproval object in the cluster, you will see that the actions will progress. 

2. List the actionapproval again. The `APPROVAL-STATE` should show as `approved`:

    ```text
    kubectl get actionapproval -n pg1
    ```
    ```output
    NAME                                                     APPROVAL-STATE
    volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e   approved 
    ```

3. List the events again:

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

#### Decline the PR

1. To decline, close the PR in Github. Autopilot will detect this and mark the action are declined in the cluster.

2. Verify that approval was declined by entering the `kubectl get actionapproval` command:
    ```text
    kubectl get actionapproval -n pg1
    ```
    ```output
    NAME                                                     APPROVAL-STATE
    volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e   declined
    ``` 

3. List the events again:

    ```text
    kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=volume-resize -n default -w
    ```
    ```output
    LAST SEEN   TYPE     REASON       OBJECT                        MESSAGE
    19m         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Initializing => Normal
    10m         Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Normal => Triggered
    9m47s       Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from Triggered => ActionAwaitingApproval
    8m52s       Normal   Transition   autopilotrule/volume-resize   rule: volume-resize:pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e transition from ActionAwaitingApproval => ActiveActionsDeclined
    ```

    Actions for the object will continue to stay in a declined state until the `actionapproval` object is present and has a declined approval state.

3. When you want Autopilot to resume monitoring this object, delete the actionapproval object:

    ```text
    kubectl delete actionapproval -n pg1 volume-resize-pvc-3906b3ed-5a3c-4c69-a737-9ddd748cfe8e
    ```
