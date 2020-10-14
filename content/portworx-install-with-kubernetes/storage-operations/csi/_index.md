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

## Supported features

The following table shows the core features supported by CSI and which minimum versions of Portworx and Kubernetes they require.

| Feature | Portworx version | Supported Kubernetes version | Alpha Kubernetes version |
| --- | --- | --- | --- |
| [Provision, attach, and mount volumes](/portworx-install-with-kubernetes/storage-operations/csi/#create-and-use-persistent-volumes) | 2.2 | 1.13.12 |  |
| [CSI Snapshots](/portworx-install-with-kubernetes/storage-operations/csi/#take-snapshots-of-csi-enabled-volumes) | 2.2 | 1.17 | 1.13.12 |
| Stork [^1] | 2.2 | 1.13 |  |
| Volume Expansion (resizing) | 2.2 | 1.16 | 1.14 |
| [Ephemeral Inline Volumes](/portworx-install-with-kubernetes/storage-operations/csi/#ephemeral-inline-volumes-with-csi) | 2.5 | 1.16 | 1.15 |

Portworx, Inc. does not recommend that you use alpha Kubernetes features in production as the API and core functionality are not finalized. Users that adopt alpha features in production may need to perform costly manual upgrades.

[^1]: Note that only Stork 2.3.0 or later is supported with CSI.

## Prerequisites

Before you install and use Portworx with CSI, ensure you meet the prerequisistes:

* Openshift users must use Openshift 4.1 or higher
* Kubernetes users must use 1.13 or higher

## Install

Enable CSI during Portworx installation. You can do this in one of two ways:

* If you're generating specs using the Portworx Kubernetes spec generator, generate the Portworx specs with the Portworx spec generator in [PX-Central](https://central.portworx.com) appropriate for your cluster. In the **Customize** tab, under **Advanced Settings**, select **CSI**. This will add the CSI components to the Portworx DaemonSet.

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
apiVersion: storage.k8s.io/v1
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
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
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

This example secures a storage class by specifying hardcoded values for the token and namespace. Users who create PVCs based on this StorageClass will always have their PVCs use the `px-user-token` StorageClass under the `portworx` namespace.

1. Find or create your token secret:

    For operator installs, a user token is automatically created and refreshed under `px-user-token` in your `StorageCluster` namespace.
    ```text
    USER_TOKEN=$(kubectl get secrets px-user-token -n portworx -o json | jq -r '.data["auth-token"]' | base64 -d)
    ```

    For all other configurations, [create your own token secret](/cloud-references/security/kubernetes/shared-secret-model/generating-tokens/):
    ```text
    kubectl create secret generic px-user-token \
      -n portworx --from-literal=auth-token=$USER_TOKEN
    ```

2. Modify the storageClass, adding the following parameters:

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: portworx-csi-sc
    provisioner: pxd.portworx.com
    parameters:
      repl: "1"
      csi.storage.k8s.io/provisioner-secret-name: px-user-token
      csi.storage.k8s.io/provisioner-secret-namespace: portworx
      csi.storage.k8s.io/node-publish-secret-name: px-user-token
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
    apiVersion: storage.k8s.io/v1
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
    kubectl create secret generic px-mysql-pvc -n portworx --from-literal=auth-token=$USER_TOKEN
    ```

<!--

### Mixing hardcoded and template values


You can mix hardcoded and template values in your StorageClass.

Hardcode the secret name, but use template values for the namespace to allow users to create PVCs on any namespace using your hardcoded secret.

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
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
apiVersion: storage.k8s.io/v1
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

For Kubernetes 1.17+, CSI Snapshotting is in beta is supported by the Portworx CSI Driver.

Given you already have a [CSI PVC and StorageClass](/portworx-install-with-kubernetes/storage-operations/csi/#create-and-use-persistent-volumes), complete the following steps to create and restore a CSI VolumeSnapshot.

1. Create a VolumeSnapshotClass, specifying the following: 
    * The `snapshot.storage.kubernetes.io/is-default-class: "true"` annotation
    * The `csi.storage.k8s.io/snapshotter-secret-name` parameter with your encryption and/or authorization secret
    * The `csi.storage.k8s.io/snapshotter-secret-namespace` parameter with the namespace your secret is in

      ```text
      apiVersion: snapshot.storage.k8s.io/v1beta1
      kind: VolumeSnapshotClass
      metadata:
        name: px-csi-snapclass
        annotations:
          snapshot.storage.kubernetes.io/is-default-class: "true"
      driver: pxd.portworx.com
      deletionPolicy: Delete
      parameters:
        csi.storage.k8s.io/snapshotter-secret-name: px-user-token
        csi.storage.k8s.io/snapshotter-secret-namespace: portworx
      ```

2. Create a VolumeSnapshot:

      ```text  
      apiVersion: snapshot.storage.k8s.io/v1beta1
      kind: VolumeSnapshot
      metadata:
        name: px-csi-snapshot
      spec:
        volumeSnapshotClassName: px-csi-snapclass
        source:
          persistentVolumeClaimName: px-mysql-pvc
      ```

3. Restore from a VolumeSnapshot:

      ```text
      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: px-csi-pvc-restored 
      spec:
        storageClassName: portworx-csi-sc
        dataSource:
          name: px-csi-snapshot
          kind: VolumeSnapshot
          apiGroup: snapshot.storage.k8s.io
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
      ```


See the [Kubernetes-CSI snapshotting documentation](https://kubernetes-csi.github.io/docs/snapshot-restore-feature.html) for more examples and documentation. 

### Snapshotting alpha

CSI volume snapshotting is alpha from Kubernetes 1.12 until 1.16. In order to take snapshots of CSI-enabled volumes for these versions, you must enable the `VolumeSnapshotDataSource` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/):

  ```text
  --feature-gates=VolumeSnapshotDataSource=true
  ```

In addition, you must use a [1.x release of the external snapshotter](https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v1.2.2) that will create and understand the nessesary alpha APIs. 

{{<info>}}
**WARNING:** Portworx, Inc. recommends that you do __NOT__ use CSI alpha, as there are significant API and reliability changes introduced in the Kubernetes 1.17 with snapshotting beta. Migrating any alpha CSI snapshotting objects to beta will require significant extra work. 
{{</info>}}

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

## Clone volumes with CSI

You can clone CSI-enabled volumes, duplicating both the volume and content within it.

1. Enable the `VolumePVCDataSource` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/):

      ```text
      --feature-gates=VolumePVCDataSource=true
      ```

2. Create a PVC that references the PVC you wish to clone, specifying the `dataSource` with the kind and name of the target PVC you wish to clone. The following spec creates a clone of the `px-mysql-pvc` PVC in a YAML file named `clonePVC.yaml`:

      ```text
      kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
         name: clone-of-px-mysql-pvc
      spec:
         storageClassName: portworx-csi-sc
         accessModes:
           - ReadWriteOnce
         resources:
           requests:
             storage: 2Gi
         dataSource:
          kind: PersistentVolumeClaim
          name: px-mysql-pvc
      ```

3. Apply the `clonePVC.yaml` spec to create the clone:

      ```text
      kubectl apply -f clonePVC.yaml
      ```

## Ephemeral Inline Volumes with CSI
You can create ephemeral inline volumes with CSI. These volumes are created during pod creation and deleted upon pod teardown.

1. Create a pod spec that uses the Portworx CSI driver, declaring the inline volume as seen below in a YAML file named `ephemeral-volume-pod.yaml`

      ```text
      kind: Pod
      apiVersion: v1
      metadata:
        name: csi-inline-volume-app
      spec:
        containers:
          - name: my-frontend
            image: busybox
            volumeMounts:
            - mountPath: "/data"
              name: my-csi-volume
            command: [ "sleep", "1000000" ]
        volumes:
          - name: my-csi-volume
            csi:
              driver: pxd.portworx.com
              volumeAttributes:
                size: "2Gi"
      ```

2. Apply the `ephemeral-volume-pod.yaml`  spec to create the pod with an ephemeral inline volume:

      ```text
      kubectl apply -f ephemeral-volume-pod.yaml
      ```

You may also use ephemeral inline volumes with deployments and other application types. See this [Kubernetes blog](https://kubernetes.io/blog/2020/01/21/csi-ephemeral-inline-volumes/) for more information and example use cases.

## Migration to CSI PVCs

Currently, you cannot migrate or convert PVCs created using the native Kubernetes driver to the CSI driver. However, this is not required and both types of PVCs can co-exist on the same cluster.

## Contribute

Portworx, Inc. welcomes contributions to its CSI implementation, which is open-source and repository is at [OpenStorage](https://github.com/libopenstorage/openstorage).
