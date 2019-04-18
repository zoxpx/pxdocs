---
title: Airgapped clusters
linkTitle: Airgapped clusters
weight: 99
logo: /logos/other.png
keywords: portworx, container, kubernetes
description: How to install Portworx in an airgapped Kubernetes cluster
noicon: true
---

When installing Portworx in Kubernetes, a number of docker images are fetched from registries on the internet.

This topic explains how to load these images onto your nodes when they don't have access to the standard registries on the internet.

## Step 1: Fetching Portworx images

1. Export your Kubernetes version

    ```text
    export KBVER=$(kubectl version --short | awk -Fv '/Server Version: / {print $3}')
    ```

    {{<info>}}If the current node doesn't have kubectl access, directly set the variable using `export KBVER=1.11.2`{{</info>}}

2. Pull all Portworx images

    ```text
    PX_IMGS="$(curl -fsSL "https://install.portworx.com/2.0/?kbver=$KBVER&type=oci&lh=true&ctl=true&stork=true" | awk '/image: /{print $2}' | sort -u)"
    PX_IMGS="$PX_IMGS portworx/talisman:latest portworx/px-node-wiper:latest"
    PX_ENT=$(echo "$PX_IMGS" | sed 's|^portworx/oci-monitor:|portworx/px-enterprise:|p;d')

    echo $PX_IMGS $PX_ENT | xargs -n1 docker pull
    ```
3. (Optional) Copy images to airgapped node

    If none of your cluster nodes have internet access, you will first need to copy over the images to one of the nodes using a tarball. Below command uses ssh to load the images on a node called _intranet-host_. Change the hostname as per your environment.

    ```text
    docker save $PX_IMGS $PX_ENT | ssh intranet-host docker load
    ```

## Step 2: Loading Portworx images on your nodes

If you have nodes which have access to a private registry, follow [Step 2a: Push to local registry server, accessible by air-gapped nodes](#step-2a-push-to-local-registry-server-accessible-by-air-gapped-nodes).

Otherwise, follow [Step 2b: Push directly to nodes using tarball](#step-2b-push-directly-to-nodes-using-tarball).

### Step 2a: Push to local registry server, accessible by air-gapped nodes

{{% content "portworx-install-with-kubernetes/on-premise/airgapped/shared/push-to-local-reg.md" %}}

Now that you have the images in your registry, continue with [Step 3: Installing Portworx](#step-3-installing-portworx).

Since you are using your own custom registry, ensure that you specify it in the spec generator in **Registry And Image Settings** -> **Custom Container Registry Location**.

### Step 2b: Push directly to nodes using tarball

{{% content "portworx-install-with-kubernetes/on-premise/airgapped/shared/push-to-nodes-tarball.md" %}}

{{<info>}}When using this method, specify Image Pull Policy as **IfNotPresent** on the "Registry and Image Settings" page when generating the Portworx spec.{{</info>}}

## Step 3: Installing Portworx

Once you have loaded Portworx images into your registry or nodes, continue with standard installation steps.

{{<homelist series2="k8s-airgapped">}}
