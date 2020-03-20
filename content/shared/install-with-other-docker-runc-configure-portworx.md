---
title: Configure on Docker (shared)
description: Learn how to configure Porworx as a runC container
keywords: Install, docker, px-runc
hidden: true
---

Now that you have downloaded and installed the Portworx OCI bundle, you can use the `px-runc install` command from the bundle to configure your installation.

The `px-runc` command is a helper tool that configures and runs the Portworx runC container.

The following example shows how you can use `px-runc` to install Portworx::

```text
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc
```

#### Command-line arguments

{{% content "shared/install-with-other-docker-cmdargs.md" %}}

#### Examples

**Install Portworx using etcd:**

```text
px-runc install -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 {{ include.sched-flags }}
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -m eth1 -d eth2 {{ include.sched-flags }}
```

**Install Portworx using Consul:**

```text
px-runc install -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 {{ include.sched-flags }}
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -m eth1 -d eth2 {{ include.sched-flags }}
```

#### Modify the Portworx configuration

After the initial installation, you can modify the Portworx configuration file at `/etc/pwx/config.json`. See the [schema definition](/shared/install-with-other-docker-config-json) page for more details. Once you're done making changes to the Portworx configuration file, restart Portworx by running:

```text
systemctl restart portworx
```
