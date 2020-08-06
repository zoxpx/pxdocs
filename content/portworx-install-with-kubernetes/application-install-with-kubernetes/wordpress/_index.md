---
title: WordPress with Portworx on Kubernetes
linkTitle: WordPress
keywords: WordPress, install, kubernetes, k8s, MySQL
description: Deploy WordPress and MySQL with Portworx on Kubernetes
noicon: true
---

This reference architecture document shows how you can deploy WordPress, an open-source content management system, with Portworx on Kubernetes. This architecture provides the following benefits:

* Portworx enables reliable and persistent storage to ensure WordPress runs with HA
* Portworx enables shared volumes for file uploads
* Kubernetes automatically replicates your MySQL data
* You can horizontally scale the WordPress container using multi-writer semantics for the file-uploads directory <!-- I don't understand the meaning of this sentence -->
* The cluster automatically repairs itself in the event of a node failure


<!-- We can probably just remove the following paragraphs

This document makes use of Kubernetes storage primitives PersistentVolumes (PV) and PersistentVolumeClaims (PVC).

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator, and a PersistentVolumeClaim (PVC) is a set amount of storage in a PV. PersistentVolumes and PersistentVolumeClaims are independent from Pod lifecycles and preserve data through restarting, rescheduling, and even deleting Pods in kubernetes.
-->


<!-- I'm not sure this paragraph is still relevant. I suggest we remove it

`Note:` The spec files provided in this tutorial are using beta Deployment APIs and are specific to Kubernetes version 1.8 and above. If you wish to use this tutorial with an earlier version of Kubernetes, please update the beta API appropriately, or reference earlier versions of kubernetes.

-->

## Prerequisites

* You must have a Kubernetes cluster with a minimum of three worker nodes.
* Portworx is installed on your Kubernetes cluster. For details about how you can install Portworx on Kubernetes, see the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page.
* You must have Stork installed on your Kubernetes cluster. For details about how you can install Stork, see the [Stork](/portworx-install-with-kubernetes/storage-operations/stork) page.


## Dynamically provision a volume for MySQL

1. Create a file called `mysql-sc.yaml`, specifying the following fields and values:

  * **apiVersion:** as `storage.k8s.io/v1`
  * **kind:** as `StorageClass`
  * **metadata.name:** with the name of your `StorageClass` object (this example uses `mysql-sc`)
  * **provisioner:** as `kubernetes.io/portworx-volume`. For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section of the Kubernetes website.
  * **parameters.repl:** with the number of replicas Portworx should create (this example creates two replicas)
  * **parameters.priority_io:** with the type of the storage pool (this example uses a high-priority storage pool)

    ```text
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: mysql-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "3"
      priority_io: "high"
    ```

    For more details about how you can configure a storage class, see the [Using Dynamic Provisioning](/portworx-install-with-kubernetes/storage-operations/create-pvcs/dynamic-provisioning/#using-dynamic-provisioning) section of the Portworx documentation.

2. Apply the spec:

    ```text
    kubectl apply -f mysql-sc.yaml.yaml
    ```

3. Create a file called `mysql-pvc.yaml` with the following content:

    ```text
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: mysql-pvc
      annotations:
        volume.beta.kubernetes.io/storage-class: mysql-sc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi
    ```

    {{<info>}}
**NOTE:** This PVC references the `mysql-sc` storage class. As a result, Kubernetes will automatically create a new PVC for each replica.
    {{</info>}}

4. Apply the spec:

    ```text
    kubectl apply -f mysql-pvc.yaml
    ```

## Dynamically provision a volume for WordPress

1. Create a file called `wordpress-sc.yaml` with the following content:

    ```text
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: wordpress-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "3"
      priority_io: "high"
      shared: "true"
    ```

    {{<info>}}
**NOTE:** The `shared: "true"` flag creates a globally shared namespace volume which can be used by multiple Pods.
    {{</info>}}

2. Apply the spec:

    ```text
    kubectl apply -f wordpress-sc.yaml
    ```

3. Create a file called `wordpress-pvc.yaml` with the following content:

    ```text
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: wp-pvc
      labels:
        app: wordpress
      annotations:
        volume.beta.kubernetes.io/storage-class: wordpress-sc
    spec:
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 1Gi
    ```

    {{<info>}}
**NOTE:** This PVC references the `wordpress-sc` storage class. As a result, Kubernetes will automatically create a new PVC for each replica.
    {{</info>}}

4. Apply the spec:

    ```text
    kubectl apply -f wordpress-pvc.yaml
    ```

## Create a Kubernetes secret for storing your MySQL password

A secret is an object that contains sensitive data. To create a secret, you can use the `kubectl create secret` command. Note that, to protect your sensitive data, the `kubectl get` and `kubectl describe` commands do not display the content of a secret.

1. Use the `echo` command to save your MySQL password to a file called `./password.txt`, replacing `<YOUR-PASSWORD>` with your actual password:

    ```text
    echo -n '<YOUR-PASSWORD' > ./password.txt
    ```

2. To create a new secret, enter the `kubectl create secret` command, specifying:

  * The `generic` parameter. This instructs Kubernetes to create a secret based on a file, directory, or specified literal value.
  * The name of your secret (this example uses `mysql-pass`)
  * The `--from-file` flag with the name of the file in which you stored your password

    ```text
    kubectl create secret generic mysql-pass --from-file=./password.txt
    ```

3. Use the `kubectl get secrets` command to verify that Kubernetes created the secret:

    ```text
    kubectl get secrets
    ```

## Deploy MySQL

1. Create a file named `mysql-service.yaml` with the following content:

    ```text
    apiVersion: v1
    kind: Service
    metadata:
      name: wordpress-mysql
      labels:
        app: wordpress
    spec:
      ports:
        - port: 3306
      selector:
        app: wordpress
        tier: mysql
      clusterIP: None
    ```

2. Apply the spec:

    ```text
    kubectl apply -f mysql-service.yaml
    ```

3. Create a file named `mysql-deployment.yaml` with the following content:

    ```text
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: wordpress-mysql
      labels:
        app: wordpress
    spec:
      selector:
        matchLabels:
          app: wordpress
      strategy:
        type: Recreate
      template:
        metadata:
          labels:
            app: wordpress
            tier: mysql
        spec:
          # Use the Stork scheduler to enable more efficient placement of the pods
          schedulerName: stork
          containers:
          - image: mysql:5.6
            imagePullPolicy:
            name: mysql
            env:
              # $ kubectl create secret generic mysql-pass --from-file=password.txt
              # make sure password.txt does not have a trailing newline
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: password.txt
            ports:
            - containerPort: 3306
              name: mysql
            volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
          volumes:
          - name: mysql-persistent-storage
            persistentVolumeClaim:
              claimName: mysql-pvc
    ```

    Note the following about this `Deployment`:
    * Kubernetes creates a single-instance MySQL database
    * Kubernetes creates an environment variable called `MYSQL_ROOT_PASSWORD` that contains your MySQL password
    * Portworx mounts the Portworx persistent volume in the `/var/lib/mysql` directory
    * The Stork scheduler will place your Pods closer to where their data is located

4. Apply the spec:

    ```text
    kubectl apply -f mysql-deployment.yaml
    ```

## Deploy WordPress

1. Create a file called `wordpress-service.yaml` with the following content:

    ```text
    apiVersion: v1
    kind: Service
    metadata:
      name: wordpress
      labels:
        app: wordpress
    spec:
      ports:
        - port: 80
          nodePort: 30303
      selector:
        app: wordpress
        tier: frontend
      type: NodePort
    ```

    Note that the `spec.type` field is set to `NodePort`. Kubernetes exposes the service on each node and makes it accessible from outside the cluster. For more details, see the [Type NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) section of the Kubernetes documentation.

2. Apply the spec:

    ```text
    kubectl apply -f wordpress-service.yaml
    ```

3. Create a file called `wordpress-deployment.yaml` with the following content:

    ```text
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: wordpress
      labels:
        app: wordpress
    spec:
      selector:
        matchLabels:
          app: wordpress
      replicas: 3
      strategy:
        type: Recreate
      template:
        metadata:
          labels:
            app: wordpress
            tier: frontend
        spec:
          # Use the Stork scheduler to enable more efficient placement of the pods
          schedulerName: stork
          containers:
          - image: wordpress:4.8-apache
            name: wordpress
            imagePullPolicy:
            env:
            - name: WORDPRESS_DB_HOST
              value: wordpress-mysql
            - name: WORDPRESS_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-pass
                  key: password.txt
            ports:
            - containerPort: 80
              name: wordpress
            volumeMounts:
            - name: wordpress-persistent-storage
              mountPath: /var/www/html
          volumes:
          - name: wordpress-persistent-storage
            persistentVolumeClaim:
              claimName: wp-pvc
    ```

    Note the following about this `Deployment`
    * Portworx will create three replicas of each volume
    * The Stork scheduler will place your Pods closer to where their data is located
    * Kubernetes will create an environment variable called `WORDPRESS_DB_PASSWORD` that contains your MySQL password

4. Apply the spec:

    ```text
    kubectl apply -f wordpress-deployment.yaml
    ```

## Validate the cluster functionality

1. List your Pods:

    ```text
    kubectl get pods
    ```

2. Display your services:

    ```text
    kubectl get services
    ```

## Clean up

1. Enter the following command to delete the Kubernetes secret:

    ```text
    kubectl delete secret mysql-pass
    ```

2. Use the `kubectl delete` to delete your WordPress deployment and PVC:

    ```text
    kubectl delete -f wordpress-deployment.yaml
    kubectl delete -f wordpress-pvc.yaml
    ```

3. Use the `kubectl delete` to delete your MySQL deployment and PVC:

    ```text
    kubectl delete -f mysql-deployment.yaml
    kubectl delete -f mysql-pvc.yaml
    ```

<!-- I don't understand the following paragraph. Do we even use a `hostPath`?
Reference: https://kubernetes.io/docs/concepts/storage/volumes/#hostpath

`Note:` Portworx PersistentVolume would allow you to recreate the Deployments and Services at this point without losing data, but hostPath loses the data as soon as the Pod stops running...

-->

{{% content "portworx-install-with-kubernetes/application-install-with-kubernetes/shared/discussion-forum.md" %}}
