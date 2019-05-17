---
title: 2. Deploy Portworx on AKS
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, aks, Azure
description: Learn about applying the spec with Portwork on Azure Kubernetes Service.
weight: 2
---

## Install

### Create a secret to give Portworx access to Azure APIs

Update `<AZURE_TENANT_ID>`, `<AZURE_CLIENT_ID>` and `<AZURE_CLIENT_SECRET>` in below command and create a secret called _px-azure_.

```text
kubectl create secret generic px-azure --from-literal=AZURE_TENANT_ID=<AZURE_TENANT_ID> \
                                       --from-literal=AZURE_CLIENT_ID=<AZURE_CLIENT_ID> \
                                       --from-literal=AZURE_CLIENT_SECRET=<AZURE_CLIENT_SECRET>
```
```output
secret/px-azure created
```

When you generate the spec in the next step, the Portworx pod will fetch the Azure environment variables from this secret.

### Generate the specs

To install _Portworx_ with Kubernetes, you will first generate Kubernetes manifests that you will deploy in your cluster.

To generate the specs, click {{<iframe url="https://aks-install.portworx.com/2.1" text="Generating the Portworx specs.">}}

_Portworx_ can also be installed using it's Helm chart by following instructions [here](/portworx-install-with-kubernetes/install-px-helm). The above method is recommended over helm as the wizard will guide you based on your environment.

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
