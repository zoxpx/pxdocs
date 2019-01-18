---
title: Cloud Snaps
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk, snapshots, stork, clones, cloud, cloudsnap
description: Learn to take a cloud snapshot of a Portworx volume using pxctl and use that snapshot
weight: 3
---

## Multi-Cloud Backup and Recovery of PX Volumes

This document outlines how PX volumes can be backed up to different cloud provider's object storage including any S3-compatible object storage. If a user wishes to restore any of the backups, they can restore the volume from that point in the timeline. This enables administrators running persistent container workloads on-prem or in the cloud to safely backup their mission critical database volumes to cloud storage and restore them on-demand, enabling a seamless DR integration for their important business application data.

### Supported Cloud Providers

Portworx PX-Enterprise supports the following cloud providers

1. Amazon S3 and any S3-compatible Object Storage
2. Azure Blob Storage
3. Google Cloud Storage

### Backing up a PX Volume to cloud storage

The first backup uploaded to the cloud is a full backup. After that, subsequent backups are incremental.
After 6 incremental backups, every 7th backup is a full backup.

### Restoring a PX Volume from cloud storage

Any PX Volume backup can be restored to a PX Volume in the cluster. The restored volume inherits the attributes such as file system, size and block size from the backup. Replication level and aggregation level of the restored volume defaults to 1 irrespective of the replication and aggregation level of the volume that was backed up. Users can increase replication or aggregation level level once the restore is complete on the restored volume.

### Performing Cloud Backups of a PX Volume

Performing cloud backups of a PX Volume is available via `pxctl cloudsnap` command. This command has the following operations available for the full lifecycle management of cloud backups.

```text
# /opt/pwx/bin/pxctl cloudsnap --help
NAME:
   pxctl cloudsnap - Backup and restore snapshots to/from cloud

USAGE:
   pxctl cloudsnap command [command options] [arguments...]

COMMANDS:
    backup, b         Backup a snapshot to cloud
    restore, r        Restore volume to a cloud snapshot
    list, l           List snapshot in cloud
    status, s         Report status of active backups/restores
    history, h        Show history of cloudsnap operations
    stop, st          stop an active backup/restore
    schedules, sched  Manage schedules for cloud-snaps
    catalog, t        Display catalog for the backup in cloud
    delete, d         Delete a cloudsnap from the objectstore. This is not reversible.

OPTIONS:
   --help, -h  show help
```

#### Set the required cloud credentials ####

For this, we will use `pxctl credentials create` command. These cloud credentials are stored in an external secret store. Before you use the command to create credentials, ensure that you have [configured a secret provider of your choice](/key-management).

```text
# pxctl credentials create

NAME:
   pxctl credentials create - Create a credential for cloud-snap

USAGE:
   pxctl credentials create [command options] <name>

OPTIONS:
   --provider value                            Object store provider type [s3, azure, google]
   --s3-access-key value
   --s3-secret-key value
   --s3-region value
   --s3-endpoint value                         Endpoint of the S3 server, in host:port format
   --s3-disable-ssl
   --azure-account-name value
   --azure-account-key value
   --google-project-id value
   --google-json-key-file value
   --encryption-passphrase value,
   --enc value  Passphrase to be used for encrypting data in the cloudsnaps
```

For Azure:

```text
# pxctl credentials create --provider azure --azure-account-name portworxtest --azure-account-key zbJSSpOOWENBGHSY12ZLERJJV my-azure-cred
```

For AWS:

By default, Portworx creates a bucket (ID same as cluster UUID) to upload cloudsnaps. With Portworx version 1.5.0 onwards,uploading to a pre-created bucket by a user is supported. Thus the AWS credential provided to Portworx should either have the capability to create a bucket or the bucket provided to Portworx at minimum must have the permissions mentioned below. If you prefer that a user specified bucket be used for cloudsnaps, specify the bucket id with `--bucket` option while creating the credentials.

With user specified bucket (applicable only from 1.5.0 onwards):
```text
# pxctl credentials create --provider s3  --s3-access-key AKIAJ7CDD7XGRWVZ7A --s3-secret-key mbJKlOWER4512ONMlwSzXHYA --s3-region us-east-1 --s3-endpoint s3.amazonaws.com --bucket bucket-id my-s3-cred
```
User created/specified bucket at minimum must have following permissions: Replace `<bucket-name>` with name of your user-provided bucket.
```json
{
     "Version": "2012-10-17",
     "Statement": [
			{
				"Sid": "VisualEditor0",
				"Effect": "Allow",
				"Action": [
					"s3:ListAllMyBuckets",
					"s3:GetBucketLocation"
				],
				"Resource": "*"
			},
			{
				"Sid": "VisualEditor1",
				"Effect": "Allow",
				"Action": "s3:*",
				"Resource": [
					"arn:aws:s3:::<bucket-name>",
					"arn:aws:s3:::<bucket-name/*"
				]
			}
		]
 }
```

Without user specified bucket:
```text
# pxctl credentials create --provider s3  --s3-access-key AKIAJ7CDD7XGRWVZ7A --s3-secret-key mbJKlOWER4512ONMlwSzXHYA --s3-region us-east-1 --s3-endpoint s3.amazonaws.com my-s3-cred
```

For Google Cloud:

```text
# pxctl credentials create --provider google --google-project-id px-test --google-json-key-file px-test.json my-google-cred
```
`pxctl credentials create` enables the user to configure the credentials for each supported cloud provider.

An additional encryption key can also be provided for each credential. If provided, all the data being backed up to the cloud will be encrypted using this key. The same key needs to be provided when configuring the credentials for restore to be able to decrypt the data succesfuly.

These credentials can only be created once and cannot be modified. In order to maintain security, once configured, the secret parts of the credentials will not be displayed.

#### List the credentials to verify ####

Use `pxctl credentials list` to verify the credentials supplied.

```text
# pxctl credentials list

S3 Credentials
UUID						NAME		REGION			ENDPOINT						ACCESS KEY			SSL ENABLED		ENCRYPTION		BUCKET		WRITE THROUGHPUT (KBPS)
af563a4d-afd7-48df-90f7-8e8f9414ff77		my-s3-cred	us-east-1		70.0.99.121:9010,70.0.99.122:9010,70.0.99.123:9010	AB6R80F3SY0VW9NS6HYQ		false			false			<nil>		1979

Google Credentials
UUID						NAME			PROJECT ID		ENCRYPTION		BUCKET		WRITE THROUGHPUT (KBPS)
6585cf56-4ccf-42cc-a235-76aaf6fb10f4		my-google-cred		235475231246		false			<nil>		1502

Azure Credentials
UUID						NAME			ACCOUNT NAME		ENCRYPTION		BUCKET		WRITE THROUGHPUT (KBPS)
1672e1c9-c513-44db-b8b5-b59e3d35a3a2		my-azure-cred		pwx-test		false			<nil>		724
```

`pxctl credentials list`  only displays non-secret values of the credentials. Secrets are neither stored locally nor displayed.  These credentials will be stored as part of the secret endpoint given for PX for persisting authentication across reboots. Please refer to `pxctl secrets` help for more information.

#### Perform Cloud Backup ####

The actual backup of the PX Volume is done via the `pxctl cloudsnap backup` command

```text
# pxctl cloudsnap backup

NAME:
   pxctl cloudsnap backup - Backup a snapshot to cloud

USAGE:
   pxctl cloudsnap backup [command options] [arguments...]

OPTIONS:
   --volume value, -v value       source volume
   --full, -f                     force a full backup
   --cred-id value, --cr value    Cloud credentials ID to be used for the backup

```

This command is used to backup a single volume to the cloud provider using the specified credentials.
This command decides whether to take a full or incremental backup depending on the existing backups for the volume.
If it is the first backup for the volume it takes a full backup of the volume. If its not the first backup, it takes an incremental backup from the previous full/incremental backup.

```text
# pxctl cloudsnap backup volume1 --cred-id 82998914-5245-4739-a218-3b0b06160332
```

Users can force the full backup any time by giving the --full option.
If only one credential is configured on the cluster, then the cred-id option may be skipped on the command line.

Here are a few steps to perform cloud backups successfully

* List all the available volumes to choose the volume to backup

```text
# pxctl volume list
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	SCALE	STATUS
56706279008755778	NewVol	4 GiB	1	no	no		LOW		1	up - attached on 70.0.9.73
980081626967128253	evol	2 GiB	1	no	no		LOW		1	up - detached
```

* List the configured credentials

```text
# pxctl cloudsnap credentials list

Azure Credentials
UUID						ACCOUNT NAME		ENCRYPTION
ef092623-f9ba-4697-aeb5-0d5d6d9b5742		portworxtest		false
```

Authenticate the nodes where the storage for volume to be backed up is provisioned.

* Login to the secrets database to use encryption in-flight

```text
# pxctl secrets kvdb login
Successful Login to Secrets Endpoint!
```

* Now issue the backup command

Note that in this particular example,  since only one credential is configured, there is no need to specify the credentials on the command line

```text
# pxctl cloudsnap backup NewVol
Cloudsnap backup started successfully with id: 3f4f0a67-e12a-4d35-81ad-985657757352
```

* Watch the status of the backup

```text
# pxctl cloudsnap status
NAME					SOURCEVOLUME									STATE		NODE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED
39f66859-14b1-4ce0-a4c0-c858e714689e	2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr	Backup-Done	70.0.73.246	420044800	17.460186585s	Wed, 16 Jan 2019 22:27:30 UTC
3f4f0a67-e12a-4d35-81ad-985657757352	2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463	Backup-Active	70.0.73.246	1247805440	10.525438874s
```

* You could also watch the status of single cloudsnap command through task-id that was returned on successful execution of the cloudsnap command.

```text
# pxctl cloudsnap status -n 3f4f0a67-e12a-4d35-81ad-985657757352
NAME					SOURCEVOLUME									STATE		NODE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED
3f4f0a67-e12a-4d35-81ad-985657757352	2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463	Backup-Active	70.0.73.246	1840250880	16.57831394s
```

Once the volume is backed up to the cloud successfully, listing the remote cloudsnaps will display the backup that just completed.

* List the backups in cloud

```text
# pxctl cloudsnap list
SOURCEVOLUME					SOURCEVOLUMEID			CLOUD-SNAP-ID										CREATED-TIME				TYPE		STATUS
volume20190116214922				590114184663672482		2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-619248560586769719		Wed, 16 Jan 2019 21:51:53 UTC		Manual		Done
volume20190116214922				590114184663672482		2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr		Wed, 16 Jan 2019 22:27:13 UTC		Manual		Done
NewVol						56706279008755778		2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463		Thu, 17 Jan 2019 00:03:59 UTC		Manual		Done
```

#### Restore from a Cloud Backup ####

Use `pxctl cloudsnap restore` to restore from a cloud backup.

Here is the command syntax.

```text
# pxctl cloudsnap restore

NAME:
   pxctl cloudsnap restore - Restore volume to a cloud snapshot

USAGE:
   pxctl cloudsnap restore [command options] [arguments...]

OPTIONS:
   --snap value, -s value         Cloud-snap id
   --node value, -n value         Optional node ID for provisioning restore volume storage
   --cred-id value, --cr value    Cloud credentials ID to be used for the restore

```

This command is used to restore a successful backup from cloud. It requires the cloudsnap ID which can be used to restore and credentials for the cloud storage provider or the object storage. Restore happens on any node where storage can be provisioned. In this release restored volume will have a replication factor of 1. The restored volume can be updated to different replication factors using `pxctl volume ha-update` command.

The command usage is as follows.
```text
# pxctl cloudsnap restore --snap cs30/669945798649540757-864783518531595119 --cred-id 82998914-5245-4739-a218-3b0b06160332
Cloudsnap restore started successfully on volume: 104172750626071399 with task name:59c4cfd5-4160-45db-b326-f37b327d9225
```

Upon successful start of the command it returns the volume id created to restore the cloud snap and the task-id which can used to get status.
If the command fails to succeed, it shows the failure reason.

The restored volume will not be attached or mounted automatically.


* Use `pxctl cloudsnap list` to list the available backups.

`pxctl cloudsnap list` helps enumerate the list of available backups in the cloud. This command assumes that you have all the credentials setup properly. If the credentials are not setup, then the backups available in those clouds won't be listed by this command.

```text
# pxctl cloudsnap list
SOURCEVOLUME					SOURCEVOLUMEID			CLOUD-SNAP-ID										CREATED-TIME				TYPE		STATUS
volume20190116214922				590114184663672482		2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-619248560586769719		Wed, 16 Jan 2019 21:51:53 UTC		Manual		Done
volume20190116214922				590114184663672482		2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr		Wed, 16 Jan 2019 22:27:13 UTC		Manual		Done
NewVol						56706279008755778		2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463		Thu, 17 Jan 2019 00:03:59 UTC		Manual		Done
```

* Choose one of them to restore

```text
# pxctl cloudsnap restore -s 2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463
Cloudsnap restore started successfully on volume: 104172750626071399 with task name:59c4cfd5-4160-45db-b326-f37b327d9225
```
`pxctl cloudsnap status` gives the status of the restore processes as well.

```text
# pxctl cloudsnap status
NAME					SOURCEVOLUME									STATE		NODE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED
3f4f0a67-e12a-4d35-81ad-985657757352	2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463	Backup-Done	70.0.73.246	11988570112	3m29.825766964s	Thu, 17 Jan 2019 00:07:29 UTC
39f66859-14b1-4ce0-a4c0-c858e714689e	2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr	Backup-Done	70.0.73.246	420044800	17.460186585s	Wed, 16 Jan 2019 22:27:30 UTC
59c4cfd5-4160-45db-b326-f37b327d9225	2e4d4b67-95d7-481e-aec5-14223ac55170/212160250617983239-283838486341798860	Restore-Done	70.0.73.246	1079287808	3.174541219s	Thu, 17 Jan 2019 00:15:19 UTC
```

#### Deleting a Cloud Backup ###

{{<info>}}
**Note:**<br/> This is only supported from PX version 1.4 onwards
{{</info>}}

You can delete backups from the cloud using the `/opt/pwx/bin/pxctl cloudsnap delete` command. The command will mark a cloudsnap for deletion and a job will take care of deleting objects associated with these backups from the objectstore.

Only cloudsnaps which do not have any dependant cloudsnaps (ie incrementals) can be deleted. If there are dependant cloudsnaps then the command will throw an error with the list of cloudsnaps that need to be deleted first.

For example to delete the backup `pqr9-cl1/538316104266867971-807625803401928868`:

```text
# pxctl cloudsnap delete --snap pqr9-cl1/538316104266867971-807625803401928868
Cloudsnap deleted successfully
# pxctl cloudsnap list
SOURCEVOLUME 	CLOUD-SNAP-ID					CREATED-TIME			STATUS
dvol		pqr9-cl1/520877607140844016-50466873928636534	Fri, 07 Apr 2017 20:22:43 UTC	Done
```

## Cloud operations

Help for specific cloudsnap commands can be found by running the following command

Note: All cloudsnap operations requires secrets login to configured endpoint with/without encryption. Please refer pxctl secrets cmd help.

Also, to see how to configure cloud provider credentials, click the link below.

[Credentials](/reference/cli/credentials)

**pxctl cloudsnap –help**

```text
/opt/pwx/bin/pxctl cloudsnap --help
NAME:
   pxctl cloudsnap - Backup and restore snapshots to/from cloud

USAGE:
   pxctl cloudsnap command [command options] [arguments...]

COMMANDS:
     backup, b         Backup a snapshot to cloud
     restore, r        Restore volume to a cloud snapshot
     list, l           List snapshot in cloud
     status, s         Report status of active backups/restores
     history, h        Show history of cloudsnap operations
     stop, st          stop an active backup/restore
     schedules, sched  Manage schedules for cloud-snaps
     catalog, t        Display catalog for the backup in cloud
     delete, d         Delete a cloudsnap from the objectstore. This is not reversible.

OPTIONS:
   --help, -h  show help
```

**pxctl cloudsnap backup**

`pxctl cloudsnap backup` command is used to backup a single volume to the configured cloud provider through credential command line. If it will be the first backup for the volume a full backup of the volume is generated. If it is not the first backup, it only generates an incremental backup from the previous full/incremental backup. If a single cloud provider credential is created then there is no need to specify the credentials on the command line.

```text
/opt/pwx/bin/pxctl cloudsnap backup vol1
Cloudsnap backup started successfully
```

If multiple cloud providers credentials are created then need to specify the credential to use for backup on command line

```text
/opt/pwx/bin/pxctl cloudsnap backup vol1 --cred-id ffffffff-ffff-ffff-1111-ffffffffffff
Cloudsnap backup started successfully
```

Note: All cloudsnap backups and restores can be monitored through CloudSnap status command which is described in following sections

**pxctl cloudsnap restore**

`pxctl cloudsnap restore` command is used to restore a successful backup from cloud. \(Use cloudsnap list command to get the cloudsnap Id\). It requires cloudsnap Id \(to be restored\) and credentials. Restore happens on any node in the cluster where storage can be provisioned. In this release, restored volume will be of replication factor 1. This volume can be updated to different repl factors using volume ha-update command.

```text
sudo /opt/pwx/bin/pxctl cloudsnap restore --snap gossip12/181112018587037740-545317760526242886
Cloudsnap restore started successfully on volume: 315244422215869148 with task name:598892d5-2130-76ab-b312-f3d234891287
```

Note: All cloudsnap backups and restores can be monitored through CloudSnap status command which is described in following sections

**pxctl cloudsnap status**

`pxctl cloudsnap status` can be used to check the status of cloudsnap operations

```text
/opt/pwx/bin/pxctl cloudsnap status
pxctl cs status
NAME					SOURCEVOLUME									STATE		NODE		BYTES-PROCESSED	TIME-ELAPSED	COMPLETED
3f4f0a67-e12a-4d35-81ad-985657757352	2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463	Backup-Done	70.0.73.246	11988570112	3m29.825766964s	Thu, 17 Jan 2019 00:07:29 UTC
44de918e-1305-4f6c-8c80-6d899177678a	2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-144412948613644984	Backup-Done	70.0.73.246	8599048192	1m14.852605207s	Wed, 16 Jan 2019 21:41:24 UTC
59c4cfd5-4160-45db-b326-f37b327d9225	2e4d4b67-95d7-481e-aec5-14223ac55170/212160250617983239-283838486341798860	Restore-Done	70.0.73.246	1079287808	3.174541219s	Thu, 17 Jan 2019 00:15:19 UTC
```

**pxctl cloudsnap list**

`pxctl cloudsnap list` is used to list all the cloud snapshots from all clusters available to this credential

Note that specifying --all could take a while to complete if there are many clusters

```text
/opt/pwx/bin/pxctl cloudsnap list --cred-id ffffffff-ffff-ffff-1111-ffffffffffff --all
SOURCEVOLUME 			CLOUD-SNAP-ID									CREATED-TIME				STATUS
vol1			gossip12/181112018587037740-545317760526242886		Sun, 09 Apr 2017 14:35:28 UTC		Done
```

Filtering on cluster ID or volume ID is available and can be done as follows:

```text
/opt/pwx/bin/pxctl cloudsnap list --cred-id ffffffff-ffff-ffff-1111-ffffffffffff --src volume20190117233039
SOURCEVOLUME			SOURCEVOLUMEID			CLOUD-SNAP-ID										CREATED-TIME				TYPE		STATUS
volume20190117233039		290373969701024085		3ac0da32-5489-4019-9d40-484e87c141c1/290373969701024085-77076017562510819		Thu, 17 Jan 2019 23:37:09 UTC		Manual		Done
volume20190117233039		290373969701024085		3ac0da32-5489-4019-9d40-484e87c141c1/290373969701024085-639824017812971975		Fri, 18 Jan 2019 01:25:59 UTC		Manual		Done

/opt/pwx/bin/pxctl cloudsnap list --cred-id ffffffff-ffff-ffff-1111-ffffffffffff --cluster 2e4d4b67-95d7-481e-aec5-14223ac55170
SOURCEVOLUME					SOURCEVOLUMEID			CLOUD-SNAP-ID										CREATED-TIME				TYPE		STATUS
bkpvolume20190116213324				56706279008755778		2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-144412948613644984		Wed, 16 Jan 2019 21:40:09 UTC		Manual		Done
bkpvolume20190116214126				276135282393365814		2e4d4b67-95d7-481e-aec5-14223ac55170/276135282393365814-497387553494372115		Wed, 16 Jan 2019 21:45:28 UTC		Manual		Done
bkpvolume20190116214622				212497362333615128		2e4d4b67-95d7-481e-aec5-14223ac55170/212497362333615128-869823822356552213		Wed, 16 Jan 2019 21:48:58 UTC		Manual		Done
bkpvolume20190116214922				590114184663672482		2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-619248560586769719		Wed, 16 Jan 2019 21:51:53 UTC		Manual		Done
bkpvolume20190116215212				50730816040093554		2e4d4b67-95d7-481e-aec5-14223ac55170/50730816040093554-286811789063715985		Wed, 16 Jan 2019 21:53:59 UTC		Manual		Done
bkpvolume20190116215510				60941762085605033		2e4d4b67-95d7-481e-aec5-14223ac55170/60941762085605033-197637759684319014		Wed, 16 Jan 2019 21:56:19 UTC		Manual		Done
bkpvolume20190116215745				124642336323598924		2e4d4b67-95d7-481e-aec5-14223ac55170/124642336323598924-789922313031870846		Wed, 16 Jan 2019 22:02:15 UTC		Manual		Done
```

**pxctl cloudsnap delete**

`pxctl cloudsnap delete` can be used to delete cloudsnaps. This is not reversible and will cause the backups to be permanently deleted from the cloud, so use with care.

```text
/opt/pwx/bin/pxctl cloudsnap  delete --snap gossip12/181112018587037740-545317760526242886
Cloudsnap deleted successfully
```
