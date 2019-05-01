---
title: Encrypting Kubernetes PVCs with Google Cloud KMS
weight: 1
keywords: Portworx, Google, Google Cloud, KMS, containers, storage, encryption
description: Instructions on using Google Cloud KMS with Portworx for encrypting PVCs
noicon: true
series: gcloud-secret-uses
series2: k8s-pvc-enc
hidden: true
---

{{% content "key-management/shared/intro.md" %}}

### Encryption using per volume secrets

In this method each volume will use its own unique passphrase for encryption. _Portworx_ generates a  unique 128 bit passphrase. This passphrase will be used during encryption and decryption. If you do not wish _Portworx_ to generate passphrases for you, use named secrets as mentioned [here](/key-management/gcloud-kms/pvc-enc#encryption-using-named-secrets)

#### Step 1: Create a Storage Class

{{% content "key-management/shared/enc-storage-class-spec.md" %}}

#### Step 2: Create a Persistent Volume Claim

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    volume.beta.kubernetes.io/storage-class: px-secure-sc
spec:
  storageClassName: px-mysql-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```

If you do not want to specify the `secure` flag in the storage class, but you want to encrypt the PVC using that Storage Class, then create the PVC as below:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-pvc
  annotations:
    px/secure: "true"
spec:
  storageClassName: portworx-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```
Note the `px/secure: "true"` annotation on the PVC object.

### Encryption using cluster wide secret

In this method a default cluster wide secret will be set for the Portworx cluster. Such a secret will be referenced by the user and Portworx as **default** secret. Any PVC request referencing the secret name as `default` will use this cluster wide secret as a passphrase to encrypt the volume.

#### Step 1: Set the cluster wide secret key

{{% content "key-management/shared/set-cluster-wide-passphrase.md" %}}

#### Step 2: Create a Storage Class

{{% content "key-management/shared/enc-storage-class-spec.md" %}}

#### Step 3: Create a Persistent Volume Claim

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    px/secret-name: default
    volume.beta.kubernetes.io/storage-class: px-secure-sc
spec:
  storageClassName: px-mysql-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```

{{% content "key-management/aws-kms/shared/px-secret-name-default.md" %}}

{{% content "key-management/aws-kms/shared/secure-flag.md" %}}

{{<info>}}
{{% content  "key-management/shared/shared-secret-warning-note.md" %}}
{{</info>}}

### Encryption using named secrets

In this method _Portworx_ will use the named secret created by you for encrypting and decrypting a volume. To create a named secret follow [this document](/key-management/gcloud-kms#creating-named-secrets).

#### Step 1: Create a Named Secret

{{% content "key-management/gcloud-kms/shared/named-secrets.md" %}}

#### Step 2: Create a Storage Class

{{% content "key-management/shared/enc-storage-class-spec.md" %}}

#### Step 3: Create a Persistent Volume Claim

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    px/secret-name: mysecret
    volume.beta.kubernetes.io/storage-class: px-secure-sc
spec:
  storageClassName: px-mysql-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

```

{{% content "key-management/aws-kms/shared/px-secret-name-mysecret.md" %}}

{{<info>}}
A single named secret can be used for encrypting multiple volumes.
{{</info>}}

{{% content "key-management/aws-kms/shared/secure-flag.md" %}}

{{<info>}}
{{% content  "key-management/shared/shared-secret-warning-note.md" %}}
{{</info>}}
