---
title: (Other Schedulers) Encrypt Portworx Volumes using AWS KMS
weight: 2
keywords: encryption, other schedulers, non-kubernetes, AWS KMS, Amazon Web Services, Key Management Service
description: Instructions on using AWS KMS with Portworx for encrypting Portworx Volumes
noicon: true
series: aws-secret-uses
hidden: true
---

You can use one of the following methods to encrypt Portworx volumes with AWS KMS, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption.
Portworx relies on the AWS KMS APIs to generate a Data Encryption key.

1. Create a volume. Enter the `pxctl volume create` command specifying the `--secure` flag with the name of your encrypted volume (this example uses `enc_vol`):

    ```text
    pxctl volume create --secure  enc_vol
    ```

<!-- We should also add the commands that attach and mount a volume. I'm not sure if the user should pass `--secret_id` argument. -->

**Docker users:**

1. Enter the following command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secure=true,name=enc_vol
    ```

2. Enter the following command to attach and mount an encrypted volume:

    ```text
    docker run --rm -it -v secure=true,name=enc_vol:/mnt busybox
    ```


## Encrypt volumes using named secrets

You can use a named secret to specify the secret Portworx uses to encrypt and decrypt your volumes.

{{<info>}}
**NOTE:** You can not use named secrets to create a cloud backup of an encrypted volume or to migrate encrypted volumes between two different Portworx clusters.
{{</info>}}

1. List your named secrets by running the following command:

    ```text
    pxctl secrets aws list-secrets
    ```

2. Generate a new AWS KMS data key and associate it with a **unique name**. Enter the following `pxctl secrets aws generate-kms-data-key` command, specifying the `--secret_id` flag with the name of the data key, which must be unique. This example uses `my-unique-secret`:

    ```text
    pxctl secrets aws generate-kms-data-key --secret_id my-unique-secret
    ```

3. Create a new encrypted volume. Enter the `pxctl volume create` command, specifying the following arguments:
    * `--secure`
    * `--secret-key` with the name of your named secret (this example uses `my-unique-secret`)
    * The name of the encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure --secret_key my-unique-secret enc_vol
    ```

    **Docker users:**
    Use the following command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secret_key=my-unique-secret,name=enc_vol
    ```

4. Attach your volume by entering the `pxctl host attach` command with the following arguments:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The `--secret-key` flag with the `default` vaule


    ```text
    pxctl host attach enc_vol --secret_key default
    ```

    ```output
    Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
    ```

5. Mount the volume by entering the `pxctl host mount` command with the following parameters:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The mount point (this example uses `mnt`)

    ```text
    pxctl host mount enc_vol /mnt
    ```

    ```output
    Volume enc_vol successfully mounted at /mnt
    ```

    **Docker users:**
    To attach and mount an encrypted volume, enter the following command:

    ```text
    docker run --rm -it -v secure=true,secret_key=my-unique-secret,name=enc_vol:/mnt busybox
    ```



## Encrypt volumes using a cluster-wide secret

Set the default cluster-wide secret, and use it to encrypt your volumes.

Starting with version 2.1, cluster-wide secrets have been deprecated. However, any volume encrypted with a cluster-wide secret can still be used in newer versions of Portworx.

<!-- Is this deprecation something specific to AWS-KMS? -->

<!-- Do we really want to specify the following steps? -->
You can use the following procedure to create new encrypted volumes using your existing cluster-wide secret:

1. Generate a new AWS KMS data key and associate it with a unique name. Enter the following `pxctl secrets aws generate-kms-data-key` command, specifying the `--secret_id` flag with the name of the data key, which must be unique (this example uses `my-unique-secret`):

    ```text
    pxctl secrets aws generate-kms-data-key --secret_id my-unique-secret
    ```
2. Enter the `pxctl secrets set-cluster-key` command, specifying the name of your new KMS data key (this example uses `my-unique-secret`):

    ```text
    pxctl secrets set-cluster-key my-unique-secret
    ```

3. Create a new volume by following the steps in the [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets) section.

{{<info>}}
**NOTE:** You can not use a cluster-wide secret to create a cloud backup of an encrypted volume or to migrate encrypted volumes between two different Portworx clusters.
{{</info>}}
