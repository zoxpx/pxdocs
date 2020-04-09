---
title: Portworx on Anthos
linkTitle: Anthos
weight: 4
hidden: true
keywords: Install, on-premise, anthos, kubernetes, k8s, air gapped
description: How to install Portworx on Anthos
---

This topic explains how to install Portworx with Kubernetes on Anthos. Follow the steps in this topic in order.

## Architecture

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-shared-arch.md" %}}

## Installation

{{<info>}}Run these steps from the anthos admin station or any other machine which has kubectl access to your cluster.{{</info>}}

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-install-common.md" %}}

#### Generate the spec file

Now generate the spec with the following curl command.

{{<info>}}Observe how curl below uses the environment variables setup up above as query parameters.{{</info>}}

```text
export VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -fsL -o px-spec.yaml "https://install.portworx.com/2.5?kbver=$VER&csida=true&c=portworx-demo-cluster&b=true&st=k8s&csi=true&vsp=true&ds=$VSPHERE_DATASTORE_PREFIX&vc=$VSPHERE_VCENTER&s=%22$VSPHERE_DISK_TEMPLATE%22"
```

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}
