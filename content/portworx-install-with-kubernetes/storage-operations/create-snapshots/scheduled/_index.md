---
title: Scheduled snapshots
weight: 2
hidesections: true
linkTitle: Scheduled snapshots
keywords: scheduled snapshots, stork, kubernetes, k8s
description: Learn how to create scheduled consistent snapshots/backups and restore them.
series: k8s-storage-snapshots
---

## Prerequisites

### Stork version

Stork version 2.2 or above is required.

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-cloud-snap-creds-prereq.md" %}}

### Storkctl

{{% content "shared/portworx-install-with-kubernetes-disaster-recovery-stork-helper.md" %}}

## Create a schedule policy

Schedule policies can be used to specify when a specific action has to be triggered. There are 4 sections in a schedule policy spec:

* **Interval:** the interval in minutes after which the action should be triggered
* **Daily:** the time at which the action should be triggered every day
* **Weekly:** the day of the week and the time in that day when the action should be triggered
* **Monthly:** the date of the month and the time on that date when the action should be triggered.

{{<info>}}
Note that scheduled snapshots do not occur if the volume you are trying to snapshot is not attached to a container.
{{</info>}}

### Create a daily policy

1. Create a file named `daily-policy.yaml`, specifying the following fields and values:

  * **apiVersion:** with the version of the Stork scheduler (this example uses `stork.libopenstorage.org/v1alpha1`)
  * **kind:** with the `SchedulePolicy` value
  * **metadata.name:** with the name of the `SchedulePolicy` object (this example uses `daily`)
  * **policy.daily.time:** with the backup time (this example uses "10:14PM")
  * **policy.retain:** with the number of backups Portworx must retain (this example retains 3 backups)

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

2. Apply the spec:

    ```text
    kubectl apply -f daily-policy.yaml
    ```

    ```output
    schedulepolicy.stork.libopenstorage.org/daily created
    ```

### Create a weekly policy

1. Create a file named `weekly-policy`, specifying the following fields and values:

  * **apiVersion:** with the version of the Stork scheduler (this example uses `stork.libopenstorage.org/v1alpha1`)
  * **kind:** with the `SchedulePolicy` value
  * **metadata.name:** with the name of the `SchedulePolicy` object (this example uses `weekly`)
  * **policy.weekly.day:** with the day of the week when Portworx must start the backup (this example uses "Thursday")
  * **policy.weekly.time:** with the backup time (this example uses "10:13PM")
  * **policy.retain:** with the number of backups Portworx must retain (this example retains 2 backups)


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

2.  Apply the spec:

    ```text
    kubectl apply -f weekly-policy.yaml
    ```

3. You can check the status of your schedule policy by entering the `storkctl get schedulepolicy` command:

    ```text
    storkctl get schedulepolicy
    ```

    ```output
    NAME      INTERVAL-MINUTES   DAILY     WEEKLY             MONTHLY
    daily     N/A                10:14PM   N/A                N/A
    weekly    N/A                N/A       Thursday@10:13PM   N/A
    ```

{{<info>}}
**NOTE:** If you do not specify the value of the `retain` field, Portworx will use the following default values:

| Policy | Default value |
|:---:|:---:|
| Interval | 10 |
| Daily | 30 |
| Weekly | 7 |
| Monthly | 12 |
{{</info>}}

## Associate a schedule policy with a StorageClass or a Volume

Once you've defined a schedule policy, you can create and associate `StorageClass` and `Volume` specs with it. Perform one of the following steps, depending on whether you want to schedule snapshots for multiple PVCs or a single volume:

### Create a VolumeSnapshotSchedule

You can create VolumeSnapshotSchedules to backup specific volumes according to a schedule you define.

Create a `VolumeSnapshotSchedule`, specifying:

  * **metadata:**
    * **name:** with the name of this VolumeSnapshotSchedule policy
    * **namespace:** the namespace in which this policy will exist
    * **annotations:**
      * **portworx/snapshot-type:** with the `cloud` or `local` value, depending on what environment you want store your snapshots in
      * **portworx/cloud-cred-id:** with your cloud environment credentials
      * **stork/snapshot-restore-namespaces:** with other namespaces snapshots taken with this policy can restore to
  * **spec:**
    * **schedulePolicyName:** with the name of the schedule policy you defined in the steps above
    * **suspend:** with a boolean value specifying if the schedule should be in a suspended state
    * **preExecRule:** with the name of a rule to run before taking the snapshot
    * **postExecRule:** with the name of a rule to run after taking the snapshot
    * **reclaimPolicy:** with `retain` or `delete`, indicating what Portworx should do with the snapshots that were created using the schedule. Specifying the `delete` value deletes the snapshots created by this schedule when the schedule is deleted.
    * **template:**
      * **spec:**
        * **persistentVolumeClaimName:** with the PVC you want this policy to apply to

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: VolumeSnapshotSchedule
metadata:
  name: mysql-snapshot-schedule
  namespace: mysql
  annotations:
    portworx/snapshot-type: cloud
    portworx/cloud-cred-id: <cred_id>
    stork/snapshot-restore-namespaces: otherNamespace
spec:
  schedulePolicyName: testpolicy
  suspend: false
  reclaimPolicy: Delete
  preExecRule: testRule
  postExecRule: otherTestRule
  template:
    spec:
      persistentVolumeClaimName: mysql-data
```

### Create a storage class

Now that we've defined a schedule policy let's create a new `StorageClass` spec. By adding the new annotations, it'll automatically create a schedule for the newly created PVCs.

Create a new file called `sc-with-snap-schedule.yaml` and paste into it the content from below:

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
kubectl apply -f sc-with-snap-schedule.yaml
```

```output
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

```output
persistentvolumeclaim/pvc-snap-schedules-demo created
```

Let's see our PVC:

```text
kubectl get pvc
```

```output
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

```output
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

```output
NAME                                                                  PVC                       STATUS    CREATED               COMPLETED             TYPE
pvc-snap-schedules-demo-default-schedule-interval-2019-03-27-015546   pvc-snap-schedules-demo   Ready     26 Mar 19 21:55 EDT   26 Mar 19 21:55 EDT   local
pvc-snap-schedules-demo-weekly-schedule-interval-2019-03-27-015546    pvc-snap-schedules-demo   Ready     26 Mar 19 21:55 EDT   26 Mar 19 21:55 EDT   cloud
```
