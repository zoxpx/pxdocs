---
title: Upgrade Portworx on Kubernetes using the Operator
linkTitle: Upgrade using the Operator
keywords: portworx, container, kubernetes, storage, k8s, upgrade
description: Find out how to upgrade Portworx using the Operator.
weight: 2
aliases:
  - /portworx-install-with-kubernetes/on-premise/openshift/operator/upgrade/
  - /portworx-install-with-kubernetes/openshift/operator/upgrade
---

{{<info>}}
**WARNING:** If you're upgrading OpenShift to 4.3, you must change Portworx before you can do so. See the [Preparing Portworx to upgrade to OpenShift 4.3](/portworx-install-with-kubernetes/openshift/operator/openshift-upgrade) page for details.
{{</info>}}

If you're using the Portworx Operator, you can upgrade or change your Portworx version at any time by modifying the `StorageCluster` spec.

## Prerequisites

* You must already be running Portworx through the Operator, this method will not work for other Portworx deployments

## Upgrade Portworx

1. Enter the `kubectl edit` command to modify your storage cluster:

      ```text
      kubectl edit -n kube-system <storagecluster_name>
      ```

2. Change the `spec.image` value to the version you want to update Portworx to:

      ```text
      apiVersion: core.libopenstorage.org/v1
      kind: StorageCluster
      metadata:
        name: portworx
        namespace: kube-system
      spec:
        image: portworx/oci-monitor:<your_desired_version>
      ```

## Upgrade Portworx components

In addition to managing a Portworx cluster, the Operator also manages the following other components in the Portworx platform:

- Stork
- Autopilot
- Lighthouse

For simplicity, the Portworx Operator handles the component upgrades without user intervention. When Portworx upgrades, the Operator upgrades the installed components to the recommended version as well.

The Portworx Operator refers to the [release manifest](https://install.portworx.com/version) to determine which recommended component version to install for a given Portworx version. This release manifest is regularly updated for
every Portworx release.

{{<info>}}
**NOTE:** Portworx does __not__ recommend you update individual component versions unless absolutely necessary.
{{</info>}}

### Force upgrade Stork

To override the operator selected Stork image, edit the `StorageCluster` object and
modify the `spec.stork.image` field, entering your desired Stork version

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  stork:
    enabled: true
    image: openstorage/stork:<your_desired_stork_version>
```

### Force upgrade Autopilot

To override the operator selected Autopilot image, edit the `StorageCluster` object and
modify the `spec.autopilot.image` field, entering your desired Autopilot version

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  autopilot:
    enabled: true
    image: portworx/autopilot:<your_desired_autopilot_version>
```

### Force upgrade Lighthouse

To override the operator selected Lighthouse image, edit the `StorageCluster` object and
modify the `spec.userInterface.image` field, entering your desired Lighthouse version

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  userInterface:
    enabled: true
    image: portworx/px-lighthouse:<your_desired_lighthouse_version>
```
