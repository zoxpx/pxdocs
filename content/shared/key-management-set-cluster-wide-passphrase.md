---
title: Shared content for all Kubernetes secrets docs - set cluster-wide passphrase
keywords: Kubernetes Secrets, k8s
description: Shared content for all Kubernetes secret docs - set cluster-wide passphrase
hidden: true
---

Use the following command to set the cluster wide secret key

```text
pxctl secrets set-cluster-key --secret <passphrase>
```

```output
Successfully set cluster secret key!
```

The `<passphrase>` in the above command will be used for encrypting the volumes. The cluster wide secret key needs to be set only once.

{{<info>}}
DO NOT overwrite the cluster wide secret key, else any existing volumes using it will not be usable
{{</info>}}
