---
title: "Automatically rebalance Portworx storage pools"
linkTitle: "Rebalance storage pools"
keywords: autopilot, storage pool
description: "Auto-rebalance storage pools"
weight: 300
---

{{% content "shared/autopilot/aut-rebalance-intro.md" %}}

## Prerequisites

{{% content "shared/autopilot/aut-rebalance-prereqs.md" %}}

## Example

The following example Autopilot rule will rebalance all storage pools which meet either of following conditions:
* Pool's **provision** space is _over 20%_ or _under 20%_ of mean value across pools
* Pool's **used** space is _over 20%_ or _under 20%_ of mean value across pools

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
 name: pool-rebalance
spec:
  conditions:
    requiredMatches: 1
    expressions:
    - keyAlias: PoolProvDeviationPerc
      operator: NotInRange
      values:
        - "-20"
        - "20"
    - keyAlias: PoolUsageDeviationPerc
      operator: NotInRange
      values:
        - "-20"
        - "20"
  actions:
    - name: "openstorage.io.action.storagepool/rebalance"
```

The AutopilotRule spec consists of two important sections: `conditions` and `actions`.

The `conditions` section establishes threshold criteria dictating when the rule must perform its action. In this example, that criteria contains 2 formulas:

* `PoolProvDeviationPerc` is an alias for a Prometheus query that gives a storage pool's provisioned space deviation percentage relative to other pools in the cluster. 
    * The `NotInRange` operator checks if the value of the metric is outside the range specified in the `values`.
       * In this case, the condition is met when the pool's provisioned space goes _over 20%_ or _under 20%_ compared to mean value across pools.
       * For example, if a particular pool's provisioned space is 25% lower compared to mean provisioned space across all pools in the cluster, then the condition is met.
* `PoolUsageDeviationPerc` is an alias for a prometheus query that gives a storage pool's used space deviation percentage relative to other pools in the cluster. 
    * The `NotInRange` operator checks if the value of the metric is outside the range specified in the `values`.
       * In this case, the condition is met when the pool's used space goes _over 20%_ or _under 20%_ compared to mean value across pools.
       * For example, if a particular pool's used space is 25% higher compared to mean used space across all pools in the cluster, then the condition is met.
* `requiredMatches` indicates that only one of the expressions need to match for the conditions to be considered as being met.

The `actions` section specifies what action Portworx performs when the conditions are met. The action name here is the Storage Pool rebalance action.

Perform the following steps to deploy this example:

### Create specs

{{<info>}}**TESTING ONLY:** The specs below all volumes to initially land on a single PX node. This is done so that we can test the rebalance rule later on to rebalance the volumes across all nodes. {{</info>}}

#### Application and PVC specs

Create the storage and application spec files:

1. Identify the ID of a single PX node in the cluster.
        
    List the cluster nodes and pick the first node. In this example, we will pick the first node _073ae0c7-d5e8-4c6c-982e-75339f2ada81_ in the list.

    ```text
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
    ```
    
    ```output
    Cluster ID: px-autopilot-demo
    Cluster UUID: cea46565-c631-46c6-9575-a0534c91a417
    Status: OK
    
    Nodes in the cluster:
    ID                                      SCHEDULER_NODE_NAME                     DATA IP         CPU             MEM TOTAL       MEM FREE        CONTAINERS      VERSION                 Kernel                  OS                      STATUS
    073ae0c7-d5e8-4c6c-982e-75339f2ada81    6043f223-4a78-4ebd-b59c-2ff85c418afe    70.0.101.1      2.641509        8.4 GB          7.0 GB          N/A             2.6.0.0-d88b8c6         4.15.0-72-generic       Ubuntu 16.04.6 LTS      Online
    f4587f8c-8df0-4cb1-9740-5431da0e8b0a    44a31bd2-1251-4335-887e-c0ae5965deac    70.0.101.3      3.666245        8.4 GB          6.9 GB          N/A             2.6.0.0-d88b8c6         4.15.0-72-generic       Ubuntu 16.04.6 LTS      Online
    7114cb68-48f7-4eb2-943e-63b06936395b    f0c4769b-24b5-48d4-b492-2b8561e244eb    70.0.101.2      3.530895        8.4 GB          7.0 GB          N/A             2.6.0.0-d88b8c6         4.15.0-72-generic       Ubuntu 16.04.6 LTS      Online
    ```

2. Create `postgres-sc.yaml` and place the following content inside it.

    ```text
    ##### Portworx storage class
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: postgres-pgbench-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "1"
      nodes: "073ae0c7-d5e8-4c6c-982e-75339f2ada81"
    allowVolumeExpansion: true
    ```
   
    {{<info>}}**NOTE:** Notice how the `nodes` section pin the volumes from this StorageClass to initially land only on _073ae0c7-d5e8-4c6c-982e-75339f2ada81_. You should use this for testing only, and you must change the value to suit your environment.{{</info>}}

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
          storage: 30Gi
    ```

    You will not deploy any application pod using this PVC. This tutorial only demonstrates rebalancing the pools.

4. Create the StorageClass and create 3 PVCs in 3 unique namespaces:

    ```text
    kubectl apply -f postgres-sc.yaml
   
    for i in {1..3}; do
      kubectl create ns pg$i || true
      kubectl apply -f postgres-vol.yaml -n pg$i
    done
    ```

5. Wait until all PVCs are bound and confirm that one pool has all the volumes.

    The output from the following commands should show all PVCs as bound:
    ```text
    kubectl get pvc -n pg1
    kubectl get pvc -n pg2
    kubectl get pvc -n pg3
    ```
    
    The output from this command should show that the provisioned space for the pool for the PX node that you selected in Step 1 has gone up by 90Gi since all the volumes are created there. You will see this in the `PROVISIONED` column of the output.
    
    ```text
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status --output-type wide
    ```

####  AutopilotRule spec

  Once you've created the PVCs, you can create an AutopilotRule to rebalance the pools. 

1.  Create a YAML spec for the autopilot rule named `autopilotrule-pool-rebalance-example.yaml` and place the following content inside it:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
 name: pool-rebalance
spec:
  conditions:
    requiredMatches: 1
    expressions:
    - keyAlias: PoolProvDeviationPerc
      operator: NotInRange
      values:
        - "-20"
        - "20"
    - keyAlias: PoolUsageDeviationPerc
      operator: NotInRange
      values:
        - "-20"
        - "20"
  actions:
    - name: "openstorage.io.action.storagepool/rebalance"
```

2. Apply the rule:

```text
kubectl apply -f autopilotrule-pool-rebalance-example.yaml
```

### Monitor

Now that you've created the rule, Autopilot will now detect that one specific pool is over-provisioned and it will start rebalancing the 3 volumes across the pools. 

1. Enter the following command to retrieve all the events generated for the `pool-rebalance` rule:

```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=pool-rebalance --all-namespaces --sort-by .lastTimestamp
```

You should see events that will show the rule has triggered. About 30 seconds later, the rebalance actions will begin. 

Once you see actions have begun on the pools, you can use pxctl to again check the cluster provision status. 

Below should now show that the provisioned space for all your pools are balanced and spread evenly. You will see this in the `PROVISIONED` column of the output.
    
```text
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status --output-type wide
```

### More rebalance examples

* [Rebalance pools by their absolute provisioned and used space](/portworx-install-with-kubernetes/autopilot/use-cases/examples/rebalance/aut-rebalance-absolute-usage)
