---
title: Upgrade Portworx using the Operator
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Find out how to upgrade Portworx on OpenShift using Operator.
weight: 3
---

If you're using the Portworx Operator, you can upgrade or change your Portworx version at any time by modifying the `StorageCluster` spec.

## Prerequisites

* You must already be running Portworx through the Operator, this method will not work for other Portworx deployments

## Upgrade Portworx

1. Enter the `oc edit` command to modify your storage cluster:

      ```text
      oc edit -n kube-system <storagecluster_name>
      ```

2. Change the `spec.image` value to the version you want to update Portworx to:

      ```text
      apiVersion: core.libopenstorage.org/v1alpha1
      kind: StorageCluster
      metadata:
        name: portworx
        namespace: kube-system
      spec:
        image: portworx/oci-monitor:<your_desired_version>
      ```

## Upgrade Portworx components

In addition to managing a Portworx cluster, the Operator also manages the following other components in the Portworx platform:

- Lighthouse
- Stork
- Autopilot

For simplicity, the Portworx Operator handles the component upgrades without user intervention. When Portworx upgrades, the Operator upgrades the installed components to the recommended version as well.

The Portworx Operator refers to the [release manifest](https://install.portworx.com/versions) to determine which recommended component version to install for a given Portworx version. This release manifest is regularly updated for
every Portworx release.

{{<info>}}
**NOTE:** Portworx does __not__ recommend you update individual component versions unless absolutely necessary.
{{</info>}}

### Force upgrade Lighthouse

By default, the Portworx Operator reverts back to the Lighthouse version that is intended to be used with your installed Portworx version.

To override the default behavior and change the Lighthouse image, modify the `StorageCluster` object:

* Edit the `spec.userInterface.image` field, entering your desired Lighthouse version
* Set the `spec.userInterface.lockImage` field to `true`, forcing Portworx to update Lighthouse to your desired version

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  userInterface:
    enabled: true
    lockImage: true
    image: portworx/px-lighthouse:<your_desired_lighthouse_version>
```

### Force upgrade Stork

By default, the Portworx Operator reverts back to the Stork version that is intended to be used with your installed Portworx version.

To override the default behavior and change the Stork image, modify the `StorageCluster` object:

* Edit the `spec.stork.image` field, entering your desired Stork version
* Set the `spec.stork.lockImage` field to `true`, forcing Portworx to update Stork to your desired version

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  stork:
    enabled: true
    lockImage: true
    image: openstorage/stork:<your_desired_stork_version>
```

### Force upgrade Autopilot

By default, the Portworx Operator reverts back to the Autopilot version that is intended to be used with your installed Portworx version.

To override the default behavior and change the Autopilot image, modify the `StorageCluster` object:

* Edit the `spec.userInterface.image` field, entering your desired Autopilot version
* Set the `spec.userInterface.lockImage` field to `true`, forcing Portworx to update Autopilot to your desired version

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  userInterface:
    enabled: true
    lockImage: true
    image: portworx/autopilot:<your_desired_autopilot_version>
```
