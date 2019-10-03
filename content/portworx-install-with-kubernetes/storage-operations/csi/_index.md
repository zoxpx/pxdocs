---
title: Portworx with CSI
keywords: csi, portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk
description: This page describes how to deploy Portworx with CSI
---

[CSI](https://kubernetes-csi.github.io/), or _Container Storage Interface_, is a model for integrating storage system service with Kubernetes and other orchestration systems. Kubernetes has supported CSI since 1.10 as beta.

With CSI, Kubernetes gives storage drivers the opportunity to release on their schedule. This allows storage vendors to upgrade, update, and enhance their drivers without the need to update Kubernetes, maintaining a consistent, dependable, orchestration system.

Using Portworx with CSI, you can perform the following operations:

* Create and use CSI-enabled persistent volumes
* Secure your CSI-enabled volumes with token authorization and encryption defined at the StorageClass or the PVC level
* Take snapshots of CSI-enabled volumes
* Create shared CSI-enabled volumes

## Prerequisites

Before you install and use Portworx with CSI, ensure you meet the prerequisistes:

* Openshift users must use Openshift 4.1 or higher
* Kubernetes users must use 1.13 or higher

## Install

Enable CSI during Portworx installation. You can do this in one of two ways:

* If you're generating specs using the Portworx Kubernetes spec generator, generate the Portworx specs with the Portworx Spec Generator in [PX-Central](https://central.portworx.com) appropriate for your cluster. In the **Customize** tab, under **Advanced Settings**, select **CSI**. This will add the CSI components to the Portworx DaemonSet.

* If you are using [cURL to fetch the Portworx spec](/portworx-install-with-kubernetes/px-k8s-spec-curl), add `csi=true` to the parameter list to include CSI specs in the generated file.

{{<info>}}**Openshift users**:
You must add the `px-csi-account` service account to the privileged security context.

```text
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-csi-account
```
{{</info>}}

## Create and use persistent volumes

To enable CSI for a StorageClass, set the `provisioner` value to `pxd.portworx.com`:

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: portworx-csi-sc
provisioner: pxd.portworx.com
parameters:
  repl: "1"
```

To create a PersistentVolumeClaim based on your CSI-enabled StorageClass, reference the StorageClass you created above with the `storageClassName` parameter:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
   name: px-mysql-pvc
spec:
   storageClassName: portworx-csi-sc
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 2Gi
```

Once you've created a storage class and PVC, you can create a volume as part of a deployment by referencing the PVC. This example creates a MySQL deployment referencing the `px-mysql-pvc` PVC you created in the step above:

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
          claimName: px-mysql-pvc
 ```

## Secure your volumes

You can secure your CSI-enabled volumes with token-based authorization. In using token-based authorization, you create secrets containing your token credentials and specify them in your StorageClass in one of two ways:

* Using hardcoded values
* Using template values

You can also mix these two methods to form your own hybrid approach.  

### Using hardcoded values

This example secures a storage class by specifying hardcoded values for the token and namespace. Users who create PVCs based on this StorageClass will always have their PVCs use the `px-secret` StorageClass under the `portworx` namespace.

1. enter the `kubectl create secret` command to create a token:

    ```text
    kubectl create secret generic px-secret -n portworx --from-literal=auth-token=$token
    ```

2. Modify the storageClass, adding the following parameters:

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1beta1
    metadata:
      name: portworx-csi-sc
    provisioner: pxd.portworx.com
    parameters:
      repl: "1"
      csi.storage.k8s.io/provisioner-secret-name: px-secret
      csi.storage.k8s.io/provisioner-secret-namespace: portworx
      csi.storage.k8s.io/node-publish-secret-name: px-secret
      csi.storage.k8s.io/node-publish-secret-namespace: portworx
    ```

### Using template values

This example secures a storage class by hardcoding the token and namespace. Users who create PVCs based on this StorageClass can have have their PVCs use the StorageClass they specified in the annotation of their PVC, and the namespace they specified in their PVC.

1. Modify the storageClass, adding the following parameters:

    * `csi.storage.k8s.io/provisioner-secret-name: ${pvc.name}`
    * `csi.storage.k8s.io/provisioner-secret-namespace: ${pvc.namespace}`
    * `csi.storage.k8s.io/node-publish-secret-name: ${pvc.name}`
    * `csi.storage.k8s.io/node-publish-secret-namespace: ${pvc.namespace}`

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1beta1
    metadata:
      name: portworx-csi-sc
    provisioner: pxd.portworx.com
    parameters:
      repl: "1"
      csi.storage.k8s.io/provisioner-secret-name: ${pvc.name}
      csi.storage.k8s.io/provisioner-secret-namespace: ${pvc.namespace}
      csi.storage.k8s.io/node-publish-secret-name: ${pvc.name}
      csi.storage.k8s.io/node-publish-secret-namespace: ${pvc.namespace}
    ```
2. Make sure your user also creates a secret in their PVC's namespace with the same name as the PVC. For example, a PVC named "px-mysql-pvc" must have an associated secret named "px-mysql-pvc". Enter the following command to create the secret:

    ```text
    kubectl create secret generic px-mysql-pvc -n portworx --from-literal=auth-token=$token
    ```

<!--

### Mixing hardcoded and template values


You can mix hardcoded and template values in your StorageClass.

Hardcode the secret name, but use template values for the namespace to allow users to create PVCs on any namespace using your hardcoded secret.

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: portworx-csi-sc
provisioner: pxd.portworx.com
parameters:
  repl: "1"
  csi.storage.k8s.io/provisioner-secret-name: px-secret
  csi.storage.k8s.io/provisioner-secret-namespace: ${pvc.namespace}
```

Hardcode the namespace but use template values for the secret to allow users to specify their own secret in the PVC, but only on the namespace you specify:

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: portworx-csi-sc
provisioner: pxd.portworx.com
parameters:
  repl: "1"
  csi.storage.k8s.io/provisioner-secret-name: ${pvc.name}
  csi.storage.k8s.io/provisioner-secret-namespace: portworx
```
-->

## Take snapshots of CSI-enabled volumes

CSI volume snapshotting is still in alpha as of Kubernetes 1.16. In order to take snapshots of CSI-enabled volumes, you must enable the `VolumeSnapshotDataSource` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/):

  ```text
  --feature-gates=VolumeSnapshotDataSource=true
  ```

### Create a VolumeSnapshotClass

Create a `VolumeSnapshotClass`, specifying the following:

* The `snapshot.storage.kubernetes.io/is-default-class: "true"` annotation
* The `csi.storage.k8s.io/snapshotter-secret-name` parameter with your encryption secret
* The `csi.storage.k8s.io/snapshotter-secret-namespace` parameter with the namespace your secret is in

```text
apiVersion: snapshot.storage.k8s.io/v1alpha1
kind: VolumeSnapshotClass
metadata:
  name: csi-hostpath-snapclass
  annotations:
    snapshot.storage.kubernetes.io/is-default-class: "true"
snapshotter: csi-hostpath
parameters:
  csi.storage.k8s.io/snapshotter-secret-name: px-secret
  csi.storage.k8s.io/snapshotter-secret-namespace: portworx
```

## Create shared CSI-enabled volumes

You can create shared CSI-enabled volumes using one of two methods:

* Using a PVC's AccessMode parameter
* Using StorageClass parameters

### PVC AccessMode

In your PVC, if you use `ReadWriteMany`, Portworx defaults to a `Sharedv4` volume type.

### StorageClass parameters

* In your SC, if you use the parameter `Shared=true` and `ReadWriteMany` in your PVC, Portworx uses the Shared volume type.
* In your SC, if you use the parameter `Sharedv4=true` and `ReadWriteMany` in your PVC, Portworx uses the Sharedv4 volume type.

## Encryption with CSI

For information about how to encrypt PVCs on CSI using Kubernetes secrets, see the [Encrypting PVCs on CSI with Kubernetes Secrets](/key-management/kubernetes-secrets/pvc-encryption-using-csi/) section of the Portworx documentation.

## Upgrade

Currently upgrades are _not_ supported. You will need to deploy using CSI onto a new Kubernetes cluster. The Kubernetes community is working very hard to make this possible in the near future.

## Contribute

Portworx welcomes contributions to our CSI implementation, which is open-source and repository is at [OpenStorage](https://github.com/libopenstorage/openstorage).
