---
title: 2. Deploy Portworx on AKS
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, aks, Azure
description: Learn about applying the spec with Portwork on Azure Kubernetes Service.
weight: 2
---

## Install

{{<info>}}
You must specify Azure environment variables in the DaemonSet spec file for _Portworx_ to manage the disks. The environment variables to specify are:
```
AZURE_TENANT_ID=ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce
AZURE_CLIENT_ID=1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde
AZURE_CLIENT_SECRET=ac49a307-xxxx-xxxx-xxxx-fa551e221170
```
If generating the DaemonSet spec via the GUI wizard, specify the Azure environment variables in the **List of environment variables** field. If generating the DaemonSet spec via the command line, specify the Azure environment variables using the `e` parameter.
{{</info>}}

### Generate the specs

To install _Portworx_ with Kubernetes, you will first generate Kubernetes manifests that you will deploy in your cluster.

To generate the specs, click {{<iframe url="https://aks-install.portworx.com/2.1" text="Generating the Portworx specs.">}}

_Portworx_ can also be installed using it's Helm chart by following instructions [here](/portworx-install-with-kubernetes/install-px-helm). The above method is recommended over helm as the wizard will guide you based on your environment.

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
