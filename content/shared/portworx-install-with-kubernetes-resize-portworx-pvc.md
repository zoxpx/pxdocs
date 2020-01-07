---
title: Shared content for install Portworx with Kubernetes - resize a Portworx PVC
hidden: true
keywords: Install, resize Portworx PVC, kubernetes, k8s
description: Shared content for install Portworx with Kubernetes - resize a Portworx PVC
---

To resize a Portworx PVC, you can simply edit the PVC spec and update the size. Let's take an example of resizing a MySQL PVC.

1. Download the [MySQL StorageClass spec](/samples/k8s/mssql/mssql_sc.yml?raw=true) and apply it. Note that the StorageClass has `allowVolumeExpansion: true`
2. Download the [MySQL PVC spec](/samples/k8s/mssql/mssql_pvc.yml?raw=true) and apply it. We will start with a 5GB volume.
3. Download the [MySQL Deployment spec](/samples/k8s/mssql/mssql_deployment.yml?raw=true) and apply it. Wail till the pod becomes 1/1 and then proceed to next step.
4. Run `kubectl edit pvc mssql-data` and change the size in the "spec" to 10Gi.

After you save the spec, `kubectl describe pvc mssql-data` should have an entry like below that confirms the volume resize.

```
Normal  VolumeResizeSuccessful  5s    volume_expand                ExpandVolume succeeded for volume default/mssql-data
```
