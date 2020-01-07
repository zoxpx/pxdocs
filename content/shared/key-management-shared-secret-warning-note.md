---
title: Shared content for all Kubernetes secrets docs - shared secret warning note
keywords: Kubernetes Secrets, k8s
description: Shared content for all Kubernetes secret docs - encrypted storage class spec
hidden: true
---

If you want to migrate encrypted volumes created through this method between two different Portworx clusters:

1. Create a secret with the same name (--secret_id) using Portworx CLI
2. Make sure you provide the same **passphrase** while generating the secret.
