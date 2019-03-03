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

    If none of your cluster nodes have internet access, you will first need to copy over the images to one of the nodes of your 'air-gapped' (intranet) cluster. Below command uses ssh to stream the images directly to the node called _intranet-host_. Please change the hostname as per your environment.

    ```text
    docker save $PX_IMGS $PX_ENT | ssh intranet-host docker load
    ```

## Step 2: Loading Portworx images on your nodes

If you have nodes which have access to a private registry, follow [Step 2a: Push to local registry server, accessible by air-gapped nodes](#step-2a-push-to-local-registry-server-accessible-by-air-gapped-nodes).

Otherwise, follow [Step 2b: Push directly to nodes using tarball](#step-2b-push-directly-to-nodes-using-tarball).

### Step 2a: Push to local registry server, accessible by air-gapped nodes

1. Export your registry location:

    ```text
    export REGISTRY=myregistry.net:5443
    ```
{{<info>}} The registry location above can be a registry and it's port (e.g _myregistry.net:5443_) or it could include your own repository in the registry (e.g _myregistry.net:5443/px-images_).
{{</info>}}

2. Push it to the above registry.

    ```text
    # Trim trailing slashes:
    REGISTRY=${$(echo $REGISTRY | tr -s /)%/}
    # re-tag and push into custom/local registry defined previously
    # Check if using custom registry+repository (e.g. `REGISTRY=myregistry.net:5443/px-images`)
    # or just the registry (e.g. `REGISTRY=myregistry.net:5443`)
    echo $REGISTRY | grep -q /
    if [ $? -eq 0 ]; then
        # registry + repo are used -- we'll strip original image repositories
        for i in $PX_IMGS $PX_ENT; do tg="$REGISTRY/$(basename $i)" ; docker pull $i; docker tag $i $tg ; docker push $tg ; done
    else
        # only registry used -- we'll keep original image repositories
        for i in $PX_IMGS $PX_ENT; do tg="$REGISTRY/$i" ; docker pull $i; docker tag $i $tg ; docker push $tg ; done
    fi
    ```

Now that you have the images in your registry, continue with [Step 3: Installing Portworx](#step-3-installing-portworx).

Since you are using your own custom registry, ensure that you specify it in the spec generator in **Registry And Image Settings** -> **Custom Container Registry Location**.

### Step 2b: Push directly to nodes using tarball

Below steps save all Portworx images into a tarball after which they can be loaded onto nodes individually.

1. Save all Portworx images into a tarball called _px-offline.tar_.

    ```text
    docker save -o px-offline.tar $PX_IMGS $PX_ENT
    ```

2. Load images from tarball

    You can load all images from the tarball on a node using `docker load` command. Below command uses ssh on nodes _node1_, _node2_ and _node3_ to copy the tarball and load it. Change the node names as per your environment.

    ```text
    for no in node1 node2 node3; do
        cat px-offline.tar | ssh $no docker load
    done
    ```

    {{<info>}}When using this method, specifiy Image Pull Policy as **IfNotPresent** on the "Registry and Image Settings" page when generating the Portworx spec.{{</info>}}

## Step 3: Installing Portworx

Once you have loaded Portworx images into your registry or nodes, continue with standard installation steps.

{{<homelist series2="k8s-airgapped">}}
