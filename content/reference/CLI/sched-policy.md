---
title: Manage snapshot schedule policies using pxctl
linkTitle: Snapshot Schedule Policies
keywords: portworx, pxctl, snapshot, reference, schedule, policy
description: Learn how to manage snapshot schedule policies using pxctl
weight: 5
---

## Overview

This document explains how to manage your snapshot schedule policies using the `pxctl` command-line tool. To see the list of the available subcommands and flags, run the `pxctl sched-policy` command with the `--help` flag as in the following example:

```text
pxctl sched-policy --help
```

```output
Manage schedule policies

Usage:
  pxctl sched-policy [flags]
  pxctl sched-policy [command]

Aliases:
  sched-policy, sp

Examples:
pxctl sched-policy create --periodic 15 myPolicyName

Available Commands:
  create      Create a schedule policy
  delete      Delete a schedule policy
  list        List all schedule policies
  update      Update a schedule policy

Flags:
  -h, --help   help for sched-policy

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

Use "pxctl sched-policy [command] --help" for more information about a command.
```

### Create a schedule policy

To create a snapshotting policy, use the `pxctl sched-policy create` command. Run it with the `--help` flag to list the available options:

```text
pxctl sched-policy create --help
```

```output
Create a schedule policy

Usage:
  pxctl sched-policy create [flags]

Aliases:
  create, c

Examples:
pxctl sched-policy create [flags] policy-name

Flags:
  -p, --periodic string   periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
  -d, --daily strings     daily snapshot at specified hh:mm,k (keeps 7 by default)
  -w, --weekly strings    weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
  -m, --monthly strings   monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
  -h, --help              help for create

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

{{% content "shared/reference-CLI-sched-policy.md" %}}

### List schedule policies

Run the following command to list your schedule policies:

```text
pxctl sched-policy list
```

```output
Policy	Description
p1		periodic 1h0m0s,keep last 5, weekly Sunday@12:00,keep last 4
```

### Update schedule policies

To update a schedule policy, use the `pxctl sched-policy update` command. Run it with the `--help` flag and you will see the list of the available options:

```text
pxctl sched-policy update --help
```

```output
Update a schedule policy

Usage:
  pxctl sched-policy update [flags]

Aliases:
  update, u

Examples:
pxctl sched-policy update [flags] policy-name

Flags:
  -p, --periodic string   periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
  -d, --daily strings     daily snapshot at specified hh:mm,k (keeps 7 by default)
  -w, --weekly strings    weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
  -m, --monthly strings   monthly snapshot at specified day@hh:mm,k (keeps 12 by default)
  -h, --help              help for update

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

Continuing our previous example with the `p1` schedule policy, let's make it so that our policy creates periodic backups every 120 minutes instead of 60:

```text
pxctl sched-policy update --periodic 120,5 --weekly sunday@12:00,4 p1
```

Now, let's make sure our new settings are applied:

```text
pxctl sched-policy list
```

```output
Policy	Description
p1		periodic 2h0m0s,keep last 5, weekly Sunday@12:00,keep last 4
```

### Delete a schedule policy

To delete a schedule policy, run the `pxctl sched-policy delete` command with the name of the policy you want to delete as a parameter:

```text
pxctl sched-policy delete p1
```
