---
title: Encrypting Kubernetes PVCs with Vault
weight: 1
keywords: Vault Key Management, Hashicorp, encrypt PVC, Kubernetes, k8s, Vault Namespaces
description: Instructions on using Vault with Portworx for encrypting PVCs in Kubernetes
noicon: true
series: vault-secret-uses
series2: k8s-pvc-enc
hidden: true
---

{{% content "shared/key-management-intro.md" %}}

There are two ways in which Portworx volumes can be encrypted and are dependent on how the Vault secret key is provided to Portworx.

### Encryption using Storage Class

In this method, Portworx will use the cluster wide secret key to encrypt PVCs.

#### Step 1: Set a cluster wide secret

{{% content "shared/key-management-set-cluster-wide-secret.md" %}}

If you are using Vault Namespaces use the following command to set the cluster-wide secret key in a specific vault namespace:

```text
pxctl secrets set-cluster-key --secret_options=vault-namespace=<name of vault-namespace>
```

{{% content "shared/key-management-storage-class-encryption.md" %}}

### Encryption using PVC annotations

In this method, each PVC can be encrypted with its own secret key.

#### Step 1: Create a Storage Class

{{% content "shared/key-management-enc-storage-class-spec.md" %}}

#### Step 2: Create a PVC with annotations

{{% content "shared/key-management-other-providers-pvc-encryption.md" %}}

{{<info>}}
**IMPORTANT:** Make sure secret `your-secret-key` exists in Vault.
{{</info>}}

### Encryption using PVC annotations with Vault Namespaces

If you have **Vault Namespaces** enabled and your secret resides inside a specific namespace, you must provide the name of that namespace and the secret key to Portworx.

#### Step 1: Create a Storage Class

{{% content "shared/key-management-enc-storage-class-spec.md" %}}

#### Step 2: Create a PVC with annotations

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-mysql-pvc
  annotations:
    px/secret-name: <your-secret-key>
    px/vault-namespace: <your-vault-namesapce>
spec:
  storageClassName: portworx-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

The PVC requires an extra annotation `px/vault-namespace` to indicate the Vault namespace where the secret key resides. If your key resides in the global vault namespace
set in Portworx using the parameter `VAULT_NAMESPACE`, you don't need to specify this annotation. However if the key resides in any other namespace then this annotation is
required.

{{<info>}}
**IMPORTANT:** Make sure the secret `your-secret-key` exists in the namespace `your-vault-namespace` in Vault.
{{</info>}}
