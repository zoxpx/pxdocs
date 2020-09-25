---
title: Install Portworx on GCP GKE using the DaemonSet
linkTitle: DaemonSet
weight: 3
keywords: Install, GKE, Google Kubernetes Engine, k8s, gcloud
description: Install Portworx with Google Kubernetes Engine (GKE).
noicon: true
---

This document shows how to install Portworx with Google Kubernetes Engine (GKE).

### Prerequisites

{{% content "shared/portworx-install-with-kubernetes-cloud-gcp-prerequisites.md" %}}

## Create a GKE cluster

{{% content "shared/operator-daemonset-configure-gcloud.md" %}}

## Install

{{% content "shared/portworx-install-with-kubernetes-cloud-gcp-install-gke.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}
