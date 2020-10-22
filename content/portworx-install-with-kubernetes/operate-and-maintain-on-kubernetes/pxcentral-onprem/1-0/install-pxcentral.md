---
title: Install PX-Central on-premises
weight: 2
keywords: Install, PX-Central, On-prem, license, GUI, k8s
description: Learn how to install PX-Central On-prem.
noicon: true
series: k8s-op-maintain
hidden: true
---

## Prerequisites

A dedicated Kubernetes cluster consisting of the following:

* 3 worker nodes
* 50GB available `/root` disk size
* 4 CPU cores
* 8GB of memory
* A minimum of 1 disk with 100 GB, ideally 2 disks on each node with at least 100 GB each
* Kubernetes version 1.14.x, 1.15.x, or 1.16.x

For internet-connected clusters, the following ports must be open:

| Port | Component | Purpose | Incoming/Outgoing |
| :---: |:---:|:---:|:---:|
| 31234 | PX-Central | Access from outside | Incoming |
| 31241 | PX-Central-Keycloak | Access user auth token | Incoming |
| 7070 | License server | License validation | Outgoing |

{{<info>}}
**NOTE:** You must use a dedicated Kubernetes cluster with no existing Portworx installations.
{{</info>}}

## Prepare air-gapped environments

If your cluster is internet-connected, skip this section. If your cluster is air-gapped, you must pull the Portworx license server and related Docker images to either your docker registry, or your server.

Pull the following required docker images onto your air-gapped environment:

* portworx/pxcentral-onprem-ui-backend:1.1.0
* portworx/pxcentral-onprem-ui-frontend:1.1.0
* portworx/pxcentral-onprem-ui-lhbackend:1.1.0
* portworx/pxcentral-onprem-els-ha-setup:1.0.1
* portworx/pxcentral-onprem-post-setup:1.0.1
* portworx/pxcentral-onprem-pre-setup:1.0.1
* portworx/px-operator:1.3.0
* portworx/pxcentral-onprem-operator:1.0.1
* portworx/pxcentral-onprem-api:1.0.1
* pwxbuild/pxc-macaddress-config:1.0.1
* openstorage/stork:2.3.2
* docker.io/bitnami/postgresql:11.7.0-debian-10-r9
* busybox:1.31
* jboss/keycloak:9.0.2
* docker.io/bitnami/etcd:3.4.7-debian-10-r14

How you pull the Portworx license server and associated images depends on your air-gapped cluster configuration:

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

## Prepare cloud environments

If you're deploying PX-Central onto AWS, Azure, or GCP, you must create and apply an nginx ingress controller:

1. Download the nginx ingress controller spec:

    ```text
    curl -o nginx-ingress-controller.yaml 'https://raw.githubusercontent.com/portworx/px-central-onprem/1.0.1/nginx-ingress-controller.yaml'
    ```

2. Apply the spec:

    ```text
    kubectl apply -f nginx-ingress-controller.yaml
    ```

## Install PX-Central on-premises

Install PX-Central by downloading and running a script which deploys both Portworx and PX-Central:

1. Download the PX-Central install script and make it executable:

    ```text
    curl -o install.sh 'https://raw.githubusercontent.com/portworx/px-central-onprem/1.0.1/install.sh' && chmod +x install.sh
    ```

2. Run the script with any of [the options](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/1-0-3/install-script-reference/) required to configure PX-Central according to your needs; note that the `--license-password` option is required:

    * The following example deploys PX-Central without OIDC:

        ```text
        ./install.sh --license-password 'examplePassword'
        ```

    * The following example deploys PX-Central with OIDC:

        ```text
        ./install.sh --oidc-clientid test --oidc-secret abc0123d-9876-zyxw-m1n2-i1j2k345678l --oidc-endpoint 192.0.2.0:12345 --license-password 'examplePassword'
        ```

    * The following example deploys PX-Central on an air-gapped environment:

        ```text
        ./install.sh  --license-password 'examplePassword' --air-gapped --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
        ```

    * The following example deploys PX-Central on an air-gapped environment with OIDC:

        ```text
        ./install.sh  --license-password 'examplePassword' --oidc-clientid test --oidc-secret abc0123d-9876-zyxw-m1n2-i1j2k345678l  --oidc-endpoint 192.0.2.0:12345 --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
        ```

    The install process may take several minutes to complete.
