---
title: "Set up a Cluster Admin namespace for Kubemotion"
keywords: cloud, backup, restore, snapshot, DR, migration, kubemotion
description: How to designate a namespace as the cluster admin namespace
---

By default, you can only migrate namespaces in which the Migration object is created.
This is to prevent any user from migrating namespaces for which they do not have access.
You can also designate one namespace as an admin namespace. This will allow an
admin who has access to that namespace to migrate any namespace from the source
cluster.

This requires passing in an additional parameter to the Stork deployment with
the admin namespace.

Run the following command to edit the Stork deployment:

```text
kubectl edit deployment -n kube-system stork
```

If `admin-namespace` is your admin namespace, in the editor, update the arguments to the Stork container to specify the cluster admin namespace using the `--admin-namespace` parameter:

```text
- command:
  - /stork
  - --driver=pxd
  - --verbose
  - --leader-elect=true
  - --admin-namespace=admin-namespace
```

Save the changes and wait for all the Stork pods to be in running state after applying the
changes:

```text
kubectl get pods -n kube-system -l name=stork
```

{{<info>}}
**NOTE:** If you're running a version of Stork older than 2.3.2, use  `--migration-admin-namespace` to specify your cluster admin namespace.

Example:
```text
- command:
  - /stork
  - --driver=pxd
  - --verbose
  - --leader-elect=true
  - --migration-admin-namespace=admin-namespace
```
{{</info>}}
