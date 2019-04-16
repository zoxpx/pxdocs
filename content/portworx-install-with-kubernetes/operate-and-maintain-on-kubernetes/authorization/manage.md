---
title: PVCs and Stork with Authorization
description: Manage PVC and Stork requests with authorization
keywords: pvc, stork, portworx, kubernetes, security, authorization, jwt, shared secret
weight: 200
series: k8s-op-maintain-auth
---

## Creating volumes
Portwox authorization provides a method of protection for creating volumes
through Kubernetes. Users must provide a token when requesting volumes. These
tokens must be saved in a Secret, normally in the same namespace as the PVC.

The key in the Secret which holds the token must be named `auth-token`.

Then the annotations of the PVC can be used to point to the secret holding the
token. The following table shows the annotation keys used to point to the
secret:

| Name | Description |
| ---- | ----------- |
| `openstorage.io/auth-secret-name` | Name of the secret which has the token |
| `openstorage.io/auth-secret-namespace` | Optional key which contains the namespace of the secret reference by `auth-secret-name`. If omitted, the namespace of the PVC will be used as default |

Here is an example:

* Create a secret with the token:

```text
kubectl create secret generic px-secret \
  -n default --from-literal=auth-token=ey..hs
```

* Create a PVC request for a 2Gi volume with the appropriate authorization:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-auth
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc
    openstorage.io/auth-secret-name: px-secret
    openstorage.io/auth-secret-namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

## Stork
When using CRDs consumed by Stork, you must use the same authorization model
described above for the PVCs. Here is an example:

```text
apiVersion: volumesnapshot.external-storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mysql-snap1
  annotations:
    openstorage.io/auth-secret-name: px-secret
    openstorage.io/auth-secret-namespace: default
spec:
  persistentVolumeClaimName: mysql-data
```

## Reference

For more information on Kubernetes Secret which holds the environment variables See [Kubernetes
Secrets](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data)
