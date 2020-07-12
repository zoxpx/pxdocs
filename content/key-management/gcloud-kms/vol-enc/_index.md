---
title: (Other Schedulers) Encrypt Portworx volumes using Google Cloud KMS
weight: 2
keywords: Encrypt volumes, other scheduleres, non-kubernetes, Google Cloud KMS, Key Management Service, gcloud, Volume Encryption
description: Instructions on using Google Cloud KMS with Portworx for encrypting Portworx Volumes
noicon: true
series: gcloud-secret-uses
hidden: true
---

You can use one of the following methods to encrypt Portworx volumes with Google Cloud KMS, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different 128-bit key. As a result, each volume uses its unique passphrase for encryption.

1. Create a volume. Enter the `pxctl volume create` command specifying the `--secure` flag with the name of your encrypted volume (this example uses `enc_vol`):

    ```text
    pxctl volume create --secure  enc_vol
    ```

<!-- We should also add the commands that attach and mount a volume. I'm not sure if the user should pass `--secret_id` argument. -->

**Docker users:**

1. Use the following command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secure=true,name=enc_vol
    ```

2. To attach and mount an encrypted volume, enter the following command:

    ```text
    docker run --rm -it -v secure=true,name=enc_vol:/mnt busybox
    ```

## Encrypt volumes using a cluster-wide secret

Set the default cluster-wide secret, and specify the secret name as `default`. Portworx will use the cluster-wide secret as a passphrase to encrypt your volume.

1. Set the cluster-wide secret key. Enter the following `pxctl secrets set-cluster-key` command, specifying the `--secret` parameter with your secret passphrase (this example uses `mysecretpassphrase`):

    ```text
    pxctl secrets set-cluster-key --secret mysecretpassphrase
    ```

    ```output
    Successfully set cluster secret key!
    ```
    {{<info>}}
**WARNING:** You must set the cluster-wide secret only once. If you overwrite the cluster-wide secret, the volumes encrypted with the old secret will become unusable.
    {{</info>}}

    If you've specified your cluster-wide secret key in the `config.json` file, the `pxctl secrets set-cluster-key` command will overwrite it. Even if you restart your cluster, Powrtworx will use the key you passed as an argument to the `pxctl secrets set-cluster-key` command.


2. Create a new encrypted volume. Enter the `pxctl volume create` command, specifying the following arguments:
    * `--secure`
    * `--secret-key` with the `default` value
    * The name of the encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure --secret_key default enc_vol
    ```

    **Docker users:**
    You can use the following command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secret_key=default,name=enc_vol
    ```

3. You can use the `pxctl volume list` command to list your volumes:

    ```text
    pxctl volume list
    ```

    ```output
    ID                      NAME        SIZE    HA SHARED   ENCRYPTED   IO_PRIORITY SCALE   STATUS
    822124500500459627   enc_vol   10 GiB  1    no yes     LOW     1   up - detached
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
    docker run --rm -it -v secure=true,secret_key=default,name=enc_vol:/mnt busybox
    ```


If you want to migrate encrypted volumes created through this method between two different Portworx clusters, then you must:

  1. Create a secret with the same name. You can use the `--secret-id` flag to specify the name of your secret, as shown in step 1.
  2. Make sure you provide the same **passphrase** while generating the secret.


## Encrypt volumes using named secrets

Use a named secret to specify the secret Portworx uses to encrypt and decrypt your volumes.

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

    Note that Portworx uses Google Cloud KMS to encrypt your passphrase, and stores it in its internal metadata store.
    To encrypt and decrypt volumes using this passphrase, you must specify the secret ID when you create or attach volumes.

3. Create a new encrypted volume. Enter the `pxctl volume create` command, specifying the following arguments:
  * `--secure`
  * `--secret-key` with the name of your named secret (this example uses `my-unique-secret`)
  * the name of the encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure --secret_key my-unique-secret enc_vol
    ```

    **Docker users:**: Use the following command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secret_key=my-unique-secret,name=enc_vol
    ```

4. You can use the `pxctl volume list` command to list your volumes:

    ```text
    pxctl volume list
    ```

    ```output
    ID                      NAME        SIZE    HA SHARED   ENCRYPTED   IO_PRIORITY SCALE   STATUS
    822124500500459627   enc_volume   10 GiB  1    no yes     LOW     1   up - detached
    ```

5. Attach your volume by entering the `pxctl host attach` command with the following arguments:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The `--secret-key` flag with the `default` value


    ```text
    pxctl host attach enc_vol --secret_key default
    ```

    ```output
    Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
    ```

6. Mount the volume by entering the `pxctl host mount` command with the following parameters:

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


If you want to migrate encrypted volumes created through this method between two different Portworx clusters, then you must:

1. Create a secret with the same name. You can use the `--secret-id` flag to specify the name of your secret, as shown in step 1.
2. Make sure you provide the same **passphrase** while generating the secret.

