---
title: Storage on demand
linkTitle: Storage on demand
keywords: portworx, container, Nomad, storage,
description: Learn how to use Portworx in order to enable applications to have storage provisioned on demand rathern than pre-provisioned.
weight: 3
series: px-nomad-useful-information
noicon: true
hidden: true
---

{{<info>}}
This document presents the **non-Kubernetes** method of provisioning volumes on-demand. Please refer to the [Dynamic Provisioning of PVCs](/portworx-install-with-kubernetes/storage-operations/create-pvcs/dynamic-provisioning/) page if you are running Portworx on Kubernetes.
{{</info>}}

Portworx provides an important feature that enables applications to have storage provisioned on demand, rather than requiring storage to be pre-provisioned.

The feature is also referred to as `inline volume creation`. For more information, [click here](/reference/cli/create-and-manage-volumes) and see the section _Inline volume spec_.

Using this feature can be seen in the above example in the `volumes` clause. Note that all relevant Portworx volume metadata can be specified through this mechanism.
