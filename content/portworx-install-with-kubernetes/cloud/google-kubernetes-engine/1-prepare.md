---
title: 1. Prepare Your Platform
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
description: How to prepare a production ready Portworx cluster in a Google Kubernetes Engine (GKE).
weight: 1
---

### Create a GKE cluster {#create-a-gke-cluster}

Following points are important when creating your GKE cluster.

1. Portworx is supported on GKE cluster provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images). So it is important to specify the node image as **Ubuntu** when creating clusters.

2. To manage and auto provision GCP disks, Portworx needs access to the GCP Compute Engine API. For GKE 1.10 and above, Compute Engine API access is disabled by default. This can be enabled in the "Project Access" section when creating the GKE cluster. You can either allow full access to all Cloud APIs or set access for each API. When settting access for each API, make sure to select **Read Write** for the **Compute Engine** dropdown.

3. Portworx requires a ClusterRoleBinding for your user. Without this `kubectl apply ...` command fails with an error like ```clusterroles.rbac.authorization.k8s.io "portworx-pvc-controller-role" is forbidden```.

    Create a ClusterRoleBinding for your user using the following commands:
    ```text
    # get current google identity
    $ gcloud info | grep Account
    Account: [myname@example.org]

    # grant cluster-admin to your current identity
    $ kubectl create clusterrolebinding myname-cluster-admin-binding \
        --clusterrole=cluster-admin --user=myname@example.org
    Clusterrolebinding "myname-cluster-admin-binding" created
    ```
