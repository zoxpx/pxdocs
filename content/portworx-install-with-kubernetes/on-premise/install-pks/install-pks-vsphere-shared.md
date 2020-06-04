---
title: Portworx install on PKS on vSphere using shared datastores
keywords: Install, on-premise, PKS, Pivotal Container Service, vsphere, kubernetes, k8s, air gapped
meta-description: Find out how to install PX in a PKS Kubernetes cluster and have PX provide highly available volumes to any application deployed via Kubernetes.
hidden: true
disableprevnext: true
---

## Pre-requisites

* This page assumes you have a running etcd cluster. If not, return to [Installing etcd on PKS](/portworx-install-with-kubernetes/on-premise/install-pks/#step-2-install-etcd).

## Architecture

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-shared-arch.md" %}}

## ESXi datastore preparation

Create one or more shared datastore(s) or datastore cluster(s) which is dedicated for Portworx storage. Use a common prefix for the names of the datastores or datastore cluster(s). We will be giving this prefix during Portworx installation later in this guide.

## Portworx installation

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-install-common.md" %}}

#### Generating the spec if using secure etcd

{{% content "portworx-install-with-kubernetes/on-premise/install-pks/vsphere-pks-generate-spec-internal-kvdb.md" %}}

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash -s -- -T pks```
2. Go to each virtual machine and delete the additional vmdks Portworx created in the shared datastore.


