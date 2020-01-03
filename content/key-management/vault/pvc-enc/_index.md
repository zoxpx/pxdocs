---
title: Encrypting Kubernetes PVCs with Vault
weight: 1
keywords: Portworx, Hashicorp, Vault, containers, storage, encryption
description: Instructions on using Vault with Portworx for encrypting PVCs in Kubernetes
noicon: true
series: vault-secret-uses
series2: k8s-pvc-enc
hidden: true
---

{{% content "shared/key-management-intro.md" %}}

There are two ways in which Portworx volumes can be encrypted and are dependent on how a secret passphrase is provided to Portworx.

### Encryption using Storage Class

In this method, Portworx will use the cluster wide secret key to encrypt PVCs.

#### Step 1: Set a cluster wide secret

{{% content "shared/key-management-set-cluster-wide-secret.md" %}}

{{% content "shared/key-management-storage-class-encryption.md" %}}

### Encryption using PVC annotations

In this method, each PVC can be encrypted with its own secret key.

#### Step 1: Create a Storage Class

{{% content "shared/key-management-enc-storage-class-spec.md" %}}

#### Step 2: Create a PVC with annotation

{{% content "shared/key-management-other-providers-pvc-encryption.md" %}}

__Important: Make sure secret `your_secret_key` exists in Vault__
