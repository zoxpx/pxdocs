---
title: Stateful application storage operations
linkTitle: Stateful applications operations
keywords: backup, restore, clone, stateful
description: Backup, restore, and clone stateful applications
hidden: false
weight: 1
---

With Portworx, you can backup stateful applications and their volumes to an external object store and restore to the same cluster or to a new cluster. When it comes to timing, you can perform backup operations manually whenever you wish, or you can schedule them with a schedulePolicy. You can even use Portworx's backup functionality to clone applications between namespaces by restoring to a different namespace in the same cluster. 


## Prerequisites

All application storage operations require the following prerequisites:

* Stork 2.3
* Administrator-level cluster privileges if you operate between namespaces
* Portworx 2.2

## Configure Application Backups

Configure application backups by creating and applying the following CRDs:

* backupLocation
* applicationBackup

### Create a backupLocation CRD

Use the backupLocation CRD to specify the configuration information for your object store. Portworx supports the following object stores:

* Any S3-compliant object store
* Azure Blob Storage
* Google Cloud Storage

The example in this document uses an S3 bucket to store application backup data. To create backupLocations using other object stores, see the [Stateful application CRD reference](/portworx-install-with-kubernetes/storage-operations/stateful-applications/crd-reference) section of the documentation. 

```
"endpoint" : "bucketEndpoint.com"
"key": "ABCDEF1234567890"
"secret": "ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890"
```

If you're restoring backups to a different cluster from the one you took your backups from, you must create a backupLocation CRD on your new cluster that matches the backupLocation CRD on your original cluster. 

You can specify your object store credentials directly in the BackupLocation configuration as plaintext or use a Kubernetes secret:

#### Plaintext credentials

1. Create a backupLocation YAML file, specifying the following:

  * **name:** the backupLocation object's name
  * **namespace:** the namespace the backupLocation exists in
  * **location:**
      * **type:** the object store type
      * **path:** the bucket Portworx will use for the backup
      * **sync:** If you're restoring to a new cluster, set `sync` to true to allow your new cluster to retrieve the previous backups from your backup location.
      * **s3Config:**
          * **region:** which region your s3 bucket is located in
          * **accessKeyID:** your bucket's accessKeyID
          * **secretAccessKey:** your bucket's secretAccessKey
          * **endpoint:** the URL or IP address of your bucket
          * **disableSSL:** whether or not to disable SSL

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: BackupLocation
    metadata:
      name: mysql
      namespace: mysql-app
      annotations:
        stork.libopenstorage.org/skipresource: "true"
    location:
      type: s3
      path: "bucket-name"
      sync: true
      s3Config:
        region: us-east-1
        accessKeyID: ABCDEF1234567890
        secretAccessKey: ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890
        endpoint: "https://bucketEndpoint.com"
        disableSSL: false
    ```

    {{<info>}}
**Note:** If you use URL as your bucket endpoint, you must include the http prefix: either `https://` or `http://`, depending on whether or not you're using SSL.
    {{</info>}}


2. Apply the YAML:

    ```text
    kubectl apply -f backLo.yaml
    ```

#### Kubernetes secret containing your credentials

1. Create a Kubernetes Secret YAML file, specifying the following:

  * **name:** the Secret object's name
  * **namespace:** the namespace the Secret exists in
  <!-- *  annotations?? -->
  * **stringData:**
      * **region:** which region your s3 bucket is located in
      * **accessKeyID:** your bucket's accessKeyID
      * **secretAccessKey:** your bucket's secretAccessKey
      * **endpoint:** the URL or IP address of your bucket
      * **disableSSL:** whether or not to disable SSL
      * **encryptionKey:** your secret's encryption key

    ```text
      apiVersion: v1
      kind: Secret
      metadata:
        name: s3secret
        namespace: mysql
        annotations:
          stork.libopenstorage.org/skipresource: "true"
      stringData:
        region: us-east-1
        accessKeyID: AB123AB43678AABCD12P
        secretAccessKey: b7D9pA3214Vafo8432023ajksndas43242kjsnfdk
        endpoint: "70.0.0.141:9010"
        disableSSL: "false"
        encryptionKey: "testKey"
      ```

2. Apply the Secret's YAML file:

    ```text
    kubectl apply -f s3secret.yaml
    ```

3. Create a backupLocation YAML file, specifying the following:

  * **name:** the backupLocation object's name
  * **namespace:** the namespace the backupLocation exists in
  * **location:**
      * **type:** the object store type
      * **path:** the bucket Portworx will use for the backup
      * **secretConfig:** the Secret object containing your bucket's credentials
      * **sync:** If you're restoring to a new cluster, set `sync` to true to allow your new cluster to retrieve the previous backups from your backup location.

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: BackupLocation
    metadata:
      name: mysql-backup
      namespace: mysql
      annotations:
        stork.libopenstorage.org/skipresource: "true"
    location:
      type: s3
      path: "bucket-name"
      secretConfig: s3secret
      sync: true
    ```

    {{<info>}}
**Note:** If you use URL as your bucket endpoint, you must include the http prefix: either `https://` or `http://`, depending on whether or not you're using SSL.
    {{</info>}}


4. Apply the YAML:

    ```text
    kubectl apply -f backLo.yaml
    ```


### Create an applicationBackup CRD

Use the applicationBackup CRD to specify what namespaces have their applications backed-up.

1. Create an applicationbackup YAML file, specifying the following:

  * **name:** the applicationBackup object's name
  * **namespace:** the namespace the applicationBackup exists in
  * **spec:**
      * **backupLocation:** what backupLocation object to use to determine where to send the backup
      * **namespaces:** the namespaces to backup
      * **reclaimPolicy:** what happens to objects in the object store when the `ApplicationBackup` object is deleted, either `Delete` or `Retain`
      * **selectors:** define specific labels to determine which objects and volumes are backed-up
      * **preExecRule:** what rule to run before performing backup
      * **postExecRule:** what rule to run after performing backup

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: ApplicationBackup
    metadata:
      name: backup
      namespace: mysql-app
    spec:
      backupLocation: mysql
      namespaces:
      - mysql-app
      reclaimPolicy: Delete
      selectors:
      preExecRule:
      postExecRule:
    ```

2. Apply the YAML:

    ```text
    kubectl apply -f appBack.yaml
    ```

3. Verify the applicationBackup object's status with the `storkctl get` command. You can see what stage the backup is in, as well as its status:

    ```text
    storkctl get applicationbackup -n mysql-app
    ```
    ```output
    NAME      STAGE     STATUS    VOLUMES   RESOURCES   CREATED               ELAPSED
    backup    Volumes   Pending   0/0       0           11 Sep 19 22:10 UTC   19.023065649s
    ```

    You can also describe the object to get more information about the backup. This is useful for troubleshooting:
    ```text
    kubectl describe applicationbackup.stork.libopenstorage.org -n mysql-app
    ```

    The following error message displays when your credentials are invalid.

    ```output
    Warning  Failed  7s  stork  Error starting ApplicationBackup for volumes: rpc error: code = Internal desc = Failed to create backup: Failed to validate credentials: error validating credential: AccessDenied: Access Denied.
             status code: 403, request id: 15C38376E0A0EA7F, host id:
    ```

### Create an ApplicationBackupSchedule CRD

The ApplicationBackupSchedule CRD associates a SchedulePolicy with an application backup operation, allowing you to schedule when and how application backups are performed.

1. Create a SchedulePolicy YAML file, specifying the following:

  * **name:** the SchedulePolicy object's name
  * **policy:**
      * **interval:** For interval backups, how frequently Portworx will back the application up
          * **intervalMinutes:** The interval, in minutes, after which Portworx starts the application backup
          * **retain:** How many backups Portworx will retain.
      * **daily:** For daily backups, Portworx will start the backup at the specified time every day
          * **time:**
          * **retain:** How many backups Portworx will retain.
      * **weekly:** For weekly backups, Portworx will start the backup at the specified day and time every week
          * **day:** The backup day, specified by string
          * **time:** The backup time, specified in 12 hour AM/PM format
          * **retain:** How many backups Portworx will retain.
      * **monthly:** for monthly backups, Portworx will start the backup at the specified day and time every month
          * **date:** The backup day, specified as an integer
          * **time:** the backup time, specified in 12 hour AM/PM format
          * **retain:** How many backups Portworx will retain.

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: SchedulePolicy
    metadata:
      name: backupSchedule
    policy:
      interval:
        intervalMinutes: 60
        retain: 5
      daily:
        time: "10:14PM"
        retain: 5
      weekly:
        day: "Thursday"
        time: "10:13PM"
        retain: 5
      monthly:
        date: 14
        time: "8:05PM"
        retain: 5
    ```

2. Create an ApplicationBackupSchedule YAML file, specifying the following:

  * **name:** the applicationBackupSchedule object's name
  * **namespace:** the namespace the applicationBackupSchedule exists in
  * **spec:**
      * **schedulePolicyName:** the name of the schedule policy that defines when backup actions happen
      * **template:**
          * **spec:**
              * **backupLocation:** the name of the backup location spec
              * **namespaces:** namespaces which will be backed up
              * **reclaimPolicy:** what happens to objects in the object store when the `ApplicationBackup` object is deleted

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: ApplicationBackupSchedule
    metadata:
      name: backup
      namespace: mysql
    spec:
      schedulePolicyName: testpolicy
      template:
        spec:
          backupLocation: mysql
          namespaces:
          - mysql
          reclaimPolicy: Delete
    ```

## Restore an application

You can restore an application by applying an ApplicationRestore object.

{{<info>}}
**NOTE:** If you're restoring an application across namespaces on OpenShift, you must modify your destination namespace to include the same supplemental group annotation values as your source namespace:

```text
annotations:
  openshift.io/sa.scc.supplemental-groups: 1001990000/10000
  openshift.io/sa.scc.uid-range: 1001990000/10000
```

{{</info>}}

1. Create an ApplicationRestore YAML file, specifying the following:

  * **name:** the ApplicationRestore object's name
  * **namespace:** the ApplicationRestore object's namespace
  * **spec:**
      * **backupName:** the name of the `applicationBackup` object to restore from
      * **backupLocation:** which backup location object to get application backups from
      * **namespaceMapping:** a map of source and destination namespaces, allowing you to restore a backup to a different namespace
      * **replacePolicy:** specifies whether you want to delete or retain any matching existing resource in the target namespace

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: ApplicationRestore
    metadata:
      name: restore
      namespace: mysql-app
    spec:
      backupName: backup
      backupLocation: mysql
      namespaceMapping:
        mysql: mysql
      replacePolicy: Delete
    ```

    {{<info>}}
**Note:** You can run the `storkctl get applicationbackup -n namespace` command to help you see which backup to restore from.
    {{</info>}}

2. Apply the YAML:

    ```text
    kubectl apply -f appRestore.yaml
    ```

The moment you apply the YAML, the application begins to restore. Monitor the status with the `storkctl get` command:

```text
storkctl get applicationrestore -n mysql-app
```
```output
NAME      STAGE     STATUS       VOLUMES   RESOURCES   CREATED               ELAPSED
restore   Final     Successful   1/1       3           11 Sep 19 23:32 UTC   35s
```

Verify its status with the `kubectl get pods` command:

```text
kubectl get pods -n mysql-app
```
```output
NAME                     READY   STATUS    RESTARTS   AGE
mysql-6d69b99774-2bv4m   0/1     Pending   0          3s
```

## Clone an Application

You can clone an application to a different namespace or within the same namespace. You must create the `ApplicationClone` object in the **admin** namespace, which is `kube-system` by default.

{{<info>}}
**NOTE:**

* If you're cloning an application across namespaces on OpenShift, you must modify your destination namespace to include the same supplemental group annotation values as your source namespace:

    ```text
    annotations:
      openshift.io/sa.scc.supplemental-groups: 1001990000/10000
      openshift.io/sa.scc.uid-range: 1001990000/10000
    ```

* Distributed apps, such as Cassandra, may use the same node IDs on the destination namespace as their source, causing disruption when the new nodes join the source cluster.
{{</info>}}

1. Create a an ApplicationClone YAML file, specifying the following:

    * **name:** the ApplicationClone object's name
    * **namespace:** the ApplicationClone object's namespace
    * **spec:**
        * **sourceNamespace:** the namespace you want to clone applications _from_
        * **destinationNamespace:** the namespace you want to clone applications _to_

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: ApplicationClone
    metadata:
      name: clone-mysql
      namespace: kube-system
    spec:
      sourceNamespace: mysql-app
      destinationNamespace: clone-mysql
    ```

2. Apply the YAML file:

    ```text
    kubectl apply -f appClone.yaml
    ```
