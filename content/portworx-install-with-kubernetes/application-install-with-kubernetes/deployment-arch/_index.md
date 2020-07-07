---
title: Deployment Architectures for Kubernetes-Based Stateful Applications
linkTitle: Deployment architectures
description: Understand various deployment architectures for Kubernetes-Based Stateful Applications
keywords: Portworx, stateful applications, Kubernetes, k8s, deployment, architecture, HA, high-availability, DR, disaster recovery
weight: 1
hideSections: true
---

Organizations leveraging Portworx have discovered how simple, reliable and secure it is to run Kubernetes-based stateful applications in production. Underneath this simplicity, however, there is a great degree of flexibility in how Portworx can be deployed. These deployment options, or architectures, vary along two primary dimensions:

1. The degree to which they address application requirements around performance, elasticity, disaster recovery, and high availability
2. Their ability to operate under different infrastructure constraints such as the number of data centers and network latency.

This section outlines the following architectures:

## Single data center/multiple-AZ Portworx deployment options

{{<widelink url="/portworx-install-with-kubernetes/application-install-with-kubernetes/deployment-arch/single-dc#option-1-dedicated-portworx-storage-cluster" >}}Option 1- Dedicated Portworx storage cluster
{{</widelink>}}

<br>

{{<widelink url="/portworx-install-with-kubernetes/application-install-with-kubernetes/deployment-arch/single-dc#option-2-hyperconverged-portworx-storage-cluster" >}}Option 2- Hyperconverged Portworx storage cluster
{{</widelink>}}

## DR and multi-site HA architectures

{{<widelink url="/portworx-install-with-kubernetes/application-install-with-kubernetes/deployment-arch/dr-and-multi-site#option-1-synchronous-dr-over-a-man-using-multiple-kubernetes-clusters-with-a-single-portworx-stretch-cluster" >}}Option 1- Synchronous DR over a MAN using multiple Kubernetes clusters with a single Portworx stretch cluster
{{</widelink>}}

<br>

{{<widelink url="/portworx-install-with-kubernetes/application-install-with-kubernetes/deployment-arch/dr-and-multi-site#option-2-asynchronous-dr-over-a-wan-using-multiple-kubernetes-clusters-with-multiple-portworx-clusters" >}}Option 2- Asynchronous DR over a WAN using multiple Kubernetes clusters with multiple Portworx clusters
{{</widelink>}}

<br>

{{<widelink url="/portworx-install-with-kubernetes/application-install-with-kubernetes/deployment-arch/dr-and-multi-site#option-3-multi-site-data-center-stretch-cluster-for-ha" >}}Option 3- Multi-site data center stretch cluster for HA
{{</widelink>}}

<br>

{{<info>}}
Some of these deployment architectures are designed to be used together to solve multiple needs at once. You can pick one of the single data center Portworx deployment options and one of the disaster recovery (DR) and multi-site high availability (HA) architectures based on your requirements. For example, organizations can use the “synchronous Portworx-DR” architecture along with the “hyperconverged” architecture to achieve DR for high-performance applications.
{{</info>}}
