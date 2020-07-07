---
title: "Wipe Portworx from an air-gapped cluster"
weight: 3
keywords: Uninstall, air gapped, wiper script, Kubernetes, k8s
meta-description: Steps to wipe Portworx in an airgapped cluster
description: Steps to wipe Portworx in an airgapped cluster
hidden: true
---


When wiping Portworx in Kubernetes, a number of docker images are fetched from registries on the internet. If your nodes don't have access to the public container registries on the internet, you can load these images onto your nodes yourself. Perform the steps below to wipe Portworx from an air-gapped cluster.

## Step 1: Download the wiper script

[Download the wiper script](https://install.portworx.com/{{% currentVersion %}}/px-wipe) and save it to any node which has kubectl access to your cluster.

Alternately, you can also use `curl`:

```text
curl -o px-wipe.sh -L https://install.portworx.com/{{% currentVersion %}}/px-wipe
```

## Step 2: Download the images that the wiper script will use

If you followed the [air-gapped install](/portworx-install-with-kubernetes/on-premise/airgapped/) instructions, you should already have all the necessary images available for your nodes.

If you did not, or require different versions of images uploaded, please follow one of the steps below:

- [Step 2a: Push to local registry server](#step-2a-push-to-local-registry-server-accessible-by-air-gapped-nodes): If you have access to a local registry server on an intranet, you can place the images that the wiper script will use there. 
- [Step 2b: Push directly to your nodes](#step-2b-push-directly-to-your-nodes): If you do not have access to a local registry server on an intranet, you must place the images directly on your nodes. 

### Step 2a: Push to local registry server, accessible by air-gapped nodes

```text
curl -fsSL https://install.portworx.com/{{% currentVersion %}}/air-gapped | sh -s -- \
    -E '*' -I portworx/talisman:1.1.0 -I portworx/px-node-wiper:2.5.0 pull push <YOUR_REGISTRY_LOCATION>
```

For example:

```text
curl -fsSL https://install.portworx.com/{{% currentVersion %}}/air-gapped | sh -s -- \
    -E '*' -I portworx/talisman:1.1.0 -I portworx/px-node-wiper:2.5.0 pull push myregistry.net:5443
```

### Step 2b: Push directly to your nodes

```text
curl -fsSL https://install.portworx.com/{{% currentVersion %}}/air-gapped | sh -s -- \
    -E '*' -I portworx/talisman:1.1.0 -I portworx/px-node-wiper:2.5.0 pull load node1 node22 node333
```

## Step 3: Run the wiper script

If you uploaded the container images to your local registry server, you will need to run the wiper script downloaded [earlier](#step-1-download-the-wiper-script) with your registry server image names:

```text
REGISTRY=myregistry.net:5443
bash px-wipe.sh -I $REGISTRY/portworx/talisman -wi $REGISTRY/portworx/px-node-wiper
```

Otherwise, if you uploaded container images directly to nodes, you can run the script without any arguments:

```text
bash px-wipe.sh
```
