---
title: Uninstall Portworx using a Nomad job
linkTitle: Uninstall Portworx using a Nomad job
keywords: Uninstall, Nomad
description: Learn how to uninstall Portworx using a Nomad job.
weight: 2
series: px-as-a-nomad-job
series2: px-postinstall-nomad-job
noicon: true
hidden: true
---

{{<info>}}
This document presents the **Nomad** method of uninstalling a Portworx cluster. Please refer to the [Uninstall on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/) page if you are running Portworx on Kubernetes.
{{</info>}}


There are two steps to completely uninstall Portworx from Nomad:

- Remove the Nomad Portworx job
- Run the px-node-wiper Nomad batch job to uninstall Portworx binaries from Nomad client nodes

### Remove Nomad portworx job

To remove the Portworx job, run the following command:

```text
nomad job stop -purge portworx
```

### Delete/wipe a Portworx cluster

{{<info>}}
The commands used in this section are DISRUPTIVE and will lead to the loss of all your data volumes. Proceed with CAUTION.
{{</info>}}

Save the Nomad batch job in a file called `px-node-wiper.nomad`:

```text
job "px-node-wiper" {
  type        = "batch"
  datacenters = ["dc1"]

  group "px-node-wiper" {
    count = 3

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    task "px-node-wiper" {
      driver = "docker"
      kill_timeout = "120s"   # allow portworx 2 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the nodes

      # container config
      config {
        image        = "portworx/px-node-wiper:2.0.3.6"
        network_mode = "host"
        ipc_mode = "host"
        privileged = true

        volumes = [
            "/etc/pwx:/etc/pwx",
            "/opt/pwx:/opt/pwx",
            "/proc:/hostproc",
            "/etc/systemd/system:/etc/systemd/system",
            "/var/run/dbus:/var/run/dbus"
        ]
      }

      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      }
    }
  }
}
```

You will have to make changes to this file to match your `portworx.nomad` file, i.e., update datacenter, count and constraints.

Then, run the following command:

```text
nomad run px-node-wiper.nomad
```

Wait for all instances to complete:

```text
nomad status px-node-wiper
```

```output
ID            = px-node-wiper
Name          = px-node-wiper
Submit Date   = 2019-05-08T01:17:53Z
Type          = batch
Priority      = 50
Datacenters   = dc1
Status        = dead
Periodic      = false
Parameterized = false

Summary
Task Group     Queued  Starting  Running  Failed  Complete  Lost
px-node-wiper  0       0         0        0       3         0

Allocations
ID        Node ID   Task Group     Version  Desired  Status    Created  Modified
145b8fda  e074a6b0  px-node-wiper  0        run      complete  57s ago  34s ago
4b9f527f  6138409d  px-node-wiper  0        run      complete  57s ago  33s ago
d4ca97ae  2299a3b6  px-node-wiper  0        run      complete  57s ago  33s ago
```
