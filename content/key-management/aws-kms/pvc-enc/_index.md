---
title: Encrypt Kubernetes PVCs with AWS KMS
weight: 1
keywords: encryption, Kubernetes PVCs, k8s, AWS KMS, Amazon Web Services, Key Management Service
description: Learn how you can encrypt Kubernetes PVCs with AWS KMS
noicon: true
series: aws-secret-uses
series2: k8s-pvc-enc
hidden: true
---

You can use one of the following methods to encrypt Kubernetes PVCs with AWS KMS, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption.
Portworx relies on the AWS KMS APIs to generate a Data Encryption key.

<!-- Is this something specific to AWS KMS? -->
If you want to create a cloud backup of an encrypted volume or migrate encrypted volumes between multiple clusters, Portworx, Inc. recommends you use per volume secrets to encrypt your volumes.

{{<info>}}
**NOTE:** If you want to generate your passphrases, refer to the [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets) section.
{{</info>}}

{{% content "shared/pvc-enc-per-volume.md" %}}

## Encrypt volumes using named secrets

Use a named secret to specify the secret Portworx uses to encrypt and decrypt your volumes.

<!-- Is this something specific to AWS KMS? -->
{{<info>}}
**NOTE:** You can not use named secrets to create a cloud backup of an encrypted volume or to migrate encrypted volumes between two different Portworx clusters.
{{</info>}}

1. List your named secrets by running the following command:

    ```text
    pxctl secrets aws list-secrets
    ```

2. Generate a new AWS KMS data key and associate it with a **unique name**. Enter the following `pxctl secrets aws generate-kms-data-key` command specifying the `--secret_id` flag with the name of the data key, which must be unique (this example uses `my-unique-secret`):

    ```text
    pxctl secrets aws generate-kms-data-key --secret_id my-unique-secret
    ```
    {{<info>}}
**NOTE:** To encrypt and decrypt a volume using this data key, you must specify the secret ID when you create or attach your volume.
    {{</info>}}

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

Set the default cluster-wide secret, and use it to encrypt your volumes.

{{<info>}}
**NOTE:** You can not use cluster-wide secrets to create a cloud backup of an encrypted volume or to migrate encrypted volumes between two different Portworx clusters.
{{</info>}}

Starting with version 2.1, cluster-wide secrets have been deprecated. However, any volume encrypted with a cluster-wide secret can still be used in newer versions of Portworx.

<!-- Is this deprecation something specific to AWS-KMS? -->

<!-- Do we really want to specify the following steps? -->
You can use the following procedure to create new encrypted volumes using your existing cluster-wide secret:

1. Generate a new KMS data key.
2. Enter the `pxctl secrets set-cluster-key` command, specifying the name of your new KMS data key (this example uses `portworx_secret`):

    ```text
    pxctl secrets set-cluster-key portworx_secret
    ```

3. Create a new volume by following the steps in the [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets) section.


{{<info>}}
**NOTE:** If you do not provide a secret key, Portworx will create new volumes using per volume encryption.
{{</info>}}
