---
title: Install
linkTitle: Install
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, cassandra
description: Install Cassandra with Portworx on Kubernetes
weight: 2
---

## Prerequisites

* You must have a Kubernetes cluster with a minimum of three worker nodes.
* Portworx is installed on your Kubernetes cluster. For details about how you can install Portworx on Kubernetes, see the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page.
* You must have Stork installed on your Kubernetes cluster. For details about how you can install Stork, see the [Stork](/portworx-install-with-kubernetes/storage-operations/stork) page.

## Install Cassandra

1. Enter the following `kubectl apply` command to create a headless service:

    ```text
    kubectl apply -f - <<'_EOF'
    ---
    apiVersion: v1
    kind: Service
    metadata:
      labels:
        app: cassandra
      name: cassandra
    spec:
      clusterIP: None
      ports:
        - port: 9042
      selector:
        app: cassandra
    ---
    _EOF
    ```

    ```output
    service/cassandra created
    ```

    Note the following about this service:

  * The `spec.clusterIP` field is set to `None`.
  * The `spec.selector.app` field is set to `cassandra`. The Kubernetes endpoints controller will configure the DNS to return addresses that point directly to your Cassandra Pods.

2. Use the following `kubectl apply` command to create a storage class:

    ```text
    kubectl apply -f - <<'_EOF'
    ---
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: portworx-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "2"
      priority_io: "high"
      group: "cassandra_vg"
      fg: "true"
    ---
    _EOF
    ```

    ```output
    storageclass.storage.k8s.io/px-storageclass created
    ```

    Note the following about this storage class:

  * The provisioner field is set to `kubernetes.io/portworx-volume`. For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section of the Kubernetes documentation
  * The name of the `StorageClass` object is `portworx-sc`
  * Portworx will create two replicas of each volume
  * Portworx will use a high priority storage pool

3. The following command creates a stateful set with three replicas and uses the STORK scheduler to place your Pods closer to where their data is located:

      ```text
      kubectl apply -f - <<'_EOF'
      ---
      apiVersion: "apps/v1beta1"
      kind: StatefulSet
      metadata:
        name: cassandra
      spec:
        serviceName: cassandra
        replicas: 3
        template:
          metadata:
            labels:
              app: cassandra
          spec:
            schedulerName: stork
            containers:
            - name: cassandra
              image: gcr.io/google-samples/cassandra:v12
              imagePullPolicy: Always
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
                  cpu: "500m"
                  memory: 1Gi
                requests:
                cpu: "500m"
                memory: 1Gi
              securityContext:
                capabilities:
                  add:
                    - IPC_LOCK
              lifecycle:
                preStop:
                  exec:
                    command: ["/bin/sh", "-c", "PID=$(pidof java) && kill $PID && while ps -p $PID > /dev/null; do sleep 1; done"]
              env:
                - name: MAX_HEAP_SIZE
                  value: 512M
                - name: HEAP_NEWSIZE
                  value: 100M
                - name: CASSANDRA_SEEDS
                  value: "cassandra-0.cassandra.default.svc.cluster.local"
                - name: CASSANDRA_CLUSTER_NAME
                  value: "K8Demo"
                - name: CASSANDRA_DC
                  value: "DC1-K8Demo"
                - name: CASSANDRA_RACK
                  value: "Rack1-K8Demo"
                - name: CASSANDRA_AUTO_BOOTSTRAP
                  value: "false"
                - name: POD_IP
                  valueFrom:
                    fieldRef:
                      fieldPath: status.podIP
                - name: POD_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
              readinessProbe:
                exec:
                  command:
                  - /bin/bash
                  - -c
                  - /ready-probe.sh
                initialDelaySeconds: 15
                timeoutSeconds: 5
              # These volume mounts are persistent. They are like inline claims,
              # but not exactly because the names need to match exactly one of
              # the stateful pod volumes.
              volumeMounts:
              - name: cassandra-data
                mountPath: /var/lib/cassandra
        # These are converted to volume claims by the controller
        # and mounted at the paths mentioned above.
        volumeClaimTemplates:
        - metadata:
            name: cassandra-data
            annotations:
              volume.beta.kubernetes.io/storage-class: px-storageclass
          spec:
            accessModes: [ "ReadWriteOnce" ]
            resources:
              requests:
                storage: 1Gi
      ---
      ```

      ```output
      statefulset.apps/cassandra configured
      ```

## Validate the cluster functionality

1. Use the `kubectl get pvc` command to verify that the PVCs are bound to your persistent volumes:

    ```text
    kubectl get pvc
    ```

    ```output
    NAME                         STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
    cassandra-data-cassandra-0   Bound     pvc-e6924b73-72f9-11e7-9d23-42010a8e0002   1Gi        RWO           portworx-sc    2m
    cassandra-data-cassandra-1   Bound     pvc-49e8caf6-735d-11e7-9d23-42010a8e0002   1Gi        RWO           portworx-sc    2m
    cassandra-data-cassandra-2   Bound     pvc-603d4f95-735d-11e7-9d23-42010a8e0002   1Gi        RWO           portworx-sc    1m
    ```

2. Verify that Kubernetes created the `portworx-sc` storage class:

    ```text
    kubectl get storageclass
    ```

    ```output
    NAME                 TYPE
    portworx-sc          kubernetes.io/portworx-volume
    ```

3. Use the `pxctl volume list` command to display the list of volumes in your cluster:

    ```text
    pxctl volume list
    ```

    ```output
    ID                      NAME                                            SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
    651254593135168442      pvc-49e8caf6-735d-11e7-9d23-42010a8e0002        1 GiB   2       no      no              LOW             0       up - attached on 10.142.0.3
    136016794033281980      pvc-603d4f95-735d-11e7-9d23-42010a8e0002        1 GiB   2       no      no              LOW             0       up - attached on 10.142.0.4
    752567898197695962      pvc-e6924b73-72f9-11e7-9d23-42010a8e0002        1 GiB   2       no      no              LOW             0       up - attached on 10.142.0.5
    ```

    Make a note of the ID of one of your volumes. You'll need it in the next step.

4. To verify that your Portworx volumes have two replicas, enter the `pxctl volume inspect` command, specifying the ID from the previous step. The following example command uses `651254593135168442`:

    ```text
    pxctl volume inspect 651254593135168442
    ```

    ```output
    Volume  :  651254593135168442
            Name                     :  pvc-49e8caf6-735d-11e7-9d23-42010a8e0002
            Size                     :  1.0 GiB
            Format                   :  ext4
            HA                       :  2
            IO Priority              :  LOW
            Creation time            :  Jul 28 06:23:36 UTC 2017
            Shared                   :  no
            Status                   :  up
            State                    :  Attached: k8s-0
            Device Path              :  /dev/pxd/pxd651254593135168442
            Labels                   :  pvc=cassandra-data-cassandra-1
            Reads                    :  37
            Reads MS                 :  72
            Bytes Read               :  372736
            Writes                   :  1816
            Writes MS                :  17648
            Bytes Written            :  38424576
            IOs in progress          :  0
            Bytes used               :  33 MiB
            Replica sets on nodes:
                    Set  0
                            Node     :  10.142.0.4
                            Node     :  10.142.0.3
    ```

    Note that this volume is up and attached to the `k8s-0` host.

5. List your Pods: <!-- Do we need this step? -->

    ```text
    kubectl get pods
    ```

    ```output

    NAME          READY     STATUS    RESTARTS   AGE
    cassandra-0   1/1       Running   0          1m
    cassandra-1   1/1       Running   0          1m
    cassandra-2   0/1       Running   0          47s
    ```

6. Show the list of your Pods and the hosts on which Kubernetes scheduled them:

    ```text
    kubectl get pods -l app=cassandra -o json | jq '.items[] | {"name": .metadata.name,"hostname": .spec.nodeName, "hostIP": .status.hostIP, "PodIP": .status.podIP}'
    ```

    ```output
    {
      "name": "cassandra-0",
      "hostname": "k8s-2",
      "hostIP": "10.142.0.5",
      "PodIP": "10.0.160.2"
    }
    {
      "name": "cassandra-1",
      "hostname": "k8s-0",
      "hostIP": "10.142.0.3",
      "PodIP": "10.0.64.2"
    }
    {
      "name": "cassandra-2",
      "hostname": "k8s-1",
      "hostIP": "10.142.0.4",
      "PodIP": "10.0.192.3"
    }
    ```

7. To open a shell session into one of your Pods, enter the following `kubectl exec` command, specifying your Pod name. This example opens the `cassandra-0` Pod:

    ```text
    kubectl exec cassandra-0
    ```

8. Use the `nodetool status` command to retrieve information about your Cassandra cluster:

    ```text
    nodetool status
    ```

    ```output
    Datacenter: DC1-K8Demo
    ======================
    Status=Up/Down
    |/ State=Normal/Leaving/Joining/Moving
    --  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
    UN  10.0.160.2  164.39 KiB  32           62.3%             ce3b48b8-1655-48a2-b167-08d03ca6bc41  Rack1-K8Demo
    UN  10.0.64.2   190.76 KiB  32           64.1%             ba31128d-49fa-4696-865e-656d4d45238e  Rack1-K8Demo
    UN  10.0.192.3  104.55 KiB  32           73.6%             c778d78d-c6bc-4768-a3ec-0d51ba066dcb  Rack1-K8Demo
    ```

9. Terminate the shell session:

    ```text
    exit
    ```

## Related topics

* [Cassandra on Kubernetes: Step-by-step guide for the most popular k8s platforms](https://portworx.com/cassandra-kubernetes/)
* [Run multiple Cassandra rings on the same hosts](https://portworx.com/run-multiple-cassandra-clusters-hosts/)