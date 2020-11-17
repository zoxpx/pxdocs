---
title: "Automatically rebalance Portworx storage pools"
linkTitle: "Automatically rebalance storage pools"
keywords: autopilot, storage pool
description: "Auto-rebalance storage pools"
weight: 200
hidden: true
---

{{% content "shared/autopilot/aut-rebalance-intro.md" %}}

## Prerequisites

{{% content "shared/autopilot/aut-rebalance-prereqs.md" %}}

## Example

The following example Autopilot rule will rebalance all storage pools which meet either of following conditions:
* Pool's **provision** space is _over 120%_ 
* Pool's **used** space is _over 60%_

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
  name: pool-rebalance-absolute
spec:
  conditions:
    requiredMatches: 1
    expressions:
    - key: 100 * (px_pool_stats_provisioned_bytes/ on (pool) px_pool_stats_total_bytes) 
      operator: Gt 
      values:
        - "120"
    - key: 100 * (px_pool_stats_used_bytes/ on (pool) px_pool_stats_total_bytes) 
      operator: Gt 
      values:
        - "70"
  actions:
    - name: "openstorage.io.action.storagepool/rebalance"
```

The AutopilotRule spec consists of two important sections: `conditions` and `actions`.

The `conditions` section establishes threshold criteria dictating when the rule must perform its action. In this example, that criteria contains 2 formulas:

* `100 * (px_pool_stats_provisioned_bytes/ on (pool) px_pool_stats_total_bytes) ` is a prometheus query that gives a storage pool's provisioned space percentage
    * The `Gt` operator checks if the value of the metric is greater than `120%`.
* `100 * (px_pool_stats_used_bytes/ on (pool) px_pool_stats_total_bytes) ` is a prometheus query that gives a storage pool's used space percentage
    * The `Gt` operator checks if the value of the metric is greater than `70%`.
* `requiredMatches` indicates that only one of the expressions need to match for the conditions to be considered as being met.

The `actions` section specifies what action Portworx performs when the conditions are met. The action name here is the Storage Pool rebalance action.

Perform the following steps to deploy this example:

### Create specs

{{<info>}}**Other rebalance rules:** If you have other AutopilotRules in the cluster for pool rebalance, {{<companyName>}} recommends you delete them for this test. This will make it easier to confirm that the rule in this example was triggered. {{</info>}}

{{<info>}}**TESTING ONLY:** The specs below cause all volumes to initially land on a single Portworx node. This allows you to test the rebalance rule later on, and rebalance the volumes across all nodes. {{</info>}}

#### Application and PVC specs

First, create the storage and application spec files:

1. Identify the ID of a single PX node in the cluster.
        
    List the cluster nodes and pick the first node. In this example, we will pick the first node _073ae0c7-d5e8-4c6c-982e-75339f2ada81_ in the list.

    ```text
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status --output-type wide
    ```
    
    ```output
    NODE                                    NODE STATUS     POOL                                            POOL STATUS     IO_PRIORITY     SIZE    AVAILABLE       USED (MEAN-DIFF %)      PROVISIONED (MEAN-DIFF %)       ZONE    REGION  RACK
    073ae0c7-d5e8-4c6c-982e-75339f2ada81    Up              0 ( e24c4dbe-4f80-48db-8a1d-17ae2e459fcc )      Online          HIGH            30 GiB  26 GiB          3.5 GiB ( +0 % )        0 B ( +0 % )                    AZ1     default default
    6eec1f0a-2679-41a7-a541-bc5f9dec52d9    Up              0 ( 4a8ec973-219b-48da-b0a1-b3f45e843789 )      Online          HIGH            30 GiB  26 GiB          3.5 GiB ( +0 % )        0 B ( +0 % )                    AZ1     default default
    a53dbf82-faca-40a2-a7bc-3f1c397f1516    Up              0 ( 44fbba64-4b10-4fa4-974b-b6dcf491ed11 )      Online          HIGH            30 GiB  26 GiB          3.5 GiB ( +0 % )        0 B ( +0 % )                    AZ1     default default
    a9cfa4ec-cf49-49f5-bdde-72cf2818e808    Up              0 ( 46ede4d0-a1ec-4758-9823-23293fd82f61 )      Online          HIGH            30 GiB  26 GiB          3.5 GiB ( +0 % )        0 B ( +0 % )                    AZ1     default default
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

4. Create the StorageClass and create 3 PVCs in 3 unique namespaces. 

    In the cluster used in example, each node has a 30Gi pool. So creating 2 30Gi volumes on a single node will cause it's provisioned space percentage to be 200%. This will trigger� the rebalance rule. 
    
    Update the PVC size in the storage field in above spec as per the pool sizes in your cluster.

    ```text
    kubectl apply -f postgres-sc.yaml
   
    for i in {1..2}; do
      kubectl create ns pg$i || true
      kubectl apply -f postgres-vol.yaml -n pg$i
    done
    ```

5. Wait until all PVCs are bound and confirm that one pool has all the volumes.

    The output from the following commands should show all PVCs as bound:
    ```text
    kubectl get pvc -n pg1
    kubectl get pvc -n pg2
    ```
    
    The output from this command should show that the provisioned space for the pool for the PX node that you selected in Step 1 has gone up since all the volumes are created there. You will see this in the `PROVISIONED` column of the output:
    
    ```text
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status --output-type wide
    ```

####  AutopilotRule spec

  Once you've created the PVCs, you can create an AutopilotRule to rebalance the pools. 

  1. Create a YAML spec for the autopilot rule named `autopilotrule-pool-rebalance-example.yaml` and place the following content inside it:

```text
apiVersion: autopilot.libopenstorage.org/v1alpha1
kind: AutopilotRule
metadata:
 name: pool-rebalance-absolute
spec:
  conditions:
    requiredMatches: 1
    expressions:
    - key: 100 * (px_pool_stats_provisioned_bytes/ on (pool) px_pool_stats_total_bytes) 
      operator: Gt 
      values:
        - "120"
    - key: 100 * (px_pool_stats_used_bytes/ on (pool) px_pool_stats_total_bytes) 
      operator: Gt 
      values:
        - "70"
  actions:
    - name: "openstorage.io.action.storagepool/rebalance"
```

2. Apply the rule

```text
kubectl apply -f autopilotrule-pool-rebalance-example.yaml
```

### Monitor

Now that you've created the rule, Autopilot will detect that one specific pool is over-provisioned and it will start rebalancing the 3 volumes across the pools. 

1. Enter the following command to retrieve all the events generated for the `pool-rebalance` rule:

```text
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=pool-rebalance-absolute --all-namespaces --sort-by .lastTimestamp
```

You should see events that will show the rule has triggered. About 30 seconds later, the rebalance actions will begin. 

Once you see actions have begun on the pools, you can use pxctl to again check the cluster provision status. 
    
```text
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status --output-type wide
```

Above command should now show that the provisioned space for all your pools are balanced and spread evenly. You will see this in the `PROVISIONED` column of the output.
