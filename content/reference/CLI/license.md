---
title: License operations using pxctl
linkTitle: License
keywords: portworx, pxctl, command-line tool, cli, reference, license
description: Learn how to manage licenses using the Portworx CLI.
weight: 8
---

NOTE: This is available from version 1.2.8 onwards.
Licensing gives details of the licenses present with details of the various features allowed and its limits within a given license.

#### License help {#license-help}

`pxctl license --help` command gives details of the help.

```text
/opt/pwx/bin/pxctl license --help
NAME:
   pxctl license - Manage licenses

USAGE:
   pxctl license command [command options] [arguments...]

COMMANDS:
     list, l        List available licenses
     add            Add a license from a file
     activate, act  Activate license from a license server

OPTIONS:
   --help, -h  show help
```

#### pxctl license list {#pxctl-license-list}

`pxctl license list` command is used to list the details of the licenses. This command gives details of various features limits allowed to run under the current license for the end user. Product SKU gives the details of the license.

```text
/opt/pwx/bin/pxctl license list
DESCRIPTION                  ENABLEMENT      ADDITIONAL INFO
Number of nodes maximum         1000
Number of volumes maximum       1024
Volume capacity [TB] maximum      40
Storage aggregation              yes
Shared volumes                   yes
Volume sets                      yes
BYOK data encryption             yes
Resize volumes on demand         yes
Snapshot to object store         yes
Bare-metal hosts                 yes
Virtual machine hosts            yes
Product SKU                     Trial        expires in 30 days

LICENSE EXPIRES: 2017-08-17 23:59:59 +0000 UTC
For information on purchase, upgrades and support, see
https://docs.portworx.com/knowledgebase/support.html
```

#### pxctl license activate {#pxctl-license-activate}

The easiest way to activate a license is to get an **activation id** from Portworx, Inc.. Next, run the following command on your Portworx node:

#### pxctl license add {#pxctl-license-add}

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
