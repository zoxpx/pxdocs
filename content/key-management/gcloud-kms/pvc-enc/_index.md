---
title: Encrypt Kubernetes PVCs with Google Cloud KMS
weight: 1
keywords: Encrypt Kubernetes PVCs, k8s, Google Cloud KMS, Key Management Service, gcloud, Volume Encryption
description: Learn how you can encrypt Kubernetes PVCs with Google Cloud KMS
noicon: true
series: gcloud-secret-uses
series2: k8s-pvc-enc
hidden: true
---

You can use one of the following methods to encrypt Kubernetes PVCs with Google Cloud KMS, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption.
Portworx generates a unique 128-bit passphrase and uses this key to encrypt and decrypt your volumes.

{{<info>}}
**NOTE:** If you want to generate your passphrases, refer to the [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets) section.
{{</info>}}

{{% content "shared/pvc-enc-per-volume.md" %}}

## Encrypt volumes using named secrets

Use a named secret to specify the secret Portworx uses to encrypt and decrypt your volumes. For details about how you can create a named secret, see the [Google Cloud KMS](/key-management/gcloud-kms) page.

1. List your named secrets by running the following command:

    ```text
    pxctl secrets gcloud list-secrets
    ```

2. Generate a new secret and associate it with a **unique name**. Enter the following `pxctl secrets gcloud create-secret` command specifying the following:
  * The `--secret_id` flag with the name of your secret, which must be unique (this example uses `my-unique-secret`):
  * The `--passphrase` flag with your secret passphrase (this example uses `mysecretpassphrase`)


    ```text
    pxctl secrets gcloud create-secret --secret_id my-unique-secret --passphrase mysecretpassphrase
    ```

{{<info>}}
**NOTE:** that Portworx uses Google Cloud KMS to encrypt your passphrase and stores it in its internal metadata store.
{{</info>}}
    To encrypt and decrypt volumes using this passphrase, you must specify the secret ID when you create or attach volumes.

3. Create a `StorageClass`, specifying the following fields and values:
  * **metadata.name** with the name of your `StorageClass` (this example uses `px-secure-sc`)
  * **secure:** with the `true` value
  * **repl:** with the desired number of replicas (this example creates 3 replicas)

    ```text
    cat <<EOF | kubectl apply -f -
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: px-secure-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      secure: "true"
      repl: "3"
    EOF
    ```

    With Portworx, you can create two types of encrypted volumes:

    * **Encrypted Volumes**. You can access a regular encrypted volume from a single node.
    * **Encrypted Shared Volumes**. You can access an encrypted shared volume from multiple nodes.

    To create an **encrypted shared volume**, you must specify the `shared: "true"` flag in the `parameters` section of your storage class:

    Example:

    ```text
    parameters:
      secure: "true"
      repl: "3"
      shared: "true"
    ```

4. Create a PVC, specifying the following fields and values:
  * **metadata.name** with the name of your PVC (this example uses `mysql-data`)
  * **metadata.annotations.px/secret-name** with the name of your secret (this example uses `my-unique-secret`). This annotation specifies that Portworx must use the secret called `my-unique-secret` to encrypt the volume. Thus, Portworx will **NOT**  create a new passphrase for this volume, and it will **NOT** use per volume encryption. If the annotation is not provided, then Portworx uses the per volume encryption workflow. See the [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets) section for details.
  * **metadata.annotations.volume.beta.kubernetes.io/storage-class** with the name of the `StorageClass` you created in the previous step (this example uses `px-secure-sc`).
  * **spec.storageClassName** with the name of the `StorageClass` you created in the previous step (this example uses `px-secure-sc`)

    ```text
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: mysql-data
      annotations:
        px/secret-name: my-unique-secret
        volume.beta.kubernetes.io/storage-class: px-secure-sc
    spec:
      storageClassName: px-secure-sc
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi

    ```


    {{<info>}}
**NOTE:** You can use the same named secret to encrypt multiple volumes.
    {{</info>}}


    If you want to migrate encrypted volumes created through this method between two different Portworx clusters, then you must:

    1. Create a secret with the same name. You can use the `--secret-id` flag to specify the name of your secret, as shown in step 1.
    2. Make sure you provide the same **passphrase** while generating the secret.


## Encrypt volumes using a cluster-wide secret

{{% content "shared/pvc-enc-cluster-wide.md" %}}
