---
title: Portworx vSphere generic spec generation
description: Portworx vSphere generic spec generation
keywords: portworx, VMware, vSphere ASG
hidden: true
---

Now generate the spec with the following curl command.

{{<info>}}Observe how curl below uses the environment variables setup up above as query parameters.{{</info>}}

```text
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -fsL -o px-spec.yaml "https://install.portworx.com/{{% currentVersion %}}?kbver=$VER&c=portworx-demo-cluster&b=true&st=k8s&pks=true&vsp=true&ds=$VSPHERE_DATASTORE_PREFIX&vc=$VSPHERE_VCENTER&s=%22$VSPHERE_DISK_TEMPLATE%22"
```

{{<info>}}Above specs use Portworx internal etcd. If you are using a dedicated etcd cluster, replace `b=true` with `k=<YOUR-ETCD-ENDPOINTS>` {{</info>}}
