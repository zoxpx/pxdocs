---
layout: page
title: "Portworx install on PKS on vSphere using shared datastores"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
meta-description: "Find out how to install PX in a PKS Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
hidden: true
disableprevnext: true
---

## Pre-requisites

* This page assumes you have a running etcd cluster. If not, return to [Installing etcd on PKS](/portworx-install-with-kubernetes/on-premise/install-pks#install-etcd-pks).

## Architecture

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-shared-arch.md" %}}

## ESXi datastore preparation

Create one or more shared datastore(s) or datastore cluster(s) which is dedicated for Portworx storage. Use a common prefix for the names of the datastores or datastore cluster(s). We will be giving this prefix during Portworx installation later in this guide.

## Portworx installation

1. Create a secret using [this template](#pks-px-vsphere-secret). Replace values replace values corresponding to your vSphere environment.
2. Deploy the Portworx spec using [this template](#pks-px-spec). Replace values replace values corresponding to your vSphere environment.

Once you have the spec, proceed below.

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash -s -- -T pks```
2. Go to each virtual machine and delete the additional vmdks Portworx created in the shared datastore.

## References

<a name="pks-px-vsphere-secret"></a>
### Secret for vSphere credentials

{{% content "cloud-references/auto-disk-provisioning/vsphere/vsphere-secret.md" %}}

<a name="pks-px-spec"></a>
### Portworx spec

* If you are using secured etcd, download [Portworx spec for PKS with secure etcd](/samples/k8s/vsphere/px-pks-vsphere-shared-specs-secure-etcd.yaml).
* If you are using non-secured etcd, download [Portworx spec for PKS with non-secure etcd](/samples/k8s/vsphere/px-pks-vsphere-shared-specs.yaml).

You need to change below things in the spec to match your environment. These are sections in the spec with a *CHANGEME* comment.

1. **PX etcd** endpoint in the -k argument.
2. **Cluster ID** in the -c argument. Choose a unique cluster ID.
3. **VSPHERE_VCENTER**: Hostname of the vCenter server.
4. **VSPHERE_DATASTORE_PREFIX**: Prefix of the ESXi datastore(s) that Portworx will use for storage.
5. **Size of disks**: In the Portworx Daemonset arguments below, change `size=100` to the size of the disks you want each Portworx node in the cluster to create.
  * For e.g if you have 10 nodes in your cluster and you give size=100, each Portworx node will create a 100GB disk in the shared datastore and the cluster storage capacity will be 1TB.


`kubectl apply` the above spec after you update the above template with your environment details.
