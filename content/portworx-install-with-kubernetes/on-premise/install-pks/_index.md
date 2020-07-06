---
title: PKS
logo: /logos/pks.png
weight: 2
description: Install, on-premise, PKS, Pivotal Container Service, kubernetes, k8s, air gapped
keywords: portworx, PKS, kubernetes
noicon: true
---

## PKS preparation

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

## Installing Portworx

For on-premise clusters, [PKS](https://pivotal.io/platform/pivotal-container-service) (Pivotal Container Service) supports VMware vSphere.

### Architecture

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-shared-arch.md" %}}

### ESXi datastore preparation

Create one or more shared datastore(s) or datastore cluster(s) which is dedicated for Portworx storage. Use a common prefix for the names of the datastores or datastore cluster(s). We will be giving this prefix during Portworx installation later in this guide.

<!--### Generating the Portworx specs -->

{{% content "shared/cloud-references-auto-disk-provisioning-vsphere-vsphere-install-common.md" %}}

{{% content "portworx-install-with-kubernetes/on-premise/install-pks/vsphere-pks-generate-spec-internal-kvdb.md" %}}

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}

## Wipe Portworx installation

Below are the steps to wipe your entire Portworx installation on PKS.

1. Run cluster-scoped wipe: ```curl -fsL https://install.portworx.com/px-wipe | bash -s -- -T pks```
2. Go to each virtual machine and delete the additional vmdks Portworx created in the shared datastore.


<!-- commented as it's not supported
If you have **local** datastores, proceed to [Portworx install on PKS on vSphere using local datastores](/portworx-install-with-kubernetes/on-premise/install-pks/install-pks-vsphere-local).
-->

{{<info>}}
**Install using bosh CFCR etcd release**:
As Portworx ships with its own internal key-value store, deploying an external etcd should not be needed on PKS. If you are still prefer using bosh to deploy an external etcd, refer to [Installing Etcd using CFCR etcd release](/portworx-install-with-kubernetes/on-premise/install-pks/install-cfcr-etcd-release) and return here once done.
{{</info>}}
