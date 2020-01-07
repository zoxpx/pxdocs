---
title: Encrypting Kubernetes PVCs with AWS KMS
weight: 1
keywords: encryption, Kubernetes PVCs, k8s, AWS KMS, Amazon Web Services, Key Management Service
description: Instructions on using AWS KMS with Portworx for encrypting PVCs
noicon: true
series: aws-secret-uses
series2: k8s-pvc-enc
hidden: true
---

{{% content "shared/key-management-intro.md" %}}

### Encryption using per volume secrets

{{% content "shared/key-management-aws-kms-unique-passphrase.md" %}}

{{<info>}}
This is the recommended method for encrypting volumes when you want to take a cloud backup of an encrypted volume or migrate encrypted volumes between multiple clusters.
{{</info>}}

#### Step 1: Create a Storage Class

{{% content "shared/key-management-enc-storage-class-spec.md" %}}

#### Step 2: Create a Persistent Volume Claim

Create a new PVC as follows:

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

### Encryption using named secrets

{{<info>}}
{{% content "shared/key-management-aws-kms-warning-note.md" %}}
{{</info>}}

#### Step 1: Creating Named Secrets {#creating-named-secrets}

{{% content "shared/key-management-aws-kms-named-secrets.md" %}}

#### Step 2: Create a Storage Class

{{% content "shared/key-management-enc-storage-class-spec.md" %}}

#### Step 3: Create a Persistent Volume Claim

Use the following to create a new PVC:

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

{{% content "shared/key-management-aws-kms-shared-px-secret-name-mysecret.md" %}}

{{<info>}}
A single named secret can be used for encrypting multiple volumes.
{{</info>}}

### Encryption using cluster wide secret

{{% content "shared/key-management-aws-kms-cluster-wide-intro.md" %}}
