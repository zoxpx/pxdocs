---
title: Portworx Operator
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift, operator
description: How to install Portworx with OpenShift using Operator
weight: 2
---

The Portworx Operator manages the complete lifecycle of a Portworx cluster. Using the Operator, you can install, configure, and update Portworx.

As shown in the diagram below, the Operator manages the Portworx platform consisting of the Portworx nodes,
Stork, Lighthouse and other components that make running stateful applications seamless for the users.

![Portworx Operator](/img/px-operator-in-kubernetes.jpg)

The topics in this section explain how to install Portworx with Kubernetes on OpenShift using the Operator.

In order to install Portworx using the Operator, you must:

1. Install the Portworx Operator
2. Deploy Portworx using the Operator

## Related topics

* For information about the `StorageCluster` object and how the Operator manages changes, refer to the [Portworx Operator](/reference/crd/storage-cluster) article.
