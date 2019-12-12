---
title: Configure on Docker (shared)
description: Learn how to configure Porworx as a runC container
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
hidden: true
---

Now that you have downloaded and installed the Portworx OCI bundle, you can use the `px-runc install` command from the bundle to configure systemd to start Portworx.

The _px-runc_ command is a helper-tool that does the following:

1. Prepares the OCI directory for runc
2. Prepares the runC configuration for Portworx 
3. Uses systemd to start the Portworx OCI bundle

Installation example:

```text
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc
```

#### Command-line arguments

{{% content "install-with-other/docker/shared/cmdargs.md" %}}

#### Examples

Installing Portworx using etcd:

```text
px-runc install -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 {{ include.sched-flags }}
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 {{ include.sched-flags }}
```

Installing Portworx using Consul:

```text
px-runc install -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 {{ include.sched-flags }}
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 {{ include.sched-flags }}
```

#### Modifying the Portworx configuration

After the initial installation, you can modify the Portworx configuration file at `/etc/pwx/config.json` (see [details](/install-with-other/docker/shared/config-json)) and restart Portworx using `systemctl restart portworx`.
