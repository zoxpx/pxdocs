---
title: Shared content for GCP
hidden: true
description: Setup a production ready Portworx cluster Google Cloud Platform (GCP).
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
---

Before installing _Portworx-Enterprise_, make sure your environment meets the following requirements:

* **Image type**: _Portworx_ is supported on GKE clusters provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images). So it is important to specify the node image as **Ubuntu** when creating clusters.

* **Resource requirements**: _Portworx_ requires that each node in the Kubernetes cluster has at least 4 CPUs and 4 GB memory for _Portworx_. It is important to keep this in mind when selecting the machine types during cluster creation.

* **Owner and Compute Admin Roles**: These roles provides _Portworx_ access to the Google Cloud Storage APIs to provision persistent disks. Make sure the user creating the GKE cluster has these roles.