---
title: Basics operations using pxctl
description: General reference for CLI, Volumes and other resources.
keywords: portworx, containers, storage, volumes, CLI
weight: 1
linkTitle: Basics
---

In this document, we are going to explore the basic operations available through the Portworx command-line tool- `pxctl`.

By default, the CLI displays the information in human readable form. For example, to learn more about the available commands, type `pxctl help`:

```text
pxctl help
```

```output
px cli

Usage:
  pxctl [command]

Available Commands:
  alerts         px alerts
  auth           pxctl auth
  clouddrive     Manage cloud drives
  cloudmigrate   Migrate volumes across clusters
  cloudsnap      Backup and restore snapshots to/from cloud
  cluster        Manage the cluster
  context        pxctl context
  credentials    Manage credentials for cloud providers
  eula           Show license agreement
  help           Help about any command
  license        Manage licenses
  objectstore    Manage the object store
  role           pxctl role
  sched-policy   Manage schedule policies
  secrets        Manage Secrets. Supported secret stores AWS KMS | Vault | DCOS Secrets | IBM Key Protect | Kubernetes Secrets | Google Cloud KMS
  service        Service mode utilities
  status         Show status summary
  storage-policy Manage storage policies for creating volumes
  upgrade        Upgrade PX
  volume         Manage volumes

Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -h, --help             help for pxctl
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx
  -v, --version          print version and exit

Use "pxctl [command] --help" for more information about a command.
```

{{<info>}}
As seen above, `pxctl` provides the capability to perform fine-grained control of the PX resources cluster-wide. Also, it lets the user manage volumes, snapshots, cluster resources, hosts in the cluster and software upgrade in the cluster.
{{</info>}}

In addition, every command takes in a `--json` flag which converts the output to a machine-parsable `JSON` format. You can do something like the following to save the output in `JSON` format:

```text
pxctl status --json > status.json
```

In most production deployments, you will provision volumes directly using _Docker_ or your scheduler (such as a _Kubernetes_ pod spec). However, `pxctl` also lets you directly provision and manage storage. In addition, `pxctl` has a rich set of cluster-wide management features which are explained in this document.

All operations available through `pxctl` are reflected back into the containers that use Portworx storage. In addition to what is exposed in Docker volumes, `pxctl`:

*   Gives access to Portworx storage-specific features, such as cloning a running container’s storage.
*   Shows the connection between containers and their storage volumes.
*   Lets you control the Portworx storage cluster, such as adding nodes to the cluster. (The Portworx tools refer to servers managed by Portworx storage as _nodes_.)

The scope of the `pxctl` command is global to the cluster. Running `pxctl` on any node within the cluster, therefore, shows the same global details. But `pxctl` also identifies details specific to that node.

The current release of `pxctl` is located in the `/opt/pwx/bin/` directory of every **worker node** and requires that you run it as a privileged user.

Let's look at some simple commands.

## Version

Here's how to find out the current version:

```text
pxctl --version
```

```output
pxctl version 2.1.0.0-d594892 (OCI)
```

## Status

The status command gives a summary like node details, cluster members, global storage capacity, etc.

The following example shows how the output looks like if the global capacity for the Docker containers is 128 GB.

```text
pxctl status
```

```output
Status: PX is operational
License: PX-Developer
Node ID: 2069387c-6c60-4e23-a88d-07d391431e01
        IP: 192.168.57.3
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       HIGH            raid0           20 GiB  1.3 GiB Online  default default
        Local Storage Devices: 3 devices
        Device  Path            Media Type              Size            Last-Scan
        0:0     /dev/sdc        STORAGE_MEDIUM_MAGNETIC 10 GiB          23 Feb 19 19:21 IST
        0:1     /dev/sdb        STORAGE_MEDIUM_MAGNETIC 10 GiB          23 Feb 19 19:21 IST
        total                   -                       20 GiB
        Cache Devices:
        Device  Path            Media Type              Size            Last-Scan
        0:2     /dev/sde        STORAGE_MEDIUM_SSD      4.0 GiB         23 Feb 19 19:21 IST
        Journal Device:
        1       /dev/sdf1       STORAGE_MEDIUM_MAGNETIC
Cluster Summary
        Cluster ID: 12345
        Cluster UUID: a6a03e7a-ad9d-42de-bff8-10d07b6bfa7e
        Scheduler: none
        Nodes: 1 node(s) with storage (1 online)
        IP              ID                                      SchedulerNodeName       StorageNode     Used    Capacity        Status  StorageStatus      Version         Kernel                  OS
        192.168.57.3    2069387c-6c60-4e23-a88d-07d391431e01    N/A                     Yes             1.3 GiB 20 GiB          Online  Up (This node)     3.0.0.0-527cd9a 4.4.0-131-generic       Ubuntu 16.04.5 LTS
Global Storage Pool
        Total Used      :  1.3 GiB
        Total Capacity  :  20 GiB
```

## Upgrade related operations

`pxctl` provides access to several upgrade related operations. You can get details on how to use it and of the available flags by running:

```text
pxctl upgrade --help
```

```output
Usage:
  pxctl upgrade [flags]

Flags:
  -l, --tag string   Specify a PX Docker image tag
  -h, --help         help for upgrade

Global Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx
```

### Running pxctl upgrade

`pxctl upgrade` upgrades the PX version on a node. Let's suppose you want to upgrade PX to version _1.1.16_. If so, you would then type the following command:

```text
pxctl upgrade --tag 1.1.6 my-px-enterprise
```

```output
Upgrading my-px-enterprise to version: portworx/px-enterprise:1.1.6
Downloading PX portworx/px-enterprise:1.1.6 layers...
<Output truncated>
```

It is recommended to upgrade the nodes in a **staggered manner**. This way, the quorum and the continuity of IOs will be maintained.

### Related topics

* For information about upgrading Portworx through Kubernetes, refer to the [Upgrade on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/upgrade/) page.

* If you’re using the Portworx Operator, refer to the [Upgrade Portworx using the Operator](/portworx-install-with-kubernetes/on-premise/openshift/operator/upgrade/) page.

## Login/Authentication

You must make PX login to the secrets endpoint when using encrypted volumes and ACLs.

`pxctl secrets` can be used to configure authentication credentials and endpoints.
Currently, Vault, Amazon KMS, and KVDB are supported.


### Vault example

Here's an example of configuring PX with Vault:

```text
pxctl secrets vault login --vault-address http://myvault.myorg.com --vault-token myvaulttoken
```

```output
Successfully authenticated with Vault.
```

{{<info>}}
To install and configure Vault, peruse [this link](https://www.vaultproject.io/docs/install/index.html)
{{</info>}}

### AWS KMS example

To configure PX with Amazon KMS, type the following command:

```text
pxctl secrets aws login
```

Then, you will be asked a few questions:

```
Enter AWS_ACCESS_KEY_ID [Hit Enter to ignore]: ***
Enter AWS_SECRET_ACCESS_KEY [Hit Enter to ignore]: ***
Enter AWS_SECRET_TOKEN_KEY [Hit Enter to ignore]: ***
Enter AWS_CMK [Hit Enter to ignore]: mykey
Enter AWS_REGION [Hit Enter to ignore]: us-east-1b
```

Finally, a success message will be displayed:

```
Successfully authenticated with AWS.
```

### Related topics

* For information about enabling and managing Portworx authorization through Kubernetes secrets, refer to the [Authorization](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/) page.


## EULA

You can get a link to our EULA by running:

```text
pxctl eula
```

```output
https://portworx.com/end-user-license-agreement
```
