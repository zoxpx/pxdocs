---
title: (Other Schedulers) Encrypting Portworx Volumes using Google Cloud KMS
weight: 2
keywords: Portworx, Google, Google Cloud, KMS, containers, storage, encryption
description: Instructions on using Google Cloud KMS with Portworx for encrypting Portworx Volumes
noicon: true
series: gcloud-secret-uses
hidden: true
---

{{% content "key-management/shared/intro.md" %}}

## Creating and using encrypted volumes

### Using per volume secret keys

There are two ways in which Portworx volumes can be encrypted and are dependent on how a secret passphrase is provided to PX. In this method portworx generates a 128 bit passphrase. This passphrase will be used during encryption and decryption.

To create a volume through pxctl, run the following command

```text
pxctl volume create --secure  enc_vol
```

To create a volume through docker, run the following command

```text
docker volume create --volume-driver pxd secure=true,name=enc_vol
```

To attach and mount an encrypted volume through docker, run the following command

```text
docker run --rm -it -v secure=true,name=enc_vol:/mnt busybox
```

Note that no `secret_key` needs to be passed in any of the commands.

### Using cluster wide secret key

In this method a default cluster wide secret will be set for the Portworx cluster. Such a secret will be referenced by the user and Portworx as **default** secret. Any volume request referencing the
secret name as `default` will use this cluster wide secret as a passphrase to encrypt the volume.

To create a volume using a cluster wide secret through pxctl, run the following command

```text
pxctl volume create --secure --secret_key default enc_vol
```

To create a volume using a cluster wide secret through docker, run the following command

```text
docker volume create --volume-driver pxd secret_key=default,name=enc_vol
```

To attach and mount an encrypted volume through docker, run the following command

```text
docker run --rm -it -v secure=true,secret_key=default,name=enc_vol:/mnt busybox
```

Note the `secret_key` is set to the value `default` to indicate PX to use the cluster-wide secret key


### Using named secrets

In this method Portworx will use the named secret created by you for encrypting and decrypting a volume. To create a named secret follow [this](/key-management/gcloud-kms/#creating-named-secrets) doc. While creating the named secret take a note of the `secret_id`. If the `secret_id` was set to `mysecret` then any volume request referencing the secret name as `mysecret` will use the corresponding passphrase to encrypt the volume.

To create a volume using a named secret through pxctl, run the following command

```text
pxctl volume create --secure --secret_key mysecret enc_vol
```

To create a volume using a cluster wide secret through docker, run the following command

```text
docker volume create --volume-driver pxd secret_key=mysecret,name=enc_vol
```

To attach and mount an encrypted volume through docker, run the following command

```text
docker run --rm -it -v secure=true,secret_key=mysecret,name=enc_vol:/mnt busybox
```