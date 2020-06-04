---
title: PKS (cloud)
linkTitle: PKS
logo: /logos/pks.png
keywords: Install, PKS, Pivotal Container Service, Kubernetes, k8s, Bosh Director
description: How to install and manage PKS
weight: 4
noicon: true
---

## Step 1: PKS preparation

Before installing Portworx, let's ensure the PKS environment is prepared correctly.

### Enable privileged containers and kubectl exec

Ensure that following options are enabled on all plans on the PKS tile.

  * Enable Privileged Containers
  * Disable DenyEscalatingExec (This is useful to run kubectl exec to run pxctl commands)

### Enable zero downtime upgrades for Portworx PKS clusters

Use the following steps to add a runtime addon to the [Bosh Director](https://bosh.io/docs/bosh-components/#director) to stop the Portworx service.

{{<info>}}
**Why is this needed ?** When stopping and upgrading instances bosh attempts to unmount _/var/vcap/store_. Portworx has it's root filesystem for it's OCI container mounted on _/var/vcap/store/opt/pwx/oci_ and the runc container is running using it. So one needs to stop Portworx and unmount _/var/vcap/store/opt/pwx/oci_ in order to allow bosh to proceed with stopping the instances. The addon ensures this is done automatically and enables zero downtime upgrades.
{{</info>}}

Perform these steps on any machine where you have the bosh CLI.

1. Create and upload the release.

    Replace _director-environment_ below with the environment which points to the Bosh Director.
    ```text
    git clone https://github.com/portworx/portworx-stop-bosh-release.git
    cd portworx-stop-bosh-release
    mkdir src
    bosh create-release --final --version=1.0.0
    bosh -e director-environment upload-release
    ```

2. Add the addon to the Bosh Director.

    First let's fetch your current Bosh Director runtime config.
    ```text
    bosh -e director-environment runtime-config
    ```

    If this is empty, you can simply use the runtime config at [runtime-configs/director-runtime-config.yaml](https://raw.githubusercontent.com/portworx/portworx-stop-bosh-release/master/runtime-configs/director-runtime-config.yaml).

    If you already have an existing runtime config, add the release and addon in [runtime-configs/director-runtime-config.yaml](https://raw.githubusercontent.com/portworx/portworx-stop-bosh-release/master/runtime-configs/director-runtime-config.yaml) to your existing runtime config.


    Once we have the runtime config file prepared, let's update it in the Director.
    ```text
    bosh -e director-environment update-runtime-config runtime-configs/director-runtime-config.yaml
    ```

3. Apply the changes

    After the runtime config is updated, go to your Operations Manager Installation Dashboard and click "Apply Changes". This will ensure bosh will add the addon on all new vm instances.

    If you already have an existing Portworx cluster, you will need to recreate the VM instances using the bosh recreate command.

## Step 2: Install Etcd

Portworx uses a key-value store for it’s clustering metadata. There are couple of options here:

### 2a: Install etcd your own way

If you are planing to install Etcd your own way, you can skip this section and proceed to [Step 3: Installing Portworx](#step-3-installing-portworx).

### 2b: Install using bosh CFCR etcd release

Follow [Installing Etcd using CFCR etcd release](/portworx-install-with-kubernetes/on-premise/install-pks/install-cfcr-etcd-release) and return here once done.

After the above steps, you should have all the etcd certs in the *etcd-certs* directory. These need to put in a Kubernetes secret so that Portworx can consume it.

```text
kubectl -n kube-system create secret generic px-kvdb-auth --from-file=etcd-certs/
kubectl -n kube-system describe secret px-kvdb-auth
```

This should output the below and shows the etcd certs are present in the secret.
```
Name:         px-kvdb-auth
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
etcd-ca.crt:      1679 bytes
etcd.crt:  1680 bytes
etcd.key:  414  bytes
```

## Step 3: Installing Portworx

Portworx supports [PKS](https://pivotal.io/platform/pivotal-container-service) (Pivotal Container Service) on various platforms.

If running on **AWS**, continue at [Portworx install with AWS Auto Scaling Groups](/portworx-install-with-kubernetes/cloud/aws/aws-asg).

If running on **GCP**, continue at [Portworx install on Google Cloud Platform](/cloud-references/auto-disk-provisioning/gcp).

If running on **VMware vSphere**, continue at [Portworx install on PKS on vSphere](/portworx-install-with-kubernetes/on-premise/install-pks/#step-3-installing-portworx).
