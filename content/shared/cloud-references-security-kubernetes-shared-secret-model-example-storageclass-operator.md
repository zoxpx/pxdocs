---
hidden: true
---

# StorageClass for non-CSI

In the previous section, you created a `StorageCluster` in the kube-system namespace with security enabled.
As a result, the operator has created the secret `px-user-token` in the `kube-system` namespace. Now you can create a storage class which points Portworx to authenticate the request using the token in that secret.

Portworx validates requests to manage volumes using the token saved in the secret referenced by the storage class. As you create more 
storage classes, remember to reference the secret with the token to authenticate the requests. 
The example below demonstrates a storage class with token secrets added:

1. Create the following `storageclass.yaml` file:

    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: px-storage
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "1"
      openstorage.io/auth-secret-name: px-user-token
      openstorage.io/auth-secret-namespace: kube-system
    allowVolumeExpansion: true
    ```

2. Apply the `storageclass.yaml` file:

    ```
    kubectl apply -f storageclass.yaml
    ```


# StorageClass for CSI

When using CSI, the storage class references the secret for the three types
of supported operations: _provision_, _node-publish_ (mount/unmount), and
_controller-expand_.

1. Create the following `storageclass.yaml` file:

    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: px-storage
    provisioner: pxd.portworx.com
    parameters:
      repl: "1"
      csi.storage.k8s.io/provisioner-secret-name: px-user-token
      csi.storage.k8s.io/provisioner-secret-namespace: kube-system
      csi.storage.k8s.io/node-publish-secret-name: px-user-token
      csi.storage.k8s.io/node-publish-secret-namespace: kube-system
      csi.storage.k8s.io/controller-expand-secret-name: px-user-token
      csi.storage.k8s.io/controller-expand-secret-namespace: kube-system
    allowVolumeExpansion: true
    ```

2. Apply the `storageclass.yaml` file:

    ```
    kubectl apply -f storageclass.yaml
    ```
