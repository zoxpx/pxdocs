---
title: Portworx on Nomad
linkTitle: Nomad
keywords: portworx, container, Nomad, storage
description: Instructions on installing Portworx on Nomad
weight: 4
series: px-other
noicon: true
---

{{<info>}}
This document presents the **Nomad** method of installing a Portworx cluster. Please refer to the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page if you want to install Portworx on Kubernetes.
{{</info>}}

This section covers information on installing Portworx on Nomad.

Nomad is a scheduler and job orchestrator from HashiCorp for managing a cluster of machines and running applications on them. Nomad abstracts away machines and the location of applications and instead enables users to declare what they want to run and Nomad handles where they should run and how to run them. Portworx can run within Nomad and provide persistent volumes to other applications running on Nomad. This section describes how to deploy and consume Portworx within a Nomad cluster.

## Portworx as a Nomad job

These sections explain how to install, upgrade, and uninstall Portworx using a Nomad job:

{{<homelist series="px-as-a-nomad-job">}}

## Install Portworx on Nomad with other methods

If you do not wish to install Portworx as a Nomad job, proceed to one of the following sections:

{{<homelist series="px-install-on-nomad-with-others">}}

## Useful Information

{{<homelist series="px-nomad-useful-information">}}
