---
title: Storage Policy
description: Manage portworx storage policies
keywords: portworx, storage policy, volume
weight: 1
series: concepts
---

## Overview
The **Storage Policy** feature lets you manage storage policies in PX cluster.
Storage Policy allows adminstrator to ensure volume being created on PX cluster has to
follows set of specs/rules based on storage policy set.

For example, you can set storage policy which ensures volume created
on PX cluster has minimum replication level 2.

To create and manage storage policy, use `pxctl storage-policy/[stp]`

## Create Storage Policy

Create storage policy takes set of volume specs to be followed by volume create operation.

```
# pxctl storage-policy create devpol --replication 2,min --secure --sticky --periodic 60,10
 
# pxctl storage-policy list
StoragePolicy   Description
devpol          HA="2,Minimum" Encrypted="true" Sticky="true"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...
```
If `devpol` storage policy is set to **default** , then volume created afterword will have minimum repl level 2, encryption enabled, sticky bit on and periodic snapshot schedule 60 mins, 10 keeps

## Set default storage policy

If storage policy is set as default, volume created afterward will follow volume parameters defined by storage policy. 
You can use `pxctl storage-policy set-default` option to set storage policy as default policy in portworx cluster

Set **devpol** as default storage policy
```
# pxctl storage-policy set-default devpol
Storage Policy *devpol* is set to default

# pxctl storage-policy list
StoragePolicy   Description
*devpol         Encrypted="true" Sticky="true" SnapInterval="periodic 1h0m0s,keep last 10"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...

# pxctl storage-policy inspect devpol
Storage Policy  :  devpol
    Default                   : Yes
    HA                        : 2,Minimum
    Encrypted                 : true
    Sticky                    : true
    SnapInterval              : periodic 1h0m0s,keep last 10
```
Let's create volume Create volume with less ha level than specified in default storage policy

```
# pxctl v c polvol --repl 1 --size 10
pxctl v i Volume successfully created: 745102698654969688
```
**Note**:  Volume Should be created with properties repl 2, secure and snap schedules as periodic 60,10
```
# ## Inspect Volume ##
# pxctl v i polvol
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

## Remove default storage policy restriction

To remove storage policy restriction from PX cluster use `pxctl storage-policy unset-default` . This will remove any storage policy restriction on
volume
```
# pxctl storage-policy list
StoragePolicy   Description
*devpol         Encrypted="true" Sticky="true" SnapInterval="periodic 1h0m0s,keep last 10"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...

# ## remove default storage policy restriction ##
# pxctl stp unset-default qapol
Default storage policy restriction is removed

# ## check whether policy is disabled ##
# pxctl storage-policy list
devpol          Encrypted="true" Sticky="true" SnapInterval="periodic 1h0m0s,keep last 10"...
qapol           HA="2,Minimum" Encrypted="true" Sticky="true"...

# ## pxctl storage-policy inspect devpol ##
Storage Policy  :  devpol
    Default                  :  No
    HA                       :  Minimum 2
    Encrypted                :  true
    Sticky                   :  true
    Snapshot             :  periodic 1h0m0s,keep last 10

# pxctl v c nonpol --size 10 --repl 1
Volume successfully created: 880058853866312532
# # Inspect volume
# pxctl v i nonpol
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

## Update Storage Policy

You can update existing storage policy parameter.
eg. Update `qapol` replication from `2,Equal to 1,min` 

```
# pxctl stp list    
StoragePolicy Description
prodpol       IOProfile="IO_PROFILE_CMS" SnapInterval="policy=snapSched" HA="2,Equal"...
qapol         SnapInterval="policy=weekpol" HA="2,Minimum" Sticky="true"...
# pxctl stp update qapol --replication 1,min
# pxctl stp list
StoragePolicy Description
prodpol       HA="2,Equal" Encrypted="true" Sticky="true"...
qapol         HA="1,Minimum" Sticky="true" SnapInterval="policy=weekpol"...

```

If storage policy which is being updated , is already set as default . Then volume creation thereafter will follow updated default policy specs

```
# pxctl stp list
StoragePolicy Description
prodpol       Sticky="true" IOProfile="IO_PROFILE_CMS" SnapInterval="policy=snapSched"...
*qapol        HA="1,Minimum" Sticky="true" SnapInterval="policy=weekpol"...

# pxctl stp inspect qapol
Storage Policy : qapol
    Default         : Yes
    HA              : 1,Minimum
    Sticky          : true
    SnapInterval    : policy=weekpol

# ## Updating default policy qapol ##
# pxctl stp update qapol --policy snapSched
# pxctl stp inspect qapol
Storage Policy : qapol
        Default         : Yes
        HA              : 1,Minimum
        Sticky          : true
        SnapInterval    : policy=snapSched
```

Let's create volume, it will have **snapSched** as snapshot policy attached
```
# pxctl v c updatedqapol --size 10
Volume successfully created: 1131539442993682535
# pxctl v i updatedqapol
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

## Delete Storage Policy

Use pxctl storage-policy delete policyname to delete storage policy. If you need to delete default policy --force flag is required.

```
# pxctl stp delete  devpol
Storage Policy devpol is deleted

# ## qapol is default storage policy ##
# pxctl stp delete qapol --force
Storage Policy qapol is deleted
```
**Note**: Deleting default storage policy, will remove volume creation restriction specified by policy

## Create volumes by specifying storage policy
You can specify storage policy during volume create, volume created will follow storage policy rules

```
# pxctl stp create testpol --replication 2,min --sticky --weekly sunday@08:30,8
# pxctl stp list
StoragePolicy   Description
testpol         HA="2,Minimum" Sticky="true" SnapInterval="weekly Sunday@08:30,keep last 8"...
# pxctl stp inspect testpol
Storage Policy  :  testpol
    Default                  :  No
    Sticky                    : true
    SnapInterval              : weekly Sunday@08:30,keep last 8
    HA                        : 2,Minimum
 ```   
Create volume using storage policy **testpol**

```
# pxctl v c customvol --size 10 --storagepolicy testpol
Volume successfully created: 492212712402729915
[root@ip-70-0-78-110 ~]# pxctl v i customvol
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

* Specs such as `replication 2` , snapshot policy `weekly Sunday@08:30,keep last 8` and `sticky` set to volume 
* Specifying custom policy will override, default storage policy if any

## Storage Policy Parameters

`pxctl storage policy create` show the available options through the –help command, description of how those options applied is as below :

```
a) If below flags are specified while creating storage policy,  volume creation will have respective spec applied. 
(You need to set default storage policy to make it in affect)

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

b) You can specify min,max or equal replication while creating storage policy. 

eg. :-

1) replication 2,min

If storage policy created with replication 2,min flag. Volume created will be ensured to have replication level at least 2

2) replication 2,max

If storage policy create with replication 2,flag. Volume created will be ensured to have maximum replication specified 2

3) replication 2

If storage policy created with replication 2, Volume created will have exact replication level 2
```


{{<homelist series="px-storage-policy">}}