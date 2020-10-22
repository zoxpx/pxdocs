---
title: (Other Schedulers) Encrypt Portworx Volumes using Vault
weight: 2
keywords: Vault Key Management, Hashicorp, encrypt volumes
description: Instructions on using Vault with Portworx for encrypting Portworx Volumes
noicon: true
series: vault-secret-uses
hidden: true
---

You can use one of the following methods to encrypt Portworx volumes with Google Cloud KMS, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using named secrets](#encrypt-volumes-using-named-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using named secrets

<!-- This example assumes the users know how to create a named secret in Vault. I think we need an additional step here.-->

1. Create an encrypted volume by entering the `pxctl volume create` command with the following parameters:

   * `--secure`
   * `--secret_key` with the name of your named secret (this example uses `key1`)
   * the name of the encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure --secret_key key1 enc_vol
    ```

    ```output
    Encrypted volume successfully created: 374663852714325215
    ```

    With Portworx, you can create two types of encrypted volumes:

   * **Encrypted Volumes**. You can access a regular volume from a single node.
   * **Shared Encrypted Volumes**. You can access an encrypted shared volume from multiple nodes.

    To create a **shared encrypted volume**, you must specify the `--shared` parameter as follows:

    ```text
    pxctl volume create --shared --secret_key key1 --secure enc_shared_vol
    ```

    ```output
    Encrypted Shared volume successfully created: 77957787758406722
    ```

    If you are using Vault Namespaces, and your secret key `key1` resides in a namespace called `ns1` then use the following command to create
    an encrypted volume


    ```text
    pxctl volume create --secure --secret_key key1 --secret_options=vault-namespace=ns1 enc_vol
    ```

    ```output
    Encrypted volume successfully created: 374663852714325215
    ```

    **Docker users:**

    Use the following command to create an encrypted volume named `enc_vol`:

    ```text
    docker volume create --volume-driver pxd secret_key=key1,name=enc_vol
    ```

    To create an **encrypted shared** volume using a specific secret through docker, you must specify the `-shared=true` option.

    Example:

    ```text
    docker volume create --volume-driver pxd shared=true,secret_key=key1,name=enc_shared_vol
    ```

2. You can use the `pxctl volume list` command to list your volumes:

    ```text
    pxctl volume list
    ```

    ```output
    ID                      NAME        SIZE    HA SHARED   ENCRYPTED   IO_PRIORITY SCALE   STATUS
    822124500500459627   enc_volume   10 GiB  1    no yes     LOW     1   up - detached
    ```

3. Attach your volume by entering the `pxctl host attach` command with the following arguments:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The `--secret-key` flag with the `default` vaule


    ```text
    pxctl host attach enc_vol --secret_key default
    ```

    ```output
    Volume successfully attached at: /dev/mapper/pxd-enc822124500500459627
    ```

4. Mount the volume by entering the `pxctl host mount` command with the following parameters:

    * The name of your encrypted volume (this example uses `enc_vol`)
    * The mount point (this example uses `mnt`)

    ```text
    pxctl host mount enc_vol /mnt
    ```

    ```output
    Volume enc_vol successfully mounted at /mnt
    ```

    **Docker users:**

    The following example command attaches and mounts an encrypted volume:

    ```text
    docker run --rm -it -v secure=true,secret_key=key1,name=enc_vol:/mnt busybox
    ```


## Encrypt volumes using a cluster-wide secret

A cluster wide secret key is a common key that can be used to encrypt all your volumes. This common key needs to be pre-created in Vault.
Portworx will use this cluster-wide secret as a passphrase to encrypt your volume.

1. Set the cluster-wide secret key. Enter the following `pxctl secrets set-cluster-key` command specifying the `--secret` parameter with the secret name you created in Vault (this example uses `mysecret`):

    ```text
    pxctl secrets set-cluster-key --secret mysecret
    ```

    ```output
    Successfully set cluster secret key!
    ```
    {{<info>}}
**WARNING:** You must set the cluster-wide secret only once. If you overwrite the cluster-wide secret, the volumes encrypted with the old secret will become unusable.
    {{</info>}}

    
    If you are using Vault Namespaces use the following command to set the cluster-wide secret key in a specific vault namespace (this example uses `ns1` as the vault namespace)

    ```text
    pxctl secrets set-cluster-key --secret_options=vault-namespace=ns1 --secret mysecret
    ```

2. Create a new encrypted volume. Enter the `pxctl volume create` command, specifying the following arguments:
  * `--secure`
  * The size of your encrypted volume (this example use `10` GiB)
  * The name of the encrypted volume (this example uses `enc_vol`)

    ```text
    pxctl volume create --secure --size 10 enc_vol
    ```

    ```output
    Volume successfully created: 822124500500459627
    ```

    With Portworx, you can create two types of encrypted volumes:

    * **Encrypted Volumes**. You can access a regular volume from a single node.
    * **Shared Encrypted Volumes**. You can access an encrypted shared volume from multiple nodes.

    To create a **shared encrypted volume**, you must specify the `--shared` parameter as follows:

    ```text
    pxctl volume create --shared --secure --size 10 enc_vol
    ```

    ```output
    Encrypted Shared volume successfully created: 77957787758406722
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

<!--
When using cluster wide secret key, the secret key does not need to be provided in any of the commands. When no secret key is provided in the pxctl volume commands, Portworx defaults to using the cluster-wide secret key **if set**

What happens if the cluster-wide secret is not set?
-->
