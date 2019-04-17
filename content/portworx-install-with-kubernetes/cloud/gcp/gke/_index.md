---
title: GKE
weight: 1
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
description: Install Portworx with Google Kubernetes Engine (GKE).
noicon: true
series: px-k8s-gcp
---

This document shows how to install _Portworx_ with Google Kubernetes Engine (GKE).

### Prerequisites

{{% content "portworx-install-with-kubernetes/cloud/gcp/shared/prerequisites.md" %}}

## Create a GKE cluster


### Configure gcloud

If this is your first time running with Google Cloud, please follow the steps below to install the gcloud shell, configure your project and compute zone. If you already have gcloud set up, you can skip to the next section.

```text
export PROJECT_NAME=<PUT-YOUR-PROJECT-NAME-HERE>
```


```text
gcloud config set project $PROJECT_NAME
gcloud config set compute/region us-east1
gcloud config set compute/zone us-east1-b
sudo gcloud components update
```

### Create your GKE cluster using gcloud

You have 2 options for the type of cluster you create: Regional or Zonal. Check out [this link](https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters) to find out more about regional clusters.

#### Create a zonal cluster

To create a 3-node zonal cluster in us-east1-a with auto-scaling enabled, run:

```text
gcloud container clusters create px-demo \
    --zone us-east1-b \
    --disk-type=pd-ssd \
    --disk-size=50GB \
    --labels=portworx=gke \
    --machine-type=n1-highcpu-8 \
    --num-nodes=3 \
    --image-type ubuntu \
    --scopes compute-rw,storage-ro \
    --enable-autoscaling --max-nodes=6 --min-nodes=3
```

#### Create a regional cluster

If you want to create a 3-node regional in us-east1 cluster with auto-scaling enabled, type:

```text
gcloud container clusters create px-demo \
     --region us-east1 \
     --node-locations us-east1-b,us-east1-c,us-east1-d \
     --disk-type=pd-ssd \
     --disk-size=50GB \
     --labels=portworx=gke \
     --machine-type=n1-highcpu-8 \
     --num-nodes=3 \
     --image-type ubuntu \
     --scopes compute-rw,storage-ro \
     --enable-autoscaling --max-nodes=6 --min-nodes=3
```

### Set your default cluster

After the above command completes, let’s check that everything is properly set up and make this cluster the default cluster while using gcloud:

```text
gcloud config set container/cluster px-demo
gcloud container clusters get-credentials px-demo
```

Next, we need to open access to the Compute API. Run the following command:

```text
gcloud services enable compute.googleapis.com
```

### Provide permissions to Portworx

_Portworx_ requires a ClusterRoleBinding for your user to deploy the specs. You can do this using:

```text
kubectl create clusterrolebinding myname-cluster-admin-binding \
    --clusterrole=cluster-admin --user=`gcloud info --format='value(config.account)'`
```

## Install

{{% content "portworx-install-with-kubernetes/cloud/gcp/shared/install-gke.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
