---
title: Run Hyper Converged
weight: 2
---

### Hyper-convergence {#hyper-convergence}

When a pod runs on the same host as its volume, it is known as convergence or hyper-convergence. Because this configuration reduces the network overhead of an application, performance is typically better.

### Using scheduler convergence {#using-scheduler-convergence}

The recommended method to run your pods hyperconverged is to use [STORK](https://docs.portworx.com/scheduler/kubernetes/stork.html).

Once you have installed STORK, all you need to do is add `schedulerName: stork` in your application specs. STORK will then ensure that the nodes with data for a volume get prioritized when pods are being scheduled.

For example, this is how you would specify the scheduler name in a MySQL deployment:

```text
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
      schedulerName: stork
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

