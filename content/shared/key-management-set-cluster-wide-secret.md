---
title: Shared content for all Kubernetes secrets docs - set cluster-wide secret
keywords: Kubernetes Secrets, k8s
description: Shared content for all Kubernetes secret docs - set cluster-wide secret
hidden: true
---

A cluster wide secret key is a common key that can be used to encrypt all your volumes. This common key needs to be pre-created in your KMS provider.
You can set the cluster secret key using the following command.

```text
pxctl secrets set-cluster-key
```

```output
Enter cluster wide secret key: *****
Successfully set cluster secret key!
```

In the above prompt you need to enter the secret key that you created in your KMS. This command needs to be run just once for the cluster. 
