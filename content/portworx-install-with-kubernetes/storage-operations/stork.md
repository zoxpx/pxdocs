---
title: "Using Stork with Portworx"
hidden: true
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, hci, hyperconvergence, snapshot
description: How to use Portwork's Stork for storage scheduling in Kubernetes.
---

Stork is the Portworx's storage scheduler for Kubernetes that helps achieve even tighter integration of
Portworx with Kubernetes. It allows users to co-locate pods with their data,
provides seamaless migration of pods in case of storage errors and makes it
easier to create and restore snapshots of Portworx volumes

Stork consists of 2 components, the Stork scheduler and an extender. Both of these componenets run in HA mode with 3 replicas by default.

## Install
### Install using the Portworx spec generator
When installing Portworx through the Portworx spec generator page in [PX-Central](https://central.portworx.com),
you can select Stork to be installed along with Portworx.

If you are using [curl to fetch the Portworx spec](/portworx-install-with-kubernetes/px-k8s-spec-curl), you can add
`stork=true` to the parameter list to include Stork specs in the generated file.

### Manual install

If you want to install Stork manually, you can follow the [steps mentioned on the
Stork project page](https://github.com/libopenstorage/stork#running-stork)

## Using Stork with your applications

To take advantage of the feature of Stork, you need to specify it as the
scheduler to be used when creating your applications. This can be done by adding
the schedulerName to your application.

An example of a mysql deployment which uses Stork as the scheduler can be found
[here](https://github.com/libopenstorage/stork/blob/master/specs/mysql.yaml).

## Snapshots with Stork

With Stork you can create and restore snapshots of Portworx volumes from Kubernetes. Instructions to perform these operations can be found
[here](/portworx-install-with-kubernetes/storage-operations/create-snapshots)

## Contribute

Portworx, Inc. welcomes contributions to Stork, which is open-source and repository is at https://github.com/libopenstorage/stork
