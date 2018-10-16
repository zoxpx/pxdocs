---
title: Dynamic Provisioning on Google Kubernetes Engine (GKE)
weight: 1
linkTitle: Google Kubernetes Engine (GKE)
---

The steps below will help you enable dynamic provisioning of Portworx volumes in your Google Kurbenetes Engine (GKE) cluster.

## Prerequisites

**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd).

## Create a GKE cluster

Following points are important when creating your GKE cluster.

1. Portworx is supported on GKE cluster provisioned on [Ubuntu Node Images](https://cloud.google.com/kubernetes-engine/docs/node-images). So it is important to specify the node image as **Ubuntu** when creating clusters.

2. To manage and auto provision GCP disks, Portworx needs access to the GCP Compute Engine API. For GKE 1.10 and above, Compute Engine API access is disabled by default. This can be enabled in the "Project Access" section when creating the GKE cluster. You can either allow full access to all Cloud APIs or set access for each API. When settting access for each API, make sure to select **Read Write** for the **Compute Engine** dropdown.

3. Portworx requires a ClusterRoleBinding for your user. Without this `kubectl apply ...` command fails with an error like ```clusterroles.rbac.authorization.k8s.io "portworx-pvc-controller-role" is forbidden```.

    Create a ClusterRoleBinding for your user using the following commands:
    ```
    # get current google identity
    $ gcloud info | grep Account
    Account: [myname@example.org]

    # grant cluster-admin to your current identity
    $ kubectl create clusterrolebinding myname-cluster-admin-binding \
        --clusterrole=cluster-admin --user=myname@example.org
    Clusterrolebinding "myname-cluster-admin-binding" created
    ```

More information about creating GKE clusters can be found [here](https://cloud.google.com/kubernetes-engine/docs/clusters/operations).

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). We will use below sections to generate the specs.

### Generate the spec

To generate the spec file, head on to the below URLs for the PX release you wish to use.

* [Default](https://install.portworx.com).
* [1.6 Stable](https://install.portworx.com/1.6/).
* [1.5 Stable](https://install.portworx.com/1.5/).
* [1.4 Stable](https://install.portworx.com/1.4/).

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](https://docs.portworx.com/scheduler/kubernetes/px-k8s-spec-curl.html).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

##### Using Kubernetes Secrets to Provision Certificates
Instead of manually copying the certificates on all the nodes, it is recommended to use [Kubernetes Secrets to provide etcd certificates to Portworx](https://docs.portworx.com/scheduler/kubernetes/etcd-certs-using-secrets.html). This way, the certificates will be automatically available to new nodes joining the cluster.

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet.

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.

### Applying the spec

Once you have generated the spec file, deploy Portworx.

```bash
$ kubectl apply -f px-spec.yaml
```

Monitor the portworx pods

```bash
kubectl get pods -o wide -n kube-system -l name=portworx
```

Monitor Portworx cluster status

```bash
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

If you are still experiencing issues, please refer to [Troubleshooting PX on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/troubleshooting/troubleshoot-and-get-support) and [General FAQs](https://docs.portworx.com/knowledgebase/faqs.html).

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/portworx-install-with-kubernetes/application-install-with-kubernetes/).

## Troubleshooting Notes

* GKE instances under certain scenarios do not automatically re-attach the persistent disks used by PX.
   - Under the following scenarios, GKE will spin up a new VM as a replacement for older VMs with the same node name:
      * Halting a VM in GKE cluster
      * Upgrading GKE between different kubernetes version
      * Increasing the size of the node pool
   - However, in these cases the previously attached persistent disks will not be re-attached automatically.
   - Currently you will have to manually re-attach the persistent disk to the new VM and then restart portworx on that node.
