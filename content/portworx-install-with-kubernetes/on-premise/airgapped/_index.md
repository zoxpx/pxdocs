---
title: Air-gapped clusters
linkTitle: Air-gapped clusters
weight: 99
logo: /logos/other.png
keywords: Install, on-premise, kubernetes, k8s, air gapped
description: How to install Portworx in an air-gapped Kubernetes cluster
noicon: true
---

This document walks you through the process of installing Portworx into an air-gapped environment. First, you must fetch the required container images from the public container registries on the internet. Then, you can load these images directly onto your nodes or upload them into your private container registry. Once you've loaded the Portworx images, you will continue with the standard installation procedure.

## Step 1: Download the air-gapped bootstrap script

1. Export your Kubernetes version by entering the following command:

    ```text
    KBVER=$(kubectl version --short | awk -Fv '/Server Version: / {print $3}')
    ```

    {{<info>}}
If the current node doesn't have `kubectl` installed, you can set the `KBVER` variable manually by running `export KBVER=<YOUR_KUBERNETES_VERSION>`. For example, if your Kubernetes version is `1.17.5`, run the following command:

```text
KBVER=1.17.5
```
    {{</info>}}

2. Download the air-gapped-install bootstrap script by entering the following curl command:

    ```text
    curl -o px-ag-install.sh -L "https://install.portworx.com/{{% currentVersion %}}/air-gapped?kbver=$KBVER"
    ```

## Step 2: Pull the container images

Pull the container images by running the `px-ag-install` script with the `pull` option:

```text
sh px-ag-install.sh pull
```

## Step 3: Make container images available to your nodes

There are two ways in which you can make the Portworx container images available to your nodes:

- Follow [Step 3a](#step-3a-push-to-a-local-registry-server-accessible-by-the-air-gapped-nodes) if your company uses private container registry
- Otherwise, follow [Step 3b](#step-3b-push-directly-to-your-nodes) to push directly to your nodes

### Step 3a: Push to a local registry server, accessible by the air-gapped nodes

{{<info>}}
**NOTE:** For details about how you can use a private registry, see the  [Using a Private Registry](https://kubernetes.io/docs/concepts/containers/images/#using-a-private-registry) section of the Kubernetes documentation.
{{</info>}}

<!-- 
* If you use this method, you must specify your custom registry in the **Customize** section of the <a href="https://central.portworx.com" target="tab">spec generator when you install Portworx</a>:

    ![Screenshot showing the customize section](/img/spec-generator-customize-section.png)
-->

1. Push the images to the registry by running the `px-ag-install` script with the `push` option and your registry location:

    ```text
    sh px-ag-install.sh push <YOUR_REGISTRY_LOCATION>
    ```

    For example:

    ```text
    sh px-ag-install.sh push myregistry.net:5443
    ```
    
    alternatively you can put all images in the same repository:
    
    ```text
    sh px-ag-install.sh push myregistry.net:5443/px-images
    ```

2. Once you've loaded the images into your registry, continue with [Step 4: Install Portworx](#step-4-install-portworx). When you install Portworx, specify your custom registry in the **Customize** section of the <a href="https://central.portworx.com" target="tab">spec generator</a>:

    ![Screenshot showing the customize section](/img/spec-generator-customize-section.png)

### Step 3b: Push directly to your nodes

Load container images onto your nodes individually by running the `px-ag-install` script with the `load` option and your intranet host locations:

```text
sh px-ag-install.sh load <intranet-host> [<host2> <host3>...]
```

For `<intranet-host>`, use the hostname or IP-address of your node.

{{<info>}}
**NOTE:** 

* The command above uses `ssh` to load the images on the nodes on intranet. You can customize or replace
the `ssh` command with the `-e command` switch. For example, `px-ag-install.sh -e "sshpass -p 5ecr3t ssh -l root"` uses the [sshpass(1)](https://linux.die.net/man/1/sshpass) command to automatically pass root's password when logging into the intranet host.
* If you're using this method, you can specify `Image Pull Policy` as **IfNotPresent** or **Never** on the "Registry and Image Settings" page when generating the Portworx spec.
{{</info>}}

## Step 4: Install Portworx

Once you've loaded the container images into your registry or nodes, continue with the standard installation procedure:

{{<homelist series2="k8s-airgapped">}}

## Air-gapped install bootstrap script reference

```text
./px-ag-install.sh [image-commands] [options] '[arguments...]'
```

{{<info>}}
**NOTE:** The script name `px-ag-install.sh` reflects the default name specified in the installation instructions, but can be whatever you named the script file when you downloaded it.
{{</info>}}

### Image commands

|**Command**|**Description**|**Required?**|
|----|----|----|
| `pull` | Pulls the Portworx container images locally | |
| `push <registry[/repo]>` | Pushes the Portworx images into remote container registry server | |
| `load node1 [node2 [...]]` | Loads the images tarball to remote nodes  (note: ssh-access required) | |

### Options

|**Option**|**Description**|**Required?**|
|----|----|----|
| `--help` | Displays help output | |
| `-I`, `--include <image>` | Specify additional images to include | |
| `-E`, `--exclude <glob>` | Specify images to EXCLUDE  (e.g. -E '*csi*') | |
| `-n`, `--dry-run` | Show commands instead of running | |
| `-V`, `--version` | Print version of the script | |
| `-v` | Verbose output | |

### Load-specific options

|**Option**|**Description**|**Required?**|
|----|----|----|
| `-e`, `--rsh <command>`       | specify the remote shell to use  (default ssh) |
| `-L`, `--load-cmd <command>`  | specify the remote container-load command to use  (default auto) |
| `-t <prefix>`              | specify temporary tarball filename  (default px-agtmp.tar) |
| `--pks`                    | assume PKS environment; transfer images using 'bosh' command | 
    
### Examples

* Pull images from default container registries, push them to custom registry server (default repositories)

    ```text
    px-ag-install.sh pull push your-registry.company.com:5000
    ```

* Pull images from default container registries, push them to custom registry server and portworx repository

    ```text
    px-ag-install.sh pull
    px-ag-install.sh push your-registry.company.com:5000/portworx
    ```

* Push images to password-protected remote registry, then import docker/podman configuration as kuberentes secret

    ```text
    docker login your-registry.company.com:5000
    px-ag-install.sh pull
    px-ag-install.sh push your-registry.company.com:5000/portworx
    px-ag-install.sh import-secrets
    ```

* Pull images, then load to given nodes using ssh

    ```text
    px-ag-install.sh pull
    px-ag-install.sh load node1 node2 node33 node444
    ```

* Pull images, then load to given nodes using ssh and root-account

    ```text
    px-ag-install.sh -e "ssh -l root" pull load node1 node2 node33 node444
    ```

* Load images to given nodes using ssh and password '5ecr3t'

    ```text
    px-ag-install.sh -e "sshpass -p 5ecr3t ssh" load node1 node2 node33 node444
    ```

* Pull ONLY busybox image, load it to given nodes

    ```text
    px-ag-install.sh -E '*' -I docker.io/busybox:latest pull load node1 node2 node33 node444
    ```
