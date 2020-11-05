---
title: Portworx SDK
keywords: OpenStorage SDK, API, gRPC, REST, monitoring, management, programmatic control
description: Details on using the Portworx SDK for programmatic control
weight: 3
linkTitle: Developer SDK
noicon: true
series: reference
---

Portworx data services can be managed and monitored through the [OpenStorage SDK](https://libopenstorage.github.io).


### OpenStorage SDK Ports

When you connect your OpenStorage SDK client to Portworx you can use either the
default gRPC port 9020 or the default REST Gateway port of 9021. If the port
range has been configured to another location during installation, you will find
the OpenStorage SDK ports by grepping for SDK in the Portworx container logs.

### OpenStorage versions

The following table shows the OpenStorage SDK version released in each version of Portworx:

| Portworx Version | OpenStorage SDK Version |
| ---------------- | ----------------------- |
| v1.6.x, v1.7.x | [v0.9.x](https://libopenstorage.github.io/w/reference.html) |
| 2.0.x | [v0.22.x](https://libopenstorage.github.io/w/reference.html) |
| 2.1.x, 2.2.x, 2.3.x, 2.4.x, 2.5.x | [v0.42.x](https://libopenstorage.github.io/w/reference.html) |
| 2.6.x | [v0.69.x](https://libopenstorage.github.io/w/reference.html) |

You may need to match the version of the OpenStorage SDK Client version.
