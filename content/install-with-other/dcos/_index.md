---
title: DCOS
weight: 1
---

This DCOS service will deploy Portworx as well as all the dependencies and additional services to manage the Portworx cluster. This includes a highly available etcd cluster, influxdb to store statistics and the Lighthouse service, which is the Web UI for Portworx.

Portworx can be used to provision volumes on DCOS using either the Docker Volume Driver Interface \(DVDI\) or, directly through CSI.

NOTE: Please ensure that your mesos private agents have unmounted block devices that can be used by Portworx.

#### \(Optional\) Deploy an AWS Portworx-ready cluster {#optional-deploy-an-aws-portworx-ready-cluster}

Using [this AWS CloudFormation template](https://docs.portworx.com/scheduler/mesosphere-dcos/px-ready-aws-cf.html), you can easily deploy a DCOS 1.10 cluster that is “Portworx-ready”.

#### Pre-install \(only required if moving from a Portworx Docker installation\) {#pre-install-only-required-if-moving-from-a-portworx-docker-installation}

If you are moving from a Docker install or Portworx to an OCI install, please make sure that the Portworx service is stopped on all the agents before updating to the OCI install. To do this run the following command on all your private agents:

```text
sudo systemctl stop portworx
```

#### Deploy Portworx {#deploy-portworx}

The Portworx service is available in the DCOS universe, you can find it by typing the name in the search bar.

![Portworx in DCOS Universe](https://docs.portworx.com/images/dcos-px-universe.png)

**Default Install**

If you want to use the defaults, you can now run the dcos command to install the service

```text
dcos package install --yes portworx
```

You can also click on the “Install” button on the WebUI next to the service and then click “Install Package”.

This will install all the prerequisites and start the Portworx service on 3 private agents. The default login/password for lighthouse would be portworx@yourcompany.com/admin

**Advanced Install**

If you want to modify the defaults, click on the “Install” button next to the package on the DCOS UI and then click on “Advanced Installation”

Through the advanced install options you can change the configuration of the Portworx deployment. Here you can choose to disable etcd \(if you have an external etcd service\) If you wish to to have a custom etcd installation please refer this [doc](https://docs.portworx.com/maintain/etcd.html). You can also disable the Lighthouse service in case you do not want to use the WebUI.

**Portworx Options**

Specify your kvdb \(consul or etcd\) server if you don’t want to use the etcd cluster with this service. If the etcd cluster is enabled this config value will be ignored. If you have been given access to the Enterprise version of PX you can replace px-dev:latest with px-enterprise:latest. With PX Enterprise you can increase the number of nodes in the PX Cluster to a value greater than 3.

> **Note:**  
> If you are trying to use block devices that already have a filesystem on them, either add the “-f” option to “Portworx Options” to force Portworx to use these disks or wipe the filesystem using wipefs command before installing.

![Portworx Install options](https://docs.portworx.com/images/dcos-px-install-options.png)

> **Note:**  
> For a full list of installtion options, please look [here](https://docs.portworx.com/runc/options.html#opts).

**Secrets Options**

To use DC/OS secrets for Volume Encryption and storing Cloud Credentials, click the link below.

{% page-ref page="../../key-management/portworx-with-dc-os-secrets.md" %}

**Etcd Options**

By default a 3 node etcd cluster will be created with 5GB of local persistent storage. The size of the persistent disks can be changed during install. This can not be updated once the service has been started so please make sure you have enough storage resources available in your DCOS cluster before starting the install. ![Portworx ETCD Install options](https://docs.portworx.com/images/dcos-px-etcd-options.png)

**Lighthouse options**

By default the Lighthouse service will be installed. If this is disabled the influxdb service will also be disabled.

You can enter the admin email to be used for creating the Lighthouse account. This can be used to login to Lighthouse after install is complete. The default password is `admin` which can be changed after login.

![Portworx Lighthouse Install options](https://docs.portworx.com/images/dcos-px-lighthouse-options.png)

Once you have configured the service, click on “Review and Install” and then “Install” to start the installation of the service.

#### Install Status {#install-status}

Once you have started the install you can go to the Services page to monitor the status of the installation.

If you click on the Portworx service you should be able to look at the status of the services being created.

In a default install there will be one service for the framework scheduler, 4 services for etcd \( 3 etcd nodes and one etcd proxy\), one service for influxdb and one service for lighthouse.

![Portworx Install finished](https://docs.portworx.com/images/dcos-px-install-finished.png)

The install for Portworx on the agent nodes will also run as a service but they will “Finish” once the installation is done.

You can check the nodes where Portworx is installed and the status of the Portworx service by clicking on the Components link on the DCOS UI. ![Portworx in DCOS Compenents](https://docs.portworx.com/images/dcos-px-components.png)

#### Accessing Lighthouse {#accessing-lighthouse}

Since Lighthouse is deployed on a private agent it might not be accessible from outside your network depending on your network configuration. To access Lighthouse from an external network you can deploy the [Repoxy](https://gist.github.com/nlsun/877411115f7e3b885b5e9daa8821722f) service to redirect traffic from one of the public agents.

To do so, run the following marathon application

```text
{
  "id": "/repoxy",
  "cpus": 0.1,
  "acceptedResourceRoles": [
      "slave_public"
  ],
  "instances": 1,
  "mem": 128,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/repoxy:2.0.0"
    },
    "volumes": [
      {
        "containerPath": "/opt/mesosphere",
        "hostPath": "/opt/mesosphere",
        "mode": "RO"
      }
    ]
  },
  "cmd": "/proxyfiles/bin/start portworx $PORT0",
  "portDefinitions": [
    {
      "port": 9998,
      "protocol": "tcp"
    },
    {
      "port": 9999,
      "protocol": "tcp"
    }
  ],
  "requirePorts": true,
  "env": {
    "PROXY_ENDPOINT_0": "Lighthouse,http,lighthouse-0-start,mesos,8085,/,/"
  }
}
```

You can then access the Lighthouse WebUI on http://&lt;public\_agent\_IP&gt;:9998. If your public agent is behind a firewall you will also need to open up two ports, 9998 and 9999.

**Login Page**

The default username/password is portworx@yourcompany.com/admin ![Lighthouse Login Page](https://docs.portworx.com/images/dcos-px-lighthouse-login.png)

#### Dashboard {#dashboard}

![Lighthouse Dashboard](https://docs.portworx.com/images/dcos-px-lighthouse-dashboard.png)

#### Scaling Up Portworx Nodes {#scaling-up-portworx-nodes}

If you add more agents to your DCOS cluster and you want to install Portworx on those new nodes, you can increase the NODE\_COUNT to start install on the new nodes. This will relaunch the service scheduler and install Portworx on the nodes which didn’t have it previously.

![Scale up PX Nodes](https://docs.portworx.com/images/dcos-px-scale-up.png)

#### Install an application

You are ready to install a application that uses Portworx. To do this, go to the next section, _Application Installs_.

