---
title: Example application
keywords: example, mysql, pvc
hidden: true
---

# Example PVC and Application

1. Create and apply the following `pvc.yaml` file:

    ```
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: mysql-data
      annotations:
        volume.beta.kubernetes.io/storage-class: px-storage
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi
    ```

2. Create and apply the following `mysql.yaml` file:

    ```
    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
      name: mysql
    spec:
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 1
        type: RollingUpdate
      replicas: 1
      template:
        metadata:
          labels:
            app: mysql
            version: "1"
        spec:
          containers:
          - image: mysql:5.6
            name: mysql
            env:
            - name: MYSQL_ROOT_PASSWORD
              value: password
            ports:
            - containerPort: 3306
            volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
          volumes:
          - name: mysql-persistent-storage
            persistentVolumeClaim:
              claimName: mysql-data
    ```
