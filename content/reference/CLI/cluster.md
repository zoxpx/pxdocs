---
title: Cluster operations using pxctl
linkTitle: Cluster Operations
keywords: pxctl, command-line tool, cli, reference, cluster operations, list nodes, inspect node, optimized restores
description: This guide shows you how to use the pxctl to perform cluster operations.
weight: 4
---

This document outlines how to manage your Portworx cluster operation with `pxctl cluster`.

First, let's get an overview of the available commands:

```text
/opt/pwx/bin/pxctl cluster --help
```

```output
Manage the cluster

Usage:
  pxctl cluster [flags]
  pxctl cluster [command]

Aliases:
  cluster, c

Available Commands:
  delete           Delete a node
  domains          A set of commands to manage Portworx Cluster Domains
  inspect          Inspect a node
  list             List nodes in the cluster
  options          List and update cluster wide options
  pair             Manage Portworx cluster pairs
  provision-status Show cluster provision status
  token            Manage cluster authentication token

Flags:
  -h, --help   help for cluster

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

Use "pxctl cluster [command] --help" for more information about a command.
```

## Listing all nodes in a cluster

To list all nodes in your Portworx cluster, run:

```text
pxctl cluster list
```

```output
Cluster ID: 8ed1d365-fd1b-11e6-b01d-0242ac110002
Status: OK

Nodes in the cluster:
ID					DATA IP		CPU		MEM TOTAL	MEM FREE	CONTAINERS	VERSION		STATUS
bf9eb27d-415e-41f0-8c0d-4782959264bc	147.75.99.243	0.125078	34 GB		33 GB		N/A		1.1.4-6b35842	Online
7d97f9ea-a4ff-4969-9ee8-de2699fa39b4	147.75.99.171	0.187617	34 GB		33 GB		N/A		1.1.4-6b35842	Online
492596eb-94f3-4422-8cb8-bc72878d4be5	147.75.99.189	0.125078	34 GB		33 GB		N/A		1.1.4-6b35842	Online
```

## Inspecting a node

Use the following command to get information on a node in the cluster:

```text
pxctl cluster inspect 492596eb-94f3-4422-8cb8-bc72878d4be5
```

```output
ID       	:  492596eb-94f3-4422-8cb8-bc72878d4be5
Mgmt IP  	:  147.75.99.189
Data IP  	:  147.75.99.189
CPU      	:  0.8755472170106317
Mem Total	:  33697398784
Mem Used 	:  702279680
Status  	:  Online
Containers:	There are no running containers on this node.
```

## Deleting a node in a cluster

Here is how to delete a node:

```text
pxctl cluster delete bf9eb27d-415e-41f0-8c0d-4782959264bc
```

```output
node bf9eb27d-415e-41f0-8c0d-4782959264bc deleted successfully
```

To get help, run:

```text
pxctl cluster delete --help
```

```output
Delete a node

Usage:
  pxctl cluster delete [flags]

Aliases:
  delete, d

Examples:
/opt/pwx/bin/pxctl cluster delete [flags] nodeID

Flags:
  -f, --force   Forcibly remove node, which may cause volumes to be irrevocably deleted
  -h, --help    help for delete

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

### Related topics

* For more information about decommissioning a Portworx node through Kubernetes, refer to the [Decommission a Node](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node/) page.

## Showing nodes based on IO Priority

To list the nodes in your Portworx cluster based on IO Priority (high, medium and low), type:

```text
pxctl cluster provision-status --io_priority low
```

```output
Node					Node Status	Pool	Pool Status	IO_Priority	Size	Available	Used	Provisioned	ReserveFactor	Zone	Region
492596eb-94f3-4422-8cb8-bc72878d4be5	Online		0	Online		LOW		100 GiB	99 GiB		1.0 GiB	0 B		default	default
492596eb-94f3-4422-8cb8-bc72878d4be5	Online		1	Online		LOW		200 GiB	199 GiB		1.0 GiB	0 B		50		default	default
7d97f9ea-a4ff-4969-9ee8-de2699fa39b4	Online		0	Online		LOW		100 GiB	92 GiB		8.2 GiB	70 GiB		default	default
bf9eb27d-415e-41f0-8c0d-4782959264bc	Online		0	Online		LOW		150 GiB	149 GiB		1.0 GiB	0 B		default	default
```

To get help, type the following:

```text
pxctl cluster provision-status --help
```

```output
NAME:
   pxctl cluster provision-status - Show cluster provision status

USAGE:
   pxctl cluster provision-status [command options] [arguments...]

OPTIONS:
   --io_priority value  IO Priority: [high|medium|low] (default: "low")
```

## Enabling optimized restores

{{% content "shared/reference-CLI-optimized-restores-definition.md" %}}

First, let's take a look at the available subcommands and flags:

```
pxctl cluster options --help
```

```output
List and update cluster wide options

Usage:
  pxctl cluster options [flags]
  pxctl cluster options [command]

Available Commands:
  list        List cluster wide options
  update      Update cluster wide options

Flags:
  -h, --help   help for options

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

Use "pxctl cluster options [command] --help" for more information about a command.
```


Next, we would want to list the options:

```
pxctl cluster options list
```

```output
Auto decommission timeout (minutes)  :  20
Replica move timeout (minutes)       :  1440
Internal Snapshot Interval (minutes) :  30
Re-add timeout (minutes)             :  1440
Resync repl-add                      :  off
Domain policy                        :  strict
Optimized Restores                   :  off
```

Now, let's see how to update these options:


```text
pxctl cluster options update --help
```

```output
Update cluster wide options

Usage:
  pxctl cluster options update [flags]
Flags:
      --auto-decommission-timeout uint                  Timeout (in minutes) after which storage-less nodes will be automatically decommissioned. Timeout cannot be set to zero. (default 20)
      --cloudsnap-abort-timeout-minutes uint            Timeout in minutes for stalled cloudsnap abort. Should be => 10 minutes (default 10)
      --cloudsnap-catalog string                        Enable or disable cloudsnap catalog collection (Valid Values: [on off]) (default "off")
      --cloudsnap-max-threads uint                      Number of cloudsnap threads doing concurrent uploads/downloads. Valid values  >= 2  and <= 16, others automatically rounded (default 16)
      --cloudsnap-nw-interface string                   network interface name used by cloudsnaps(data, mgmt, eth0, etc)
      --concurrent-api-limit uint                       Maximum number of concurrent api invocations allowed (default 20)
      --disable-provisioning-labels string              Semi-colon separate string
      --disabled-temporary-kvdb-loss-support string     Enable or disable temporary kvdb loss support (Valid Values: [on off]) (default "off")
      --domain-policy string                            Domain policy for domains (Valid Values: [strict eventual]) (default "strict")
  -h, --help                                            help for update
      --internal-snapshot-interval uint                 Interval (in minutes) after which internal snapshots are rotated (default 30)
      --license-expiry-check days                       Number of days to raise alert before license expires. Set to zero to disable alerts. (default 7)
      --license-expiry-check-interval string            Interval for license expiry checks.  Valid only if 'license-expiry-check' is defined. (default "6h")
      --optimized-restores string                       Enable or disable optimized restores (Valid Values: [on off]) (default "off")
      --provisioning-commit-labels string               Json, example of global rule followed by node specific and pool specific rule: '[{'OverCommitPercent': 200, 'SnapReservePercent': 30},{'OverCommitPercent': 50, 'SnapReservePercent':30, 'LabelSelector':{'node':'node-1,node-2', 'poolLabel':'poolValue'},]'
      --px-http-proxy string                            proxy to be used by px services(cloudsnap, etc) (default "off")
      --re-add-wait-timeout uint                        Timeout (in minutes) after which re-add will abort and new replication node is added instead. Set timeout to zero to disable replica move. (default 1440)
      --repl-move-timeout uint                          Timeout (in minutes) after which offline replicas will be moved to available nodes. Set timeout to zero to disable replica move. (default 1440)
      --repl-move-timestamp-records-threshold uint      Timestamp record threshold after which offline replicas will be moved to available nodes. Set threshold to zero to disable replica move. (default 134217728)
      --resync-repl-add string                          Enable or disable repl-add based resync (Valid Values: [on off]) (default "off")
      --runtime-options string                          Comma seprated key value pairs for runtime options
      --runtime-options-action string                   Specify type of action for runtime options (Valid Values: [update-global delete-global update-node-specific delete-node-specific]) (default "update-global")
      --runtime-options-selector string                 Comma seprated key value labels for node specific runtime options.
      --sharedv4-mount-timeout-sec uint                 Timeout in seconds for sharedv4 (NFS) mount commands. (default 120)
      --sharedv4-threads uint                           Number of sharedv4 threads. This will affect sharedv4 volume performance as well as the amount of CPU and memory consumed for handling sharedv4 volumes. (default 16)
      --snapshot-schedule-option string                 for detached volumes none will not generate schedule snapshots, optimized will generated one, always will generate them always (Valid Values: [none always optimized]) (default "optimized")
      --uniqueblocks-size-sched-interval-minutes uint   Configure periodic interval to query unique blocks size for volumes. (default 720)
Global Flags:
      --ca string            path to root certificate for ssl usage
      --cert string          path to client certificate for ssl usage
      --color                output with color coding
      --config string        config file (default is $HOME/.pxctl.yaml)
      --context string       context name that overrides the current auth context
  -j, --json                 output in json
      --key string           path to client key for ssl usage
      --output-type string   use "wide" to show more details
      --raw                  raw CLI output for instrumentation
      --ssl                  ssl enabled for portworx
```

Use the following command to enable optimized restores:

```text
pxctl cluster options update --optimized-restores on
```

```output
Successfully updated cluster wide options
```

Let's make sure the new settings were applied:

```text
pxctl cluster options list
```

```output
Auto decommission timeout (minutes)  :  20
Replica move timeout (minutes)       :  1440
Internal Snapshot Interval (minutes) :  30
Re-add timeout (minutes)             :  1440
Resync repl-add                      :  off
Domain policy                        :  strict
Optimized Restores                   :  on
```

## Use a network interface for cloudsnaps

By default, cloudsnaps do not use a specific network interface to upload/download the cloudsnap data. Instead, the underlying Go libraries determine the network interface. If you need to use a specific network interface, you can set one using the `--cloudsnap-nw-interface` option. Setting this option directs Portworx to use the specified interface for all cloudsnap related operations. 

This is a cluster-wide setting, meaning that the chosen network interface must be available on all nodes. If the chosen network interface is not available, Portworx falls-back to the "no interface chosen" default behavior. 

To enable this feature, enter the following `pxctl cluster options update` command with the `--cloudsnap-nw-interface` option and specify your desired network interface and confirm at the prompt:

```text
pxctl cluster options update --cloudsnap-nw-interface <your-network-interface>
```
```output
Currently cloudsnap network interface is set to :data, changing this will affect new cloudsnaps and not the current onesDo you still want to change this now? (Y/N): y
Successfully updated cluster wide options
```

### Related topics

* For more information about creating and managing the snapshots of your Portworx volumes through Kubernetes, refer to the [Create and use snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/) page.


## pxctl cluster options update --provisioning-commit-labels reference

```text
--provisioning-commit-labels '[{"OverCommitPercent": <percent_value>, "SnapReservePercent": <percent_value>, "LabelSelector": {"<label_key>": "<label_value>"}},{"OverCommitPercent": <percent_value>, "SnapReservePercent":<percent_value>} ]'
```

| Key | Description | Value |
| --- | --- | --- |
| OverCommitPercent | The maximum storage percentage volumes can provision against backing storage | Any integer over 100 |
| SnapReservePercent | The percent of the previously specified maximum storage storage percentage that is reserved for snapshots | Any integer under 100 |
| labelSelector | The key values for labels or node IDs you wish to apply this rule to | Enumerated string: `node` with a comma separated list of node IDs <br/> Any existing label key and value. |

## Configure cache flush operations

On systems with a large amount of memory and heavy IO activity, system memory and page cache experience a lot of activity, resulting in significant memory pressure. On these systems, the Portworx storage process may slow down or get stuck trying to allocate memory. 

To prevent Portworx from slowing or getting stuck, you can preemptively drop system memory pages which are not currently in use, i.e. pages which are inactive and not dirty.

You can configure cache flush operations for all nodes on the cluster using flags with the `pxctl cluster options update` command. 

{{<info>}}
**NOTE:** 

* This command is intended for advanced users only. 
* This operation drops all cached pages for all devices and may impact read performance; you should only apply the config when necessary.
* Legacy support for cache flush was enabled through an environment variable: `PX_ENABLE_CACHE_FLUSH="true"`. As long as the cache flush feature has not been enabled, Portworx still checks for this env var when a node starts and will enable cache flushing if it's set to `true`. If you disable cache flush using the `pxctl` command, cache flush will be disabled regardless of whether the env var is set to `true` or not.  
{{</info>}}

### Enable cache flush operations

Enter the `pxctl cluster options update` command with the `--cache-flush` flag set to `enabled`:

```text
pxctl cluster options update --cache-flush enabled
```
```output
Successfully updated cluster wide options
```

### Disable cache flush operations

Enter the `pxctl cluster options update` command with the `--cache-flush` flag set to `disabled`:

```text
pxctl cluster options update --cache-flush disabled
```
```output
Successfully updated cluster wide options
```

### Configure the cache flush interval

Enter the `pxctl cluster options update` command with the `--cache-flush-seconds` flag followed by your desired cache flush interval in seconds:

```text
pxctl cluster options update --cache-flush-seconds 60
```
```output
Successfully updated cluster wide options
```

{{<info>}}
**NOTE:** You can specify the `--cache-flush-seconds` flag alongside the `--cache-flush` flag in a single command:

```text
pxctl cluster options update --cach-flush enabled --cache-flush-seconds 300
```
{{</info>}}

### Check cache flush configuration

To see if cache flush is enabled and see what the current interval is, enter the `pxctl cluster options list` command:

```text
pxctl cluster options list
```
```output

...

Cache flush                                             : enabled
Cache flush interval in seconds                         : 30
```


