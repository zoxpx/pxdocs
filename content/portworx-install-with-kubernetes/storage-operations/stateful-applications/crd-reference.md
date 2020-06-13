---
title: Stateful Application CRD Reference
keywords:
description: Backup, restore, and clone stateful applications
hidden: false
weight: 2
---

## BackupLocation

The BackupLocation CRD parameters differ based on the object store you use.

### S3-compliant storage

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
  s3Config:
    region: us-east-1
    accessKeyID: ABCDEF1234567890
    secretAccessKey: ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890
    endpoint: "https://bucketEndpoint.com"
    disableSSL: false
```

#### s3Config Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|region| Which region your s3 bucket is located in | **Default:** None | Yes |
|accessKeyID| Your object store's accessKeyID | **Default:** None | Yes |
|secretAccessKey| Your object store's secretAccessKey | **Default:** None | Yes |
|endpoint| The URL or IP address of your bucket | **Default:** None | Yes |
|disableSSL| Whether or not to disable SSL | **Default:** `false` | No |

### Azure Blob Storage

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: azure
  namespace: mysql
  annotations:
    stork.libopenstorage.ord/skipresource: "true"
location:
  type: azure
  path: "bucket-name"
  azureConfig:
    storageAccountName: myaccount
    storageAccountKey: A634w4534G3424D342s9A5hGyQ+IOP+aadahnbFk5n6G8c9f+DD719G5oht34H26u7Zu9Hjd4laq7F7E7fK67A==
```

#### azureConfig Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|storageAccountName| Your object store's storage account name | **Default:** None | Yes |
|storageAccountKey| Your object store's storage account key | **Default:** None | Yes |


### Google Cloud Storage

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: gcs
  namespace: mysql
  annotations:
    stork.libopenstorage.ord/skipresource: "true"
location:
  type: google
  path: "bucket-name"
  googleConfig:
    projectID: "portworx-eng"
    accountKey: >-
      {
       "type": "service_account",
       "project_id": "portworx-eng",
       "private_key_id": "a125b4235345c4325d3434f335234f32a342b0d1",
       "private_key": "-----BEGIN PRIVATE KEY-----
       ...
       -----END PRIVATE KEY-----\n",
       "client_email": "username@email.com",
       "client_id": "842514386544312356786",
       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
       "token_uri": "https://oauth2.googleapis.com/token",
       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/user%40email.com"
       }
```

#### googleConfig Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|projectID| Your Google Cloud Platform (GCP) [project ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects) | **Default:** None | Yes |
|accountKey| Your GCP JSON [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) | **Default:** None | Yes |

<!-- there are pxctl commands to take this in, you pass that JSON object to it in the form of a file, there should be instrcutions on it, if not, we should write them. -->

## ApplicationBackup

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

#### Spec Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|backupLocation| What backupLocation object to use to determine where to send the backup | **Default:** None | Yes |
|namespaces| The namespaces to backup | **Default:** None | Yes |
|reclaimPolicy| What happens to objects in the object store when the `ApplicationBackup` object is deleted | **Default:** `Delete` | No |
|selectors| Define specific labels to determine which objects and volumes are backed-up | **Default:** None | No |
|preExecRule| Rule to run before performing backup | **Default:** None | No |
|PostExecRule| Rule to run after performing backup | **Default:** None | No |

## ApplicationRestore

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

#### Spec Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|backupName| The name of the ApplicationBackup you want to restore from | **Default:** None | Yes |
|backupLocation| Which backup location object to get application backups from | **Default:** None | Yes |
| namespaceMapping | A map of source and destination namespaces, allowing you to restore a backup to a different namespace. You must provide the map in key value pairs, with the source namespace as the key and the destination namespace as the value. {{<info>}}**NOTE:** You must run this spec from an admin namespace (kube-system by default). {{</info>}} | **Default:** None | No |
| replacePolicy | What happens if matching resources already exist | **Default:** Retain <br/><br/> **Enumerated string:** Delete, Retain | No |

## ApplicationClone

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationClone
metadata:
  name: clone-mysql
  namespace: kube-system
spec:
  sourceNamespace: mysql-app
  destinationNamespace: clone-mysql
  selectors:
    app: mysql-app-db
```

#### Spec Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|sourceNamespace| The namespace you want to clone applications _from_ | **Default:** None | Yes |
|destinationNamespace| The namespace you want to clone applications _to_ | **Default:** None | Yes |
|selectors| Define specific labels to determine which resources are cloned | **Default:** None | No |

## ApplicationBackupSchedule

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

#### Spec Parameters

|Parameter |Description | Value | Required? |
|----|----|----|----|
|schedulePolicyName| The name of the schedule policy that defines when backup actions happen | **Default:** None | Yes |
|backupLocation| The name of the backup location spec | **Default:** None | Yes |
|namespaces| Namespaces in which the backup will run | **Default:** None | Yes |
|reclaimPolicy| What happens to objects in the object store when the `ApplicationBackup` object is deleted | **Default:** `Delete` | No |

{{<info>}}
**Note:** Some spec parameters are nested under `template:` and `spec:`. Refer to the example spec above to see which parameters are nested.
{{</info>}}
