---
title: PVCs and Stork with Authorization
description: Manage PVC and Stork requests with authorization
keywords: authorization, security, kubernetes, k8s
weight: 200
series: k8s-op-maintain-auth
---

## Creating volumes
Portwox authorization provides a method of protection for creating volumes
through Kubernetes. PVCs must refer to a StorageClass which point to the
Kubernetes Secret containing the token for the user.

For more information, refer to the [Securing your Portworx system](/cloud-references/security/) article of the Portworx documentation.

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
