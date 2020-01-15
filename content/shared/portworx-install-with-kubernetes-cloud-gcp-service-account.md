---
title: GCP service account
hidden: true
description: Setup a production ready Portworx cluster Google Cloud Platform (GCP).
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
---

Portworx requires access to the Google Cloud APIs to provision & manage disks. Make sure the worker service account created by `openshift-install` has the following roles: 

* Compute Admin
* Service Account User
* Kubernetes Engine Cluster Viewer

For more information about roles and permissions within GCP, see the [Granting, changing, and revoking access to resources](https://cloud.google.com/iam/docs/granting-changing-revoking-access) section of the GCP documentation.
