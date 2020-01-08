---
title: "Step 4: Set up the StorageClass"
keywords: storageclass, csi, security, authorization
weight: 40
---

# StorageClass for CSI

The following CSI StorageClass enables your tenants to create volumes
using their token stored in a secret in their namespace.

When using CSI, the storage class references the secret for the three types of supported
operations:

* _provision_
* _node-publish_ (mount/unmount)
* _controller-expand_

```text
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: px-storage
provisioner: pxd.portworx.com
parameters:
  repl: "1"
  csi.storage.k8s.io/provisioner-secret-name: px-k8s-user
  csi.storage.k8s.io/provisioner-secret-namespace: ${pvc.namespace}
  csi.storage.k8s.io/node-publish-secret-name: px-k8s-user
  csi.storage.k8s.io/node-publish-secret-namespace: ${pvc.namespace}
  csi.storage.k8s.io/controller-expand-secret-name: px-k8s-user
  csi.storage.k8s.io/controller-expand-secret-namespace: ${pvc.namespace}
allowVolumeExpansion: true
```

Note the value `${pvc.namespace}`. This will ensure that the CSI controller
gets the appropriate token, which is tied to the namespace of the PVC.
