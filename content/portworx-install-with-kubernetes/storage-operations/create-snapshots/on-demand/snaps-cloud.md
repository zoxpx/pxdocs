---
title: Create and use cloud snapshots
weight: 2
linkTitle: Cloud snapshots
keywords: cloud snapshots, cloud snaps, stork, kubernetes, k8s
description: Learn to take a cloud snapshot of a volume from a Kubernetes persistent volume claim (PVC) and use that snapshot as the volume for a new pod. Try today!
---

This document shows how you can create cloud snapshots of Portworx volumes and how you can clone those snapshots to use them in pods.

{{<info>}}
**NOTE:** You cannot use an older version of Portworx to restore a cloud snapshot created with a newer one. For example, if you're running Portworx 2.1, you can't restore a cloud snapshot created with Portworx 2.2.
{{</info>}}


## Back up a volume and restore it to the same Portworx cluster

This section shows how you can back up a volume and restore it to the same Portworx cluster.

### Prerequisites

* This requires that you already have [Stork](/portworx-install-with-kubernetes/storage-operations/stork) installed and running on your
Kubernetes cluster. If you fetched the Portworx specs from the Portworx spec generator in [PX-Central](https://central.portworx.com) and used the default options, Stork is already installed.
* Cloud snapshots using below method is supported in Portworx version 1.4 and above.
* Cloud snapshots (for aggregated volumes) using below method is supported in Portworx version 2.0 and above.

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-cloud-snap-creds-prereq.md" %}}

### Create cloud snapshots

With cloud snapshots, you can either snapshot individual PVCs one by one or snapshot a group of PVCs.

{{<homelist series="k8s-cloud-snap">}}

### Restore cloud snapshots

Once you've created a cloud snapshot, you can restore it to a new PVC or the original PVC.

#### Restore a cloud snapshot to a new PVC

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-restore-pvc-from-snap.md" %}}

#### Restore a cloud snapshot to the original PVC

{{% content "shared/portworx-install-with-kubernetes-storage-operations-create-snapshots-k8s-in-place-restore-pvc-from-snap.md" %}}


### References

* To create PVCs from existing snapshots, read [Creating PVCs from cloud snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-cloud#creating-pvcs-from-cloud-snapshots).
* To create PVCs from group snapshots, read [Creating PVCs from group snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-group#restoring-from-group-snapshots).


##  Back up a volume and restore it to a different Portworx cluster

This section shows how you can back up a volume and restore it to a different Portworx cluster using the `pxctl` command-line utility.

### Prerequisites

Before you can back up and restore a volume to a different Portworx cluster, you must meet the following prerequisites:

* **Two running Portworx clusters** <!-- Do we want to specify the minimum Portworx version? -->. Refer to the [Installation](/start-here-installation/#installation) page for details about how to install Portworx.
* **An object store**. Cloud snapshots work with Amazon S3, Azure Blob, Google Cloud Storage, or any S3 compatible object store. If you don't have an object store, Portworx, Inc. recommends using MinIO. See the [MinIO Quickstart Guide](https://docs.min.io/) page for details about installing MinIO.
* **A secret store provider**. Refer to the [Secret store management](/key-management/) page for details about configuring a secret store provider.


### Create your cloud snapshot credentials on the source cluster

The options you use to create your cloud snapshot credentials differ based on which secret store provider you use. The steps in this document describe AWS KMS, but you can find instructions for creating other credentials in the [CLI reference](/reference/cli/credentials/#create-and-configure-credentials).

1. Enter the `pxctl credentials create` command, specifying the following:

      * The `--provider` flag with the name of the cloud provider (`s3`).
      * The `--s3-access-key` flag with your secret access key
      * The `--s3-secret-key` flag with your access key ID
      * The `--s3-region` flag with the name of the S3 region (`us-east-1`)
      * The `--s3-endpoint` flag with the  name of the endpoint (`s3.amazonaws.com`)
      * The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
      * The name of your cloud credentials

      Example:

      ```text
      pxctl credentials create --provider s3 --s3-access-key <YOUR_ACCESS_KEY> --s3-secret-key <YOUR_SECRET_KEY> --s3-region us-east-1 --s3-endpoint <YOUR_ENDPOINT> --s3-storage-class <YOUR_STORAGE_CLASS> <YOUR_SOURCE_S3_CRED>
      ```

      ```output
      Credentials created successfully, UUIDU0d9847d6-786f-4ed8- b263-5cde5a5a12f5
      ```

2. You can validate your cloud snapshot credentials by entering the `pxctl credentials validate` command followed by the name of your cloud credentials:

      ```text
      pxctl cred validate <YOUR_SOURCE_S3_CRED>
      ```

      ```output
      Credential validated successfully
      ```

### Back up a volume

1. Enter the following `pxctl volume list` command to list all volumes on the source cluster:

      ```text
      pxctl volume list
      ```

      ```output
      ID			NAME	SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS				SNAP-ENABLED
      869510655149846346	testvol	1 GiB	1	no	no		HIGH		up - attached on 70.0.88.123	no
      186765995885697345	vol2	1 GiB	1	no	no		HIGH		up - attached on 70.0.88.123	no
      ```

2. To back up a volume, enter the following `pxctl cloudsnap backup` command, specifying the name of your volume. The following example backs up a volume called `testvol`:

      ```text
      pxctl cloudsnap backup testvol
      ```

      ```output
      Cloudsnap backup started successfully with id: 0be453e1-ec7a-4db7-9724-a46868cc6b5c
      ```

3. Enter the `pxctl cloudsnap status` command to display the status of your backup or restore operations:

      ```text
      pxctl cloudsnap status
      ```

      ```output
      NAME					SOURCEVOLUME		STATE		NODE		TIME-ELAPSED	COMPLETED
      5c5d3afa-6579-465e-9e34-9bff6ea440eb	869510655149846346	Backup-Failed	70.0.87.153	80.915632ms	Wed, 22 Jan 2020 23:51:17 UTC
      e44b3fb4-45f6-4a83-980b-10458b7a8445	869510655149846346	Backup-Done	70.0.87.153	55.098204ms	Wed, 22 Jan 2020 23:52:15 UTC
      8a32dd41-931b-4ccf-8b99-f15839b26e76	186765995885697345	Backup-Failed	70.0.87.153	39.703754ms	Wed, 29 Jan 2020 18:17:30 UTC
      7ddc9d23-541c-41d3-90c6-2f4a504c01f9	186765995885697345	Backup-Done	70.0.87.153	60.439873ms	Wed, 29 Jan 2020 18:34:17 UTC
      0be453e1-ec7a-4db7-9724-a46868cc6b5c	869510655149846346	Backup-Done	70.0.87.153	45.874676ms	Wed, 29 Jan 2020 22:32:30 UTC
      ```

4. To see more details about your backup operation, enter the `pxctl cloudsnap status` command specifying the following:

   * The `--json` flag
   * The `--name` flag with the task name of your backup.

      Example:

      ```text
      pxctl --json cloudnsap status --name 0be453e1-ec7a-4db7-9724-a46868cc6b5c
      ```

      ```output
      0be453e1-ec7a-4db7-9724-a46868cc6b5c
      {
      "0be453e1-ec7a-4db7-9724-a46868cc6b5c": {
      "ID": "3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-1140911084048715440",
      "OpType": "Backup",
      "Status": "Done",
      "BytesDone": 368640,
      "BytesTotal": 0,
      "EtaSeconds": 0,
      "StartTime": "2020-01-29T22:32:30.258745865Z",
      "CompletedTime": "2020-01-29T22:32:30.304620541Z",
      "NodeID": "a5f87c11-05c5-41b4-84e5-3c38a8c04736",
      "SrcVolumeID": "869510655149846346",
      "Info": [
      ""
      ],
      "CredentialUUID": "0d9847d6-786f-4ed8-b263-5cde5a5a12f5",
      "GroupCloudBackupID": ""
      }
      ```


5. Run the `pxctl cloudsnap list` command, and look through the output to find the identifier of the cloud snapshot associated with your volume. You will use this to restore your cloud snapshot.

      ```text
      pxctl cloudsnap list
      ```

      ```output
      SOURCEVOLUME		SOURCEVOLUMEID			CLOUD-SNAP-ID										CREATED-TIME				TYPE		STATUS
      testvol			869510655149846346		3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-457116323485794032		Wed, 22 Jan 2020 23:52:15 UTC		Manual		Done
      vol2			186765995885697345		3f2fa12e-186f-466d-ac35-92cf569c9358/186765995885697345-237744851553132030		Wed, 29 Jan 2020 18:34:17 UTC		Manual		Done
      testvol			869510655149846346		3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-1140911084048715440		Wed, 29 Jan 2020 22:32:30 UTC		Manual		Done
      ```

      The `CLOUD-SNAP-ID` column is in the form of `<YOUR_SOURCE_CLUSTER_ID>/<YOUR_CLOUD_SNAP_ID>`. In this example, the identifier of the source cluster is `3f2fa12e-186f-466d-ac35-92cf569c9358`, and the identifier of the cloud snapshot is `869510655149846346-457116323485794032`.


### Create your cloud snapshot credentials on the destination cluster

1. Enter the `pxctl credentials create` command, specifying the following:

      * The `--provider` flag with the name of the cloud provider (`s3`).
      * The `--s3-access-key` flag with your secret access key
      * The `--s3-secret-key` flag with your access key ID
      * The `--s3-region` flag with the name of the S3 region (`us-east-1`)
      * The `--s3-endpoint` flag with the  name of the endpoint (`s3.amazonaws.com`)
      * The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
      * The name of your cloud credentials

      Example:

      ```text
      pxctl credentials create --provider s3 --s3-access-key <YOUR_ACCESS_KEY> --s3-secret-key <YOUR_SECRET_KEY> --s3-region us-east-1 --s3-endpoint <YOUR_ENDPOINT> --s3-storage-class <YOUR_STORAGE_CLASS> <YOUR_DEST_S3_CRED>
      ```

      ```output
      Credentials created successfully, UUID:bb281a27-c2bb-4b3d-b5b9- efa0316a9561
      ```

### Restore your volume on the target cluster

1. On the target cluster, verify that your cloud snapshot is visible. Enter the `pxctl cloudsnap list` command, specifying the `--cluster` flag with the identifier of the source cluster.

      Example:

      ```text
      pxctl cloudsnap list --cluster 3f2fa12e-186f-466d- ac35-92cf569c9358
      ```

      ```output
      3f2fa12e-186f-466d-ac35-92cf569c9358
      SOURCEVOLUME		SOURCEVOLUMEID			CLOUD-SNAP-ID										CREATED-TIME				TYPE		STATUS
      testvol			869510655149846346		3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-457116323485794032		Wed, 22 Jan 2020 23:52:15 UTC		Manual		Done
      vol2			186765995885697345		3f2fa12e-186f-466d-ac35-92cf569c9358/186765995885697345-237744851553132030		Wed, 29 Jan 2020 18:34:17 UTC		Manual		Done
      testvol			869510655149846346		3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-1140911084048715440		Wed, 29 Jan 2020 22:32:30 UTC		Manual		Done
      ```

2. To restore your volume, run the `pxctl cloudsnap restore` command specifying the `--snap` flag with the cloud snapshot identifier associated with your backup.
Example:

      ```text
      pxctl cloudsnap restore --snap 3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-1140911084048715440
      ```

      ```output
      Cloudsnap restore started successfully on volume: 1127186980413628688 with task name:e306a2e0-4c88-426c-ae88-a6b731f73983
      ```

3. To see the status of your restore operation, enter the following command:

      ```text
      pxctl cloudsnap status
      ```

      ```output
      NAME				                  	SOURCEVOLUME									STATE		NODE		TIME-ELAPSED	COMPLETED
      2e53ca62-8289-498b-ad9d-dd77c14c00bc	79001397979145130								Backup-Done	70.0.91.94	44.634974ms	Wed, 29 Jan 2020 20:13:58 UTC
      6304dfb7-2f9f-4236-9392-2aba15c5b300	3f2fa12e-186f-466d-ac35-92cf569c9358/869510655149846346-1140911084048715440	Restore-Done	70.0.91.94	53.527074ms	Wed, 29 Jan 2020 22:52:47 UTC
      ```

4. Run the `pxctl volume list` command to list all volumes on the destination cluster:

      ```text
      pxctl volume list
      ```

      ```output
      ID			NAME					SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS		SNAP-ENABLED
      1021141073379827532	Restore-869510655149846346-556794585	1 GiB	1	no	no		HIGH		up - detached	no
      79001397979145130	samvol					1 GiB	1	no	no		HIGH		up - detached	no
      ```
