---
title: Scale up
linkTitle: Scale up
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, cassandra, scaling, scale up
description: Scale up your Cassandra cluster
weight: 3
---

Portworx runs as a `DaemonSet` in Kubernetes. Hence, when you add a node or a worker to your Kubernetes cluster, you do not need to install Portworx on it.

{{<info>}}
**Terraform users:** If you used the [Terraform scripts](https://github.com/portworx/terraporx) to create a Kubernetes cluster, you must update the minion count and apply the changes via Terraform to add a new node.
{{</info>}}

### Add a new node

1. Add a new node to your Kubernetes cluster. <!-- I think we added two nodes -->

2. List your daemon sets while Kubernetes is adding the new node. Enter the `kubectl get daemonsets` command specifying the following:

   * The `-n` flag with the name of your namespace (this example uses `kube-system`)
   * The `-l` flag with the label of your Portworx Pods (`name=portworx`)

    ```text
    kubectl get ds -n kube-system -l "name=portworx"
    ```

    ```output
    NAME         DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR   AGE
    portworx     6         5         5         5            5           <none>          4h
    ```

    <!-- I think we added two nodes. Need a test cluster to verify this and update the outputs -->

3. Use the `kubectl get pods` command to display your Pods:

    ```text
    kubectl get pods -n kube-system -l "name=portworx"
    ```

    ```output
    NAME                                 READY     STATUS    RESTARTS   AGE
    portworx-14g3z                       1/1       Running   0          4h
    portworx-ggzvz                       0/1       Running   0          2m
    portworx-hhg0m                       1/1       Running   0          4h
    portworx-rkdp6                       1/1       Running   0          4h
    portworx-stvlt                       1/1       Running   0          4h
    portworx-vxqxh                       1/1       Running   0          4h
    ```

4. Your Portworx cluster automatically scales as you scale your Kubernetes cluster.  Display the status of your Portworx cluster, by entering the `pxctl status` command:

    ```text
    pxctl status
    ```

    ```output
    Status: PX is operational
    License: Trial (expires in 30 days)
    Node ID: k8s-master
            IP: 10.140.0.2
            Local Storage Pool: 1 pool
            POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
            0       MEDIUM          raid0           10 GiB  471 MiB Online  default default
            Local Storage Devices: 1 device
            Device  Path            Media Type              Size            Last-Scan
            0:1     /dev/sdb        STORAGE_MEDIUM_SSD      10 GiB          31 Jul 17 12:59 UTC
            total                   -                       10 GiB
    Cluster Summary
            Cluster ID: px-cluster
            Cluster UUID: d2ebd5cf-9652-47d7-ac95-d4ccbd416a6a
            IP              ID              Used    Capacity        Status
            10.140.0.7      k8s-4           266 MiB 10 GiB          Online
            10.140.0.2      k8s-master      471 MiB 10 GiB          Online (This node)
            10.140.0.4      k8s-2           471 MiB 10 GiB          Online
            10.140.0.3      k8s-0           461 MiB 10 GiB          Online
            10.140.0.5      k8s-1           369 MiB 10 GiB          Online
            10.140.0.6      k8s-3           369 MiB 10 GiB          Online
    Global Storage Pool
            Total Used      :  2.3 GiB
            Total Capacity  :  60 GiB

    ```

### Scale up the Cassandra StatefulSet

1. Display your stateful sets by entering the `kubectl get statefulsets` command:

    ```text
    kubectl get sts cassandra
    ```

    ```output
    NAME        DESIRED   CURRENT   AGE
    cassandra   4         4         4h
    ```

    In the above example output, note that the number of replicas is four.

2. To scale up the `cassandra` stateful set, you must increase the number of replicas. Enter the `kubectl scale statefulsets` command, specifying the following:

   * The name of your stateful set (this example uses `cassandra`)
   * The desired number of replicas (this example creates five replicas)

    ```text
    kubectl scale statefulsets cassandra --replicas=5
    ```

    ```output
    statefulset "cassandra" scaled
    ```

3. To list your Pods, enter the `kubectl get pods` command:

    ```text
    kubectl get pods -l "app=cassandra" -w
    ```

    ```output
    NAME          READY     STATUS    RESTARTS   AGE
    cassandra-0   1/1       Running   0          5h
    cassandra-1   1/1       Running   0          4h
    cassandra-2   1/1       Running   0          4h
    cassandra-3   1/1       Running   0          3h
    cassandra-4   1/1       Running   0          57s
    ```

4. To open a shell session into one of your Pods, enter the following `kubectl exec` command, specifying your Pod name. This example opens the `cassandra-0` Pod:

    ```text
    kubectl exec cassandra-0
    ```

5. Use the `nodetool status` command to retrieve information about your Cassandra cluster:

    ```text
    nodetool status
    ```

    ```output
    Datacenter: DC1-K8Demo
    ======================
    Status=Up/Down
    |/ State=Normal/Leaving/Joining/Moving
    --  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
    UN  10.0.128.1  84.75 KiB   32           41.4%             1c14f7dc-44f7-4174-b43a-308370c9139e  Rack1-K8Demo
    UN  10.0.240.1  130.81 KiB  32           45.2%             60ebbe70-f7bc-48b0-9374-710752e8876d  Rack1-K8Demo
    UN  10.0.192.2  156.84 KiB  32           41.1%             915f33ff-d105-4501-997f-7d44fb007911  Rack1-K8Demo
    UN  10.0.160.2  125.1 KiB   32           45.3%             a56a6f70-d2e3-449a-8a33-08b8efb25000  Rack1-K8Demo
    UN  10.0.64.3   159.94 KiB  32           26.9%             ae7e3624-175b-4676-9ac3-6e3ad4edd461  Rack1-K8Demo
    ```

6. Terminate the shell session:

    ```text
    exit
    ```