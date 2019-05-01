---
title: (Other Schedulers) Encrypting Portworx Volumes using AWS KMS
weight: 2
keywords: Portworx, Amazon, AWS KMS, containers, storage, encryption
description: Instructions on using AWS KMS with Portworx for encrypting Portworx Volumes
noicon: true
series: aws-secret-uses
hidden: true
---

{{% content "key-management/shared/intro.md" %}}

## Creating and using encrypted volumes

### Using per volume secret keys

{{% content "key-management/aws-kms/shared/unique-passphrase.md" %}}

To create a volume through pxctl, run the following command:

```text
pxctl volume create --secure  enc_vol
```

To create a volume through docker, run the following command:

```text
docker volume create --volume-driver pxd secure=true,name=enc_vol
```

To attach and mount an encrypted volume through docker, run the following command:

```text
docker run --rm -it -v secure=true,name=enc_vol:/mnt busybox
```

Note that no `secret_key` argument needs to be passed in any of the commands.

### Using named secret keys

In this method, you will create an AWS Data Key and assign it a unique name. This data key will then be used for encrypting volumes.

{{<info>}}
{{% content "key-management/aws-kms/shared/warning-note.md" %}}
{{</info>}}

#### Step1: Create a Named Secret

{{% content "key-management/aws-kms/shared/named-secrets.md" %}}

#### Step2: Use the Named Secrets for encrypting volumes

To create a volume using a named secret through pxctl, run the following command

```text
pxctl volume create --secure --secret_key mysecret enc_vol
```

To create a volume using a named secret through docker, run the following command

```text
docker volume create --volume-driver pxd secret_key=mysecret,name=enc_vol
```

To attach and mount the same encrypted volume through docker, run the following command

```text
docker run --rm -it -v secure=true,secret_key=mysecret,name=enc_vol:/mnt busybox
```

### Using cluster-wide secret key

{{% content "key-management/aws-kms/shared/cluster-wide-intro.md" %}}

