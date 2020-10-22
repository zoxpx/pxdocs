---
title: Install Portworx on-prem using the Operator
linkTitle: Install using the Operator
weight: 2
keywords: Install, on-premise, kubernetes, k8s, operator
description: Learn how to install Portworx with Kubernetes using the Operator
noicon: true
---

This topic provides instructions for installing Portworx with Kubernetes on-prem using the Operator.

## Install

{{<info>}}**Airgapped clusters**: If your nodes are airgapped and don't have access to common internet registries, first follow [Airgapped clusters](/portworx-install-with-kubernetes/on-premise/airgapped) to fetch Portworx images.{{</info>}}

### Install the Operator

1. Enter the following `kubectl create` command to deploy the Operator:

    ```text
    kubectl create -f https://install.portworx.com/?comp=pxoperator
    ```

{{% content "shared/portworx-install-with-kubernetes-shared-generate-the-spec-footer-operator.md" %}}

{{% content "shared/operator-apply-the-spec.md" %}}

{{% content "shared/operator-monitor.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}