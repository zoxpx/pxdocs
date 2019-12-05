---
title: StorageClass Setup
description: A reference architecture to support Multitenancy with Portworx and CSI
keywords: portworx, security, ownership, tls, rbac, claims, jwt, oidc
weight: 40
series: ra-shared-secrets-model
---

# StorageClass for non-CSI

Create a storage class to use secret:

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: px-storage
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  openstorage.io/auth-secret-name: px-k8s-user
  openstorage.io/auth-secret-namespace: portworx
allowVolumeExpansion: true
```

# StorageClass for CSI

Create a storage class to use secret. The following is a CSI based storage class:

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: px-storage
provisioner: pxd.portworx.com
parameters:
  repl: "1"
  csi.storage.k8s.io/provisioner-secret-name: px-k8s-user
  csi.storage.k8s.io/provisioner-secret-namespace: portworx
  csi.storage.k8s.io/node-publish-secret-name: px-k8s-user
  csi.storage.k8s.io/node-publish-secret-namespace: portworx
  csi.storage.k8s.io/controller-expand-secret-name: px-k8s-user
  csi.storage.k8s.io/controller-expand-secret-namespace: portworx
allowVolumeExpansion: true
```
