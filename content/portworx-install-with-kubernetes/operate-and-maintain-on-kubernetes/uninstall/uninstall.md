---
title: Uninstall from Kubernetes cluster
weight: 2
keywords: Uninstall, air gapped, Kubernetes, k8s
meta-description: Steps to uninstall Portworx from a Kubernetes cluster
description: Steps to uninstall Portworx from the entire Kubernetes cluster
series: k8s-uninstall
linkTitle: Uninstall
---

When uninstalling Portworx from your cluster, you have 2 choices:

1. Stop Portworx and remove the Kubernetes specs and completely wipe the data. If this is what you want, continue to [Delete/Wipe Portworx](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/uninstall/#delete-wipe-portworx-cluster-configuration).
2. Stop Portworx and remove the Kubernetes specs without wiping the data. If this is what you want, continue to [Uninstall](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/uninstall/#uninstall).

## Delete/Wipe Portworx cluster configuration

{{<info>}}The commands used in this section are DISRUPTIVE and will lead to loss of all your data volumes. Proceed with CAUTION.{{</info>}}

{{<info>}}**Airgapped clusters**: If your nodes are airgapped and don’t have access to common internet registries, use [Wipe Portworx in an airgapped cluster](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/px-wipe-airgapped) instead.{{</info>}}

You can use the following command to wipe your entire Portworx cluster:
```text
curl -fsL https://install.portworx.com/px-wipe | bash
```

Above command will run a Kubernetes Job that will perform following operations:

* Detect the key value store that was being used for Portworx from the DaemonSet spec and wipe the Portworx cluster metadata from it.
* Remove Portworx systemd files from all nodes.
* Removes directories `/etc/pwx` and `/opt/pwx` from all nodes.
* Removes Portworx fingerprint data from all the storage devices used by Portworx. It also removes all the volume data from the storage devices.
* Delete all Portworx Kubernetes spec objects.

Before running the above wipe job, ensure that the Portworx spec is applied on your cluster.


{{<info>}}
If you are wiping off the cluster to re-use the nodes for installing a brand new Portworx cluster, make sure you use a different ClusterID in the DaemonSet spec file \(ie. `-c myUpdatedClusterID`\).
{{</info>}}

## Uninstall

{{<info>}}Uninstalling or deleting the Portworx daemonset only removes the Portworx containers from the nodes. As the configurations files which Portworx use are persisted on the nodes the storage devices and the data volumes are still intact. These Portworx volumes can be used again if the Portworx containers are started with the same configuration files.{{</info>}}

You can uninstall Portworx from the cluster using the following steps:

1. Remove the Portworx systemd service and terminate pods by labelling nodes as below. On each node, Portworx monitors this label and will start removing itself when the label is applied.
   ```text
   kubectl label nodes --all px/enabled=remove --overwrite
   ```

2. Monitor the Portworx pods until all of them are terminated
   ```text
   kubectl get pods -o wide -n kube-system -l name=portworx
   ```

3. Remove all Portworx Kubernetes Objects
   ```text
    VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
    kubectl delete -f "https://install.portworx.com?ctl=true&kbver=$VER"
   ```

4. Remove the ‘px/enabled’ label from your nodes
   ```text
   kubectl label nodes --all px/enabled-
   ```

{{<info>}}
During uninstall, the Portworx configuration files under `/etc/pwx/` directory are preserved, and will not be deleted.
{{</info>}}


## Related topics

* [Unlink a Portworx Essentials cluster](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/troubleshooting/unlink-a-portworx-essentials-cluster/)