---
title: Scheduled snapshots
weight: 2
hidesections: true
linkTitle: Scheduled snapshots
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones
description: Learn how to create scheduled consistent snapshots/backups and restore them.
series: k8s-storage-snapshots
---

## Prerequisites

### Stork version

Stork version 2.2 or above is required.

{{% content "portworx-install-with-kubernetes/storage-operations/create-snapshots/shared/k8s-cloud-snap-creds-prereq.md" %}}

### Storkctl

{{% content "portworx-install-with-kubernetes/disaster-recovery/shared/stork-helper.md" %}}

## Creating a schedule policy

Schedule policies can be used to specify when a specific action has to be triggered. There are 4 sections in a schedule policy spec:

* **Interval:** the interval in minutes after which the action should be triggered
* **Daily:** the time at which the action should be triggered every day
* **Weekly:** the day of the week and the time in that day when the action should be triggered
* **Monthly:** the date of the month and the time on that date when the action should be triggered.

Let's look at an example of how we could create a daily and weekly policy.

Create a daily policy with the following `policy-daily.yaml`:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: SchedulePolicy
metadata:
  name: daily
policy:
  daily:
    time: "10:14PM"
    retain: 3
```

```text
kubectl apply -f policy-daily.yaml
```

```
schedulepolicy.stork.libopenstorage.org/daily created
```

Similarly, create a weekly policy with the following `policy-weekly.yaml`:

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: SchedulePolicy
metadata:
  name: weekly
policy:
  weekly:
    day: "Thursday"
    time: "10:13PM"
    retain: 2
```

```text
kubectl apply -f policy-weekly.yaml
```

If you want to check the status of our schedule policy, type:

```text
storkctl get schedulepolicy
```

```
NAME      INTERVAL-MINUTES   DAILY     WEEKLY             MONTHLY
daily     N/A                10:14PM   N/A                N/A
weekly    N/A                N/A       Thursday@10:13PM   N/A
```

## Creating a storage class

Now that we've defined a schedule policy let's create a new `StorageClass` spec. By adding the new annotations, it'll automatically create a schedule for the newly created PVCs.

Create a new file called `sc-with-snap-schedule.ymal` and paste into it the content from below:

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: px-sc-with-snap-schedules
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   snapshotschedule.stork.libopenstorage.org/default-schedule: |
     schedulePolicyName: daily
     annotations:
       portworx/snapshot-type: local
   snapshotschedule.stork.libopenstorage.org/weekly-schedule: |
     schedulePolicyName: weekly
     annotations:
       portworx/snapshot-type: cloud
       portworx/cloud-cred-id: <credential-uuid>
```

The above StorageClass references 2 schedules. The `default-schedule` backs up volumes to the local Portworx cluster on a daily basis. The `weekly-schedule` backs up volumes to cloud storage on a weekly basis.

### Specifying the cloud credential to use

{{<info>}}Specifying the `portworx/cloud-cred-id` is required only if you have more than one cloud credentials configured. If you have a single one, by default, that credential is used.{{</info>}}

Let's list all the available cloud credentails we have.

```text
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl credentials list
```


The above command will output the credentials required to authenticate/access the objectstore. Pick the one you want to use for this snapshot schedule and specify it in the `portworx/cloud-cred-id` annotation in the StorageClass.

Next, let's apply our newly created storage class:

```text
kubectl apply -f sc-with-snap-schedule.ymal
```
```
storageclass.storage.k8s.io/px-sc-with-snap-schedules created
```

## Create a PVC

After we've created the new `StorageClass`, we can refer to it by name in our PVCs like this:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-snap-schedules-demo
  annotations:
    volume.beta.kubernetes.io/storage-class: px-sc-with-snap-schedules
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

Paste the listing from above into a file named `pvc-snap-schedules-demo.yaml` and run:

```text
kubectl create -f pvc-snap-schedules-demo.yaml
```

```
persistentvolumeclaim/pvc-snap-schedules-demo created
```

Let's see our PVC:

```text
kubectl get pvc
```

```
NAME                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                AGE
pvc-snap-schedules-demo   Bound    pvc-3491fc8a-6222-11e9-89a9-080027ee1df7   2Gi        RWO            px-sc-with-snap-schedules   14s
```

The above output shows that a volume named `pvc-3491fc8a-6222-11e9-89a9-080027ee1df7` was automatically created and is now bounded to our PVC.

We're all set!

## Checking snapshots

### Verifying snapshot schedules

First let's verify that the snapshot schedules are created correctly.

```text
storkctl get volumesnapshotschedules
```

```
NAME                                       PVC                       POLICYNAME   PRE-EXEC-RULE   POST-EXEC-RULE   RECLAIM-POLICY   SUSPEND   LAST-SUCCESS-TIME
pvc-snap-schedules-demo-default-schedule   pvc-snap-schedules-demo   daily                                         Retain           false
pvc-snap-schedules-demo-weekly-schedule    pvc-snap-schedules-demo   weekly                                        Retain           false
```

Here we can see 2 snapshot schedules, one daily and one weekly.

### Verifying snapshots

Now that we've put everything in place, we would want to verify that our cloudsnaps are created.

### Using storkctl

Also, you can use `storkctl` to make sure that the snapshots are created by running:

```text
storkctl get volumesnapshots
```

```
NAME                                                                  PVC                       STATUS    CREATED               COMPLETED             TYPE
pvc-snap-schedules-demo-default-schedule-interval-2019-03-27-015546   pvc-snap-schedules-demo   Ready     26 Mar 19 21:55 EDT   26 Mar 19 21:55 EDT   local
pvc-snap-schedules-demo-weekly-schedule-interval-2019-03-27-015546    pvc-snap-schedules-demo   Ready     26 Mar 19 21:55 EDT   26 Mar 19 21:55 EDT   cloud
```
