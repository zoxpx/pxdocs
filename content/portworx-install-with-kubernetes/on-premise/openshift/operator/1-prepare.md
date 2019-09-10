---
title: 1. Prepare your platform
weight: 1
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift, operator
description: Find out how to prepare PX within a OpenShift cluster and have PX provide highly available volumes to any application deployed via Kubernetes.
---

{{<info>}}Portworx Operator is supported Openshift 4 and above.{{</info>}}

### Install Portworx Operator

Starting OpenShift 4 you can install the Certified Portworx Operator from OperatorHub under the Catalog tab in Openshift console.

![Portworx Operator](/img/openshift-operatorhub-portworx.png)

### Airgapped clusters

If your nodes are airgapped and don't have access to common internet registries, first follow [Airgapped clusters](/portworx-install-with-kubernetes/on-premise/airgapped) to fetch _Portworx_ images.

### Select nodes where Portworx will installed

OpenShift Container Platform 3.9 started restricting where pods can be installed (see [reference](https://docs.openshift.com/container-platform/3.9/dev_guide/daemonsets.html)),
Portworx Operator will install pods only on nodes that have the label `node-role.kubernetes.io/compute=true`.

If you want to install _Portworx_ on additional nodes, you have 2 options.

1. To allow _Portworx_ pods on all nodes in let's say `kube-system` namespace run:
```text
oc patch namespace kube-system -p '{"metadata": {"annotations": {"openshift.io/node-selector": ""}}}'
```

2. Alternatively, add the following label to the individual nodes where you want _Portworx_ to run:
```text
oc label nodes mynode1 node-role.kubernetes.io/compute=true
```

### Prepare a docker-registry credentials secret

{{<info>}}This is required in order to retrieve the images from a secure registry. Set these credentials using access information for the Docker registry.{{</info>}}

* Confirm the username/password works (e.g. user:john, passwd:s3cret)
```text
docker login -u john -p s3cret mysecure.registry.com
```

* Configure username/password as a [Kubernetes "docker-registry" secret](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config) (e.g. "regcred")
```text
oc create secret docker-registry regcred \
   --docker-server=mysecure.registry.com \
   --docker-username=john \
   --docker-password=s3cret \
   --docker-email=test@acme.org \
   -n kube-system
```
