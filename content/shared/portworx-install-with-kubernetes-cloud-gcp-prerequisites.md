---
title: Shared content for GCP
hidden: true
description: Setup a production ready Portworx cluster Google Cloud Platform (GCP).
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
---

Before installing {{< pxEnterprise >}}, make sure your environment meets the following requirements:

* **Image type**: Only GKE clusters provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images) support Portworx. You must specify the **Ubuntu** node image when you create clusters.

* **Resource requirements**: Portworx requires that each node in the Kubernetes cluster has at least 4 CPUs and 4 GB memory for Portworx. It is important to keep this in mind when selecting the machine types during cluster creation.

* **Permissions**: Portworx requires access to the Google Cloud APIs to provision & manage disks. Make sure the user/service account creating the GKE cluster has the following roles:

    * Compute Admin
    * Service Account User
    * Kubernetes Engine Cluster Viewer

