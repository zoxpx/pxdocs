---
title: Upgrade on Kubernetes
linkTitle: Upgrade
weight: 2
hidesections: true
keywords: portworx, container, Kubernetes, upgrade, update, storage, Docker, k8s, flexvol, pv, persistent disk
description: Steps on how to upgrade Portworx on Kubernetes
noicon: true
series: k8s-op-maintain
---

This guide describes the procedure to upgrade Portworx running as OCI container using [talisman](https://github.com/portworx/talisman).

To upgrade to the latest stable **2.1** release, run the curl command:

```text
curl -fsL https://install.portworx.com/2.1/upgrade | bash -s
```

This runs a script that will start a Kubernetes Job to perform the following operations:

1. Updates RBAC objects that are being used by Portworx with the latest set of permissions that are required
2. Triggers RollingUpdate of the Portworx DaemonSet to the default stable image and monitors that for completion

## Customizing the upgrade process

#### Specify a different Portworx upgrade image

You can invoke the upgrade script with the _-t_ to override the default Portworx image. For example below command upgrades Portworx to _portworx/oci-monitor:2.0.3.4_ image.

```text
curl -fsL https://install.portworx.com/2.1/upgrade | bash -s -- -t 2.0.3.4
```

## Airgapped clusters

When upgrading Portworx in Kubernetes using the curl command in examples above, a number of docker images are fetched from container registries on the Internet (e.g. docker.io, gcr.io). If your nodes don't have access to these registries, you need to first pull the required images in your cluster and then provide the precise image names to the upgrade process.

The below sections outline the exact steps for this.

### Step 1: Pull the required images

If you want to upgrade to the latest 2.1 stable release, skip the below export. If you wish to upgrade to a specific 2.1 release, set the `PX_VER` variable as below to the desired version.

```text
# To determine the latest minor 2.1 release currently available, please use the curl-expression below
# Alternatively, you can specify the version yourself, e.g.: PX_VER=2.0.2.3
export PX_VER=$(curl -fs https://install.portworx.com/2.1/upgrade | awk -F'=' '/^OCI_MON_TAG=/{print $2}')
```

Now pull the required Portworx images.

```text
export PX_IMGS="portworx/oci-monitor:$PX_VER portworx/px-enterprise:$PX_VER portworx/talisman:latest"

echo $PX_IMGS | xargs -n1 docker pull
```

### Step 2: Loading Portworx images on your nodes

If you have nodes which have access to a private registry, follow [Step 2a: Push to local registry server, accessible by air-gapped nodes](#step-2a-push-to-local-registry-server-accessible-by-air-gapped-nodes).

Otherwise, follow [Step 2b: Push directly to nodes using tarball](#step-2b-push-directly-to-nodes-using-tarball).

#### Step 2a: Push to local registry server, accessible by air-gapped nodes

{{% content "portworx-install-with-kubernetes/on-premise/airgapped/shared/push-to-local-reg.md" %}}

Now that you have the images in your registry, continue with [Step 3: Start the upgrade](#step-3-start-the-upgrade).

#### Step 2b: Push directly to nodes using tarball

{{% content "portworx-install-with-kubernetes/on-premise/airgapped/shared/push-to-nodes-tarball.md" %}}

### Step 3: Start the upgrade

Run the below script to start the upgrade on your airgapped cluster.

```text

# Default image names
TALISMAN_IMAGE=portworx/talisman
OCIMON_IMAGE=portworx/oci-monitor

# Do we have container registry override?
if [ "x$REGISTRY" != x ]; then
   echo $REGISTRY | grep -q /
   if [ $? -eq 0 ]; then  # REGISTRY defines both registry and repository
      TALISMAN_IMAGE=$REGISTRY/talisman
      OCIMON_IMAGE=$REGISTRY/oci-monitor
   else                   # $REGISTRY contains only registry, we'll assume default repositories
      TALISMAN_IMAGE=$REGISTRY/portworx/talisman
      OCIMON_IMAGE=$REGISTRY/portworx/oci-monitor
   fi
fi

[[ -z "$PX_VER" ]] || ARG_PX_VER="-t $PX_VER"

curl -fsL https://install.portworx.com/2.1/upgrade | bash -s -- -I $TALISMAN_IMAGE -i $OCIMON_IMAGE $ARG_PX_VER
```

## Troubleshooting {#troubleshooting}

#### Find out status of Portworx pods {#find-out-status-of-portworx-pods}

To get more information about the status of Portworx daemonset across the nodes, run:

```text
kubectl get pods -o wide -n kube-system -l name=portworx
NAME             READY   STATUS              RESTARTS   AGE   IP              NODE
portworx-9njsl   1/1     Running             0          16d   192.168.56.73   minion4
portworx-fxjgw   1/1     Running             0          16d   192.168.56.74   minion5
portworx-fz2wf   1/1     Running             0          5m    192.168.56.72   minion3
portworx-x29h9   0/1     ContainerCreating   0          0s    192.168.56.71   minion2
```

As we can see in the example output above:

* looking at the STATUS and READY, we can tell that the rollout-upgrade is currently creating the container on the “minion2” node
* looking at AGE, we can tell that:
  * “minion4” and “minion5” have Portworx up for 16 days \(likely still on old version, and to be upgraded\), while the
  * “minion3” has Portworx up for only 5 minutes \(likely just finished upgrade and restarted Portworx\)
* if we keep on monitoring, we will observe that the upgrade will not switch to the “next” node until STATUS is “Running” and the READY is 1/1 \(meaning, the “readynessProbe” reports Portworx service is operational\).

#### Find out version of all nodes in Portworx cluster {#find-out-version-of-all-nodes-in-portworx-cluster}

One can run the following command to inspect the Portworx cluster:

```text
PX_POD=$(kubectl get pods -n kube-system -l name=portworx -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $PX_POD -n kube-system /opt/pwx/bin/pxctl cluster list
```

```output
[...]
Nodes in the cluster:
ID      DATA IP         CPU        MEM TOTAL  ...   VERSION             STATUS
minion5 192.168.56.74   1.530612   4.0 GB     ...   1.2.11.4-3598f81    Online
minion4 192.168.56.73   3.836317   4.0 GB     ...   1.2.11.4-3598f81    Online
minion3 192.168.56.72   3.324808   4.1 GB     ...   1.2.11.10-421c67f   Online
minion2 192.168.56.71   3.316327   4.1 GB     ...   1.2.11.10-421c67f   Online
```

* from the output above, we can confirm that the:
  * “minion4” and “minion5” are still on the old Portworx version \(1.2.11.4\), while
  * “minion3” and “minion2” have already been upgraded to the latest version \(in our case, v1.2.11.10\).
