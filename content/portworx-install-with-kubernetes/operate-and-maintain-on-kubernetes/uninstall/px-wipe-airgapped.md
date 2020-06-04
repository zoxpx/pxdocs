---
title: Wipe Portworx in an airgapped cluster
weight: 3
keywords: Uninstall, air gapped, wiper script, Kubernetes, k8s
meta-description: Steps to wipe Portworx in an airgapped cluster
description: Steps to wipe Portworx in an airgapped cluster
hidden: true
---


When wiping Portworx in Kubernetes, a number of docker images are fetched from registries on the internet.

This topic explains how to load these images onto your nodes when they don't have access to the standard registries on the internet.

## Step 1: Download the wiper script

Click [Download wiper script](https://install.portworx.com/{{% currentVersion %}}/px-wipe) and save it any node which has kubectl access to your cluster.

Alternately, you can also use `wget`.

```text
wget -O px-wipe.sh https://install.portworx.com/{{% currentVersion %}}/px-wipe
```

## Step 2: Download the images that the wiper script will use

First let's pull all the images required for the wipe process.

```text
PX_IMGS="$PX_IMGS portworx/talisman:1.1.0 portworx/px-node-wiper:2.5.0"
echo $PX_IMGS | xargs -n1 docker pull
```

## Step 3: Push to local registry server, accessible by air-gapped nodes

This steps assumes your cluster nodes have access to a custom/private registry.

{{% content "shared/portworx-install-with-kubernetes-on-premise-airgapped-push-to-local-reg.md" %}}

Now that you have the images in your registry, continue with [Step 4: Run the wiper script](#step-4-run-the-wiper-script).

## Step 4: Run the wiper script

First let's figure out the image names and tags for our private registry.

Below we are simply prefixing the actual image names with the custom/private registry.

{{<info>}}Below commands use the REGISTRY variable. Ensure it's still exported on the terminal you run the below commands by using `echo $REGISTRY`.{{</info>}}

```text
export WIPER_IMAGE=$REGISTRY/portworx/px-node-wiper
export TALISMAN_IMAGE=$REGISTRY/portworx/talisman
```

Now let's run the wiper script we downloaded previously from any node that has kubectl access.

```text
chmod +x px-wipe.sh
./px-wipe.sh -I $TALISMAN_IMAGE -wi $WIPER_IMAGE
```
