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

1. As a Kubernetes cluster administrator, create a new Kubernetes role, or find an existing one you wish to modify.

2. Modify the role, adding permissions for Stork resources to it:


        apiVersion: rbac.authorization.k8s.io/v1
        kind: Role
        metadata:
          namespace: default
          name: pod-reader
        rules:
        - apiGroups: ["stork.libopenstorage.org"]
          resources: [ * ]
          verbs: ["get", "list", "create", "watch", "update", "delete"]
        - apiGroups: ["volumesnapshot.external-storage.k8s.io"]
          resources: ["volumesnapshots", "volumesnapshotdatas", "volumesnapshotrestores", ]
          verbs:     ["get", "list", "create", "watch", "update", "delete"]
