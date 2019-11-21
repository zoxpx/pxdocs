---
title: Install Portworx with Terraform
linkTitle: Install with Terraform
keywords: portworx, container, Nomad, storage, Terraform
description: Instructions for installing Portworx on Nomad with Terraform.
weight: 2
series: px-install-on-nomad-with-others
noicon: true
hidden: true
---

{{<info>}}
This document presents a **non-Kubernetes** method of installing a Portworx cluster. Please refer to the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page if you want to install Portworx on Kubernetes.
{{</info>}}

## Installing

To install with **Terraform**, please use the [Terraform Portworx Module](https://registry.terraform.io/modules/portworx/portworx-instance/)


## Upgrading Portworx

If you have installed Portworx with Terraform, _Portworx_ needs to be upgraded through the CLI on a node-by-node basis. Please see the [upgrade instructions](/install-with-other/operate-and-maintain)

## Scaling

A _Portworx_ cluster is uniquely defined by its `kvdb` and `clusterID` parameters. As long as these are consistent, a cluster can easily scale up in Terraform, by using the same `kvdb` and `clusterID`, and then increasing the instance `count`.
