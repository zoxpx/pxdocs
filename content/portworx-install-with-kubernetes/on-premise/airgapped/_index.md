---
title: Air-gapped clusters
linkTitle: Air-gapped clusters
weight: 99
logo: /logos/other.png
keywords: Install, on-premise, kubernetes, k8s, air gapped
description: How to install Portworx in an air-gapped Kubernetes cluster
noicon: true
---

During installation, Portworx fetches required images and packages from the internet. If you're installing Portworx onto an air-gapped cluster, you'll need to perform extra steps to make these resources available.

To fetch required container images, you can download them through a bootstrap script and upload them to either an internal container repository or directly to your cluster nodes.

To fetch required services, such as the NFS service used with the sharedv4 feature, you can do one of the following:

* Download and run a package repository container which contains the needed packages
* Specify an HTTP proxy
* Disable sharedv4 support, removing the service dependency entirely
* Preinstall and maintain the required services manually

The steps in this document walk you through the process of installing Portworx and its required packages and images into an air-gapped environment. Once you've loaded the Portworx images and, if necessary, installed the packages, you will continue with the spec-based installation procedure.

## Install images

### Step 1: Export variables

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

2. Export the Portworx version you want to install

    ```text
    PXVER=2.6.0
    ```

### Step 2: Copy the Portworx version manifest

{{<info>}}
Skip these steps if you are not using the Portworx Operator.
{{</info>}}

1. Download the version manifest

    ```text
    wget -O versions https://install.portworx.com/$PXVER/version
    ```

2. Store the version manifest

    Create a ConfigMap from the downloaded version manifest. The ConfigMap must be created in the same namespace as your `StorageCluster` object.

    ```text
    kubectl -n <cluster-namespace> create configmap px-versions --from-file=versions
    ```

### Step 3: Download the air-gapped bootstrap script

Download the air-gapped-install bootstrap script by entering the following curl command:

```text
curl -o px-ag-install.sh -L "https://install.portworx.com/$PXVER/air-gapped?kbver=$KBVER"
```

### Step 4: Pull the container images

Pull the container images by running the `px-ag-install` script with the `pull` option:

```text
sh px-ag-install.sh pull
```

### Step 5: Make container images available to your nodes

There are two ways in which you can make the Portworx container images available to your nodes:

- Follow [Step 5a](#step-5a-push-to-a-local-registry-server-accessible-by-the-air-gapped-nodes) if your company uses a private container registry
- Otherwise, follow [Step 5b](#step-5b-push-directly-to-your-nodes) to push directly to your nodes

#### Step 5a: Push to a local registry server, accessible by the air-gapped nodes

{{<info>}}
**NOTE:** For details about how you can use a private registry, see the  [Using a Private Registry](https://kubernetes.io/docs/concepts/containers/images/#using-a-private-registry) section of the Kubernetes documentation.
{{</info>}}

1. Push the images to the registry by running the `px-ag-install` script with the `push` option and your registry location:

    ```text
    sh px-ag-install.sh push <YOUR_REGISTRY_LOCATION>
    ```

    For example:

    ```text
    sh px-ag-install.sh push myregistry.net:5443
    ```

    alternatively, you can put all images in the same repository:

    ```text
    sh px-ag-install.sh push myregistry.net:5443/px-images
    ```

2. When you install Portworx, specify your custom registry in the **Customize** section of the <a href="https://central.portworx.com" target="tab">spec generator</a>:

    ![Screenshot showing the customize section](/img/spec-generator-customize-section.png)

#### Step 5b: Push directly to your nodes

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


## Install NFS packages

Your host systems require the NFS service in order for Portworx to use the sharedv4 feature. Depending on your needs, you can manage this requirement in one of the following ways:

* If your host-systems can install NFS packages, no further actions are required. Portworx will automatically install the NFS packages on the host system.
* If you have an HTTP proxy available:
  * you can configure your host to use the HTTP proxy system-wide, or configure the package management to use the HTTP proxy.
  * Alternatively, you can pass the HTTP proxy to Portworx via the `PX_HTTP_PROXY` environment variable when generating an installation spec.
* If you don't need sharedv4 support, disable it by providing the `-disable-sharedv4` parameter to Portworx during installation.

Install the NFS packages either manually or using a package repository container that Portworx provides.

{{<info>}}
**NOTE:**
If you plan on installing the NFS packages manually, do so now:

| Linux distribution       | Install command                                               |
|:-------------------------|:--------------------------------------------------------------|
| RedHat, Fedora, AmazonV2 | yum install -y nfs-utils rpcbind                              |
| OpenSuSE, SLES           | zypper install -y nfs-utils rpcbind nfs-kernel-server         |
| Ubuntu, Debian           | apt-get install -yq dbus nfs-common rpcbind nfs-kernel-server |
| CoreOS, Flatcar          | none  (packages already pre-installed)                        |

{{</info>}}

### Install NFS packages using the Portworx package repository

If you're installing NFS packages manually, disabling sharedv4 support, or using HTTP proxy, skip this step.

 To make NFS packages installations easier on air-gapped environments, Portworx, Inc. provides an all-in-one package repository, delivered as a docker container. Currently, the container includes package repositories for the following Linux distributions:

* CentOS 7 and 8,
* RedHat Enterprise Linux 7 and 8,
* Ubuntu 16.04 (xenial), 18.04 (bionic), 20.04 (focal) LTS, and
* Debian 8 (jessie), 9 (stretch), 10 (buster)

1. Deploy the package repository either as a standalone service in Docker, or onto your Kubernetes cluster:

    * Start the repository container as a standalone service in Docker by entering the following `docker run` command:

        ```text
        docker run -p 8080:8080 docker.io/portworx/px-repo:1.0.0
        ```

    * Deploy the repository container into your Kubernetes cluster by entering the following `kubectl` commands:

        ```text
        kubectl create deployment px-repo --image=docker.io/portworx/px-repo:1.0.0
        kubectl get pods -l app=px-repo -o wide
        # expose px-repo deployment, to enable access to host-systems
        kubectl expose deployment px-repo --name=px-repo-service --type=LoadBalancer --port 80 --target-port 8080
        kubectl get service px-repo-service
        ```

2. Using a browser within your air-gapped environment, navigate to the service's URL (e.g. `http://my-package-repo-host:8080`), and follow the instructions provided by the container to configure your hosts to use the package repository service, and install missing NFS packages:

    ![screen capture of the service URL steps](/img/package-repo-screen.png)

## Install Portworx

In this section, you'll create an install spec using the spec generator. By now, you should have completed the following tasks from the previous sections:

* Loaded the Portworx images into your registry or nodes.
* If you chose to, installed the packages either manually or using the package repository.

### Manage NFS requirements

 If you installed your NFS packages already, skip this step. If you intend to use HTTP proxy to install packages or disable sharedv4 support, specify one these options when you create the install spec:

#### Specify the PX_HTTP_PROXY environment variable

Specify the `PX_HTTP_PROXY` variable in the environment variables tab of the spec generator to define the HTTP proxy for the Portworx installation, including the automated installation of the NFS packages and kernel modules on the host:

![screen capture of PX_HTTP_PROXY on the spec generator](/img/spec-gen-proxy-env-var.png)

#### Disable sharedv4 support

Append the `&misc=-disable-sharedv4` parameter to the end of the URL created by the spec generator. For example, the following output `kubectl` command:

```
kubectl apply -f 'https://install.portworx.com/2.5?mc=false&kbver=1.17.3&b=true&c=px-cluster-0f123456-a12b-345c-678d-e90f1ab234c2&stork=true&st=k8s'
```

becomes:

```
kubectl apply -f 'https://install.portworx.com/2.5?mc=false&kbver=1.17.3&b=true&c=px-cluster-0f123456-a12b-345c-678d-e90f1ab234c22&stork=true&st=k8s&misc=-disable-sharedv4'
```

### Create an install spec

Using the Portworx [spec generator](https://central.portworx.com/specGen/home), create an install spec, making sure to enable sharedV4 support and specify the `PX_HTTP_PROXY` environment variable if you need to.

Refer to the following installation topics for more installation information:

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
