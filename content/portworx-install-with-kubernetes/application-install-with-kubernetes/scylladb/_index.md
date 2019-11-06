---
title: ScyllaDB on Kubernetes and Portworx
linkTitle: ScyllaDB
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, scylladb
description: See how Portworx can be used to deploy a ScyllaDB StatefulSet on top of Kubernetes.
weight: 9
noicon: true
---

ScyllaDB is a NoSQL database that aims to provide low latency and high throughput. Portworx is a software-defined storage overlay that allows you to run highly-available stateful applications. This article shows how you can create and run a ScyllaDB cluster on Kubernetes, which stores data on Portworx volumes.

## Prerequisites


<!--
Storage requirements? The sc mentions SSDs, and there's probably a minimum storage amount: looks like 60GB x 3 nodes x a repl of 2 = 360GB?
-->

* You must have a Kubernetes cluster with a minimum of 3 worker nodes.
* Portworx is installed on your Kubernetes cluster. For more details on how to install Portworx, refer to the instructions from the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page.


## Create a StorageClass for volume provisioning

1. Use the following command to list the nodes in your cluster:

    ```text
    kubectl get nodes -o wide
    ```

    ```output
    NAME                           STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION              CONTAINER-RUNTIME
    ravi-blr-dev-dour-shoulder-0   Ready    master   103d   v1.14.1   70.0.87.119   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
    ravi-blr-dev-dour-shoulder-1   Ready    <none>   16d    v1.14.1   70.0.87.82    <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
    ravi-blr-dev-dour-shoulder-2   Ready    <none>   103d   v1.14.1   70.0.87.118   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
    ravi-blr-dev-dour-shoulder-3   Ready    <none>   103d   v1.14.1   70.0.87.120   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
    ```

2. Define the following `portworx-sc.yaml` StorageClass:

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: scylla-ssd
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "2"
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    ```

3. Apply the StorageClass configuration:

    ```text
    kubectl apply -f portworx-sc.yml
    ```

## ScyllaDB installation

1. Create a file called `scylla-configmap.yaml` with the following content:

    ```text
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: scylla
    data:
      ready-probe.sh: |
        #!/bin/bash

        if [[ $(nodetool status | grep $POD_IP) == *"UN"* ]]; then
          if [[ $DEBUG ]]; then
            echo "UN";
          fi
          exit 0;
        else
          if [[ $DEBUG ]]; then
            echo "Not Up";
          fi
          exit 1;
        fi
    ```

2. Apply the ConfigMap:

    ```text
    kubectl apply -f scylla-configmap.yaml
    ```

3. Create a file called `scylla-service.yaml` with the following content:

    ```text
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: scylla
      name: scylla
    spec:
      clusterIP: None
      ports:
        - port: 9042
      selector:
        app: scylla
    ```

4. Apply the Service:

    ```text
    kubectl apply -f scylla-service.yaml
    ```

5. The spec below creates StatefulSet for ScyllaDB with 3 replicas and uses the Stork scheduler to place pods to closer to where their data is located. Create a file called `scylla-statefulset.yaml` with the following content:

      ```text
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: scylla
      labels:
        app: scylla
    spec:
      serviceName: scylla
      replicas: 3
      selector:
        matchLabels:
          app: scylla
      template:
        metadata:
          labels:
            app: scylla
        spec:
          schedulerName: stork
          containers:
            - name: scylla
              image: scylladb/scylla:2.0.0
              imagePullPolicy: IfNotPresent
              args: ["--seeds", "scylla-0.scylla.default.svc.cluster.local"]
              ports:
                - containerPort: 7000
                  name: intra-node
                - containerPort: 7001
                  name: tls-intra-node
                - containerPort: 7199
                  name: jmx
                - containerPort: 9042
                  name: cql
              resources:
                limits:
                  cpu: 500m
                  memory: 1Gi
                requests:
                  cpu: 500m
                  memory: 1Gi
              securityContext:
                capabilities:
                  add:
                    - IPC_LOCK
              lifecycle:
                preStop:
                  exec:
                    command: ["/bin/sh", "-c", "PID=$(pidof scylla) && kill $PID && while ps -p $PID > /dev/null; do sleep 1; done"]
              env:
                - name: POD_IP
                  valueFrom:
                    fieldRef:
                      fieldPath: status.podIP

              readinessProbe:
                exec:
                  command:
                    - /bin/bash
                    - -c
                    - exec
                    - /opt/ready-probe.sh
                initialDelaySeconds: 15
                timeoutSeconds: 5
              volumeMounts:
                - name: scylla-data
                  mountPath: /var/lib/scylla
                - name: scylla-ready-probe
                  mountPath: /opt/ready-probe.sh
                  subPath: ready-probe.sh
          volumes:
            - name: scylla-ready-probe
              configMap:
                name: scylla
      volumeClaimTemplates:
        - metadata:
            name: scylla-data
            annotations:
              volume.beta.kubernetes.io/storage-class: scylla-ssd
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 60Gi
    ```

6. Apply the `scylla-statefulset.yaml` StatefulSet:

    ```text
    kubectl apply scylla-statefulset.yaml
    ```

## Verify ScyllaDB installation

1. Enter the `kubectl get pvc` command to verify that the PVCs are bound to a volume using the storage class. The PVC status shows as `Bound` if the operation succeeded:

    ```text
    kubectl get pvc
    ```

    ```output
    NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    scylla-data-scylla-0   Bound    pvc-cc1c5c4f-e665-11e9-a83a-000c29886e3e   60Gi       RWO            scylla-ssd     3h
    scylla-data-scylla-1   Bound    pvc-df1cb1a2-e665-11e9-a83a-000c29886e3e   60Gi       RWO            scylla-ssd     3h
    scylla-data-scylla-2   Bound    pvc-ee87e5d7-e665-11e9-a83a-000c29886e3e   60Gi       RWO            scylla-ssd     3h
    ```

2. Enter the `kubectl get pods` command to verify that the ScyllaDB pods have deployed successfully. The pod status shows as `Running` if the operation succeeded:

    ```text
    kubectl get pods
    ```

    ```output
    NAME       READY   STATUS    RESTARTS   AGE
    scylla-0   1/1     Running   0          3h
    scylla-1   1/1     Running   0          3h
    scylla-2   1/1     Running   0          3h
    ```

3. Run the `nodetool status` command in the `scylla-0` pod to verify that the ScyllaDB cluster was created:

    ```text
    kubectl exec scylla-0 -- nodetool status
    ```

    ```output
    Datacenter: datacenter1
    =======================
    Status=Up/Down
    |/ State=Normal/Leaving/Joining/Moving
    --  Address        Load       Tokens       Owns (effective)  Host ID                               Rack
    UN  10.233.127.67  356.04 KB  256          61.5%             b7250433-7f4b-414e-8632-d9b928f1fc4a  rack1
    UN  10.233.76.19   351.15 KB  256          70.5%             814bf13f-8d4a-441d-bbba-c897c7441895  rack1
    UN  10.233.121.53  359.24 KB  256          68.0%             013699ce-1fa8-4a32-86ec-640ce9ec9f6e  rack1
    ```

    Note the pods placement and the hosts on which they are scheduled

4. Enter the `kubectl get pods` command, filtering the output using the `jq` command to display the following:

  * Pod name
  * Hostname
  * Host IP
  * Pod IP

    ```text
    kubectl get pods -l app=scylla -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
    ```

    ```output
    {
      "name": "scylla-0",
      "hostname": "ravi-blr-dev-dour-shoulder-3",
      "hostIP": "70.0.87.120",
      "PodIP": "10.233.121.53"
    }
    {
      "name": "scylla-1",
      "hostname": "ravi-blr-dev-dour-shoulder-1",
      "hostIP": "70.0.87.82",
      "PodIP": "10.233.76.19"
    }
    {
      "name": "scylla-2",
      "hostname": "ravi-blr-dev-dour-shoulder-2",
      "hostIP": "70.0.87.118",
      "PodIP": "10.233.127.67"
    }
    ```

5. Enter the `ssh` command to open a shell session into one of your nodes:

    ```text
    ssh 70.0.87.120
    ```

6. Enter the `pxctl volume list` command to list your volume IDs. Save one of the node IDs for future reference:

    ```text
    pxctl volume list
    ```

    ```output
    ID			NAME						SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS			SNAP-ENABLED
    242236313329814877	pvc-cc1c5c4f-e665-11e9-a83a-000c29886e3e	60 GiB	2	no	no		LOW		up - attached on 70.0.87.120	no
    702215287887827398	pvc-df1cb1a2-e665-11e9-a83a-000c29886e3e	60 GiB	2	no	no		LOW		up - attached on 70.0.87.82	no
    685261507172158119	pvc-ee87e5d7-e665-11e9-a83a-000c29886e3e	60 GiB	2	no	no		LOW		up - attached on 70.0.87.118	no
    ```

7. Enter the `pxctl volume inspect` command to examine your volume. In the example output below, the Portworx volume contains 2 replica sets and is attached to node 3:

    ```text
    pxctl volume inspect 242236313329814877
    ```

    ```output
    Volume	:  242236313329814877
      Name            	 :  pvc-cc1c5c4f-e665-11e9-a83a-000c29886e3e
      Size            	 :  60 GiB
      Format          	 :  ext4
      HA              	 :  2
      IO Priority     	 :  LOW
      Creation time   	 :  Oct 4 05:14:10 UTC 2019
      Shared          	 :  no
      Status          	 :  up
      State           	 :  Attached: fe471f15-d91c-4f94-900e-fdb2c8379541 (70.0.87.120)
      Device Path     	 :  /dev/pxd/pxd242236313329814877
      Labels          	 :  pvc=scylla-data-scylla-0,repl=2,namespace=default
      Reads           	 :  887
      Reads MS        	 :  553
      Bytes Read      	 :  4526080
      Writes          	 :  4086
      Writes MS       	 :  27087
      Bytes Written   	 :  1032036352
      IOs in progress 	 :  0
      Bytes used      	 :  24 MiB
      Replica sets on nodes:
        Set 0
          Node 		 : 70.0.87.120 (Pool 2)
          Node 		 : 70.0.87.82 (Pool 2)
      Replication Status	 :  Up
      Volume consumers	 :
        - Name           : scylla-0 (cc1d3b71-e665-11e9-a83a-000c29886e3e) (Pod)
          Namespace      : default
          Running on     : ravi-blr-dev-dour-shoulder-3
          Controlled by  : scylla (StatefulSet)
    ```

## Failover

Once you've created a ScyllaDB cluster on Kubernetes and Portworx, you can test how the cluster reacts to a failure.

### Pod failover

The steps in this exercise simulate a pod failure and demonstrate Portworx and Kubernetes' ability to recover from that failure. 

1. List the pods on which ScyllaDB is running:

    ```text
    kubectl get pods -l "app=scylla"
    ```

    ```output
    NAME       READY   STATUS    RESTARTS   AGE
    scylla-0   1/1     Running   0          4h
    scylla-1   1/1     Running   0          4h
    scylla-2   1/1     Running   0          4h
    ```

2. Enter the following `kubectl exec` command to open a `bash` session with the worker node on which ScyllaDB is running:

    ```text
    kubectl exec -it scylla-0 -- bash
    ```

3. Enter the `cqlsh` command to open a Cassandra shell session:


    ```text
    cqlsh
    ```

    ```output
    Connected to Test Cluster at 10.233.121.53:9042.
    [cqlsh 5.0.1 | Cassandra 3.0.8 | CQL spec 3.3.1 | Native protocol v4]
    Use HELP for help.
    cqlsh>
    ```

4. Enter the following `CREATE KEYSPACE` statement to create a keyspace named `demodb`:

    ```text
    CREATE KEYSPACE demodb WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };
    ```
5. Enter the following commands to switch to the `demodb` keyspace and create a table called `emp` within it:

    ```text
    cqlsh> use demodb;
    cqlsh:demodb> CREATE TABLE emp(emp_id int PRIMARY KEY, emp_name text, emp_city text, emp_sal varint,emp_phone varint);
    ```

6. Enter the following `INSERT INTO` statement to insert a record into the `emp` table:

    ```text
    cqlsh:demodb> INSERT INTO emp (emp_id, emp_name, emp_city, emp_phone, emp_sal) VALUES(123423445,'Steve', 'Denver', 5910234452, 50000);
    ```

7. Exit the Cassandra shell session:

    ```text
    cqlsh> exit
    ```

8. Enter the following `nodetool getendpoints` command to list the IP addresses of the nodes which are also hosting ScyllaDB information based on the partition key:

    ```text
    nodetool getendpoints demodb emp 123423445
    ```
    ```output
    10.233.76.19
    10.233.127.67
    ```

9. Enter the following `kubectl get pods` command to crosscheck the pod IP addresses with the IP addresses you just listed:

    ```text
    kubectl get pods -l app=scylla -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
    ```

    ```output
    {
      "name": "scylla-0",
      "hostname": "ravi-blr-dev-dour-shoulder-3",
      "hostIP": "70.0.87.120",
      "PodIP": "10.233.121.53"
    }
    {
      "name": "scylla-1",
      "hostname": "ravi-blr-dev-dour-shoulder-1",
      "hostIP": "70.0.87.82",
      "PodIP": "10.233.76.19"
    }
    {
      "name": "scylla-2",
      "hostname": "ravi-blr-dev-dour-shoulder-2",
      "hostIP": "70.0.87.118",
      "PodIP": "10.233.127.67"
    }
    ```

10. Enter the following `kubectl cordon` command to mark the `scylla-1` node as unschedulable:

    ```text
    kubectl cordon ravi-blr-dev-dour-shoulder-1
    ```

11. Enter the following `kubectl delete` command to delete the `syclla-1` pod:

    ```text
    kubectl delete pods scylla-1
    ```

12. Enter the following `kubectl get pods` command to see if Kubernetes scheduled the `syclla-1` pod to a different node:


    ```text
    kubectl get pods -o wide
    ```

    ```output

    NAME       READY   STATUS    RESTARTS   AGE   IP              NODE                           NOMINATED NODE   READINESS GATES
    scylla-0   1/1     Running   0          4h    10.233.121.53   ravi-blr-dev-dour-shoulder-3   <none>           <none>
    scylla-1   1/1     Running   0          25s   10.233.127.68   ravi-blr-dev-dour-shoulder-2   <none>           <none>
    scylla-2   1/1     Running   0          4h    10.233.127.67   ravi-blr-dev-dour-shoulder-2   <none>           <none> 
    ```

    Note that the `scyla-1` pod is now scheduled to the `ravi-blr-dev-dour-shoulder-2 ` node.


13. Enter the `kubectl get pods` command, filtering the output using the `jq` command to display the following

  * Pod name
  * Host name
  * Host IP
  * Pod IP

    ```text
    kubectl get pods -l app=scylla -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
    ```

    ```output
    {
      "name": "scylla-0",
      "hostname": "ravi-blr-dev-dour-shoulder-3",
      "hostIP": "70.0.87.120",
      "PodIP": "10.233.121.53"
    }
    {
      "name": "scylla-1",
      "hostname": "ravi-blr-dev-dour-shoulder-2",
      "hostIP": "70.0.87.118",
      "PodIP": "10.233.127.68"
    }
    {
      "name": "scylla-2",
      "hostname": "ravi-blr-dev-dour-shoulder-2",
      "hostIP": "70.0.87.118",
      "PodIP": "10.233.127.67"
    }
    ```

14. Enter the following `SELECT` statement to read the columns from the `demodb.emp` table:


    ```text
    kubectl exec scylla-1 -- cqlsh -e 'select * from demodb.emp'
    ```
    ```output
     emp_id    | emp_city | emp_name | emp_phone  | emp_sal
    -----------+----------+----------+------------+---------
     123423445 |   Denver |    Steve | 5910234452 |   50000

    (1 rows)
    ```

