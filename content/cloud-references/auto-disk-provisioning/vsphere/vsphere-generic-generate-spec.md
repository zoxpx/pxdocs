---
title: Portworx vSphere generic spec generation
description: Portworx vSphere generic spec generation
keywords: portworx, VMware, vSphere ASG
hidden: true
---

#### Generate the spec file

Now generate the spec with the following curl command.

{{<info>}}Observe how curl below uses the environment variables setup up above as query parameters.{{</info>}}

```text
export VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -fsL -o px-spec.yaml "https://install.portworx.com/{{% currentVersion %}}?kbver=$VER&c=portworx-demo-cluster&b=true&st=k8s&csi=true&vsp=true&ds=$VSPHERE_DATASTORE_PREFIX&vc=$VSPHERE_VCENTER&s=%22$VSPHERE_DISK_TEMPLATE%22"
```
