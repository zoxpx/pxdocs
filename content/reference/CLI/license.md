---
title: License operations using pxctl
linkTitle: License
keywords: pxctl, command-line tool, cli, reference, list licenses, add license, activate license, offline-activation, license transfer, list available features, px-developer, Portworx Enterprise
description: Learn how to manage licenses using the Portworx CLI.
weight: 14
---

This document explains how to manage your Portworx licenses with
`pxctl license`. The CLI lets you add, activate, and transfer licenses. It also gives details about the installed licenses, and it shows what features are available within a given license.

## Overview

Here's how to get the list of the available subcommands:

```text
pxctl license --help
```

```output
Manage licenses

Usage:
  pxctl license [flags]
  pxctl license [command]

Available Commands:
  activate    Activate license from a license server
  add         Add a license from a file
  list        List available licenses
  setls       Set license server
  transfer    Transfer license to remote PX cluster

Flags:
  -h, --help   help for license

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

Use "pxctl license [command] --help" for more information about a command.
```

Now, let's have a closer look at these commands.

## List available licenses

You can use `pxctl license list` to list installed licenses as follows:

```text
pxctl license list
```

```output
DESCRIPTION				ENABLEMENT	ADDITIONAL INFO
Number of nodes maximum			1000
Number of volumes maximum		100000
Volume capacity [TB] maximum		  40
Storage aggregation			 yes
Shared volumes				 yes
Volume sets				 yes
BYOK data encryption			 yes
Resize volumes on demand		 yes
Snapshot to object store [CloudSnap]	 yes
Cluster-level migration [Kubemotion]	 yes
Bare-metal hosts			 yes
Virtual machine hosts			 yes
Product SKU				Trial		expires in 6 days, 12:13

LICENSE EXPIRES: 2019-04-07 23:59:59 +0000 UTC
For information on purchase, upgrades and support, see
https://docs.portworx.com/knowledgebase/support.html
```

As you can see, the command gives details on the features allowed under the current licenses and it also lists the SKU.

## Activate a license

The easiest way to activate a license is to get an **activation id** from Portworx, Inc.. Next, run the following command on your Portworx node:

```text
pxctl license activate <activation-id>
```

{{<info>}}
**NOTE:** You can also execute the `pxctl license activate` command inside a Pod as follows:

```text
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl license activate <activation-id>
```

{{</info>}}


However, there are cases where the servers are configured without access to the Internet. Such customers should request an offline-activation license file, and install it like this:

```text
pxctl license add <license file>
```

## Connect to a license server

You can connect a Portworx cluster to a license server using the `pxctl license setls` command. To see the list of available flags, enter the `-h` flag:

```text
pxctl license setls --help 
```
```output
Set license server

Usage:
  pxctl license setls [flags]

Examples:
  pxctl license setls http://hostname:7070/fne/bin/capability

Flags:
      --add feat1[,feat2,...]   add license features (feat1[,feat2,...] format)
      --ca-path files           extra root CA files (/usr/share/ca-certificates/extra/root-corp.crt[,/path2/lvl2-corp.crt] format)
  -h, --help                    help for setls
      --import-unknown-ca       auto-import self-signed root CA certificate
  -i, --interval .M.w.d.h.m.s   license borrow interval (.M.w.d.h.m.s [e.g. 1w15m] or number)
```

Connect your Portworx cluster to a license server by entering the `pxctl license setls` command with the following:

* **Optional:** The `--add` option with a comma delimited list of additional feature licenses you want to add. This will add any of the specified feature licenses, as long as the license server has enough available feature license seats. 
* The license server endpoint.

```text
pxctl license setls --add <feature-license>,<feature-license> <license-server-endpoint>
```


