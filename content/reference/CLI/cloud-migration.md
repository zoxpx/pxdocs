---
title: Cloud migrations using pxctl
linkTitle: Cloud Migrations
keywords: portworx, container, Kubernetes, storage, Docker, k8s, cloud, DR, disaster recovery, cluster, migration
description: Learn to migrate volumes between clusters using pxctl
weight: 12
---

This document explains how to migrate _PX_ volumes between clusters. In order to do this, we'll first have to pair up 2 clusters and then issue the migration command to _Portworx_.

{{<info>}}
The pairing is **uni-directional**. Say there are two clusters- C1 and C2. If you pair C1 with C2 you can only migrate volumes from C1 to C2.
{{</info>}}

With _Portworx_, there are two ways of migrating volumes between clusters:

* using `pxctl` or
* using `Stork` on `Kubernetes`

This document will cover the steps required to migrate _PX_ volumes between clusters using `pxctl`. If you want to migrate your volumes using `Stork` on `Kubernetes`, head over to the [PX-Motion](/portworx-install-with-kubernetes/migration/px-motion/) page.


## Prerequisites

### Configuring a secret store

Before we begin, make sure you have configured a [secret store] (/key-management/) on both clusters. This will be used to store the credentials for the objectstore.

## Pairing clusters

The installation may take a while, depending on your Intenet connection. Once the installation is finished we're going to want to pair our clusters.

First, let's get the cluster token of the destination cluster. Run the following command from one of the _Portworx_ nodes in the **destination cluster**:


```text
pxctl cluster token show
```

You should see something like:

```
Token is 0795a0bcd46c9a04dc24e15e7886f2f957bfee4146442774cb16ec582a502fdc6aebd5c30e95ff40a6c00e4e8d30e31d4dbd16b6c9b93dfd56774274ee8798cd
```

Next, let's jump to the **source cluster** and create the cluster pair:

```text
pxctl cluster pair create --ip <ip_of_source_destination_cluster_node> --token <token_from_2c>
```

Just to make sure our pairing was created, try running the following command on the second cluster:

```text
/opt/pwx/bin/pxctl cluster pair list
```

The output should look similar to this:

```
ClusterID                                               Name        IP              Port           CredID
7c6fbc24-5b36-4fa1-bf5e-10cbe9576427 (default)          mycluster   192.168.56.75   9001           e28b4bcc-e4d5-4bb9-b9ad-c86a2554d71e
```

You can pair multiple clusters with each other. The first pair created will be listed as the default one.


You can delete a cluster pair by running the following command:

```
pxctl cluster pair delete --id <cluster_id>
```

## Migrating volumes

Now that we've paired our clusters, the next step is to migrate our volume(s) between them by running `pxctl cloudmigrate`.

Let's get a glimpse of the available commands:

```text
pxctl cloudmigrate --help
```

```
Migrate volumes across clusters

Usage:
  pxctl cloudmigrate [flags]
  pxctl cloudmigrate [command]

Aliases:
  cloudmigrate, cm

Available Commands:
  cancel      Cancel migrate tasks
  start       Migrate volume(s) to a paired Portworx cluster
  status      Status of volume migrations

Flags:
  -h, --help   help for cloudmigrate

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

Now, let's use again the built-in help and take a look at how to start migration:

```text
pxctl cloudmigrate start --help
```

```
Migrate volume(s) to a paired Portworx cluster

Usage:
  pxctl cloudmigrate start [flags]

Flags:
  -a, --all                 Migrate all volumes
  -v, --volume_id string    ID of the volume to be migrated
  -c, --cluster_id string   ID of the cluster where the volume should be migrated
  -h, --help                help for start

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

As the above output shows, you can either migrate all volumes or just one.


### Migrating all volumes

To migrate all volumes, run `pxctl cloudmigrate start` with the `-a` and `-c` flags:

```text
pxctl cloudmigrate start -a -c <cluster_id>
```

### Migrating a particular volume

To migrate a particualr volume, try using:

```text
pxctl cloudmigrate start -v <volumeId> -c <cluster_id>
```

### Checking the migration status

While _Portworx_ migrates your volume(s), you can check the status by running the following command:

```text
pxctl cloudmigrate status
```

You should see something similar to this:

```
Cluster UUID: 7c6fbc24-5b36-4fa1-bf5e-10cbe9576427
VolumeId            VolumeName                                  Stage   Status      LastUpdate                          LastSuccess
1028723504085545761 pvc-e0231935-a651-11e8-9e30-0214683e8447    Done    Complete    Wed, 05 Sep 2018 03:04:10 UTC       Wed, 05 Sep 2018 03:04:10 UTC
1147613441858984344 pvc-f21111e1-a651-11e8-9e30-0214683e8447    Done    Complete    Wed, 22 Aug 2018 23:56:19 UTC       Wed, 22 Aug 2018 23:56:19 UTC
228731158998208592  pvc-08d8dcfa-a045-11e8-a76b-0214683e8447    Done    Complete    Wed, 22 Aug 2018 21:18:44 UTC       Wed, 22 Aug 2018 21:18:44 UTC
280749584627774298  pvc-2b7ff70a-a045-11e8-a76b-0214683e8447    Done    Complete    Wed, 22 Aug 2018 21:18:44 UTC       Wed, 22 Aug 2018 21:18:44 UTC
580746088570435304  pvc-82c8508c-b86d-11e8-9e30-0214683e8447    Done    Complete    Wed, 19 Sep 2018 03:21:38 UTC       Wed, 19 Sep 2018 03:21:38 UTC
775806166668776083  pvc-47e9b090-a652-11e8-9e30-0214683e8447    Done    Complete    Wed, 22 Aug 2018 23:56:19 UTC       Wed, 22 Aug 2018 23:56:19 UTC
873404678173271727  pvc-952322a9-b236-11e8-9e30-0214683e8447    Restore Failed      Fri, 14 Sep 2018 19:18:07 UTC       InvalidTime
91307080409549411   pvc-7325480f-a03e-11e8-a76b-0214683e8447    Done    Complete    Wed, 22 Aug 2018 21:18:44 UTC       Wed, 22 Aug 2018 21:18:44 UTC
```

The stages of a particular migration will progress from Backup→ Restore→ Done. If any stage fails the status will be marked as Failed.

If the migration is successful you should see the volume(s) with the same name created on the destination cluster.
