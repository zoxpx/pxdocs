---
title: "Step 4: StorageClass Setup"
keywords: storageclass, csi, security, authorization
weight: 40
series: ra-shared-secrets-model
---

# StorageClass for non-CSI

In the previous section, you saved the Kubernetes token in a secret called
`px-k8s-user` in the `portworx` namespace. Now you can create a storage class
which points Portworx to authenticate the request using the token in the
that secret.

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: px-storage-repl-1
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  openstorage.io/auth-secret-name: px-k8s-user
  openstorage.io/auth-secret-namespace: portworx
allowVolumeExpansion: true
```

As you can see above, Portworx validates requests to manage volumes using the token saved in the secret referenced by the storage class.
As you create more storage classes, remember to reference the secret with the
token to authenticate the requests.

# StorageClass for CSI

When using CSI, the storage class references the secret for the three types
of supported operations: _provision_, _node-publish_ (mount/unmount), and
_controller-expand_.

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
