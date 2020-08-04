---
title: Encrypt Kubernetes PVCs with Vault
weight: 1
keywords: Vault Key Management, Hashicorp, encrypt PVC, Kubernetes, k8s
description: Learn how you can encrypt Kubernetes PVCs with Vault
noicon: true
series: vault-secret-uses
series2: k8s-pvc-enc
hidden: true
---

You can use one of the following methods to encrypt Kubernetes PVCs with Vault, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using a cluster wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption.

{{% content "shared/pvc-enc-per-volume.md" %}}

## Encrypt volumes using a cluster wide secret

{{% content "shared/pvc-enc-cluster-wide.md" %}}
