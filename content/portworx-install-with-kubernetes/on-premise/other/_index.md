---
title: All other on-premises Kubernetes clusters
linkTitle: All other
weight: 3
logo: /logos/other.png
keywords: Install, on-premise, kubernetes, k8s, air gapped
description: How to install Portworx with Kubernetes
noicon: true
series2: k8s-airgapped
---

You can deploy Portworx on your internet-capable Kubernetes cluster using either the Operator or using the DaemonSet.

The Portworx Operator provides you with a way to manage the complete Portworx deployment on Kubernetes. Previously in Kubernetes, Portworx was deployed as a DaemonSet. The Operator confers advantages over a DaemonSet-based installation, by deploying and managing the complete lifecycle of Portworx pods. 

In addition to deploying the Portworx pods, the Operator also deploys other components in the Portworx stack:

* Stork
* Autopilot
* Lighthouse
* CSI
* Monitoring

 The Operator introduces a CRD, called "StorageCluster", which specifies the configuration with which the Portworx cluster is deployed. You can use the [StorageCluster spec](/reference/crd/storage-cluster/) to enable and disable the components mentioned above in the StorageCluster object. The StorageCluster object is a Kubernetes representation of the Portworx cluster.