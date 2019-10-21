---
title: Kubernetes secret for VMware
description: Kubernetes secret for VMware
keywords: portworx, VMware, vSphere ASG
hidden: true
---


Update the following items in the Secret template below to match your environment:

1. **VSPHERE_USER**: Use output of `printf <vcenter-server-user> | base64`
2. **VSPHERE_PASSWORD**: Use output of `printf <vcenter-server-password> | base64`

```text
apiVersion: v1
kind: Secret
metadata:
  name: px-vsphere-secret
  namespace: kube-system
type: Opaque
data:
  VSPHERE_USER: YWRtaW5pc3RyYXRvckB2c3BoZXJlLmxvY2Fs
  VSPHERE_PASSWORD: cHgxLjMuMEZUVw==
```

`kubectl apply` the above spec after you update the above template with your user and password.
