---
title: Storage policy using pxctl
description: Manage portworx storage policies
keywords: portworx, storage policy, volume
weight: 1
series: concepts
linkTitle: Storage Policy
---

## Overview

This feature lets you manage the **storage policies** of the PX cluster.
Once defined, a **storage policy** ensures that the volumes being created on the PX cluster follow the same set of specs/rules.

To learn about the available commands, type:

```text
pxctl storage-policy --help
```

```
Manage storage policies for creating volumes

Usage:
  pxctl storage-policy [flags]
  pxctl storage-policy [command]

Aliases:
  storage-policy, stp

Examples:
pxctl storage-policy create --replication 2,min --periodic 60,10 devpolicy

Available Commands:
  create        Create a storage policy
  delete        Delete a storage policy
  inspect       Inspect a storage policy.
  list          List all storage policies
  set-default   Set storage policy as default policy
  unset-default Remove default storage policy restriction
  update        Update a storage policy

Flags:
  -h, --help   help for storage-policy

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

Use "pxctl storage-policy [command] --help" for more information about a command.
```

Note that, instead of typing `pxctl storage-policy`, you can use the `stp` shorthand like this:

```text
pxctl stp --help
```

## Create a Storage Policy

Say we want to create a storage policy named `devpol` with:

*   a minimum replication level of 2,
*   encryption enabled,
*   sticky bit on, and
*   periodic snapshot scheduled at 60 mins, with 10 keeps.

Then, you should run the following command:

```text
pxctl storage-policy create devpol --replication 2,min --secure --sticky --periodic 60,10
```

{{<info>}}
To get more details on the available parameters, please refer to the [Storage Policy Parameters](#storage-policy-parameters) Section.
{{</info>}}

Now, let's inspect the storage policy by typing:

```text
pxctl storage-policy list
```

```
StoragePolicy   Description
devpol          HA="2,Minimum" Encrypted="true" Sticky="true"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...
```

## Set the Default Storage Policy

If a storage policy is set as the default one, all volumes created afterward will follow the parameters defined by the said storage policy.

Here is how to set `devpol` as the default storage policy in your PX cluster:

```text
pxctl storage-policy set-default devpol
```

```
Storage Policy *devpol* is set to default
```

Now, let's list the storage policies again:

```text
pxctl storage-policy list
```

The output should look something like this:

```
StoragePolicy   Description
*devpol         Encrypted="true" Sticky="true" SnapInterval="periodic 1h0m0s,keep last 10"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...
```

Notice the `*` in front of `devpol`? It means that `devpol` has been set as the default storage policy.

Let's say you don't remember the settings of the `devpol` storage policy. If so, `pxctl` provides an easy way to refresh your memory:

```text
pxctl storage-policy inspect devpol
```

```
Storage Policy  :  devpol
    Default                   : Yes
    HA                        : 2,Minimum
    Encrypted                 : true
    Sticky                    : true
    SnapInterval              : periodic 1h0m0s,keep last 10
```

Now that we've created a storage policy and set it as the default one, let's move forward and try to create a volume with an HA level lower than the one specified in the default storage policy:

```text
pxctl v c polvol --repl 1 --size 10
```

```
pxctl v i Volume successfully created: 745102698654969688
```

Lastly, we would want to check the settings of the new volume:

```text
pxctl v i polvol
```

```
Volume  :  745102698654969688
    Name                 :  polvol
    Size                 :  10 GiB
    Format               :  ext4
    HA                   :  2
    IO Priority          :  LOW
    Creation time        :  Feb 13 16:41:49 UTC 2019
    Snapshot             :  periodic 1h0m0s,keep last 10
    Shared               :  no
    Status               :  up
    State                :  detached
    Attributes           :  encrypted,sticky
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  131 MiB
    Replica sets on nodes:
        Set 0
          Node       : 70.0.82.116 (Pool 0)
          Node       : 70.0.82.114 (Pool 0)
    Replication Status   :  Detached
 ```

As expected, the volume was being created with the properties inherited from the `devpol` policy:

*   HA is equal to 2,
*   periodic snapshots scheduled every 60 mins, with 10 keeps

## Remove the Default Storage Policy

To remove the default storage policy from a PX cluster use: `pxctl storage-policy unset-default`

Let's look at an example.

Suppose `devpol` was initially set as the default storage policy:

```text
pxctl storage-policy list
```

```
StoragePolicy   Description
*devpol         Encrypted="true" Sticky="true" SnapInterval="periodic 1h0m0s,keep last 10"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...
```

We can remove the default storage policy like so:

```text
pxctl stp unset-default qapol
```

```
Default storage policy restriction is removed
```

To check whether the policy is disabled type:

```text
pxctl storage-policy list
```

```
devpol          Encrypted="true" Sticky="true" SnapInterval="periodic 1h0m0s,keep last 10"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...

```

Can't recall the settings for `devpol`? Here's how to refresh your memory:

```text
pxctl storage-policy inspect devpol
```

```
Storage Policy  :  devpol
    Default                  :  No
    HA                       :  Minimum 2
    Encrypted                :  true
    Sticky                   :  true
    Snapshot             :  periodic 1h0m0s,keep last 10
```

The following creates a volume with a replication level lower than the one specified in `devpol`:

```text
pxctl v c nonpol --size 10 --repl 1
```

```
Volume successfully created: 880058853866312532
```

So, we've created a new volume. Go ahead and inspect its settings:

```text
pxctl v i nonpol
```

```
Volume  :  880058853866312532
    Name                 :  nonpol
    Size                 :  10 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Creation time        :  Feb 13 16:51:16 UTC 2019
    Shared               :  no
    Status               :  up
    State                :  detached
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  2.6 MiB
    Replica sets on nodes:
        Set 0
          Node       : 70.0.82.116 (Pool 0)
    Replication Status   :  Detached
```

As you can see, the replication level is now set to 1.

## Update a Storage Policy

`pxctl` lets you update the parameters of an existing storage policy.

Say you want to update `qapol` and make it so that the current replication parameters (`2,Equal`) become (`1,min`).

First, let's list our storage policies:

``` text
pxctl stp list
```

```
StoragePolicy Description
prodpol       IOProfile="IO_PROFILE_CMS" SnapInterval="policy=snapSched" HA="2,Equal"...
qapol         SnapInterval="policy=weekpol" HA="2,Minimum" Sticky="true"...
```

Then, here's how to update the `replication` parameter for `qapol`:

```text
pxctl stp update qapol --replication 1,min
```

Lastly, we would want to check if the parameter has been updated:

```text
pxctl stp list
```

```
StoragePolicy Description
prodpol       HA="2,Equal" Encrypted="true" Sticky="true"...
qapol         HA="1,Minimum" Sticky="true" SnapInterval="policy=weekpol"...

```

If the storage policy which is being updated is already set as **default** , all volumes created thereafter will follow the updated policy specs.

Again, we are going to walk you through an example.

Start by listing existing storage policies:

```text
pxctl stp list
```

```
StoragePolicy Description
prodpol       Sticky="true" IOProfile="IO_PROFILE_CMS" SnapInterval="policy=snapSched"...
*qapol        HA="1,Minimum" Sticky="true" SnapInterval="policy=weekpol"...
```

The above shows that `qapol` is the default policy. Let's get more details:

```text
pxctl stp inspect qapol
```

```
Storage Policy : qapol
    Default         : Yes
    HA              : 1,Minimum
    Sticky          : true
    SnapInterval    : policy=weekpol
```

Now, we would want to update its parameters:

```text
pxctl stp update qapol --policy snapSched
```

The following checks if the parameters were successfully updated:

```text
pxctl stp inspect qapol
```

```
Storage Policy : qapol
        Default         : Yes
        HA              : 1,Minimum
        Sticky          : true
        SnapInterval    : policy=snapSched
```

Let's create a new volume. It will have **snapSched** as snapshot policy attached:

```text
pxctl v c updatedqapol --size 10
```

```
Volume successfully created: 1131539442993682535
```

Lastly, we would want to inspect the settings of the new volume like so:


```text
pxctl v i updatedqapol
```

```
Volume  :  1131539442993682535
    Name                 :  updatedqapol
    Size                 :  10 GiB
    Format               :  ext4
    HA                   :  1
    IO Priority          :  LOW
    Creation time        :  Feb 19 17:06:53 UTC 2019
    Snapshot             :  policy=snapSched
    Shared               :  no
    Status               :  up
    State                :  detached
    Attributes           :  sticky
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  2.6 MiB
    Replica sets on nodes:
        Set 0
          Node       : 70.0.78.114 (Pool 0)
    Replication Status   :  Detached
```

## Delete a Storage Policy

Use `pxctl storage-policy delete policyname` to delete storage policy:

```text
pxctl stp delete  devpol
```

```
Storage Policy devpol is deleted
```

If you need to delete the default policy, then the `--force` flag is required.

```text
pxctl stp delete qapol --force
```

```
Storage Policy qapol is deleted
```

{{<info>}}
Deleting the default storage policy will remove the volume creation restrictions specified by the policy.
{{</info>}}

## Creating Volumes by Specifying a Storage Policy

When you create a new volume, `pxctl` allows you to specify the storage policy that will be applied to the volume.

Let's see how it works.

Create a new policy like this:

```text
pxctl stp create testpol --replication 2,min --sticky --weekly sunday@08:30,8
```

List storage policies:

```
pxctl stp list
```

```
StoragePolicy   Description
testpol         HA="2,Minimum" Sticky="true" SnapInterval="weekly Sunday@08:30,keep last 8"...
```

Inspect `testpol`:

```text
pxctl stp inspect testpol
```

```
Storage Policy  :  testpol
    Default                  :  No
    Sticky                    : true
    SnapInterval              : weekly Sunday@08:30,keep last 8
    HA                        : 2,Minimum
 ```

Now, let's create a volume named `customvol` using **testpol**:

```text
pxctl v c customvol --size 10 --storagepolicy testpol
```

```
Volume successfully created: 492212712402729915
```

Lastly, let's check `customvol`'s settings:

```text
pxctl v i customvol
```

```
Volume  :  492212712402729915
    Name                 :  customvol
    Size                 :  10 GiB
    Format               :  ext4
    HA                   :  2
    IO Priority          :  LOW
    Creation time        :  Feb 19 17:34:08 UTC 2019
    Snapshot             :  weekly Sunday@08:30,keep last 8
    StoragePolicy        :  testpol
    Shared               :  no
    Status               :  up
    State                :  detached
    Attributes           :  sticky
    Reads                :  0
    Reads MS             :  0
    Bytes Read           :  0
    Writes               :  0
    Writes MS            :  0
    Bytes Written        :  0
    IOs in progress      :  0
    Bytes used           :  2.6 MiB
    Replica sets on nodes:
        Set 0
          Node       : 70.0.78.114 (Pool 0)
          Node       : 70.0.78.110 (Pool 0)
    Replication Status   :  Detached
```

**Note**:

*   Specs such as `replication 2` , snapshot policy `weekly Sunday@08:30,keep last 8` and `sticky` are applied to the new volume
*   Specifying a custom policy will override the default storage policy (if any)

## Storage Policy Parameters

`pxctl storage policy create` shows the available options through the `–help` command.

Here's the description of the options:

```
a) If below flags are specified while creating storage policy, the volume creation will have respective spec applied.
(You need to set a default storage policy to make it in effect)

* sticky - sticky volumes cannot be deleted until the flag is disabled
* journal - Journal data for volume
* secure - encrypt volumes using AES-256
* shared - make a globally shared namespace volumes
* aggregation_level string aggregation level (Valid Values: [1 2 3 auto]) (default "1")
* policy string policy names separated by comma
* periodic mins,k periodic snapshot interval in mins,k (keeps 5 by default), 0 disables all schedule snapshots
* daily hh:mm,k daily snapshot at specified hh:mm,k (keeps 7 by default)
* weekly weekday@hh:mm,k weekly snapshot at specified weekday@hh:mm,k (keeps 5 by default)
* monthly day@hh:mm,k monthly snapshot at specified day@hh:mm,k (keeps 12 by default)

b) You can specify min, max or equal replication while creating a storage policy.

eg. :-

1) replication 2,min

If storage policy created with replication 2, min flag. Volume created will be ensured to have replication level at least 2

2) replication 2,max

If storage policy creates with replication 2, flag. Volume created will be ensured to have maximum replication specified 2

3) replication 2

If storage policy is created with replication 2, Volume created will have exact replication level 2
```


{{<homelist series="px-storage-policy">}}
