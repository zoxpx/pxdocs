---
title: Air-gapped clusters
linkTitle: Air-gapped clusters
weight: 99
logo: /logos/other.png
keywords: Install, on-premise, kubernetes, k8s, air gapped
description: How to install Portworx in an air-gapped Kubernetes cluster
noicon: true
---

This document walks you through the process of installing Portworx into an air-gapped environment. First, you must fetch the required Docker images from the public Internet registries. Then, you are required to load these images onto your nodes. Once you've loaded the Portworx images, you will continue with the standard installation procedure.

## Step 1: Fetch Portworx images

1. Export your Kubernetes version with:

    ```text
    export KBVER=$(kubectl version --short | awk -Fv '/Server Version: / {print $3}')
    ```

    If the current node doesn't have `kubectl` installed, set the `KBVER` variable manually by running `export KBVER=<YOUR_KUBERNETES_VERSION>`.

    For example, if your Kubernetes version is `1.11.2`, run the following command:

    ```text
    export KBVER=1.11.2
    ```

2. Pull the Portworx images by running:

    ```text
    PX_IMGS="$(curl -fsSL "https://install.portworx.com/{{% currentVersion %}}/?kbver=$KBVER&type=oci&lh=true&ctl=true&stork=true&csi=true" | awk '/image: /{print $2}' | sort -u)"
    PX_IMGS="$PX_IMGS portworx/talisman:1.1.0 portworx/px-node-wiper:2.5.0"
    PX_ENT=$(echo "$PX_IMGS" | sed 's|^portworx/oci-monitor:|portworx/px-enterprise:|p;d')

    echo $PX_IMGS $PX_ENT | xargs -n1 docker pull
    ```

3. (Optional) Copy the Portworx images to the airgapped node:

    ```text
    docker save $PX_IMGS $PX_ENT | ssh <intranet-host> docker load
    ```

    For `<intranet-host>`, use the address of your node.

{{<info>}}
Note that the above command uses `ssh` to load the images on a node called `intranet-host`. If your cluster nodes don't have Internet access, you first need to copy over the images to one of the nodes using a tarball.
{{</info>}}

## Step 2: Load Portworx images to your nodes

There are two ways in which you can load the Portworx images to your nodes:

- If your nodes have access to a private registry, follow [Step 2a: Push to a local registry server, accessible by air-gapped nodes](#step-2a-push-to-a-local-registry-server-accessible-by-the-air-gapped-nodes).

- Otherwise, follow [Step 2b: Push directly to nodes using tarball](#step-2b-push-directly-to-your-nodes-using-a-tarball).

### Step 2a: Push to a local registry server, accessible by the air-gapped nodes

{{<info>}}
For details about how you can use a private registry, see the  [Using a Private Registry](https://kubernetes.io/docs/concepts/containers/images/#using-a-private-registry) section of the Kubernetes documentation.
{{</info>}}

{{% content "shared/portworx-install-with-kubernetes-on-premise-airgapped-push-to-local-reg.md" %}}

{{<info>}}
**NOTE:** You must specify your custom registry in the **Customize** section of the <a href="https://central.portworx.com" target="tab">spec generator</a>:

![Screenshot showing the customize section](/img/spec-generator-customize-section.png)
{{</info>}}


Now that you have loaded the images into your registry, continue with [Step 3: Install Portworx](#step-3-install-portworx).


### Step 2b: Push directly to your nodes using a tarball

{{% content "shared/portworx-install-with-kubernetes-on-premise-airgapped-push-to-nodes-tarball.md" %}}

{{<info>}}
If you're using this method, specify `Image Pull Policy` as **IfNotPresent** on the "Registry and Image Settings" page when generating the Portworx spec.
{{</info>}}

## Step 3: Install Portworx

Once you have loaded the Portworx images into your registry or nodes, you're ready to create an install spec using the spec generator. Determine whether you need to specify the `PX_HTTP_PROXY` environment variable during installation:

### Step 3a: Specify the PX_HTTP_PROXY environment variable

SharedV4 volumes require that your host run dependent services. If your host does not already have dependent services installed, Portworx will attempt to install them automatically. However, installation may fail if the hosts are not configured properly. For example: if your host is air-gapped and does not have dependent packages on intranet-accessible package repositories, or doesn't have package management configured to use the HTTP proxy server.

If your air-gapped environment doesn't have a system-wide HTTP proxy, specify the  `PX_HTTP_PROXY=...` variable in the environment variables tab of the spec generator to define the HTTP proxy for Portworx installation, including the automated installation of NFS service on the host.

### Step 3b: Create an install spec
Using the Portworx [spec generator](https://central.portworx.com/specGen/home), create an install spec, making sure to enable sharedV4 support and specify the `PX_HTTP_PROXY` environment variable if you need to.

Refer to the following installation topics for more installation information:

{{<homelist series2="k8s-airgapped">}}
