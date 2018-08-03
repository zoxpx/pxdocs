---
title: WordPress and MySQL
---

This page provides instructions for deploying a WordPress site and a MySQL database with Portworx on Kubernetes.

{% hint style="info" %}
The spec files provided here use the beta Deployment APIs and are specific to Kubernetes version 1.8 and above.
{% endhint %}

**Create a MySQL Portworx PersistentVolume\(PV\) and PersistentVolumeClaim\(PVC\)**

Create the file `mysql-vol.yaml` with the following contents:

```text
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: portworx-sc-repl3
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  priority_io: "high"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc-1
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc-repl3
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

**Create a WordPress Portworx PersistentVolume\(PV\) and PersistentVolumeClaim\(PVC\)**

Create the file `wordpress-vol.yaml` with the following contents:

```text
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: portworx-sc-repl3-shared
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  priority_io: "high"
  shared: "true"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc-repl3-shared
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

#### Create a Secret for MySQL Password {#create-a-secret-for-mysql-password}

A Secret is an object that stores a piece of sensitive data such as a password or key. The manifest files are already configured to use a Secret, but you must create your own Secret.

{% hint style="info" %}
It's important to prevent sensitive data in a Secret from being exposed. For more information, see this [page](https://kubernetes.io/docs/concepts/configuration/secret/).
{% endhint %}

**Create the Secret object from the following command:**

`kubectl create secret generic mysql-pass --from-file=password.txt`

or

`kubectl create secret generic mysql-pass --from-literal=password=YOUR_PASSWORD`

#### Deploy MySQL with Portworx {#deploy-mysql-with-portworx}

The following manifest describes a single-instance MySQL Deployment. The MySQL container mounts the Portworx PersistentVolume at /var/lib/mysql. The MYSQL\_ROOT\_PASSWORD environment variable sets the database password from the Secret. The deployment uses stork as the scheduler to enable the pods to be placed closer to where their data is located.

**Deploy MySQL from the mysql.yaml file:**

`kubectl create -f mysql.yaml`

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
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
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
          claimName: mysql-pvc-1
```

#### Deploy WordPress {#deploy-wordpress}

The following manifest describes a three-instance WordPress Deployment and Service. It uses many of the same features like a Portworx PVC for persistent storage and a Secret for the password. But it also uses a different setting: type: NodePort. This setting exposes WordPress to traffic from outside of the cluster This deployment also uses stork as the scheduler to enable the pods to be placed closer to where their data is located.

**Deploy WordPress from the wordpress.yaml file:**

`kubectl create -f wordpress-deployment.yaml`

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
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 3
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
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
          claimName: wp-pv-claim
```

**Verify Pods and Get WordPress Service by running the following command:**

`kubectl get pods`

`kubectl get services wordpress`

#### Cleaning up {#cleaning-up}

* Deleting secret for mysql

`kubectl delete secret mysql-pass`

* Deleting wordpress

`kubectl delete -f wordpress.yaml`

`kubectl delete -f wordpress-vol.yaml`

* Deleting mysql for wordpress

`kubectl delete -f mysql.yaml`

`kubectl delete -f mysql-vol.yaml`

`Note:` Portworx PersistentVolume would allow you to recreate the Deployments and Services at this point without losing data, but hostPath loses the data as soon as the Pod stops running…

