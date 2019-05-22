---
title: Install Portworx with Ansible
linkTitle: Install with Ansible
keywords: portworx, container, Nomad, storage, Ansible
description: Instructions for installing Portworx on Nomad with Ansible.
weight: 1
series: px-install-on-nomad-with-others
noicon: true
hidden: true
---

## Installing

To install with **Ansible**, please use the [Ansible Galaxy Role](https://galaxy.ansible.com/portworx/portworx-defaults/)

## Upgrading

If you have installed Portworx with Ansible, _Portworx_ needs to be upgraded through the CLI on a node-by-node basis. Please see the [upgrade instructions](/install-with-other/operate-and-maintain)

## Scaling

For Ansible, as long as the same `kvdb` and `clusterID` are used, any new nodes can automatically join an existing cluster. Also, be sure to exclude existing nodes from the inventory before running the playbook on the new nodes.