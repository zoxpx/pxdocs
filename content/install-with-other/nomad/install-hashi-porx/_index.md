---
title: Hashi-porx
linkTitle: Full-stack deployment through Hashi-porx
keywords: portworx, container, Nomad, storage, consul, aws
description: Use Hashi-porx for a full-stack deployment of consul, nomad, vault, the Hashi UI, and Portworx.
weight: 3
series: px-install-on-nomad-with-others
noicon: true
hidden: true
---

{{<info>}}
This document presents a **non-Kubernetes** method of installing a Portworx cluster. Please refer to the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page if you want to install Portworx  on Kubernetes.
{{</info>}}

As a community resource, please refer to the [hashi-porx](https://github.com/portworx/terraporx/tree/master/hashi-porx/aws) repository for a full-stack deployment of consul, nomad, vault, the Hashi UI, and Portworx all deployed through Terraform on AWS.

When using the `hashi-porx` stack, the status for the Nomad and Consul clusters can be accessed through the GUI via the `nomad_url` output variable, which refers to port 3000 of the external load balancer.
