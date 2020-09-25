---
title: Install Portworx on PKS using the DaemonSet
linkTitle: Install using the DaemonSet
logo: /logos/pks.png
weight: 3
description: Install, on-premise, PKS, Pivotal Container Service, kubernetes, k8s, air gapped
keywords: portworx, PKS, kubernetes
noicon: true
---

{{% content "shared/on-prem-pks-common-install.md" %}}

### Architecture

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-shared-arch.md" %}}

### ESXi datastore preparation

Create one or more shared datastore(s) or datastore cluster(s) which is dedicated for Portworx storage. Use a common prefix for the names of the datastores or datastore cluster(s). We will be giving this prefix during Portworx installation later in this guide.

<!--### Generating the Portworx specs -->

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-install-common.md" %}}

{{% content "portworx-install-with-kubernetes/on-premise/install-pks/vsphere-pks-generate-spec-internal-kvdb.md" %}}

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}

{{<info>}}
**NOTE:** Some errors, such as incorrect vSphere user credentials, are only shown in the container logs. To display these errors, use the `kubectl logs` command:

```text
kubectl logs portworx-pod -n kube-system
```
{{</info>}}

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash -s -- -T pks```
2. Go to each virtual machine and delete the additional vmdks Portworx created in the shared datastore.


<!-- commented as it's not supported
If you have **local** datastores, proceed to [Portworx install on PKS on vSphere using local datastores](/portworx-install-with-kubernetes/on-premise/install-pks/install-pks-vsphere-local).
-->
