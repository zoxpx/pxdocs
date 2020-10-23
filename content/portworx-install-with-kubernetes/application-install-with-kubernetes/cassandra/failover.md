---
title: Failover
linkTitle: Failover
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, cassandra
description: Learn how to failover Cassandra with Portworx on Kubernetes.
weight: 4
---

## Pod failover

Verify that your Cassandra cluster is formed of five nodes:

```text
kubectl get pods -l "app=cassandra"
```

```output
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          1h
cassandra-1   1/1       Running   0          10m
cassandra-2   1/1       Running   0          18h
cassandra-3   1/1       Running   0          17h
cassandra-4   1/1       Running   0          13h
```

### Add data to Cassandra

1. Run the `bash` command on one of your Pods. The following example command runs the `bash` command on the `cassandra-2` Pod:

    ```text
    kubectl exec -it cassandra-2 -- bash
    ```

2. Start `cqlsh`, the command line shell for interacting with Cassandra:

    ```text
    cqlsh
    ```

    ```output
    Connected to TestCluster at 127.0.0.1:9042.
    [cqlsh 5.0.1 | Cassandra 3.11.4 | CQL spec 3.4.4 | Native protocol v4]
    Use HELP for help.
    ```

3. Enter the following example command to add data to a keyspace called `demodb`:


    ```text
    CREATE KEYSPACE demodb WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };
    use demodb;
    CREATE TABLE emp(emp_id int PRIMARY KEY, emp_name text, emp_city text, emp_sal varint,emp_phone varint);
    INSERT INTO emp (emp_id, emp_name, emp_city, emp_phone, emp_sal) VALUES(123423445,'Steve', 'Denver', 5910234452, 50000);
    ```

4. Run the `exit`  command to terminate `cqlsh` and return to the shell session.

5. Display the list of nodes that host the data in your Cassandra ring based on its partition key:

    ```text
    nodetool getendpoints demodb emp 123423445
    ```

    ```output
    10.0.112.1
    10.0.160.1
    ```

6. Terminate the shell session:

    ```text
    exit
    ```

7. Use the following command to list the nodes and the Pods they host:

    ```text
    kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
    ```

    ```output
    {
      "name": "cassandra-0",
      "hostname": "k8s-5",
      "hostIP": "10.140.0.8",
      "PodIP": "10.0.112.1"
    }
    {
      "name": "cassandra-1",
      "hostname": "k8s-0",
      "hostIP": "10.140.0.3",
      "PodIP": "10.0.160.1"
    }
    {
      "name": "cassandra-2",
      "hostname": "k8s-1",
      "hostIP": "10.140.0.5",
      "PodIP": "10.0.64.3"
    }
    {
      "name": "cassandra-3",
      "hostname": "k8s-3",
      "hostIP": "10.140.0.6",
      "PodIP": "10.0.240.1"
    }
    {
      "name": "cassandra-4",
      "hostname": "k8s-4",
      "hostIP": "10.140.0.7",
      "PodIP": "10.0.128.1"
    }
    ```

    Note that the `k8s-0` node hosts the `cassandra1` Pod.


### Delete a Cassandra Pod

1. Cordon a node where one of the replicas resides. The Kubernetes stateful set will schedule the Pod to another node. The following `kubectl cordon` command cordons the `k8s-0` node:

    ```text
    kubectl cordon k8s-0
    ```

    ```output
    node "k8s-0" cordoned
    ```

2. Use the `kubectl delete pods` command to delete the `cassandra-1` Pod:

    ```text
    kubectl delete pods cassandra-1
    ```

    ```output
    pod "cassandra-1" deleted
    ```
3. The Kubernetes stateful set schedules the `cassandra-1` Pod on a different host. You can use the `kubectl get pods -w` command to see where the Pod is in its lifecycle:

    ```text
    kubectl get pods -w
    ```

    ```output
    NAME          READY     STATUS              RESTARTS   AGE
    cassandra-0   1/1       Running             0          1h
    cassandra-1   0/1       ContainerCreating   0          1s
    cassandra-2   1/1       Running             0          19h
    cassandra-3   1/1       Running             0          17h
    cassandra-4   1/1       Running             0          14h
    cassandra-1   0/1       Running   0         4s
    cassandra-1   1/1       Running   0         28s
    ```

4. To see the node on which the Kubernetes stateful set schedules the `cassandra-1` Pod, enter the following command:

    ```text
    kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": status.podIP}'
    ```

    ```output
    {
      "name": "cassandra-0",
      "hostname": "k8s-5",
      "hostIP": "10.140.0.8",
      "PodIP": "10.0.112.1"
    }
    {
      "name": "cassandra-1",
      "hostname": "k8s-2",
      "hostIP": "10.140.0.4",
      "PodIP": "10.0.192.2"
    }
    {
      "name": "cassandra-2",
      "hostname": "k8s-1",
      "hostIP": "10.140.0.5",
      "PodIP": "10.0.64.3"
    }
    {
      "name": "cassandra-3",
      "hostname": "k8s-3",
      "hostIP": "10.140.0.6",
      "PodIP": "10.0.240.1"
    }
    {
      "name": "cassandra-4",
      "hostname": "k8s-4",
      "hostIP": "10.140.0.7",
      "PodIP": "10.0.128.1"
    }
    ```

    Note that the `cassandra-1` Pod is now scheduled on the `k8s-2` node.


5. Verify that there is no data loss by entering the following command:

    ```text
    kubectl exec cassandra-1 -- cqlsh -e 'select * from demodb.emp'
    ```

    ```output
    emp_id    | emp_city | emp_name | emp_phone  | emp_sal
    -----------+----------+----------+------------+---------
    123423445 |   Denver |    Steve | 5910234452 |   50000

    (1 rows)
    ```

## Node failover

1. List the Pods in your cluster by entering the following command:

    ```text
    kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": status.podIP}'
    ```

    ```output
    {
      "name": "cassandra-0",
      "hostname": "k8s-5",
      "hostIP": "10.140.0.8",
      "PodIP": "10.0.112.1"
    }
    {
      "name": "cassandra-1",
      "hostname": "k8s-2",
      "hostIP": "10.140.0.4",
      "PodIP": "10.0.192.2"
    }
    {
      "name": "cassandra-2",
      "hostname": "k8s-1",
      "hostIP": "10.140.0.5",
      "PodIP": "10.0.64.3"
    }
    {
      "name": "cassandra-3",
      "hostname": "k8s-3",
      "hostIP": "10.140.0.6",
      "PodIP": "10.0.240.1"
    }
    {
      "name": "cassandra-4",
      "hostname": "k8s-4",
      "hostIP": "10.140.0.7",
      "PodIP": "10.0.128.1"
    }
    ```

    Note that Kubernetes scheduled the `cassandra-2` Pod on the `k8s-1` node.

2. Display the list of nodes and their labels:

    ```text
    kubectl get nodes --show-labels
    ```

    ```output
    NAME         STATUS        LABELS
    k8s-0        Ready         cassandra-data-cassandra-1=true,cassandra-data-cassandra-3=true
    k8s-1        Ready         cassandra-data-cassandra-1=true,cassandra-data-cassandra-4=true
    k8s-2        Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
    k8s-3        Ready         cassandra-data-cassandra-3=true
    k8s-4        Ready         cassandra-data-cassandra-4=true
    k8s-5        Ready
    k8s-master   Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
    ```

    {{<info>}}
**NOTE:** This example output is truncated for brevity.
    {{</info>}}

3. Decommission the `k8s-1` Portworx node by following the steps in the [Decommission a Node](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node) section.

4. Decommission the `k8s-1` Kubernetes node by entering the `kubectl delete node` command with `k8s-1` as an argument:

    ```text
    kubectl delete node k8s-1
    ```


5. List the Pods in your cluster by entering the following command:

    ```text
    kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
    ```

    ```output
    {
      "name": "cassandra-0",
      "hostname": "k8s-5",
      "hostIP": "10.140.0.8",
      "PodIP": "10.0.112.1"
    }
    {
      "name": "cassandra-1",
      "hostname": "k8s-2",
      "hostIP": "10.140.0.4",
      "PodIP": "10.0.192.2"
    }
    {
      "name": "cassandra-2",
      "hostname": "k8s-0",
      "hostIP": "10.140.0.3",
      "PodIP": "10.0.160.2"
    }
    {
      "name": "cassandra-3",
      "hostname": "k8s-3",
      "hostIP": "10.140.0.6",
      "PodIP": "10.0.240.1"
    }
    {
      "name": "cassandra-4",
      "hostname": "k8s-4",
      "hostIP": "10.140.0.7",
      "PodIP": "10.0.128.1"
    }
    ```

    Note that the `cassandra-2` pod is scheduled on the `k8s-0` node.

6. Display the list of nodes and their labels:

    ```text
    kubectl get nodes --show-labels
    ```

    ```output
    NAME         STATUS        LABELS
    k8s-0        Ready         cassandra-data-cassandra-1=true,cassandra-data-cassandra-3=true
    k8s-2        Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
    k8s-3        Ready         cassandra-data-cassandra-3=true
    k8s-4        Ready         cassandra-data-cassandra-4=true
    k8s-5        Ready
    k8s-master   Ready         cassandra-data-cassandra-0=true,cassandra-data-cassandra-2=true
    ```