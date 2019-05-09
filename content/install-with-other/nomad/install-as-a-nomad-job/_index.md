---
title: Install Portworx as a Nomad job
linkTitle: Install as a Nomad job
keywords: portworx, container, Nomad, storage
description: Learn how to install Portworx using Nomad job.
weight: 1
series: px-as-a-nomad-job
noicon: true
hidden: true
---

This section shows how to install _Portworx_ using a Nomad job.

## Prerequisites

_Portworx_ OCI-monitor container needs to run in privileged mode, so you need to configure your Nomad clients to allow docker containers running on privileged mode.

Add the following lines in your Nomad client configuration files and restart your clients:

```text
options {
   "docker.privileged.enabled" = "true"
}
```

## Install Portworx

### Create a Nomad job file

Create a new file called `portworx.nomad` and paste into it the content from below:

```text
job "portworx" {
  type        = "service"
  datacenters = ["dc1"]

  group "portworx" {
    count = 3

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    # restart policy for failed portworx tasks
    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }

    # how to handle upgrades of portworx instances
    update {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "5m"
      auto_revert      = true
      canary           = 0
      stagger          = "30s"
    }

    task "px-node" {
      driver = "docker"
      kill_timeout = "120s"   # allow portworx 2 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the nodes

      # consul service check for portworx instances
      service {
        name = "portworx"
        check {
          port     = "portworx"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # setup environment variables for px-nodes
      env {
        "AUTO_NODE_RECOVERY_TIMEOUT_IN_SECS" = "1500"
        "PX_TEMPLATE_VERSION"                = "V4"
       }

      # container config
      config {
        image        = "portworx/oci-monitor:2.0.3.4"
        network_mode = "host"
        ipc_mode = "host"
        privileged = true

        # configure your parameters below
        # do not remove the last parameter (needed for health check)
        args = [
            "-c", "px-cluster-nomadv8",
            "-a",
            "-k", "consul://127.0.0.1:8500",
            "--endpoint", "0.0.0.0:9015"
        ]

        volumes = [
            "/var/cores:/var/cores",
            "/var/run/docker.sock:/var/run/docker.sock",
            "/run/containerd:/run/containerd",
            "/etc/pwx:/etc/pwx",
            "/opt/pwx:/opt/pwx",
            "/proc:/host_proc",
            "/etc/systemd/system:/etc/systemd/system",
            "/var/run/log:/var/run/log",
            "/var/log:/var/log",
            "/var/run/dbus:/var/run/dbus"
        ]
      }

      # resource config
      resources {
        cpu    = 1024
        memory = 2048

        network {
          mbits = 100
          port "portworx" {
            static = "9015"
          }
        }
      }
    }
  }
}
```

Note that our example installs _Portworx_ on a Nomad cluster with 3 clients.

Don't forget to update:

- the `datacenters` on the file above to fit your environment,
- the `count` to specify the number of nomad nodes you want _Portworx_ to be installed on and
- any constraints you may have.

Also, you can update the arguments as well. Here are the valid arguments you can use:

```text
-c                        [REQUIRED] Specifies the cluster ID that this PX instance is to join
-k                        [REQUIRED] Points to your key value database, such as an etcd cluster or a consul cluster
-s                        [REQUIRED unless -a is used] Specifies the various drives that PX should use for storing the data
-e key=value              [OPTIONAL] Specify extra environment variables
-v <dir:dir[:shared,ro]>  [OPTIONAL] Specify extra mounts
-d <ethX>                 [OPTIONAL] Specify the data network interface
-m <ethX>                 [OPTIONAL] Specify the management network interface
-z                        [OPTIONAL] Instructs PX to run in zero storage mode
-f                        [OPTIONAL] Instructs PX to use an unmounted drive even if it has a filesystem on it
-a                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives
-A                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives or partitions
-j                        [OPTIONAL] Specifies a journal device for PX.  Specify a persistent drive like /dev/sdc or use auto (recommended)
-x <swarm|kubernetes>     [OPTIONAL] Specify scheduler being used in the environment
-r <portnumber>           [OPTIONAL] Specifies the portnumber from which PX will start consuming. Ex: 9001 means 9001-9020
```

## Deploy Portworx

Next, let's deploy `portworx.nomad` by running:

```text
nomad run portworx.nomad
```

## Monitoring the installation process

Check status and wait for all instances to be healthy:

```text
nomad status portworx
```

```output
ID            = portworx
Name          = portworx
Submit Date   = 2019-05-08T00:48:39Z
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
portworx    0       0         3        0       0         0

Latest Deployment
ID          = 64d1d011
Status      = successful
Description = Deployment completed successfully

Deployed
Task Group  Auto Revert  Desired  Placed  Healthy  Unhealthy  Progress Deadline
portworx    true         3        3       3        0          2019-05-08T01:00:40Z

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created   Modified
20a20fd0  e074a6b0  portworx    0        run      running  2m9s ago  23s ago
54f759fa  2299a3b6  portworx    0        run      running  2m9s ago  9s ago
c44ee856  6138409d  portworx    0        run      running  2m9s ago  10s ago
```

You can also follow the logs to wait for _Portworx_ to be ready.

In the example below, I am using the first allocation ID, i.e. 20a20fd0:

```text
nomad alloc logs -f 20a20fd0
```

```output
...
@ip-10-1-1-199 portworx[2414]: time="2019-05-07T15:35:18Z" level=info msg="PX is ready on Node: 6f160613-1fe4-45c4-8d04-079f3bde2921. CLI accessible at /opt/pwx/bin/pxctl."
....
```

After that, you can `ssh` to any one of Nomad clients and check the status using `pxctl`:

```text
pxctl status
```

```output
Status: PX is operational
License: Trial (expires in 31 days)
Node ID: 6f160613-1fe4-45c4-8d04-079f3bde2921
    IP: 10.1.1.199
     Local Storage Pool: 1 pool
    POOL    IO_PRIORITY    RAID_LEVEL    USABLE    USED    STATUS    ZONE        REGION
    0    LOW        raid0        50 GiB    4.3 GiB    Online    us-east-2a    us-east-2
    Local Storage Devices: 1 device
    Device    Path        Media Type        Size        Last-Scan
    0:1    /dev/xvdd    STORAGE_MEDIUM_SSD    50 GiB        07 May 19 15:35 UTC
    total            -            50 GiB
Cluster Summary
    Cluster ID: px-cluster-nomadv4
    Cluster UUID: 8e955967-9c74-4465-8014-610c3fe3c0d7
    Scheduler: none
    Nodes: 3 node(s) with storage (3 online)
    IP        ID                    SchedulerNodeName            StorageNode    Used    Capacity    Status    StorageStatus    Version        Kernel        OS
    10.1.1.111    8a003439-d361-4cfa-8e53-2c32f808290e    8a003439-d361-4cfa-8e53-2c32f808290e    Yes        4.3 GiB    50 GiB        Online    Up        2.0.3.4-0c0bbe4    4.4.0-1079-aws    Ubuntu 16.04.6 LTS
    10.1.1.199    6f160613-1fe4-45c4-8d04-079f3bde2921    6f160613-1fe4-45c4-8d04-079f3bde2921    Yes        4.3 GiB    50 GiB        Online    Up (This node)    2.0.3.4-0c0bbe4    4.4.0-1079-aws    Ubuntu 16.04.6 LTS
    10.1.2.34    5f51038a-5296-492a-894e-031bab836747    5f51038a-5296-492a-894e-031bab836747    Yes        4.3 GiB    50 GiB        Online    Up        2.0.3.4-0c0bbe4    4.4.0-1079-aws    Ubuntu 16.04.6 LTS
Global Storage Pool
    Total Used        :  13 GiB
    Total Capacity    :  150 GiB
```

## Post-Install

Once you have successfully installed _Portworx_ using a Nomad job, below sections are useful.

{{<homelist series2="px-postinstall-nomad-job">}}