---
title: "Configure role-based access control for Stork"
linkTitle: "Configure RBAC for Stork"
keywords: cloud, backup, restore, snapshot, DR, migration, kubemotion, stork, rbac, role, clusterrole
description: Learn how to configure role-based access control to allow your users to perform Stork operations.
noicon: true
weight: 11
---

Cluster administrators can allow certain users to perform Stork operations by creating and assigning custom roles for their users. Under the configuration described below, a Cluster administrator defines permissions in a user role which allows the user to perform Stork operations.

## Modify a role

1\. As a Kubernetes cluster administrator, create a new Kubernetes role, or find an existing one you wish to modify.

2\. Modify the role, adding permissions for Stork resources to it:

```text
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: stork-crd-role
rules:
- apiGroups: ["stork.libopenstorage.org"]
  resources: [ * ]
  verbs: ["get", "list", "create", "watch", "update", "delete"]
- apiGroups: ["volumesnapshot.external-storage.k8s.io"]
  resources: ["volumesnapshots", "volumesnapshotdatas"]
  verbs:     ["get", "list", "create", "watch", "update", "delete"]
```

## SchedulePolicy example

An RBAC role grants access to all Stork CRDs except `SchedulePolicy`, which is cluster-scoped. To grant access to schedule policy resources, you must create a `ClusterRole` and the corresponding `ClusterRoleBinding`.

1\. Create a new `ClusterRole` by entering the following command:

```text
kubectl apply -f - <<'_EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: schedulepolicy-clusterrole
rules:
- apiGroups: ["stork.libopenstorage.org"]
  resources: [ "schedulepolicy" ]
  verbs: ["get", "list", "create", "watch", "update", "delete"]
_EOF
```

2\. To create a `ClusterRoleBinding`, use the following example spec, adjusting the values in the `subjects` section to match your environment:

```text
kubectl apply -f - <<'_EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: schedulepolicy-clusterrolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: schedulepolicy-clusterrole
subjects:
- kind: ServiceAccount
  name: stork-crd
  namespace: default
_EOF
```
