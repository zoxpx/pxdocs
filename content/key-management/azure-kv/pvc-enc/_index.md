---
title: Encrypt Kubernetes PVCs with Azure Key Vault
weight: 1
keywords: encryption, Kubernetes PVCs, k8s, Azure Key Vault, Key Management Service
description: Learn how you can encrypt Kubernetes PVCs with Azure Key Vault
noicon: true
series: azure-key-vault-secret-uses
series2: azure-pvc-enc
hidden: true
---

You can use one of the following methods to encrypt Kubernetes PVCs with Azure Key Vault, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)
- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)

## Prerequisites

Your Portworx cluster must be authenticated with Azure Key Vault. Refer to the [Setting up Azure Key Vault](/key-management/azure-kv/#setting-up-azure-key-vault) section for details about how you can authenticate Portworx with Azure Key Vault

## Encrypt volumes using a cluster-wide secret

{{% content "shared/pvc-enc-cluster-wide.md" %}}


## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption.

{{% content "shared/pvc-enc-per-volume.md" %}}