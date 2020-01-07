---
title: Shared content for all Kubernetes secrets docs - storage class encryption
keywords: Kubernetes Secrets, k8s
description: Shared content for all Kubernetes secret docs - storage class encryption
hidden: true
---

#### Step 2: Create a StorageClass

{{% content "shared/key-management-enc-storage-class-spec.md" %}}

#### Step 3: Create Persistent Volume Claim
Create a PVC that uses the above `px-secure-sc` storage class.

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-pvc
spec:
  storageClassName: px-secure-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

#### Step 4: Verify the volume
Once the PVC has been created, verify the volume created in Portworx is encrypted.

```text
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume list
```

```output
ID                 NAME                                      ...  ENCRYPTED  ...
10852605918962284  pvc-5a885584-44ca-11e8-a17b-080027ee1df7  ...  yes        ...
```
