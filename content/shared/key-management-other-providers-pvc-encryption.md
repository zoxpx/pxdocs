---
title: Shared content for all Kubernetes secrets docs - encrypted storage class spec
keywords: Kubernetes Secrets, k8s
description: Shared content for all Kubernetes secret docs - encrypted storage class spec
hidden: true
---

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-mysql-pvc
  annotations:
    px/secret-name: your-secret-key
spec:
  storageClassName: portworx-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```
