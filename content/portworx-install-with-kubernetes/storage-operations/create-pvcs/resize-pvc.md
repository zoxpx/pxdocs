---
title: Resize a Portworx PVC
weight: 4
linkTitle: Resize PVCs
keywords: resize, resizing a PVC, Kubernetes, k8s,
description: Step-by-step tutorial on how to resize a Portworx volume with Kubernetes
series: k8s-vol
---

This document describes how to dynamically resize a volume (PVC) using Kubernetes and Portworx.

## Pre-requisites

* Resize support for PVC is in Kubernetes 1.11 and above. If you have an older version, use [pxctl volume update](/reference/cli/updating-volumes) to update the volume size.
* The StorageClass must have `allowVolumeExpansion: true`.
* The PVC must be in use by a Pod.

## Example

{{% content "shared/portworx-install-with-kubernetes-resize-portworx-pvc.md" %}}
