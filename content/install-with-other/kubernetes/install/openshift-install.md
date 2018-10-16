---
title: Deploy Portworx on OpenShift
weight: 1
linkTitle: OpenShift
---

## Prerequisites

**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd).

**Firewall**

Ensure ports 9001-9015 are open between the nodes that will run Portworx. Your nodes should also be able to reach the port KVDB is running on (for example etcd usually runs on port 2379).

**NTP**

Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.

**Red Hat account**

Portworx container for OpenShift resides in [RedHat's container repository](https://access.redhat.com/containers/#/registry.connect.redhat.com/portworx/px-enterprise), and needs to be installed using your Red Hat account's username and password.
You can register Red Hat account for free at https://www.redhat.com/wapps/ugc/register.html.

**OpenShift Version**

Portworx supports OpenShift 3.7 and above.

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Add Portworx service accounts to the privileged security context

```bash
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-account
oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:portworx-pvc-controller-account
oc adm policy add-scc-to-user anyuid system:serviceaccount:default:default
```

### Prepare docker-registry credentials secret

To install Portworx for OpenShift, you will require a valid Red Hat account ([register here](https://www.redhat.com/wapps/ugc/register.html)), and configured [Kubernetes secret](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config) with username/password credentials:

```bash
# confirm the username/password works  (e.g. user:john-rhel, passwd:s3cret)
docker login -u john-rhel -p s3cret registry.connect.redhat.com
> Login Succeeded

# configure username/password as a kubernetes "docker-registry" secret  (e.g. "regcred")
oc create secret docker-registry regcred --docker-server=registry.connect.redhat.com \
  --docker-username=john-rhel --docker-password=s3cret --docker-email=test@acme.org \
  -n kube-system
```

### Generate the spec

{{<info>}}
**Note:**<br/> Make sure to select "[x] OpenShift" and provide "Kubernetes docker-registry secret: _regcred_" while generating the spec  (i.e. the spec-URL should have the _osft=true_ and _rsec=regcred_ parameters defined).
{{</info>}}

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


### Apply the spec

{{<info>}}
**Note:**<br/> OpenShift Container Platform 3.9 started restricting where Daemonsets can install
(see [reference](https://docs.openshift.com/container-platform/3.9/dev_guide/daemonsets.html)),
which will prevent the installation of Portworx Daemonset.

1. To enable Daemonsets on "kube-system" namespace run: `oc patch namespace kube-system -p \`<br>
`'{"metadata": {"annotations": {"openshift.io/node-selector": ""}}}'`
2. Alternatively, add the following label to the individual nodes where you want Portworx to run:
`oc label nodes mynode1 node-role.kubernetes.io/compute=true`
{{</info>}}

Once you have generated the spec file, deploy Portworx.
```bash
oc apply -f px-spec.yaml
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

We will test if the installation was successful using a persistent mysql deployment.

* Create a Portworx StorageClass by applying following spec:

```
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-demo-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "3"
```
* Log into OpenShift console: https://MASTER-IP:8443/console

* Create a new project "hello-world".

* Import and deploy [this mysql application template](/k8s-samples/px-mysql-openshift.json?raw=true)
    * For _STORAGE\_CLASS\_NAME_, we use the storage class _px-demo-sc_ created in step before.

* Verify mysql deployment is active.

You can find other examples at [applications using Portworx on Kubernetes](/install-with-other/kubernetes/k8s-px-app-samples).
