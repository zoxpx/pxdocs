---
title: Deploy Portworx on Kubernetes
weight: 7
linkTitle: Kubernetes (Other)
---

## Interactive Tutorials

If you wish to get an overview of using Portworx on Kubernetes, start with [these interactive tutorials](/install-with-other/kubernetes/px-k8s-interactive). These serve as a playground for you to get an idea about the capabilities of Portworx without having to install it in your cluster.

## Prerequisites

**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd).

**Firewall**

Ensure ports 9001-9015 are open between the nodes that will run Portworx. Your nodes should also be able to reach the port KVDB is running on (for example etcd usually runs on port 2379).

**NTP**

Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

#### Generating the spec

To generate the spec file, head on to the below URLs for the PX release you wish to use.

* [Default](https://install.portworx.com).
* [1.6 Stable](https://install.portworx.com/1.6/).
* [1.5 Stable](https://install.portworx.com/1.5/).
* [1.4 Stable](https://install.portworx.com/1.4/).

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/install-with-other/kubernetes/px-k8-spec-curl).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

##### Using Kubernetes Secrets to Provision Certificates
Instead of manually copying the certificates on all the nodes, it is recommended to use [Kubernetes Secrets to provide etcd certificates to Portworx](/install-with-other/kubernetes/etcd-certs-using-secrets). This way, the certificates will be automatically available to new nodes joining the cluster.

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet.

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.

#### Internal Kvdb (beta)

Portworx can be configured to run with internal kvdb by enabling it in the above spec generator.

{{<info>}}
**Note:** Internal Kvdb is in beta and available for PX version > 1.4
{{</info>}}

#### Applying the spec

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

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/install-with-other/kubernetes/k8s-px-app-samples).
