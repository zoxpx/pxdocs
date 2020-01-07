---
title: Volume access using pxctl
linkTitle: Volume Access
keywords: portworx, pxctl, command-line tool, cli, reference, volume access rules, read access, write access, admin access, show volume access, add volume access, remove volume access, update volume access, volume ownership
description: Learn to update volume access in your Portworx cluster
weight: 16
---

## Overview
This document outlines how to manage your volume access rules. Portworx allows you to change access permissions per volume. There are two ways to provide access, one is by adding a group and the other is by adding a specific user as a collaborator. When adding a collaborator, you must use the unique id of the user. Please consult with your admin on how to obtain the unique id of the user.

## Access types
When adding a group or collaborator, an access type must also be given, which can be either Read, Write, or Admin:

* __Read__ access type allows access to the volume without modifying it. With a Read access type, one can clone or inspect the volume.
* __Write__ access type allows modification of the volume and its metadata. For example, the user can mount, unmount, and restore the volume from a snapshot in addition to all Read access.
* __Admin__ access type allows full access to the volume, like deleting the volume in addition to all Write access.


## Setting access types
To set access types, add one of the following suffixes to the group or collaborator separated by a colon ':'

* __r__ - For Read access type
* __w__ - For Write access type
* __a__ - For Admin access type

## Volume access commands
The `pxctl` command-line utility supports the following commands for updating volume access permissions.

#### Add volume access for a single group or collaborator ####

```text
pxctl volume access add <volume> --collaborator user1:a
```

#### Remove volume access from a group or collaborator ####

```text
pxctl volume access remove <volume> --collaborator user1
```

#### Show volume access ####

```text
pxctl volume access show <volume>
```

#### Update full volume access spec ####

```text
pxctl volume access update <volume> --groups group1:r,group2:w --collaborators user1:a
```

#### Updating volume ownership ####

```text
pxctl volume access update <volume> --owner <username>
```

{{<info>}}
The volume owner can only be a single username. In addition, volume ownership updates can only be performed by administrators.
{{</info>}}
