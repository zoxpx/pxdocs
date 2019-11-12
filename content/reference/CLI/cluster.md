---
title: Cluster operations using pxctl
linkTitle: Cluster Operations
keywords: portworx, pxctl, command-line tool, cli, reference
description: This guide shows you how to use the pxctl to perform cluster operations.
weight: 4
---

This document outlines how to manage your _Portworx_ cluster operation with `pxctl cluster`.

First, let's get an overview of the available commands:

```text
/opt/pwx/bin/pxctl cluster --help
```

```
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

To list all nodes in your _Portworx_ cluster, run:

```text
pxctl cluster list
```

```
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

```
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

```
node bf9eb27d-415e-41f0-8c0d-4782959264bc deleted successfully
```

To get help, run:

```text
pxctl cluster delete --help
```

```
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

## Showing nodes based on IO Priority

To list the nodes in your _Portworx_ cluster based on IO Priority (high, medium and low), type:

```text
pxctl cluster provision-status --io_priority low
```

```
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

```
NAME:
   pxctl cluster provision-status - Show cluster provision status

USAGE:
   pxctl cluster provision-status [command options] [arguments...]

OPTIONS:
   --io_priority value  IO Priority: [high|medium|low] (default: "low")
```

## Enabling optimized restores

{{% content "reference/CLI/shared/optimized-restores-definition.md" %}}

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
      --resync-repl-add string               Enable or disable repl-add based resync (Valid Values: [on off]) (default "off")
      --domain-policy string                 Domain policy for domains (Valid Values: [strict eventual]) (default "strict")
      --optimized-restores string            Enable or disable optimized restores (Valid Values: [on off]) (default "off")
      --disable-provisioning-labels string   Semi-colon separate string
      --provisioning-commit-labels string    Json, example of global rule followed by node specific and pool specific rule: '[{'OverCommitPercent': 200, 'SnapReservePercent': 30},{'OverCommitPercent': 50, 'SnapReservePercent':30, 'LabelSelector':{'node':'node-1,node-2', 'poolLabel':'poolValue'},]'
      --auto-decommission-timeout uint       Timeout (in minutes) after which storage-less nodes will be automatically decommissioned. Timeout cannot be set to zero. (default 20)
      --internal-snapshot-interval uint      Interval (in minutes) after which internal snapshots are rotated (default 30)
      --repl-move-timeout uint               Timeout (in minutes) after which offline replicas will be moved to available nodes. Set timeout to zero to disable replica move. (default 1440)
      --re-add-wait-timeout uint             Timeout (in minutes) after which re-add will abort and new replication node is added instead. Set timeout to zero to disable replica move. (default 1440)
  -h, --help                                 help for update
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

## pxctl cluster options update --provisioning-commit-labels reference

```text
--provisioning-commit-labels '[{"OverCommitPercent": <percent_value>, "SnapReservePercent": <percent_value>, "LabelSelector": {"<label_key>": "<label_value>"}},{"OverCommitPercent": <percent_value>, "SnapReservePercent":<percent_value>} ]'
```

| Key | Description | Value |
| --- | --- | --- |
| OverCommitPercent | The maximum storage percentage volumes can provision against backing storage | Any integer over 100 |
| SnapReservePercent | The percent of the previously specified maximum storage storage percentage that is reserved for snapshots | Any integer under 100 |
| labelSelector | The key values for labels or node IDs you wish to apply this rule to | Enumerated string: `node` with a comma separated list of node IDs <br/> Any existing label key and value. |
