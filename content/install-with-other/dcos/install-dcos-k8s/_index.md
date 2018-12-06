---
title: Run Portworx with Kubernetes on Mesosphere DC/OS
description: Find out how to deploy Portworx with Kubernetes on DC/OS.
keywords: portworx, PX-Developer, container, Mesos, Mesosphere, storage, kubernetes, DCOS, DC/OS
linkTitle: Install on Kubernetes on DC/OS
weight: 2
noicon: true
---

{{<info>}}
**Note:**<br/> Kubernetes on DC/OS with Portworx is only supported from PX version 1.4 onwards
{{</info>}}

Please make sure you have installed [Portworx on DC/OS](/install-with-other/dcos/install) before proceeding further.

The latest framework starts Portworx with scheduler set to mesos (`-x mesos` option) to
allow Portworx to mount volumes for Kubernetes pods. If you are using an older
version of the framework please update `/etc/pwx/config.json` to set `scheduler`
to `mesos`.

## Install dependencies

When using Kubernetes on DC/OS you will be able to use Portworx from your DC/OS
cluster. You only need to create a Kubernetes Service and proxy pods for Portworx to allow the
in-tree Kubernetes volume plugin to dynamically create and use Portworx volumes. This will also install [Stork](/portworx-install-with-kubernetes/storage-operations/stork).

You can create the Service by running the following command:
```text
version=$(kubectl version --short | awk -Fv '/Server Version: / {print $3}')
kubectl apply -f "https://install.portworx.com?kbver=${version}&dcos=true&stork=true"
```

## Provisioning volumes

After the above spec has been applied, you can create volumes and snapshots
using Kubernetes.
Please use the following guides:

* [Dynamic Provisioning](/portworx-install-with-kubernetes/storage-operations/create-pvcs/dynamic-provisioning)
* [Using Pre-provisioned volumes](/portworx-install-with-kubernetes/storage-operations/create-pvcs/using-preprovisioned-volumes)
* [Creating and using snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots)
* [Volume encryption](/reference/cli/encrypted-volumes)
