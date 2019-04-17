---
title: All other
linkTitle: All other
weight: 3
logo: /logos/other.png
keywords: portworx, container, kubernetes
description: How to install Portworx with Kubernetes
noicon: true
series2: k8s-airgapped
---

This topic explains how to install Portworx with Kubernetes.

## Install

{{<info>}}**Airgapped clusters**: If your nodes are airgapped and don't have access to common internet registries, first follow [Airgapped clusters](/portworx-install-with-kubernetes/on-premise/airgapped) to fetch Portworx images.{{</info>}}

{{% content "portworx-install-with-kubernetes/shared/1-generate-the-spec-footer.md" %}}

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
