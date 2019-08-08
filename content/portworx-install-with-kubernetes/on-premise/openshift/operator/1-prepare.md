---
title: 1. Prepare your platform
weight: 1
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift, operator
description: Find out how to prepare PX within a OpenShift cluster and have PX provide highly available volumes to any application deployed via Kubernetes.
---

{{<info>}}Portworx Operator is supported Openshift 4 and above.{{</info>}}

### Install Portworx Operator

Starting OpenShift 4 you can install the Certified Portworx Operator from OperatorHub under the Catalog tab in Openshift console.

![Portworx Operator](/img/openshift-operatorhub-portworx.png)

{{% content "portworx-install-with-kubernetes/on-premise/openshift/shared/1-prepare.md" %}}
