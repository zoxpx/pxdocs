---
title: Harbor with Portworx on Kubernetes
linkTitle: Harbor
keywords: portworx, container, Kubernetes, harbor, storage, Docker, k8s, pvc
description: See how Harbor can be deployed on Kubernetes using Portworx volumes.
weight: 2
noicon: true
---


This reference architecture document shows how you can deploy [Harbor](https://goharbor.io/), an open-source container image registry, and its dependencies with Portworx on Kubernetes. Under this architecture, Portworx provides reliable and persistent storage to ensure Harbor runs with HA.

## Create a StorageClass

All of the components will use a `StorageClass` with 3 replicas, so create and apply the following spec:

```text
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: portworx-sc-repl3
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  priority_io: "high"
EOF
```

For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section.

{{<info>}}
**NOTE:** If you're using Portworx with CSI, you must set the value of the `provisioner` parameter to `pxd.portworx.com`.
{{</info>}}

## Setup Harbor

### Prequisites

* By default, the instructions in this document deploy everything in the `harbor` namespace, but you can change this by specifying your own namespace:

    ```text
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: harbor
    EOF
    ```

* Harbor is deployed using [Helm](https://helm.sh/), so it will need to be installed and have permissions on the `harbor` namespace. You can find instructions [here](https://v2.helm.sh/docs/using_helm/#role-based-access-control).

### Deploy dependencies

Harbor requires a PostgreSQL and Redis database.

1. Apply the following spec to deploy PostgreSQL, making sure to change the password and username to your preferred values:

    ```text
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: postgres-pvc
      namespace: harbor
      annotations:
        volume.beta.kubernetes.io/storage-class: portworx-sc-repl3
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: postgres
      namespace: harbor
      labels:
        app: postgres
    spec:
      ports:
        - port: 5432
      selector:
        app: postgres
      clusterIP: None
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: postgres
      namespace: harbor
      labels:
        app: postgres
    spec:
      strategy:
        type: Recreate
      replicas: 1
      selector:
        matchLabels:
          app: postgres
      template:
        metadata:
          labels:
            app: postgres
        spec:
          schedulerName: stork
          containers:
          - name: postgres
            image: postgres:9.5
            ports:
            - containerPort: 5432
              name: postgres
            env:
            - name: POSTGRES_USER
              value: postgres
            - name: POSTGRES_PASSWORD
              value: password
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
            volumeMounts:
            - name: postgres-persistent-storage
              mountPath: /var/lib/postgresql/data
          volumes:
          - name: postgres-persistent-storage
            persistentVolumeClaim:
              claimName: postgres-pvc
    EOF
    ```

2. Apply the following spec to deploy Redis:

    ```text
    kubectl apply -f - <<EOF
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: redis-pvc
      namespace: harbor
      annotations:
        volume.beta.kubernetes.io/storage-class: portworx-sc-repl3
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: redis
      namespace: harbor
    spec:
      ports:
        - port: 6379
          name: redis
      clusterIP: None
      selector:
        app: redis
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: redis
      namespace: harbor
      labels:
        app: redis
    spec:
      selector:
        matchLabels:
          app: redis
      template:
        metadata:
          labels:
            app: redis
        spec:
          schedulerName: stork
          containers:
          - name: redis
            image: redis:3.2-alpine
            imagePullPolicy: Always
            args: ["--requirepass", "password"]
            ports:
              - containerPort: 6379
                name: redis
            volumeMounts:
              - name: redis-vol
                mountPath: /data
          volumes:
          - name: redis-vol
            persistentVolumeClaim:
              claimName: redis-pvc
    EOF
    ```

3. Enter the following command to create the four PostgreSQL databases Harbor requires:

    ```text
    DB_POD=$(kubectl get pods -n harbor -l app=postgres | awk '/postgres/{print$1}')
    kubectl exec $DB_POD -n harbor -- createdb -Upostgres registry
    kubectl exec $DB_POD -n harbor -- createdb -Upostgres clair
    kubectl exec $DB_POD -n harbor -- createdb -Upostgres notary_server
    kubectl exec $DB_POD -n harbor -- createdb -Upostgres notary_signer
    ```

### Deploy Harbor

Enter the following commands to add the Harbor repository and deploy Harbor. Replace `myharbor` with a name of your choosing:

```text
helm repo add harbor https://helm.goharbor.io
NAMESPACE=harbor
helm install harbor/harbor \
  --set redis.type=external \
  --set redis.external.host=redis.$NAMESPACE \
  --set redis.external.password=password \
  --set database.type=external \
  --set database.external.host=postgres.$NAMESPACE \
  --set database.external.username=postgres \
  --set database.external.password=password \
  --set persistence.persistentVolumeClaim.registry.storageClass=portworx-sc-repl3 \
  --set persistence.persistentVolumeClaim.chartmuseum.storageClass=portworx-sc-repl3 \
  --set persistence.persistentVolumeClaim.jobservice.storageClass=portworx-sc-repl3 \
  --namespace $NAMESPACE --name myharbor
```

## Clean up Harbor

To clean up the environment created above, run the following:

```text
helm delete --purge myharbor
kubectl delete -n harbor \
  deploy/redis \
  svc/redis \
  pvc/redis-pvc \
  deploy/postgres \
  svc/postgres \
  pvc/postgres-pvc \
  pvc/myharbor-harbor-chartmuseum \
  pvc/myharbor-harbor-jobservice \
  pvc/myharbor-harbor-registry
kubectl delete sc/portworx-sc-repl3
```

## Configuring snapshots

Scheduled snapshots can be configured. PostgreSQL does not require any special Pre or Post rules to be added; Redis is only used for cache and temporary storage, so it does not need a Pre rule to ensure it is flushed to disk. See the [Create and use snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/) page for more details about snapsots.
