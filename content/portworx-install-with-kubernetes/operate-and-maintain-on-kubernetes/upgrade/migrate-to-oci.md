---
title: Migrate to OCI
weight: 1
---

This page describes the procedure to migrate your current Portworx installation to use OCI/runc containers.

### Get your current Portworx Spec parameters {#step-1-get-your-current-portworx-arguments}

Run this command:

```text
$ kubectl get ds/portworx -n kube-system -o jsonpath='{.spec.template.spec.containers[*].args}'
```

Click the link below to work through the remainder of the migration to OCI process. In _Section 1. Generate the Spec_, use the current spec parameters that you retrieved above.

{% page-ref page="../../portworx-install-with-kubernetes/" %}

