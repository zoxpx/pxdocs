---
title: 2. Deploy Portworx
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Find out how to apply the spec for PX within a OpenShift cluster and have PX provide highly available volumes to any application deployed via Kubernetes.
weight: 2
---

{{<info>}}
If you are generating the DaemonSet spec via the GUI wizard, select **OpenShift** under the **Customize** page.
{{</info>}}

{{% content "portworx-install-with-kubernetes/shared/1-generate-the-spec-footer.md" %}}

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
