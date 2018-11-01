---
title: Deploy and Pre-installation
weight: 2
linkTitle: 1. Deploy and Pre-installation
---

This DCOS service will deploy Portworx as well as all the dependencies and additional services to manage the Portworx cluster. This includes a highly available etcd cluster. This includes a highly available etcd cluster and the Lighthouse service, which is the Web UI for Portworx.

Portworx can be used to provision volumes on DCOS using either the Docker Volume Driver Interface \(DVDI\) or, directly through CSI.

{{<info>}}
**Note:**<br/>Please ensure that your mesos private agents have unmounted block devices that can be used by Portworx.
{{</info>}}

#### \(Optional\) Deploy an AWS Portworx-ready cluster {#optional-deploy-an-aws-portworx-ready-cluster}

Using [this AWS CloudFormation template](/install-with-other/dcos/operate-and-maintain/px-ready-aws-cf), you can easily deploy a DCOS 1.10 cluster that is “Portworx-ready”.

#### Pre-install \(only required if moving from a Portworx Docker installation\) {#pre-install-only-required-if-moving-from-a-portworx-docker-installation}

If you are moving from a Docker install of Portworx to an OCI install, please make sure that the Portworx service is stopped on all the agents before updating to the OCI install. To do this run the following command on all your private agents:

```bash
sudo systemctl stop portworx
```

#### Deploy Portworx {#deploy-portworx}

The Portworx service is available in the DCOS universe, you can find it by typing the name in the search bar.

[Portworx in DCOS Universe](/install-with-other/dcos/install/install-universe)

To modify the defaults, click on the `Review & Run` button next to the package on the DCOS UI.

On the `Edit configuration` page you can change the default configuration for Portworx deployment. Here you can choose to
enable etcd (if you do not have an external etcd service). To have a custom etcd installation please refer to
[this doc](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd). You can also enable the Lighthouse service if you want to use the WebUI.
