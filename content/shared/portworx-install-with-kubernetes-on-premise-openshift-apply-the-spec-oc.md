---
title: Shared
hidden: true
description: Learn how to install Portworx with Kubenetes
keywords: portworx, kubernetes
---

1. Apply the generated specs to your cluster with the `oc apply` command:

      ```text
      oc apply -f px-spec.yaml
      ```

2. Using the `oc get pods` command, monitor the Portworx deployment process. Wait until all Portworx pods show as ready:

      ```text
      oc get pods -o wide -n kube-system -l name=portworx
      ```

3. Verify that Portworx has deployed by checking its status with the following command:

      ```text
      PX_POD=$(oc get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
      oc exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
      ```
