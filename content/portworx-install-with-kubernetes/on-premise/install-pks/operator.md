---
title: Install Portworx on PKS using the Operator
linkTitle: Install using the Operator
logo: /logos/pks.png
weight: 2
description: Install, on-premises PKS, Pivotal Container Service, kubernetes, k8s, air gapped
keywords: portworx, PKS, kubernetes
noicon: true
---

{{% content "shared/on-prem-pks-common-install.md" %}}

### Architecture

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-shared-arch.md" %}}

### Install the Operator

Enter the following `kubectl create` command to deploy the Operator:

```text
kubectl create -f https://install.portworx.com/?comp=pxoperator
```

### ESXi datastore preparation

Create one or more shared datastore(s) or datastore cluster(s) which is dedicated for Portworx storage. Use a common prefix for the names of the datastores or datastore cluster(s). We will be giving this prefix during Portworx installation later in this guide.

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-install-common.md" %}}

<!-- This section below was part of a shared section title called "vsphere-pks-generate-spec-internal-kvdb.md" but this has changed and will no longer be shared. -->

Now generate the spec with the following curl command.

{{<info>}}Observe how curl below uses the environment variables setup up above as query parameters.{{</info>}}

```text
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -fsL -o px-spec.yaml "https://install.portworx.com/2.5?kbver=$VER&c=portworx-demo-cluster&b=true&st=k8s&pks=true&vsp=true&ds=$VSPHERE_DATASTORE_PREFIX&vc=$VSPHERE_VCENTER&s=%22$VSPHERE_DISK_TEMPLATE%22&operator=true"
```

{{<info>}}The specs above use Portworx with an internal etcd. If you are using a dedicated etcd cluster, replace `b=true` with `k=<YOUR-ETCD-ENDPOINTS>` {{</info>}}

{{% content "shared/operator-apply-the-spec.md" %}}

{{% content "shared/operator-monitor.md" %}}