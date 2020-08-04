---
title: Install the Portworx Operator
weight: 1
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift, operator
description: Find out how to prepare your OpenShift cluster by installing the Operator.
aliases:
  - /portworx-install-with-kubernetes/on-premise/openshift/operator/1-prepare/
---

Before you can install Portworx on your OpenShift cluster, you must first install the Portworx Operator. Perform the following steps to prepare your OpenShift cluster by installing the Operator.

## Prerequisites

* Your cluster must be running OpenShift 4 or higher
* You must have an OpenShift cluster deployed on infrastructure meeting the [minimum requirements](/start-here-installation/) for Portworx

## Install the Portworx Operator

1. Navigate to the **OperatorHub** tab of your OpenShift cluster admin page:

      ![Portworx catalog](/img/OpenshiftOperatorHub.png)

2. Select the **kube-system** project from the project dropdown. This defines the namespace in which the Operator will be deployed:

      ![Portworx project callout](/img/OpenshiftSelectKube.png)

3. Search for and select either the **{{< pxEnterprise >}}** or **{{< pxEssentials >}}** Operator:

      ![select {{< pxEnterprise >}}](/img/OpenshiftOperatorSelect.png)

4. Select **Install** to install the Certified Portworx Operator:

      ![Portworx Operator](/img/OpenshiftConsoleInstall.png)

The Portworx Operator begins to install and takes you to the **Installed Operators** page. From there, you can deploy Portworx onto your cluster.
