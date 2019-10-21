---
title: Upgrade Portworx using the Operator
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Find out how to upgrade Portworx on OpenShift using Operator.
weight: 3
---

If you're using the Portworx Operator, you can upgrade or change your Portworx version at any time by modifying the `StorageCluster` spec.

## Prerequisites

* You must already be running the Portworx through Operator, this method will not work for other Portworx deployments

## Upgrade Portworx

<!-- taking a guess at this step -->

1. Enter the `oc edit` command to modify your storage cluster:

      ```text
      oc edit -n kube-system <storagecluster_name>
      ```

2. Change the `spec.image` value to the version you want to update Portworx to:

      ```text
      apiVersion: core.libopenstorage.org/v1alpha1
      kind: StorageCluster
      metadata:
        name: portworx
        namespace: kube-system
      spec:
        image: portworx/oci-monitor:<your_desired_version>
      ```
