---
title: Portworx on Anthos
linkTitle: Anthos
weight: 4
keywords: Install, on-premise, anthos, kubernetes, k8s, air gapped
description: How to install Portworx on Anthos
---

Portworx has been certified with the following Anthos versions:

* Anthos 1.1
* Anthos 1.2
* Anthos 1.3 


## Architecture

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-shared-arch.md" %}}

## Installation

This topic explains how to install Portworx with Kubernetes on Anthos. Follow the steps in this topic in order.

{{<info>}}Run these steps from the anthos admin station or any other machine which has kubectl access to your cluster.{{</info>}}

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-install-common.md" %}}

#### Max storage nodes

Anthos cluster management operations, such as upgrades, recycle cluster nodes by deleting and recreating them. During this process, the cluster momentarily scales up to more nodes than initially installed. For example, a 3-node cluster may increase to a 4-node cluster.

To prevent Portworx from creating storage on these additional nodes, you must cap the number of Portworx nodes that will act as storage nodes. You can do this by setting the `MAX_NUMBER_OF_NODES_PER_ZONE` environment variable according to the following requirements:

* If your Anthos cluster does not have zones configured, this number should be your initial number of cluster nodes
* If your Anthos cluster has zones configured, this number should be initial number of cluster nodes per zone

```text
export MAX_NUMBER_OF_NODES_PER_ZONE=3
```
{{<info>}} **NOTE:** In the command above, 3 is an example. Change this number to suit your cluster.{{</info>}}

#### Generate the spec file

Now generate the spec with the following curl command.

{{<info>}}Observe how curl below uses the environment variables setup up above as query parameters.{{</info>}}

```text
export VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
curl -fsL -o px-spec.yaml "https://install.portworx.com/{{% currentVersion %}}?kbver=$VER&mz=$MAX_NUMBER_OF_NODES_PER_ZONE&csida=true&c=portworx-demo-cluster&b=true&st=k8s&csi=true&vsp=true&ds=$VSPHERE_DATASTORE_PREFIX&vc=$VSPHERE_VCENTER&s=%22$VSPHERE_DISK_TEMPLATE%22&misc=-rt_opts%20kvdb_failover_timeout_in_mins=25"
```

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}

## Known issues

### vSphere 6.5

* **Issue**: If you are running on VMware vSphere version 6.5 or lower: When you delete a worker node VM, vSphere deletes all disks attached to the VM. While this is the default vSphere behavior, the deletion of these disks will cause the Portworx cluster to lose quorum.
* **Workaround**: Upgrade to vSphere 6.7.3 and use Portworx 2.5.1.3 or higher
 
