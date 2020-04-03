---
title: Etcd for Portworx
keywords: Install, etcd, portworx, kvdb
description: Instructions on installing and configuring an external ETCD cluster for Portworx
linkTitle: Etcd for Portworx
series: kb
weight: 1
---

Portworx requires a key-value database such as etcd for configuring storage. A highly available clustered etcd with persistent storage is preferred.

This page list various approaches for installing an external ETCD cluster and provides recommendations on best practices.

{{<info>}}With Portworx 2.0 and above, you can use Internal KVDB during installation. In this mode, Portworx will create and manage an internal key-value store (kvdb) cluster.{{</info>}}

### Requirements

For production Portworx clusters, Portworx, Inc. recommends the following configuration of an etcd cluster:

1. Etcd Version > 3.1.x
2. Minimum 3 nodes
3. Minimum 8G of memory dedicated to each etcd node.
4. Each Etcd node in the etcd cluster backed with storage disks (minimum 100GB)

More detailed set of hardware requirements as recommended by etcd can be found [here](https://etcd.io/docs/v3.3.12/op-guide/hardware/).

### Setup

You can use one of the following methods to setup an etcd cluster

#### Setup an ETCD cluster with a static set of nodes

If you have 3 static nodes where you want to run etcd follow [this](/reference/knowledge-base/etcd-quick-setup) guide to setup systemd services for an etcd cluster.

#### Setup an ETCD cluster using the official documentation

Follow [this](https://etcd.io/docs/v3.3.12/op-guide/clustering/) detailed step by step process provided by etcd to setup a brand new multi-node cluster.

#### Setup an ETCD cluster using Ansible Playbook

Follow [this](https://github.com/portworx/px-docs/blob/gh-pages/etcd/ansible/index.md) ansible playbook to install a 3 node etcd cluster.


### Tuning Etcd

Etcd provides multiple knobs to fine tune the cluster based on your needs. We recommend fine tuning the following three settings.

#### Compaction

etcd keeps an exact history of its keyspace, this history should be periodically compacted to avoid performance degradation and eventual storage space exhaustion. Regular compaction ensures that the memory usage of the etcd process is under check.
The keyspace can be compacted automatically with etcd's time windowed history retention policy, or manually with `etcd`.

We recommend keeping history for last 3 hours. While setting up etcd you can specify the retention policy in the following way:

```text
etcd --auto-compaction-retention=3
```

#### Database Size (Space Quota)

The space quota in etcd ensures the cluster operates in a reliable fashion. Without a space quota, etcd may suffer from poor performance if the keyspace grows excessively large, or it may simply run out of storage space, leading to unpredictable cluster behavior.

We recommend setting the space quota to max value of 8Gi. While setting up etcd you can specify the space quota in the following way:

```text
etcd --quota-backend-bytes=$((8*1024*1024*1024))
```

#### Snapshots

Etcd provides a command to take snapshots of its keyspace which can be used to restore the etcd cluster in case of a complete disaster. We recommend running the following command as a part of a cron job which will take periodic snapshots

```text
ETCDCTL_API=3 etcdctl --endpoints="<comma-separated-etcd-url>" snapshot save </path/to/snapshot-file> --command-timeout=60s
```

You can run the above command either on the etcd nodes or on a separate node where you would want to store these etcd snapshots.

For a more detailed setup, maintenance and tuning information refer the following coreos etcd reference docs.

* [Maintenance](https://etcd.io/docs/v3.3.12/op-guide/maintenance/)
* [Tuning](https://etcd.io/docs/v3.3.12/tuning/)
* [Recovery from failure](https://etcd.io/docs/v3.3.12/op-guide/recovery/)
* [Consul](https://www.consul.io/intro/getting-started/join.html)

### Securing with certificates in Kubernetes

SSL certificates for etcd can be stored as Kubernetes secrets. Three files are required - in this example, the CA certificate is `etcd-ca.crt`, the etcd certificate `etcd.crt` and the etcd key `etcd.key`. These files should be copied to a directory on the Kubernetes master (`etcd-secrets`). Next, create a secret from these files:

```text
kubectl -n kube-system create secret generic px-kvdb-auth --from-file=etcd-secrets/
```

```output
secret/px-kvdb-auth created
```

```text
kubectl -n kube-system describe secret px-kvdb-auth
```

```output
Name:         px-kvdb-auth
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
etcd-ca.crt:      1679 bytes
etcd.crt:  1680 bytes
etcd.key:  414  bytes
```

Use the Portworx spec generator in [PX-Central](https://central.portworx.com), selecting "Certificate Auth" under the etcd section, ensuring the filenames match those specified.
