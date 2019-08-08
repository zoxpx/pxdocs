---
title: 2. Deploy Portworx
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Find out how to apply the spec for PX within a OpenShift cluster and have PX provide highly available volumes to any application deployed via Kubernetes.
weight: 2
---

The _Portworx_ Enterprise Operator takes a new custom Kubernetes resource called `StorageCluster` as input. The `StorageCluster` is
a representation of your _Portworx_ cluster configuration. Once the `StorageCluster` object is created, the operator will deploy
a Portworx cluster corresponding to the specification in the `StorageCluster` object. The operator will watch for changes on the
`StorageCluster` and update your cluster according to the latest specifications.

To know more details of the `StorageCluster` object and how operator manages changes, visit the [Portworx Operator page](/reference/crd/storage-cluster).

### Generate the specs

To install _Portworx_ with Openshift, you will first generate `StorageCluster` spec that you will deploy in your cluster.
To generate the spec, click {{<iframe url="https://openshift4.install.portworx.com" text="Generating the Portworx cluster spec">}}

- Under the _Portworx_ Operator, you can click on `Create New` to create a StorageCluster object.

![Create Storage Cluster](/img/openshift-px-operator-storage-cluster.png)

- Copy the spec created from the spec generator and paste in the YAML editor on the Openshift Console.

![Storage Cluster Spec](/img/openshift-px-operator-create-storage-cluster.png)

You can also create the StorageCluster object using `oc` or `kubectl` as show below.

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
