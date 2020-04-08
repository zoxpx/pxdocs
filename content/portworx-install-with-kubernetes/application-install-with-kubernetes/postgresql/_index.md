---
title: PostgreSQL on Portworx
linkTitle: PostgreSQL
keywords: PostgreSQL, Postgres, install, kubernetes, k8s
description: Use this guide to install and run PostgreSQL using Kubernetes
weight: 2
noicon: true
---

Perform the steps in this topic to deploy PostgreSQL with Portworx on Kubernetes.

## Prerequisites

* **A running Portworx cluster**. Refer to the [Installation](/start-here-installation/#installation) page for details about how to install Portworx.
* **Kubectl**. Refer to the [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) page of the Kubernetes documentation for details about installing `kubectl`.
* **Stork**. Refer to the [Using Stork with Portworx](/portworx-install-with-kubernetes/storage-operations/stork/) page for details about installing Stork.

## Create a StorageClass

1. Create a file named `px-postgres-sc.yaml`, and copy in the following spec:

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
        name: px-postgres-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "2"
    ```

    Note the following about this `StorageClass`:

    * The `provisioner` parameter is set to  `kubernetes.io/portworx-volume`. For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section of the Kubernetes website.
    * Two replicas of each volume will be created

2. Apply the spec by entering the following command:

    ```text
    kubectl apply -f px-postgres-sc.yaml
    ```

## Create a PVC

1. Create a file named `px-postgres-vol.yaml` with the following content:

    ```text
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: postgres-data
      annotations:
        volume.beta.kubernetes.io/storage-class: px-postgres-sc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi

    ```

    Note that this PVC references the `px-postgres-sc` storage class defined in the [Create a StorageClass](#create-a-storageclass) section. As a result, Kubernetes will automatically create a new PVC for each replica.

2. Apply the spec by entering the following command:

    ```
    kubectl apply -f px-postgres-vol.yaml
    ```

## Deploy PostgreSQL using Stork


1. Create a file named `px-postgres-app.yaml` with the following content:

    ```text
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: postgres
    spec:
      selector:
        matchLabels:
          app: postgres
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 1
        type: RollingUpdate
      replicas: 1
      template:
        metadata:
          labels:
            app: postgres
        spec:
          schedulerName: stork
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: px/enabled
                    operator: NotIn
                    values:
                    - "false"
          containers:
          - name: postgres
            image: postgres:9.5
            imagePullPolicy: "IfNotPresent"
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
              name: postgredb
          volumes:
          - name: postgredb
            persistentVolumeClaim:
              claimName: postgres-data
      ```

    Note the following:

    * Specifies Stork as scheduler (`schedulerName: stork`)
    * Sets the following environment variables:
      * POSTGRES_USER (defines the superuser)
      * POSTGRES_PASSWORD (specifies the superuser password)
      * PGDATA (configures the location for the database files)
    * References the `postgres-data` PVC defined in the [Create a PVC](#create-a-pvc) section.


2. Apply the spec by entering the following command:

      ```text
      kubectl apply -f px-postgres-app.yaml
      ```

## Verify your PostgreSQL installation

1. Enter the following `kubectl get` command to list your storage classes:

      ```text
      kubectl get sc
      ```

      ```
      NAME             PROVISIONER                     AGE
      px-postgres-sc   kubernetes.io/portworx-volume   1h
      ```

    In the above example output, note that the provisioner is set to `kubernetes.io/portworx-volume`


2. Enter the `kubectl get pvc` command to verify that the PVC is bound to a volume:

      ```text
      kubectl get pvc
      ```

      ```
      NAME            STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
      postgres-data   Bound     pvc-60e43292-06e3-11e8-96b4-022185d04910   1Gi        RWO            px-postgres-sc   1h
      ```

3. Use the `kubectl get pods` command to verify the status of the PostgreSQL pod:

      ```text
      kubectl get pod
      ```

      ```
      NAME                        READY     STATUS    RESTARTS   AGE
      postgres-86cb8587c4-l9r48   1/1       Running   0          1h
      ```

    Make a note of the name of the pod. You'll need it in the next step.

4. Enter the following `kubectl exec` command, specifying your own pod name, to open a shell session into your pod. This example opens the `postgres-86cb8587c4-l9r48` pod:

      ```text
      kubectl exec -it postgres-86cb8587c4-l9r48 bash
      ```

      ```
      root@postgres-86cb8587c4-l9r48:/#
      ```

5. Start the PostgreSQL interactive shell. Use the`-U` flag to connect as the `pgbench` user:

      ```text
      root@postgres-86cb8587c4-l9r48:/# psql -U pgbench
      ```

      ```
      psql (9.5.10)
      Type "help" for help.
      ```

6. List your databases:

      ```text
      pgbench=# \l
      ```

      ```
                                    List of databases
        Name    |  Owner  | Encoding |  Collate   |   Ctype    |  Access privileges
      -----------+---------+----------+------------+------------+---------------------
      pgbench   | pgbench | UTF8     | en_US.utf8 | en_US.utf8 |
      postgres  | pgbench | UTF8     | en_US.utf8 | en_US.utf8 |
      template0 | pgbench | UTF8     | en_US.utf8 | en_US.utf8 | =c/pgbench         +
                |         |          |            |            | pgbench=CTc/pgbench
      template1 | pgbench | UTF8     | en_US.utf8 | en_US.utf8 | =c/pgbench         +
                |         |          |            |            | pgbench=CTc/pgbench
      (4 rows)
      ```

7. Exit the PostgreSQL interactive shell:

      ```text
      pgbench=# \q
      ```

{{% content "portworx-install-with-kubernetes/application-install-with-kubernetes/shared/discussion-forum.md" %}}
