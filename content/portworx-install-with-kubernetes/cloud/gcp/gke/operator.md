---
title: Install Portworx on GCP GKE using the Operator
linkTitle: Operator
weight: 2
keywords: Install, GKE, Google Kubernetes Engine, k8s, gcloud
description: Install Portworx with Google Kubernetes Engine (GKE).
noicon: true
---

This document shows how to install Portworx with Google Kubernetes Engine (GKE).

## Prerequisites

{{% content "shared/portworx-install-with-kubernetes-cloud-gcp-prerequisites.md" %}}

## Create a GKE cluster

{{% content "shared/operator-daemonset-configure-gcloud.md" %}}

## Install

{{<info>}}
**NOTE:** Portworx gets its storage capacity from the block storage mounted in the nodes and aggregates the capacity across all the nodes. This way, it creates a **global storage pool**. In this example, Portworx uses Persistent Disks (PD) as that block storage, where Portworx adds PDs automatically as the Kubernetes scales-out and removes PDs as nodes exit the cluster or get replaced.
{{</info>}}

{{% content "shared/operator-install.md" %}}

{{% content "shared/portworx-install-with-kubernetes-shared-generate-the-spec-footer-operator.md" %}}

{{% content "shared/operator-apply-the-spec.md" %}}

{{% content "shared/operator-monitor.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}
