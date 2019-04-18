---
title: Group Snaps using pxctl
keywords: portworx, pxctl, command-line tool, cli, reference
description: Explore the CLI reference guide for taking group snapshots of container data volumes using Portworx. Try it today!
linkTitle: Group Snaps
weight: 5
---

This document explains how to take group snapshots of your container data with _Portworx_.

First, let's get an overview of the available flags before diving in:

```text
pxctl volume snapshot group -h
```

```
Create group snapshots for given group id or labels

Usage:
  pxctl volume snapshot group [flags]

Aliases:
  group, g

Flags:
  -g, --group string        group id
  -l, --label string        list of comma-separated name=value pairs
  -v, --volume_ids string   list of comma-separated volume IDs
  -h, --help                help for group

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

To take a group snapshot of the volumes labelled with `v1=x1`, use this command:

```text
pxctl volume snapshot group --label v1=x1
```

```
Volume 549285969696152595 : Snapshot 1026872711217134654
Volume 952350606466932557 : Snapshot 218459942880193319
```

You can easily group volumes by IDs and take a group snapshot with the `--volume_ids` flag:

```text
pxctl volume snapshot group --volume_ids 83958335106174418,874802361339616936
```

```
Volume 83958335106174418 : Snapshot 362408823552094597
Volume 874802361339616936 : Snapshot 895516478416742770

```

