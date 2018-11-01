---
title: Access, Troubleshooting and Scaling
weight: 4
linkTitle: 3. Access, Troubleshooting and Scaling
---

## Install Status {#install-status}

Once you have started the install you can go to the `Services` page to monitor the status of the installation.

If you click on the `portworx` service you should be able to look at the status of the tasks being created. If
you have enabled etcd and Lighthouse, there will be 1 task for the framework scheduler, 3 tasks for etcd and 1
task for Lighthouse. Apart from these there will be one task on every node where Portworx runs.

![Portworx Install finished](/img/dcos-px-install-finished.png)

## Accessing Lighthouse {#accessing-lighthouse}

If Lighthouse is deployed on a private agent, it might not be accessible from outside your network depending on your network configuration. To access Lighthouse from an external network you can deploy the [Repoxy](https://gist.github.com/nlsun/877411115f7e3b885b5e9daa8821722f) service to redirect traffic from one of the
public agents.

To do so, run the following marathon application:

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

You can then access the Lighthouse WebUI on http://&lt;public\_agent\_ip&gt;:9998. If your public agent is behind a firewall you will also need to open up two ports, 9998 and 9999.

**Login Page**

The default username/password is `admin`/`Password1` ![Lighthouse Login Page](/img/dcos-px-lighthouse-login.png)

## Dashboard

![Lighthouse Dashboard](/img/dcos-px-lighthouse-dashboard.png)

## Troubleshooting
Lighthouse stores it's config on host volume. If the node is lost, Lighthouse will retain only
that cluster in which it is deployed. You will have to manually add other clusters that you want
to monitor using the Lighthouse. Also, the password will be reset to `Password1`.

 In case of node failures, to move the Lighthouse task to some other node, run the following command:
```bash
dcos portworx pod replace lighthouse-0
```
