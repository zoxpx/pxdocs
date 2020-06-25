---
title: Install PX-Central on-premises
weight: 2
keywords: Install, PX-Central, On-prem, license, GUI, k8s
description: Learn how to install PX-Central On-prem.
noicon: true
series: k8s-op-maintain
---

## Prerequisites

* Any Kubernetes cluster consisting of the following:

    * 3 worker nodes
    * 50GB available `/root` disk size
    * 4 CPU cores
    * 8GB of memory
    * A minimum of 1 disk with 100 GB, ideally 2 disks on each node with at least 100 GB each
* For internet-connected clusters, the following ports must be open:

    | Port | Component | Purpose | Incoming/Outgoing |
    | :---: |:---:|:---:|:---:|
    | 31234 | PX-Central | Access from outside | Incoming |
    | 31241 | PX-Central-Keycloak | Access user auth token | Incoming | 
    | 31240 | PX-Central | Metrics store endpoint | Outgoing |
    | 7070 | License server | License validation | Outgoing |
* You must have [jq](https://stedolan.github.io/jq/) installed on the node where you will run the `install.sh` script
* For GKE clusters, only Ubuntu OS is supported.

{{<info>}}
**NOTE:** 

* You can install PX-Central on a Kubernetes cluster that are already running Portworx, or on a fresh Kubernetes cluster that does not have Portworx installed. 
* If you're using an external OIDC provider, you must use certificates signed by a trusted certificate authority.
{{</info>}}

## Prepare air-gapped environments

If your cluster is internet-connected, skip this section. If your cluster is air-gapped, you must pull the Portworx license server and related Docker images to either your docker registry, or your server.

1. Run the following command to create an environment variable called `kube_version` and assign your Kubernetes version to it:

    ```
    kube_version=`kubectl version --short | awk -Fv '/Server Version: / {print $3}'`
    ```

2. Pull the following required docker images onto your air-gapped environment:

    * portworx/pxcentral-onprem-ui-backend:1.1.1
    * portworx/pxcentral-onprem-ui-frontend:1.1.1
    * portworx/pxcentral-onprem-ui-lhbackend:1.1.1
    * portworx/pxcentral-onprem-els-ha-setup:1.0.1
    * portworx/pxcentral-onprem-post-setup:1.0.1
    * portworx/pxcentral-onprem-pre-setup:1.0.1
    * portworx/pxcentral-onprem-operator:1.0.3
    * portworx/pxcentral-onprem-api:1.0.3
    * portworx/px-els:1.0.0
    * portworx/px-backup:1.0.1
    * docker.io/bitnami/etcd:3.4.7-debian-10-r14
    * quay.io/coreos/etcd:latest
    * pwxbuild/pxc-macaddress-config:1.0.1
    * pwxbuild/px-forwarding-proxy:1.0.0
    * portworx/px-operator:1.3.1
    * portworx/px-dev:2.5.0
    * openstorage/stork:2.4.0
    * docker.io/bitnami/postgresql:11.7.0-debian-10-r9
    * busybox:1.31
    * jboss/keycloak:9.0.2
    * pwxbuild/keycloak-login-theme:1.0.0
    * quay.io/cortexproject/cortex:v0.4.0
    * cassandra:3.0
    * postgres:9.6
    * nginx:1.17.8
    * consul:0.7.1
    * memcached:1.4.25
    * pwxbuild/go-dnsmasq:release-1.0.7
    * quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1
    * quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.31.1
    * jettech/kube-webhook-certgen:v1.2.0
    * mysql:5.7.22
    * grafana/grafana:6.5.2
    * k8s.gcr.io/pause:3.1
    * portworx/px-node-wiper:2.1.4
    * portworx/oci-monitor:2.5.0
    * quay.io/coreos/configmap-reload:v0.0.1
    * quay.io/prometheus/prometheus:v2.7.1
    * quay.io/coreos/prometheus-config-reloader:v0.35.0
    * quay.io/coreos/prometheus-config-reloader:v0.34.0
    * quay.io/coreos/prometheus-operator:v0.35.0
    * quay.io/coreos/prometheus-operator:v0.34.0
    * gcr.io/google_containers/kube-scheduler-amd64:$kube_version
    * gcr.io/google_containers/kube-controller-manager-amd64:$kube_version

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

## Save your cloud credentials in a Kubernetes secret (Optional)

As part of the installation process, the spec generator asks you to input your cloud credentials. If you don't want to specify your cloud credentials in the spec generator, you can create a Kubernetes secret and point the spec generator to that Kubernetes secret:

Create a Kubnernetes secret, save the name and namespace in which it's located for use in the installation steps. The contents of the secret you create depend on the cloud you're using:

* **AWS**:

    ```text
    kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY --namespace $PXCNAMESPACE
    ```

* **Azure**:

    ```text
    kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET --from-literal=AZURE_CLIENT_ID=$AZURE_CLIENT_ID --from-literal=AZURE_TENANT_ID=$AZURE_TENANT_ID --namespace $PXCNAMESPACE
    ```

* **vSphere**:

    ```text
    kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=VSPHERE_USER=$VSPHERE_USER --from-literal=VSPHERE_PASSWORD=$VSPHERE_PASSWORD --namespace $PXCNAMESPACE
    ```


## Install PX-Central on-premises

1. To install PX-Central on-prem, generate the install script through the **PX-Backup using PX-Central** [spec generator](https://central.portworx.com/specGen/wizard). If you saved your cloud credentials as a Kubernetes secret ahead of time, enter the name and namespace of your secret.

2. Once you've generated the script, paste it into the command line of the Kubernetes master node in which you want to install PX-Backup and run it:

    ```text
    bash <(curl -s https://raw.githubusercontent.com/portworx/px-central-onprem/<version>/install.sh) --px-store --px-backup --admin-password 'examplePassword' --oidc --pxcentral-namespace portworx --px-license-server --license-password 'examplePassword' --px-backup-organization backup --cluster-name px-central --admin-email admin@portworx.com --admin-user admin
    ```

    {{<info>}}
**NOTE:**  

* PX-Central is installed with PX-Backup.
* If you're using your Kubernetes master IP as the Keycloak endpoint, you must run the following command on all worker nodes:

    ```text
    `sudo iptables -P FORWARD ACCEPT`
    ```

    This enables port forwarding using `iptables`, making the `NodePort` service accessible through the master endpoint.
    {{</info>}}

## Configure external OIDC endpoints

 If you enabled an external OIDC during PX-Central installation, you must manually configure the redirect URI in your OIDC provider. Refer to the [Set up login redirects](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/set-up-login-redirects) article for instructions on how to do this.
