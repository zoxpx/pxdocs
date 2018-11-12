---
title: "Pre-requisites : Devicemapper setup"
keywords: portworx, px-developer, devicemapper
description: Portworx recommends using devicemapper as the default graph driver for container images. Follow these instructions to setup Device Mapper for your distribution.
weight: 3
linkTitle: Devicemapper Thinpool setup
---

Portworx recommends using devicemapper as the default graph driver for container images.

Please follow [these instructions](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/#/configure-docker-with-devicemapper) to setup Device Mapper for your distribution.

[This script](https://raw.githubusercontent.com/portworx/px-docs/gh-pages/devicemapper-setup.sh) can also be used to help with the basic thinpool and devicemapper setup.

Please note the following caveats:

 * This script must be run as 'root'
 * This script requires one command line argument for the device to be used
 * This is intended to run at docker installation time (and will stop docker if it's already running)
