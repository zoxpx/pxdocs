---
title: GKE
logo: /logos/gke.png
weight: 1
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
description: This page describes how to setup a production ready Portworx cluster in a Google Kubernetes Engine (GKE).
noicon: true
---

This topic explains how to install Portworx with Google Kubernetes Engine (GKE). Follow the steps in this topic in order.

## Prepare

#### Create a GKE cluster {#create-a-gke-cluster}

Following points are important when creating your GKE cluster.

1. Portworx is supported on GKE cluster provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images). So it is important to specify the node image as **Ubuntu** when creating clusters.

2. To manage and auto provision GCP disks, Portworx needs access to the GCP Compute Engine API. This can be enabled in the "Project Access" section when creating the GKE cluster. You can either allow full access to all Cloud APIs or set access for each API. When settting access for each API, make sure to select **Read Write** for the **Compute Engine** dropdown.

    You can do this using:
    ```text
    gcloud services enable compute.googleapis.com
    ```

3. Portworx requires a ClusterRoleBinding for your user to deploy the specs.

    You can do this using:
    ```text
    kubectl create clusterrolebinding myname-cluster-admin-binding \
        --clusterrole=cluster-admin --user=`gcloud info --format='value(config.account)'`
    ```

## Deploy

{{% content "portworx-install-with-kubernetes/shared/1-generate-the-spec-footer.md" %}}

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}
