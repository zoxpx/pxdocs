---
title: Example Application
description: A reference architecture to support Multitenancy with Portworx and CSI
keywords: portworx, security, ownership, tls, rbac, claims, jwt, oidc
weight: 50
series: ra-shared-secrets-model
---


# PVC

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

# Application: MySQL

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
