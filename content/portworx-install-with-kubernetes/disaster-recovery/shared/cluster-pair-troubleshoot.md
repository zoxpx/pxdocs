---
title: Cluster pair troubleshoot
hidden: true
keywords: portworx, kubernetes, dr
description: cluster pair troubleshooting page
---
### Troubleshooting
If the status is in error state you can describe the clusterpair to get more information by running:

```text
kubectl describe clusterpair remotecluster
```

{{<info>}}
You might need to perform additional steps for [GKE](/portworx-install-with-kubernetes/cloud/gke) and [EKS](/portworx-install-with-kubernetes/cloud/aws/aws-eks/).
{{</info>}}
