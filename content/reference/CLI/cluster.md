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

### Related topics

* For more information about how to decommission a Portworx node through Kubernetes, refer to the [Decommission a Node](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/decommission-a-node/) page.

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
