---
title: Encrypt Kubernetes PVCs with IBM Key Protect
weight: 1
keywords:  IBM Key Protect, encrypt Kubernetes PVC, k8s
description: Learn how you can encrypt Kubernetes PVCs with IBM Key Protect
noicon: true
disableprevnext: true
series: ibm-key-protect-uses
series2: k8s-pvc-enc
hidden: true
---

You can use one of the following methods to encrypt Kubernetes PVCs with IBM Key Protect, depending on how you provide the secret password to Portworx:

- [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets)
- [Encrypt volumes using a cluster-wide secret](#encrypt-volumes-using-a-cluster-wide-secret)

## Encrypt volumes using per volume secrets

Use per volume secrets to encrypt each volume with a different key. As a result, each volume uses its unique passphrase for encryption.
Portworx uses IBM Key Protect APIs to generate a unique 256-bit passphrase.

{{% content "shared/pvc-enc-per-volume.md" %}}

## Encrypt volumes using a cluster-wide secret

{{% content "shared/pvc-enc-cluster-wide.md" %}}
