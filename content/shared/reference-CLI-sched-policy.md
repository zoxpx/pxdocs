---
title: Shared content for managing snapshot schedule policies using pxctl
keywords: portworx, pxctl, snapshot, reference, schedule, policy
description: Shared content for managing snapshot schedule policies using pxctl
hidden: true
---

The example below creates a policy named `p1` with the following properties:

- Portworx performs periodic backups every 60 minutes and keeps the last periodic 5 backups
- Portworx performs weekly backups every Sunday at 12:00 and keeps the last 4 weekly backups

Run the following command to create the `p1` backup policy:

```text
pxctl sched-policy create --periodic 60,5 --weekly sunday@12:00,4 p1
```

You can add schedule policies either when a volume gets created or afterward.

Here is an example of how you can add a schedule policy when the volume is created:

```text
pxctl volume create --policy p1 vol1
```

The following example adds or updates a schedule policy later:

```text
pxctl volume snap-interval-update --policy p1 vol1
```

The example below removes a policy from a volume by setting the snap interval to 0:

```
pxctl volume snap-interval-update --periodic 0 vol1
```