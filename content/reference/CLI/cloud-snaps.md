---
title: Cloud Snapshots and Recovery using pxctl
linkTitle: Cloud Snaps
keywords: pxctl, command-line tool, cli, reference, cloud snapshots, volume backups, cloud storage, persistent disk, backup database
description: Learn to take a cloud snapshot of a Portworx volume using pxctl and use that snapshot
weight: 8
---

## Overview of cloud backups

This document outlines how to back-up Portworx volumes to different cloud providers' object storage, including any S3-compatible object storage. To restore a specific backup, the user can restore the volume from that point in time.

Portworx helps administrators running persistent container workloads, on-prem or in the cloud, to safely backup their mission-critical database volumes to any supported cloud storage. Next, they can restore them on-demand. This way, Portworx enables a **seamless DR integration** for all the important business application data.

### Supported cloud providers

PX-Enterprise supports the following cloud providers:

1.  Amazon S3 and any S3-compatible Object Storage
2.  Azure Blob Storage
3.  Google Cloud Storage

## Performing cloud backups of a Portworx volume

Portworx volumes can be backed up to cloud via `pxctl cloudsnap`. If you run this command with the `--help` flag, it shows the list of available operations for the **full lifecycle management** of your cloud backups:

```text
pxctl cloudsnap --help
```

```output
Backup and restore snapshots to/from cloud

Usage:
  pxctl cloudsnap [flags]
  pxctl cloudsnap [command]

Aliases:
  cloudsnap, cs

Available Commands:
  backup       Backup a snapshot to cloud
  backup-group Backup a group of snapshot for a given group id or labels to cloud
  catalog      Display catalog for the backup in cloud
  delete       Delete a cloudsnap from the objectstore. This is not reversible.
  history      Show history of cloudsnap operations
  list         List snapshot in cloud
  restore      Restore volume to a cloud snapshot
  schedules    Manage schedules for cloud-snaps
  status       Report status of active backups/restores
  stop         stop an active backup/restore

Flags:
  -h, --help   help for cloudsnap
```

### Login to the secrets database

Note that the cloud credentials are stored in an external secret store. Hence, before creating the credentials, make sure that you have [configured a secret provider](/key-management) of your choice.

Now, we can login to the secrets database by typing:

```text
pxctl secrets kvdb login
```

```output
Successful Login to Secrets Endpoint!
```

{{<info>}}
**Kubernetes users:** This is not required if you are using Portworx 2.0 and higher on _Kubernetes_ and you have `-secret_type` as k8s in Daemonset
{{</info>}}

### Set the required cloud credentials

For this, we will use the `pxctl credentials create` command. To see the list of available command line options, type:

```text
pxctl credentials create --help
```

```output
Create a credential for cloud providers

Usage:
  pxctl credentials create [flags]

Aliases:
  create, c

Examples:
/opt/pwx/bin/pxctl cred create [flags] <name>
Flags:
      --s3-disable-ssl
      --use-iam                        Optional, use instance IAM for credentials, current support only for s3(ec2 IAM)
      --disable-path-style             optional, required for virtual-host-style access
      --use-proxy                      optional, currently supported for s3 only, requires cluster wide proxy(under cluster options)
      --provider string                Cloud provider type [s3, azure, google]
      --s3-access-key string
      --s3-secret-key string
      --s3-region string
      --s3-storage-class string        Storage class type [STANDARD, STANDARD_IA]
      --bucket string                  Optional pre-created bucket name
      --azure-account-name string
      --azure-account-key string
      --google-project-id string
      --google-json-key-file string
      --encryption-passphrase string   Passphrase to be used for encrypting data in the cloudsnaps
      --s3-endpoint strings            Endpoint of the S3 servers, in comma separated host:port format
  -h, --help        
                     help for create
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

#### Azure

Here's how you can create the credentials for _Azure_:

```text
pxctl credentials create --provider azure --azure-account-name portworxtest --azure-account-key zbJSSpOOWENBGHSY12ZLERJJV my-azure-cred
```

At this point, we can list the configured credentials as follows:

```text
pxctl cloudsnap credentials list
```

```output
Azure Credentials
UUID                        ACCOUNT NAME        ENCRYPTION
ef092623-f9ba-4697-aeb5-0d5d6d9b5742        portworxtest        false
```

{{<info>}}
Note that that listing the credentials does mean that connection to a secret-store endpoint has been validated.
{{</info>}}

#### AWS

If you are using _AWS_, Portworx creates a bucket (`ID` same as the cluster `UUID`) to upload cloudsnaps by default. Starting with Portworx version 1.5.0, users can upload to a pre-created bucket. Thus, the _AWS_ credentials provided to Portworx should either:

*   have the capability to create a bucket or
*   the bucket provided to Portworx at a minimum must have the permissions mentioned below.

If you prefer that a user-specified bucket be used for cloudsnaps, specify the bucket id with the `--bucket` option while creating the credentials.

##### With a user-specified bucket

Say you are using `us-east-1 region`. If so, you should type something like the following:

```text
pxctl credentials create --provider s3  --s3-access-key <AccessKey> --s3-secret-key <secretKey> --s3-region us-east-1 --s3-endpoint s3.amazonaws.com --bucket bucket-id my-s3-cred
```

If you are using a different region, replace the `--s3-region` and `--s3-endpoint` parameters with the appropriate values. For more information about region-specific endpoints, check out the "Amazon Simple Storage Service (Amazon S3)" section on [this page](https://docs.aws.amazon.com/general/latest/gr/rande.html).

If you use the above command to create the credentials for an s3 endpoint that supports only virt-host-style access, then you will hit an error like below:

```text
createCred: error validating credential during create: SecondLevelDomainForbidden: Please use virtual hosted style to access. status code: 403, request id: xxyyzzaabbcc, host id:,
```

In this case, you should specify the `--disable-path-style` parameter while creating credentials as follows:

```text
pxctl credentials create mycreds --provider=s3 --s3-disable-ssl --s3-region=us-east-1 --s3-access-key=<S3-ACCESS_KEY> --s3-secret-key=<S3-SECRET_KEY> --s3-endpoint=mys3-enpoint.com --disable-path-style --bucket=mybucket
```

```output
Credentials created successfully, UUID:77c336ac-9937-46cf-ad42-297ea41c8022
```

The user created/specified bucket at a minimum must have the following permissions:

```text
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

{{<info>}}
Note: Replace `<bucket-name>` with name of your user-provided bucket.
{{</info>}}


##### Without a user-specified bucket

```text
pxctl credentials create --provider s3  --s3-access-key AKIAJ7CDD7XGRWVZ7A --s3-secret-key mbJKlOWER4512ONMlwSzXHYA --s3-region us-east-1 --s3-endpoint s3.amazonaws.com my-s3-cred
```

#### Google Cloud

1. Make sure the user or service account used by Portworx has the following roles:

   * Editor
   * Storage
   * Object Admin
   * Storage Object Viewer

    For more information about roles and permissions within GCP, see the [Granting, changing, and revoking access to resources](https://cloud.google.com/iam/docs/granting-changing-revoking-access) section of the GCP documentation.

2. Enter the `pxctl credentials create` command  specifying:

   * The `provider` flag with the name of the provider (`google`)
   * The `--google-project-id` flag with your Google project ID
   * The `--google-json-key-file` flag with the name of the JSON file containing your key
   * The name of your cloud credentials

    Example:

    ```text
    pxctl credentials create --provider google --google-project-id px-test --google-json-key-file px-test.json my-google-cred
    ```

#### Configure credentials

`pxctl credentials create` enables the user to configure the credentials for each supported cloud provider.

An additional encryption key can also be provided for each credential. If provided, all the data being backed up to the cloud will be encrypted using this key. The same key needs to be provided when configuring the credentials for restore. This way, Portworx will be able to decrypt the data successfully.

These credentials can only be created once and cannot be modified. In order to maintain security, once configured, the secret parts of the credentials will not be displayed.

### List the credentials to verify

Use `pxctl credentials list` to verify the credentials supplied as follows:

```text
pxctl credentials list
```

```output
S3 Credentials
UUID                        NAME        REGION            ENDPOINT                        ACCESS KEY            SSL ENABLED        ENCRYPTION        BUCKET        WRITE THROUGHPUT (KBPS)
af563a4d-afd7-48df-90f7-8e8f9414ff77        my-s3-cred    us-east-1        70.0.99.121:9010,70.0.99.122:9010,70.0.99.123:9010    AB6R80F3SY0VW9NS6HYQ        false            false            <nil>        1979

Google Credentials
UUID                        NAME            PROJECT ID        ENCRYPTION        BUCKET        WRITE THROUGHPUT (KBPS)
6585cf56-4ccf-42cc-a235-76aaf6fb10f4        my-google-cred        235475231246        false            <nil>        1502

Azure Credentials
UUID                        NAME            ACCOUNT NAME        ENCRYPTION        BUCKET        WRITE THROUGHPUT (KBPS)
1672e1c9-c513-44db-b8b5-b59e3d35a3a2        my-azure-cred        pwx-test        false            <nil>        724
```

`pxctl credentials list` only displays non-secret values of the credentials. Secrets are neither stored locally nor displayed. The credentials will be stored as part of the secret endpoint given to Portworx for persisting authentication across reboots.

{{% content "shared/reference-CLI-secrets-definition.md" %}}

You can find more details on how to manage your cloud credentials with `pxctl` by checking out the [Credentials](/reference/cli/credentials) page.

### Perform cloud backups of single volumes

The actual backup of the Portworx volume is done via the `pxctl cloudsnap backup`.

To get more details, run it with the `--help` flag:

```text
pxctl cloudsnap backup --help
```

```output
NAME:
   pxctl cloudsnap backup - Backup a snapshot to cloud

USAGE:
   pxctl cloudsnap backup [command options] [arguments...]

OPTIONS:
   --volume value, -v value       source volume
   --full, -f                     force a full backup
   --cred-id value, --cr value    Cloud credentials ID to be used for the backup

```

As an example, to back up a volume named `volume1`, you would use something like:

```text
pxctl cloudsnap backup volume1 --cred-id 82998914-5245-4739-a218-3b0b06160332

```

Here are a few things to consider about this command:

* it is used to back up a single volume to the cloud provider of your choice using the specified credentials.
* it decides whether to take a full or an incremental backup depending on the existing backups for the volume, as follows:
 * the first backup uploaded to the cloud is always a full backup.
 * after that, subsequent backups are incremental.
 * after 6 incremental backups, every 7th backup is a full backup.
* users can force a full backup any time by giving the `--full` flag.
* if only one credential is configured on the cluster, then the `cred-id` option may be skipped.

Next, we’re going to focus on the steps to perform a successful cloud backup:

* List all the available volumes to choose the volume to backup:

 ```text
 pxctl volume list
 ```

 ```output
 ID            NAME    SIZE    HA    SHARED    ENCRYPTED    IO_PRIORITY    SCALE    STATUS
 56706279008755778    NewVol    4 GiB    1    no    no        LOW        1    up - attached on 70.0.9.73
 980081626967128253    evol    2 GiB    1    no    no        LOW        1    up - detached
 ```

* Now, run the backup command:

 ```text
 pxctl cloudsnap backup NewVol
 ```

 ```output
 Cloudsnap backup started successfully with id: 3f4f0a67-e12a-4d35-81ad-985657757352
 ```

 {{<info>}}
 Note that, in this particular example, since only one credential is configured, there is no need to specify the credentials on the command line.
 {{</info>}}

* While Portworx is working, let's check the progress of our backups:

 ```text
 pxctl cloudsnap status
 ```

 ```output
 NAME                    SOURCEVOLUME                                    STATE        NODE        BYTES-PROCESSED    TIME-ELAPSED    COMPLETED
 39f66859-14b1-4ce0-a4c0-c858e714689e    2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr    Backup-Done    70.0.73.246    420044800    17.460186585s    Wed, 16 Jan 2019 22:27:30 UTC
 3f4f0a67-e12a-4d35-81ad-985657757352    2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463    Backup-Active    70.0.73.246    1247805440    10.525438874s
 ```

 You could also check the status of a particular job, by passing the `task-id` returned upon the successful execution of the `pxctl cloudsnap backup` command:

 ```text
 pxctl cloudsnap status --name 3f4f0a67-e12a-4d35-81ad-985657757352
 ```

 ```output
 NAME                    SOURCEVOLUME                                    STATE        NODE        BYTES-PROCESSED    TIME-ELAPSED    COMPLETED
 3f4f0a67-e12a-4d35-81ad-985657757352    2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463    Backup-Active    70.0.73.246    1840250880    16.57831394s
 ```

 Once the volume is backed up to the cloud successfully, listing the remote cloudsnaps will display the backup that has just been completed.


### List your cloud backups

Use the `pxctl cloudsnap list` command to list your cloud backups:

```text
pxctl cloudsnap list
```

```output
SOURCEVOLUME                    SOURCEVOLUMEID            CLOUD-SNAP-ID                                        CREATED-TIME                TYPE        STATUS
volume20190116214922                590114184663672482        2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-619248560586769719        Wed, 16 Jan 2019 21:51:53 UTC        Manual        Done
volume20190116214922                590114184663672482        2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr        Wed, 16 Jan 2019 22:27:13 UTC        Manual        Done
NewVol                        56706279008755778        2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463        Thu, 17 Jan 2019 00:03:59 UTC        Manual        Done
```

{{<info>}}
**Note:** This command assumes that all your credentials are properly set up. If that is not the case, the cloud backups won't show up.
{{</info>}}

If you enter the `pxctl cloudsnap list` command followed by the `--help` flag, you'll see the avaiable options:

```text
pxctl cloudsnap list
```

```output
pxctl cloudsnap list --help
List snapshot in cloud

Usage:
  pxctl cloudsnap list [flags]

Aliases:
  list, l

Flags:
  -m, --migration             Optional, lists migration related cloudbackups
  -a, --all                   List cloud backups of all clusters in cloud
  -s, --src string            Optional source volume to list cloud backups
      --cred-id string        Cloud credentials ID to be used for the backup
  -c, --cluster string        Optional cluster id to list cloud backups. Current cluster-id is default
  -t, --status string         Optional backup status(failed. aborted, stopped) to list cloud backups; Defaults to Done
      --label pairs           Optional list of comma-separated name=value pairs to match with cloudsnap metadata
  -i, --cloudsnap-id string   Optional cloudsnap id to list(lists a single entry)
  -x, --max uint              Optional number to limit display of backups in each page
  -h, --help                  help for list

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

### Inspect a cloud snapshot

The `pxctl cloudsnap list` command displays all the cloud snapshots for a given credential, source volume, or type of cloud snapshot. To view more details about a particular cloud snapshot, you must specify the `-i` flag with the ID of the cloud snapshot you want to inspect.

Example:

1. Start by listing your cloud snapshots with:

      ```text
      pxctl cloudsnap list
      ```

      ```output
      SOURCEVOLUME            SOURCEVOLUMEID            CLOUD-SNAP-ID                                        CREATED-TIME                TYPE        STATUS
      agg-cs_journal_1        10769800556491614        fe431d7d-0b42-4a4b-9496-f3e9050d0f68/10769800556491614-673132711323933325        Thu, 24 Oct 2019 19:02:08 UTC        Manual        Done
      agg-cs_0            365276421799434338        fe431d7d-0b42-4a4b-9496-f3e9050d0f68/365276421799434338-461608030527675278        Thu, 24 Oct 2019 19:02:47 UTC        Manual        Done
```


2. To inspect the first cloud snapshot (`fe431d7d-0b42-4a4b-9496-f3e9050d0f68/10769800556491614-673132711323933325`) and print the output in JSON format, enter the following command:

      ```text
      pxctl -j cloudsnap list --cloudsnap-id fe431d7d-0b42-4a4b-9496-f3e9050d0f68/10769800556491614-673132711323933325
      ```

      ```output
      [
      {
        "ID": "fe431d7d-0b42-4a4b-9496-f3e9050d0f68/10769800556491614-673132711323933325",
        "SrcVolumeID": "10769800556491614",
        "SrcVolumeName": "agg-cs_journal_1",
        "Timestamp": "2019-10-24T19:02:08Z",
        "Metadata": {
        "cloudsnapType": "Manual",
        "compression": "lz77",
        "sizeBytes": "2152751104",
        "starttime": "Thu, 24 Oct 2019 19:02:08 UTC",
        "status": "Done",
        "updatetime": "Thu, 24 Oct 2019 19:06:12 UTC",
        "version": "V2.00",
        "volume": "{\"DevSpec\":{\"size\":137438953472,\"format\":2,\"block_size\":4096,\"ha_level\":1,\"cos\":3,\"volume_labels\":{\"best_effort_location_provisioning\":\"true\",\"name\":\"vContainer\"},\"replica_set\":{},\"aggregation_level\":1,\"scale\":1,\"journal\":true,\"queue_depth\":128,\"force_unsupported_fs_type\":true,\"io_strategy\":{}},\"UsedSize\":0,\"PoolId\":0,\"ClusterId\":\"PX-INT-C0-BVT-MN-NS-BRANCH_476_24_Oct_19_04_49_UTC\",\"PublicSecretData\":null,\"Labels\":null}",
        "volumename": "agg-cs_journal_1"
        },
        "Status": "Done"
      }
      ```

### Perform cloud backup of a group of volumes

Portworx 2.0.3 and higher supports backing up multiple volumes to cloud at the same consistency point. To see the available command line options, run:

```text
pxctl cloudsnap backup-group --help
```

```output
Backup a group of snapshot for a given group id or labels to cloud

Usage:
  pxctl cloudsnap backup-group [flags]

Aliases:
  backup-group, bg

Flags:
      --full                Force a full backup
      --group string        group id
      --cred-id string      Cloud credentials ID to be used for the backup
      --label pairs         list of comma-separated name=value pairs
  -v, --volume_ids string   list of comma-separated volume IDs
  -h, --help                help for backup-group

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

#### Examples

The below command  takes a group cloud backup of volumes _vol1_ and _vol2_:

```text
pxctl cloudsnap backup-group --volume_ids vol1,vol2
```

```output
Group Cloudsnap backup started successfully with groupID:a1c8ba67-90e1-4c58-acbe-8eaca61a02ae
```

Then, you can grab the `groupID` from above and use it to check the status of the group cloud snapshot. The following command will show the status of each cloud snapshot in the group:

```text
pxctl cloudsnap status --name a1c8ba67-90e1-4c58-acbe-8eaca61a02ae
```

```output
NAME                                    SOURCEVOLUME                                                                    STATE           NODE            BYTES-PROCESSED TIME-ELAPSED    COMPLETED
29bf533d-1469-4610-953e-bd24f945e6de    fb468067-d7aa-40ff-992d-8f40a9e51c9a/201412281295404839-463199598055620776-incr Backup-Done     192.168.56.92   0 B             1.627836177s    Fri, 08 Mar 2019 22:12:14 UTC
650e26f3-f7c9-42c5-b830-2601da6d5fff    fb468067-d7aa-40ff-992d-8f40a9e51c9a/592806372953104727-884041223239759095-incr Backup-Done     192.168.56.92   0 B             1.629703129s    Fri, 08 Mar 2019 22:12:14 UTC
```

You can also take a group cloud backup by selecting the volumes based on their labels. In the example below, we have 2 volumes with the label *app=mysql*:

```text
 pxctl volume list --label app=mysql
```

```output
ID                      NAME    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     STATUS          SNAP-ENABLED
592806372953104727      vol1    1 GiB   1       no      no              LOW             up - detached   no
201412281295404839      vol2    1 GiB   1       no      no              LOW             up - detached   no
```

To back them up as a group to the cloud backup, run the following:

```text
pxctl cloudsnap backup-group --label app=mysql
```

```output
Group Cloudsnap backup started successfully with groupID:3b1de846-1078-40e6-ac1a-2e66ef3986d1
```

### Extent based cloudsnaps

{{<info>}}This feature is not available in versions prior to 2.0.{{</info>}}

With PX-Enterprise 2.0, Portworx has enhanced the way cloud backups are done. Now, users can resume interrupted backups or restores.

For example, if the node performing backups or restores restarts, the backup/restore will resume once that node becomes operational.

This feature is also available for cloud backups of aggregated volumes. Here are a few points to consider in this regard:

* For aggregated volumes, aggregated parts are backed up/restored sequentially.

* Each aggregated part is backed up/restored on one of the nodes where the replica of that aggregated part is provisioned.

* If not enough nodes are available to create the required aggregation level, aggregated volumes are restored to a non-aggregated volume(i.e. `aggregation=1`).

### Restore from a cloud backup

Use `pxctl cloudsnap restore` to restore from a cloud backup. To see the available command options and arguments, run the following:

```text
pxctl cloudsnap restore --help
```

```output
Restore volume to a cloud snapshot

Usage:
  pxctl cloudsnap restore [flags]

Aliases:
  restore, r

Flags:
  -v, --volume string    Volume name to be created for restore
  -s, --snap string      Cloud-snap id to restore
  -n, --node string      Optional node ID for provisioning restore volume storage
      --cred-id string   Cloud credentials ID to be used for the restore
  -h, --help             help for restore

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

This command is used to restore a successful backup from the cloud. It requires the cloudsnap ID and the credentials for the cloud storage provider or the object storage. Restore happens on any node where storage can be provisioned.

You can restore a backup of a Portworx to one of your Portworx volumes in the cluster. Once restored, the volume inherits the attributes from the backup (e.g.: file system, size and block size). The replication level of the restored volume defaults to 1, irrespective of the replication level of the volume that was backed up. Users can increase the replication factor once the restore is complete on the restored volume.

To restore a backup from cloud, enter the following command:

```text
pxctl cloudsnap restore --snap 2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463
```

```output
Cloudsnap restore started successfully on volume: 104172750626071399 with task name:59c4cfd5-4160-45db-b326-f37b327d9225
```

Once a restore gets started, `pxctl` shows the id of the volume created to restore the cloud snap together with the task-id.

While the restore process is running, run the `pxctl cloudsnap status` command to see its status:

```text
pxctl cloudsnap status
```

```output
NAME                    SOURCEVOLUME                                    STATE        NODE        BYTES-PROCESSED    TIME-ELAPSED    COMPLETED
3f4f0a67-e12a-4d35-81ad-985657757352    2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463    Backup-Done    70.0.73.246    11988570112    3m29.825766964s    Thu, 17 Jan 2019 00:07:29 UTC
39f66859-14b1-4ce0-a4c0-c858e714689e    2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr    Backup-Done    70.0.73.246    420044800    17.460186585s    Wed, 16 Jan 2019 22:27:30 UTC
59c4cfd5-4160-45db-b326-f37b327d9225    2e4d4b67-95d7-481e-aec5-14223ac55170/212160250617983239-283838486341798860    Restore-Done    70.0.73.246    1079287808    3.174541219s    Thu, 17 Jan 2019 00:15:19 UTC
```

If you want to see the status of a particular process, run the `pxctl cloudsnap status` command and pass it the `--name` flag with the name of the task you want to inspect:

```text
pxctl cloudsnap status --name 59c4cfd5-4160-45db-b326-f37b327d9225
```

```output
59c4cfd5-4160-45db-b326-f37b327d9225    2e4d4b67-95d7-481e-aec5-14223ac55170/212160250617983239-283838486341798860    Restore-Done    70.0.73.246    1079287808    3.174541219s    Thu, 17 Jan 2019 00:15:19 UTC
```

If the restore command fails, it shows the reason why it failed.

Note that the restored volume will not be attached or mounted automatically.

{{<info>}}
{{% content "shared/reference-CLI-optimized-restores-definition.md" %}}
For more details about optimized restores, visit the [Enabling optimized restores](/reference/cli/cluster/#enabling-optimized-restores) section.
{{</info>}}


### Deleting a Cloud Backup

{{<info>}}
This feature is only supported starting with Portworx version 1.4 or later.
{{</info>}}

To delete a cloud backup, run:

```text
pxctl cloudsnap delete
```

The command will flag a cloudsnap for deletion and a job will take care of deleting objects associated with these backups from the objectstore.

Only cloudsnaps which do not have any dependant cloudsnaps (ie incrementals) can be deleted. If there are dependent cloudsnaps then the command will throw an error and will show the list of cloudsnaps that need to be deleted first.

{{<info>}}
For Portworx versions above and including 2.1, delete requests are queued and processed in the background. Since querying cloud to figure out dependent backups can take a while, user requests to delete the backups are added to a queue and an immediate response is returned to the user. If a cloud backup could not be deleted because of other dependent backups, an alert is logged and this will be deleted when all other dependent backups are deleted by the user.
{{</info>}}

As an example, to delete the backup `pqr9-cl1/538316104266867971-807625803401928868`, you could run the following:

```text
pxctl cloudsnap delete --snap pqr9-cl1/538316104266867971-807625803401928868
```

```output
Cloudsnap deleted successfully
pxctl cloudsnap list
SOURCEVOLUME     CLOUD-SNAP-ID                    CREATED-TIME            STATUS
dvol        pqr9-cl1/520877607140844016-50466873928636534    Fri, 07 Apr 2017 20:22:43 UTC    Done
```

### Cloud backup schedules

Cloud backup schedules allow backups to be uploaded to cloud at periodic intervals of time. These schedules can be managed through `pxctl`.

To view the list of available commands and flags, use:

```text
pxctl cloudsnap schedules --help
```

```output
Manage schedules for cloud-snaps

Usage:
  pxctl cloudsnap schedules [flags]
  pxctl cloudsnap schedules [command]

Aliases:
  schedules, sched

Available Commands:
  create       Create a cloud-snap schedule
  delete       Delete a cloud-snap schedule
  list         List the configured cloud-snap schedules

Flags:
  -h, --help   help for schedules

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

Use "pxctl cloudsnap schedules [command] --help" for more information about a command.
```

#### Creating a cloud backup schedule

Cloud backup schedules can be created using `pxctl cloudsnap schedules create`. To get help on using this command, run:

```text
pxctl cloudsnap schedules create  --help
```

```output
Create a cloud-snap schedule

Usage:
  pxctl cloudsnap schedules create [flags]

Aliases:
  create, c

Flags:
  -f, --full              Force scheduled backups to be full always
  -v, --volume string     Volume ID to set the cloud-snap schedule
  -p, --periodic string   Cloudsnap interval in minutes (default "0")
      --cred-id string    Cloud credentials ID to be used for the backup
  -x, --max uint          Maximum number of cloud snaps to maintain, default 7 (default 7)
  -d, --daily strings     Daily snapshot at specified hh:mm (UTC)
  -w, --weekly strings    Weekly snapshot at specified weekday@hh:mm (UTC)
  -m, --monthly strings   Monthly snapshot at specified day@hh:mm (UTC)
  -h, --help              help for create

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

Let's look at a simple example:

```text
 pxctl cloudsnap schedules create testVol --daily 21:00 --max 15 --cred-id cc84ef11-6d94-4c20-b4b9-01615119a442
 ```

```output
 Cloudsnap schedule created successfully
```

The above command creates a daily schedule that retains a maximum of 15 backups in the cloud. Use the `--max` parameter to indicate the number of backups you want to retain in the cloud. Then, the most recent `--max` number of backups are retained and older backups are deleted periodically.

{{<info>}}
Note that, while listing cloud backups, you may see more than the `--max` number of backups. Due to the incremental nature of backups, we may need to retain more than `--max` backups in order to allow `--max` backups to be restored at any given time.
{{</info>}}

#### Listing Cloud Backup Schedules
You can list the backup schedules that are currently configured using the following command:

```text
pxctl cloudsnap schedules list
```

```output
UUID                        VOLUMEID            MAX-BACKUPS        FULL        SCHEDULE(UTC)
078557a3-26c7-49b1-9822-34e6f816c2d1        648038464574631167        15            false        daily @21:00
```


#### Deleting a Cloud Backup Schedule
Run the following to delete a backup schedule:

```text
pxctl cloudsnap schedules  delete --uuid 078557a3-26c7-49b1-9822-34e6f816c2d1
```

```output
Cloudsnap schedule deleted successfully
```
## Related topics

* For information about creating and managing cloud snapshots of your Portworx volumes through Kubernetes, refer to the [Create and use cloud snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-cloud/) page.
