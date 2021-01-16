---
title: Install PX-Central on-premises
weight: 1
keywords: Install, PX-Central, On-prem, license, GUI, k8s
description: Learn how to install PX-Central On-prem.
noicon: true
hideSections: true
hidden: true
---

You can install PX-Central on any Kubernetes cluster using Helm charts as long as your cluster meets the prerequisites.

## Prerequisites

* Any Kubernetes cluster consisting of the following:

    * 3 worker nodes
    * 4 CPU cores
    * 8GB of memory
    * A minimum of 1 disk with 100 GB, ideally 2 disks on each node with at least 100 GB each
    * If your Kubernetes cluster does not have Portworx installed, verify that you have at least 50GB of available disk space on the `/root` file system.
    * If you're using an external OIDC provider, you must use certificates signed by a trusted certificate authority.
    * [Helm](https://helm.sh/docs/intro/install/)

* For internet-connected clusters, the following ports must be open:

    | Port | Component | Purpose | Incoming/Outgoing |
    | :---: |:---:|:---:|:---:|
    | 31234 | PX-Central | Access from outside | Incoming |
    | 31241 | PX-Central-Keycloak | Access user auth token | Incoming |
    | 31240 | PX-Central | Metrics store endpoint | Outgoing |
    | 7070 | License server | License validation | Outgoing |
* For GKE clusters, only Ubuntu OS is supported.

{{<info>}}
**NOTE:**
You can install PX-Central on a Kubernetes cluster that is already running Portworx, or on a fresh Kubernetes cluster that does not have Portworx installed.
{{</info>}}

## Prepare air-gapped environments

If your cluster is internet-connected, skip this section. If your cluster is air-gapped, you must pull the Portworx license server and related Docker images to either your Docker registry or directly onto your nodes.

1. Run the following command to create an environment variable called `kube_version` and assign your Kubernetes version to it:

    ```
    kube_version=`kubectl version --short | awk -Fv '/Server Version: / {print $3}'`
    ```

2. Pull the following required Docker images onto your air-gapped environment:

    * docker.io/portworx/px-backup:1.2.0
    * docker.io/portworx/pxcentral-onprem-api:1.2.0
    * docker.io/portworx/pxcentral-onprem-ui-backend:1.2.0
    * docker.io/portworx/pxcentral-onprem-ui-frontend:1.2.0
    * docker.io/portworx/pxcentral-onprem-ui-lhbackend:1.2.0
    * docker.io/bitnami/etcd:3.4.13-debian-10-r22
    * docker.io/portworx/pxcentral-onprem-post-setup:1.1.3
    * docker.io/bitnami/postgresql:11.7.0-debian-10-r9
    * docker.io/jboss/keycloak:9.0.2
    * docker.io/portworx/keycloak-login-theme:1.0.4
    * docker.io/library/busybox:1.31
    * docker.io/library/mysql:5.7.22

3. Pull the Portworx license server and associated images. How you do this depends on your air-gapped cluster configuration:

    * If you have a company-wide docker-registry server, pull the Portworx license server from Portworx:

        ```text
        sudo docker pull <required-docker-images>
        sudo docker tag <required-docker-images> <company-registry-hostname>:5000<path-to-required-docker-images>
        sudo docker push <company-registry-hostname>:5000<path-to-required-docker-images>
        ```

    * If you do not have a company-wide docker-registry server, pull the Portworx license server from portworx onto a computer that can access the internet and send it to your air-gapped cluster. The following example sends the docker image to the air-gapped cluster over ssh:

        ```text
        sudo docker pull <required-docker-images>
        sudo docker save <required-docker-images> | ssh root@<air-gapped-address> docker load
        ```

## Install PX-Central on-premises

1. If you're installing PX-Central alone -- without {{< pxEnterprise >}} -- skip this step. If you do want to install PX-Central with {{< pxEnterprise >}}, you must first [install Portworx](/portworx-install-with-kubernetes/), then create the following storage class on your Kubernetes cluster:

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
        name: portworx-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
    repl: "3"
    ```
2. Generate the install spec through the **PX-Central** [spec generator](https://central.portworx.com/specGen/wizard).

     If you're using Portworx for the PX-Central installation, select the **Use storage class** checkbox under the **Storage** section of the **Spec Details** tab, and enter the name of the storage class you created in the previous step.

    If your cluster is air-gapped, select the **Air Gapped** checkbox, and enter the following information:

      * **Custom Registry**: The hostname of your custom registry
      * **Image Repository**: The path to the required Docker images
      * **Image Pull Secret(s)**: A comma-separated list of your image pull secrets.

2. Using Helm, add the {{< pxEnterprise >}} repo to your cluster and update it:
    <!-- I may instead just push these two steps together and refer users to the spec generator -->

    ```text
    helm repo add portworx http://charts.portworx.io/ && helm repo update
    ```

3. Install PX-Central using either the `--set` flag or the `values.yml` file provided in the **Step 2** section of the **Complete** tab of the spec generator.


4. To monitor the status of the installation, enter the following `kubectl get` command:

    ```text
    kubectl get po --namespace px-backup -ljob-name=pxcentral-post-install-hook  -o wide | awk '{print $1, $3}' | grep -iv error
    ```

    <!-- Is this the right way to do it? Also, is this the correct command? -->

    {{<info>}}
**NOTE:**

* PX-Central is installed with PX-Backup.
* If you're using your Kubernetes master IP as the Keycloak endpoint, you must run the following command on all worker nodes:

    ```text
    sudo iptables -P FORWARD ACCEPT
    ```

    This enables port forwarding using `iptables`, making the `NodePort` service accessible through the master endpoint.
    {{</info>}}

## Configure external OIDC endpoints

 If you enabled an external OIDC during PX-Central installation, you must manually configure the redirect URI in your OIDC provider. Refer to the [Set up login redirects](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/set-up-login-redirects) article for instructions on how to do this.
