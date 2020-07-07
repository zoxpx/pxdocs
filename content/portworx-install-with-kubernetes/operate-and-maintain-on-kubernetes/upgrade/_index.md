---
title: Upgrade Portworx on Kubernetes
linkTitle: Upgrade
weight: 2
hidesections: true
keywords: Upgrade, upgrading, OCI, talisman, Kubernetes, k8s
description: Steps on how to upgrade Portworx on Kubernetes
noicon: true
series: k8s-op-maintain
---

This guide describes the procedure to upgrade Portworx running as OCI container using [talisman](https://github.com/portworx/talisman).

## Upgrade Portworx

To upgrade to the **{{% currentVersion %}}** release, run the following command:

```text
curl -fsSL https://install.portworx.com/{{% currentVersion %}}/upgrade | bash -s
```

This runs a script that will start a Kubernetes Job to perform the following operations:

1. Updates RBAC objects that are being used by Portworx with the latest set of permissions that are required
2. Triggers RollingUpdate of the Portworx DaemonSet to the default stable image and monitors that for completion

If you see any issues, review the [Troubleshooting](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/upgrade/#troubleshooting) section on this page.

{{% content "shared/upgrade/upgrade-to-2-1-2.md" %}}

## Upgrade Stork

1.  On a machine that has kubectl access to your cluster, enter the following commands to download the latest Stork specs:

      ```text
      KBVER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
      curl -o stork.yaml -L "https://install.portworx.com/{{% currentVersion %}}?kbver=${KBVER}&comp=stork"
      ```


    If you are using your own private or custom registry for your container images, add `&reg=<your-registry-url>` to the URL. Example:

      ```text
      curl -o stork.yaml -L "https://install.portworx.com/{{% currentVersion %}}?kbver=1.17.5&comp=stork&reg=artifactory.company.org:6555"
      ```
2. Next, apply the spec with:

      ```text
      kubectl apply -f stork.yaml
      ```

## Upgrade Lighthouse

1. On a machine that has kubectl access to your cluster, enter the following commands to download the latest Lighthouse specs:

      ```text
      KBVER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
      curl -o lh.yaml -L "https://install.portworx.com/{{% currentVersion %}}?kbver=${KBVER}&comp=lighthouse"
      ```

    If you are using your own private or custom registry for your container images, add `&reg=<your-registry-url>` to the URL. Example:

      ```text
      KBVER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
      curl -o lh.yaml -L "https://install.portworx.com/{{% currentVersion %}}?kbver=${KBVER}&comp=lighthouse&reg=artifactory.company.org:6555"
      ```
2. Apply the spec by running:

      ```text
      kubectl apply -f lh.yaml
      ```

## Customize the upgrade process

#### Specify a different Portworx upgrade image

You can invoke the upgrade script with the _-t_ to override the default Portworx image. For example below command upgrades Portworx to _portworx/oci-monitor:2.5.0_ image.

```text
curl -fsSL https://install.portworx.com/{{% currentVersion %}}/upgrade | bash -s -- -t 2.5.0
```

## Airgapped clusters

### Step 1: Make container images available to your nodes

To make container images available to nodes that do not have access to the internet, please follow the [air-gapped install](/portworx-install-with-kubernetes/on-premise/airgapped) instructions first.

### Step 2: Run the upgrade

Once you've made the new container images available for your nodes, perform one of the following steps, depending on how you're storing your images:

- [Step a: Upgrade using local registry server](#step-2a-upgrade-using-local-registry-server): You can pre-load your private registry server with the required Portworx images and have Kubernetes and Portworx fetch the images from there rather than reaching out to the internet. 
<!-- this doesn't make sense, "using images directly ON your nodes?" or "pulling images directly TO your nodes"? -->
- [Step b: Upgrade using images directly to your nodes](#step-2b-upgrade-using-images-directly-to-your-nodes): You can load the images directly to your nodes and configure Kubernetes and Portworx to upgrade using those images. 

#### Step 2a: Upgrade using local registry server

If you uploaded the container images to your local registry server, you must run the upgrade script with your registry server image names:

```text
REGISTRY=myregistry.net:5443
curl -fsL https://install.portworx.com/{{% currentVersion %}}/upgrade | bash -s -- \
    -I $REGISTRY/portworx/talisman -i $REGISTRY/portworx/oci-monitor -t {{% currentVersion %}}
```

#### Step 2b: Upgrade using images directly on your nodes

Fetch and run the upgrade script with the following `curl` command to override the automatically defined image locations and instruct Kubernetes and Portworx to use the images located on your nodes during the upgrade:


```text
curl -fsL https://install.portworx.com/{{% currentVersion %}}/upgrade | bash -s -- -t {{% currentVersion %}}
```


## Troubleshooting

### The "field is immutable" error message

If the you see the following error when you upgrade Stork, it means that the `kubectl apply -f stork.yaml` command tries to update a label selector which is immutable:

```
The Deployment "stork-scheduler" is invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"component":"scheduler", "name":"stork-scheduler", "tier":"control-plane"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
```

To resolve this problem:

1. Delete the existing Stork deployment
2. Resume the [upgrade process](#upgrade-stork) by applying the new spec.

### Failed to apply spec due Forbidden: may not be used when type is ClusterIP

{{% content "shared/upgrade/upgrade-nodeport-issue.md" %}}

### Find out status of Portworx pods

To get more information about the status of Portworx DaemonSet across the nodes, run:

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
  * “minion3” has Portworx up for only 5 minutes (likely just finished upgrade and restarted Portworx)
* if we keep on monitoring, we will observe that the upgrade will not switch to the “next” node until STATUS is “Running” and the READY is 1/1 \(meaning, the “readynessProbe” reports Portworx service is operational\).

### Find out version of all nodes in the Portworx cluster

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
