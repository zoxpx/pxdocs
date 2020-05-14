---
title: Upgrade issue due to NodePort service type
keywords: forbidden,clusterip
description: Upgrade issue due to NodePort service type
hidden: true
---


If you had an older version of Portworx manifests installed, and you try to apply the latest manifests, you might see the following error during `kubectl apply`.

```
Service "portworx-service" is invalid: [spec.ports[0].nodePort: Forbidden: may not be used when `type` is 'ClusterIP', spec.ports[1].nodePort: Forbidden: may not be used when `type` is 'ClusterIP', spec.ports[2].nodePort: Forbidden: may not be used when `type` is 'ClusterIP', spec.ports[3].nodePort: Forbidden: may not be used when `type` is 'ClusterIP']
Error from server (Invalid): error when applying patch:
```

To fix this:

* Change the type of the `portworx-service` service to type ClusterIP. If the type was NodePort, you will also have to remove the nodePort entries from the spec.

      ```text
      kubectl edit service portworx-service -n kube-system
      ```

* Change the type of the `portworx-api` service to type ClusterIP. If the type was NodePort, you will also have to remove the nodePort entries from the spec.
   
      ```text
      kubectl edit service portworx-api -n kube-system
      ```
  
* Reapply your specs

