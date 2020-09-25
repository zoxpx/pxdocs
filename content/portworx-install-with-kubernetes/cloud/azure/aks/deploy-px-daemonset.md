---
title: Install Portworx on AKS using the DaemonSet
linkTitle: Install using the DaemonSet
keywords: on cloud, AKS, Azure Kubernetes Service, Microsoft, Kubernetes, k8s
description: Learn about applying the spec with Portwork on Azure Kubernetes Service.
weight: 4
---

## Install

{{% content "shared/portworx-install-with-kubernetes-shared-1-generate-the-spec-footer.md" %}}

{{<info>}}
**NOTE:** To deploy Portworx to an Azure Sovereign cloud, you must go to the **Customize** page and set the value of the `AZURE_ENVIRONMENT` variable. The following example screenshot shows how you can deploy Portworx to the Azure US Government cloud:

![Screenshot showing the AZURE_ENVIRONMENT variable](/img/azure-sovereign-example.png)

{{</info>}}

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}
