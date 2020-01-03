---
title: (Other Schedulers) Encrypting Portworx Volumes using Vault
weight: 2
keywords: Portworx, Hashicorp, Vault, containers, storage, encryption
description: Instructions on using Vault with Portworx for encrypting Portworx Volumes
noicon: true
series: vault-secret-uses
hidden: true
---

{{% content "shared/key-management-intro.md" %}}


## Creating and using encrypted volumes

There are two ways in which Portworx volumes can be encrypted and are dependent on how a secret passphrase is provided to Portworx.

### Using per volume secret keys

{{% content "shared/key-management-per-volume-secret.md" %}}

__Important: Make sure secret `key1` exists in Vault__

### Using cluster wide secret key


{{% content "shared/key-management-set-cluster-wide-secret.md" %}}

{{% content "shared/key-management-volume-cluster-wide-secret.md" %}}

__Important: Make sure the cluster wide secret key is set when you are setting up Portworx with Vault__
