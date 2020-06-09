---
title: Portworx Release Notes
weight: 200
description: Notes on Portworx releases.
keywords: portworx, release notes
series: release-notes
---

## 2.5.1.3

June 05, 2020

## Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
|PWX-13086| For vSphere 6.7.3 and above, create PX disks (vmdks) such that they don't get deleted on VM deletion. |
|PWX-13542| Fixed in issue where PX would fail to come up vSphere using cloud drives when it cannot find the path of the attached disk|
|PWX-13510| Added a new runtime option `rt_opts kvdb_failover_timeout_in_mins` to configure kvdb offline node failover timeout. Default value is set to 3 mins|

## 2.5.2

May 29, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

| **Improvement Number** | **Improvement Description** |
|----|----|
| PWX-12737 | Added support for automatic cloud disk management for non-public Azure clouds like US Government, Germany and China clouds. |
| PWX-13082 | You can now configure the frequency with which Portworx takes its KVDB backups using the `kvdb_dump_frequency_minutes` runtime option. |
| PWX-10216 | Added support for Vault Namespaces. |
| PWX-11288 | Added support for Vault Kubernetes Authentication. |
| PWX-12603 | When sharedv4 volumes are in use, Portworx uses 16 NFS threads to process them by default. You can change the total number of threads Portworx uses by running the `pxctl cluster options update --sharedv4-threads <num>` command. |
| PWX-12512 | PX-Essential can now refresh licenses through an HTTP or HTTPS proxy. |
| PWX-13116 | Users can now request max backups to be enumerated anywhere between > 0 and < 5000. |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-13189 | A recursive `chmod` operation in Kubernetes 1.18 and lower caused mounts with large block volumes to hang when users set a security context for a pod using `fsGroup`. <br/><br/>**User Impact:** Users with hung mounts would see mount timeouts when creating a pod referencing large block volumes, and pod creation would fail. <br/><br/>**Resolution:** Portworx, Inc. added the `allow_others` storage class label that, when set to true, will apply a permission change to the mount path. This label should only be used for Kubernetes versions lower than 1.18. Users on newer Kubernetes versions can return to using `fsGroup` over the Portworx `allow_others=true` label. |
| PWX-12655 | When Portworx images were uploaded to nodes via docker load command, Docker may not have set the image digest properly.<br/><br/>**User Impact:** When the image digest was not available, OCI-Monitor would not detect manually uploaded Portworx images, and would attempt to pull the Portworx image, potentially failing in air-gapped environments.<br/><br/>**Resolution:** Portworx now has improved image detection, even in cases where image digests are not available. |
| PWX-13171 | The `px_volume_readthroughput`, `px_volume_writethrougput` and `px_volume_iops` metrics did not update.<br/><br/>**User Impact:** Users may have seen values for these metrics reported as zero.<br/><br/>**Resolution:** Portworx once again updates these metrics. |
| PWX-12088 | Portworx used a version of IBM KeyProtect that caused a kernel panic if multiple threads tried to use it.<br/><br/>**User Impact:** Portworx nodes experiencing a kernel panic restarted, and some apps did not come back online after recovery.<br/><br/>**Resolution:** Portworx now uses IBM KeyProtect library v0.3.5, which solves this problem. |
| PWX-12466 | The `--all` option for the `pxctl cloudmigrate start` CLI command has been deprecated. |

## 2.5.1.2

May 28, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

| **Improvement Number** | **Improvement Description** |
|----|----|
| PWX-13175 | Portworx now supports sharedv4 volumes on hosts running Flatcar OS. |

## 2.5.1

April 24, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

| **Improvement Number** | **Improvement Description** |
|----|----|
| PWX-11638 | Starting with 2.5.1, credentials can be configured without providing secret key or access key to use instance’s IAM capabilities to access cloud provider’s object store. Current support is limited to AWS’s EC2 instance in 2.5.1. |
| PWX-12314 | For PX-Essentials, an improvment to the `pxctl status` command now provides the reason for why a license is expired. |


### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-11602 | When Portworx detected an issue with container volumes, for example, if a drive was removed, OCI-Monitor resulted in Portworx pods being stuck in a `CrashLoopBackupOff` state. <br/><br/> **User Impact:** Portworx pods in users' clusters would not recover. <br/><br/> **Resolution:** When Portworx (OCI-Monitor) detects an issue with container mounts, it sends a request to Kuberenetes to reset/reinitialize the Portworx pod, which fixes the issue. |
| PWX-12289 | For the CRI-O container runtime, when OCI-Monitor is set to `ImagePullPolicy:IfNotPresent`, it should pull the PX-Enterprise image only when the image is not present on the system. The OCI-Monitor incorrectly identified the image as present while it wasn't. <br/><br/> **User Impact:** Portworx failed to pull the required image and OCI-Monitor failed. <br/><br/> **Resolution:** The OCI-Monitor `ImagePullPolicy` handling now properly pulls images. |
| PWX-12292 | When using OCI-Monitor, Portworx failed to drain its pods when required. <br/><br/> **User Impact:** OCI-Monitor failed to start and upgrade operations failed. <br/><br/> **Resolution:** OCI-monitor now properly starts and Portworx upgrades. |
| PWX-12252 | For CRI-O integrations, the OCI-Monitor did not copy the install logs into its own output. As a consequence, the OCI-Monitor did not parse/retrieve the `INFO: Module version check: Success` install log line, and always triggered the cordoning/draining of the nodes. <br/><br/> **User Impact:** Upgrades to version 2.5.0 stalled on OpenShift and/or CRI-O container-runtime Kubernetes clusters. <br/><br/> **Resolution:** Portworx application cordoning and draining during the upgrade process now works properly, allowing upgrades. |
| PWX-12180 | Portworx didn't send license server alerts for errors packaged into the response body of a valid REST call. <br/><br/> **User Impact:** Users did not see license server alerts for these kinds of errors. <br/><br/> **Resolution:** Portworx now treats these kinds of errors in the same manner as REST errors, and raises alerts accordingly. |
| PWX-11595 | When a Portworx node's storage is down or full, it reports `Not Ready` to Kubernetes to notify the users. In this case, the Portworx node is still available and serves storage in `read-only` mode if it's full, or proxies the storage from other nodes if local storage is not available. |

## 2.5.0.1

April 21, 2020

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-12322 | Portworx failed to start if NFS was in an errored state. <br/><br/> **User Impact:** Users could not start Portworx if NFS was errored. <br/><br/> **Resolution:** Users can now start Portworx if NFS is errored, and Portworx will now raise an alert instead. |

## 2.5

April 3, 2020

### New features

 * Introducing [PX-Central on-premises](https://2.5.docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/): Deploy your own PX-Central dashboard with Portworx on your own cluster.
 * Introducing [PX Essentials](https://2.5.docs.portworx.com/concepts/portworx-essentials/): A free Portworx license for prototyping and small production clusters.

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

| **Improvement Number** | **Improvement Description** |
|----|----|
| PWX-11777 | Added support to the `pxctl volume list` command, allowing you to list snapshots by node IDs: `pxctl volume list -s --node <node-id>`. |
| PWX-11515 | CLI command flags now use `--node` instead of `--node_id` or `--node-id`.<br/><br/>The following commands were modified:<ul><li>pxctl clouddrive inspect --node</li><li>pxctl clouddrive update-labels --node</li><li>pxctl clouddrive delete --node</li><li>pxctl volume list --node</li></ul> |
| PWX-11464 | Portworx now allows non-root user access to sharedv4 volumes by default. To restrict sharedv4 volume access to the root user, set the `allow_others` label to `false`:<br/><br/>`allow_others=false` |
| PWX-11418 | All cluster and node level alerts will now be raised as Kubernetes events. <br/><br/>NODE alerts: <ul><li>Daemonset model: Events are  raised on the Portworx pod running on that node.</li><li>Operator model: Events are raised on the `StorageNode` object created by the Operator for that node.</li></ul>CLUSTER alerts: <ul><li>Daemonset model: Events are raised on an arbitrary object called `Portworx`</li><li>Operator model: Events are raised on the `StorageCluster` object defined in Kubernetes.</li></ul> |
| PWX-10783 | When Portworx restarts, storageless Portworx nodes will automatically detect any new available storage devices and transition themselves into a storage node. |
| PWX-10756 | When running an internal KVDB without a dedicated drive, `pxctl status` now reports a warning saying that such a configuration is not recommended for a production cluster. |
| PWX-10724 | In cloud, you can now add drives to storageless nodes using the `pxctl` CLI. |
| PWX-10371 | `pxctl status` now reports last known failures if Portworx fails to startup on the node. |
| PWX-9834 | An internal KVDB can now run on storageless nodes. In order to run on storageless nodes, you must provide a `-kvdb_dev` in on-prem clusters, while on cloud PX will provision a drive to be used by kvdb. |
| PWX-11774 | A new `pxctl clouddrive listdrives` command allows you to list all the drives in cloud drivesets. On VSphere, this command also lists the datastore for a VMDK in the labels column.


### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10400 | In some situations, a busy volume remained attached even after a pod is terminated in Kubernetes.<br/><br/>**User impact:** Upgrades or other operations relying on the `kubectl drain` command got stuck on a node with these attached volumes.<br/><br/>**Resolution:** Portworx now detaches these busy volumes from terminated Kubernetes pods. |
| PWX-11753 | Portworx sent the nodeID with cluster-level license alerts: `LicenseExpiring` and `LicenseExpired`. <br/><br/>**User impact:** Customers saw the nodeID associated with license alerts when the clusterID would have been more helpful. <br/><br/>**Resolution:** Portworx now reports the ClusterID instead of NodeID with the `LicenseExpiring` and `LicenseExpired` license alerts. |
| PWX-11722 | Portworx raised alerts at the `CLUSTER` level that are more appropriately raised at the `NODE` level. <br/><br/> **User impact:** Users may have seen these alerts at a level they did not expect. <br/><br/> **Resolution:** Portworx now raises the following alerts as `NODE` instead of `CLUSTER` level:<ul><li>NodeStartFailure:</li><li>NodeStartSuccess:</li><li> NodeStateChange:</li><li>NodeJournalHighUsage:</li><li>NodeTimestampFailure:</li><li>NodeJournalFailure:</li><li>NodeDecommissionSuccess:</li><li>NodeDecommissionFailure:</li><li>NodeDecommissionPending:</li><li> NodeInitFailure:</li><li>NodeMarkedDown:</li></ul> |
| PWX-11637 | Cloudsnaps did not work with some AWS S3 endpoints when bucket name being uploaded to had uppercase letters in the name. <br/><br/>**Customer impact:** Snapshot restore operations involving buckets with uppercase letters failed. <br/><br/>**Resolution:** Portworx now supports uppercase letters in bucket names when used with S3 endpoints. |
| PWX-11365 | Portworx only checked the health of the NFS service on the default port: 2049. However, as this port is configurable, these checks failed if the NFS port changed. <br/><br/>**User impact:** Users who configured their NFS to use a port other than the default encountered errors.<br/><br/>**Resolution:** Portworx now checks the health of the NFS service regardless of the port it's running on, and will raise an alert if determines the NFS server is unhealthy. |
| PWX-11280 | Portworx did not update the cloud drive in-progress state after performing a pool expand operation using `resize-disk`. <br/><br/>**User impact:** Users could have seen a misleading output indicating pool expansion was still in-progress from the `pxctl cloud list` command output, even though the operation completed.<br/><br/>**Resoultion:** Portworx now correctly reports the cloud drive status after a `resize-disk` operation. |
| PWX-10749 | If all nodes in a cluster were storageless, Portworx failed to properly install. <br/><br/>**User impact:** Users attempting to install Portworx on a cluster with only storageless nodes would be left with an out-of-quorum cluster, and would have to wipe the whole installation and redo it with storage nodes.<br/><br/>**Resolution:** Portworx will no longer form a cluster if it cannot find any storage nodes, and will keep reporting an error until a storage node is added to the cluster. |
| PWX-10711 | On slower systems, Portworx occasionally received an `access denied` error from the NFS, and failed to mount sharedv4 volumes. <br/><br/>**User impact:** Users experiencing this issue had to manually retry the sharedv4 mount operation.<br/><br/>**Resolution:** Portworx now retries mounting a sharedv4 volume if it gets an access denied error. |
| PWX-11643 | Intermittent vCenter API failures occasionally caused Portworx to fail to find its already attached cloud drives.<br/><br/>**User Impact:** Disk operations reliant on the the vCenter API would fail.<br/><br/>**Resolution:** Portworx now automatically retries operations involving the vCenter API before reporting an error. |


## 2.4

March 3, 2020

### New Features

* Introducing the Portworx license server: Add and manage licenses for multiple Portworx clusters from an on-premises license server. UI integration coming soon.

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

| **Improvement Number** | **Improvement Description** |
|----|----|
| PWX-10852 | Improved prometheus metrics for Portworx |


### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10939| A difference between how Portworx calculates license expiration dates using time-zones and how Flexera calculates expiration dates without time-zones caused Portworx to occasionally consider new licenses "expired" on their first day.<br/><br/>**User Impact:** Users with multi-part licenses may have been unable to use their multi-part licenses on the first day they activated them.<br/><br/>**Resolution:** Licenses once again work on the first day they're applied and license expiration dates for multi-part licenses display accurately.|


## 2.3.6

February 29, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

| **Improvement Number** | **Improvement Description** |
|----|----|
| 11377 | Adding support for the 4.18.0-147.5.1.el8_1.x86_64 kernel. |

## 2.3.5

February 19, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
|PWX-11000| Portworx now features a Disaster Recovery plan in the IBM Cloud Marketplace. |
|PWX-11122| Portworx now supports dynamic port range change |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
|PWX-11101| If nodes were decommissioned with pending snapshots, those snapshots contained references to the decommissioned node.<br/><br/>**User impact:** New nodes sometimes failed to come up.<br/><br/>**Resolution:** When a node is now decommissioned, Portworx removes any pending snapshots which had references on the decommissioned node. |
|PWX-10441| Due to a race condition in the logic which handles volume attachments during a Portworx restart, sharedv4 volumes could be  tagged as attached when they were not. <br/><br/>**User impact:** This caused stale entries in `/etc/exports`, which led NFS to error out.<br/><br/>**Resolution:** Portworx no longer experiences a race condition at restart, and no longer creates stale entries in `/etc/exports`. |


## 2.3.4

February 3, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
| PWX-10726 | Portworx can now be installed on OpenShift 4.3 when coupled with [Portworx Operator 1.1.1](https://github.com/libopenstorage/operator/releases). |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10974 | In version 2.3.3, Portworx erroneously showed multi-part licenses as "expired" when the license with the earliest expiration date expired. Despite this incorrect reporting, multi-part licenses did not expire and the cluster continued functioning normally. <br/><br/>**User Impact:** Users may have seen multi-part licenses erroneously marked "expired". <br/><br/>**Resolution:** Portworx now correctly displays multi-part license expiration dates. |
| PWX-10967 | PX-Migrate erroneously indicated success when migrating volumes between clusters with the same internal IP addresses. <br/><br/>**User Impact:** Migrations under these circumstances failed, but users saw Portworx indicate success. <br/><br/>**Resolution:** Px-Migrate now successfully migrates volumes between clusters with the same internal IP addresses. |


## 2.3.3

January 23, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
| PWX-10819 | `replica anti-affinity` rules have been deprecated. <br/><br/>**User impact:** Volume creation may fail if using replica anti-affinity volume placement strategy or when restoring volume using cloud backup configured with such a policy. <br/><br/>**Recommendation:** Remove anti-affinity rules and use affinity rules with NotIn, NotEqual operators to achieve the same effect. |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10400 | In some situations, a busy volume remained attached even after a pod is terminated in Kubernetes.<br/><br/>**User impact:** Upgrades or other operations relying on the `kubectl drain` command got stuck on a node with these attached volumes.<br/><br/>**Resolution:** Portworx now detaches these busy volumes from terminated Kubernetes pods. |
| PWX-10809 | Portworx ignored the `max_drive_set_count` field when deployed in disaggregated mode on cloud deployments.<br/><br/>**User Impact:** If an existing node was terminated and replaced without releasing its storage devices, Portworx sometimes brought a new node online as a storage node, exceeding the `max_drive_set_count` field value.<br/><br/>**Resolution:** Portworx now correctly enforces the `max_drive_set_count` field values. |
| PWX-10627 | Portworx processes license expiration dates based on a combination of PX-Enterprise and AddOn licenses. If these licenses expired at different times, Portworx would not accurately report when they would expire. <br/><br/>**User Impact:** Users with these licenses may have had their cluster's node capacity reduced unexpectedly and may not have been able to start their cluster if it exceeded the remaining available license capacity.<br/><br/>**Resolution:** Portworx now aligns the license expiration dates and accurately reports when they expire. |

## 2.3.2

December 18, 2019

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
| PWX-10095 | Portworx now restricts access to SharedV4 volumes to nodes requesting a mount on that volume. |
| PWX-10499 | The `storage pool expansion` operation now supports the `auto` option. |
| PWX-10570 | Portworx now accepts the `VAULT_BACKEND` input argument. When `VAULT_BACKEND` is provided, Portworx uses that version of Vault Backend instead of querying Vault's `sys/mounts/*` directory to fetch all the backends. |
| PWX-10535 | If a SharedV4 Portworx volume must be accessed over NFS outside the Portworx cluster, set the label "allow_all_ips=true" on the volume. This will export the volume on 0.0.0.0/0.0.0.0, which allows you to mount this volume on any node accessible in the network. |
| PWX-10380 | SharedV4 volumes are now enabled when SELinux is enabled on Portworx nodes. If you expect SELinux labels to be propagated from an NFS client to a server, set the `ExportOptions` on a volume to `security_label`. You can use the following command to update the volume option: `pxctl volume update --export_options security_label <vol-name>` |
| PWX-10690 | Portworx now uses hourly usage billing. At end of billing cycle, customers are charged by the number of hours Portworx ran rather than the maximum number of nodes used in a given billing cycle. |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10366 | Portworx did not delete node region or zone values when instructed. <br/><br/>**User Impact:** Portworx continued to show deleted node and region zone labels after users deleted them. This issue persisted over restarts. <br/><br/>**Resolution:** Portworx now properly deletes these labels and replaces them with the `default` value. |
| PWX-10381 | Portworx enabled a license feature intended only for cloud deployments in on-prem clusters. <br/><br/>**User Impact:** This feature transferred licenses of offline storageless nodes to available nodes when running on an on-prem cluster. <br/><br/> **Resolution:** Portworx now only enables this feature when deployed in cloud environments. |
| PWX-10468 | On nodes which were also volume servers and had attached SharedV4 volumes, Portworx did not restart application pods when it entered maintenance mode or was decommissioned. <br/><br/>**User Impact:** Users experienced I/O errors caused by missing application pods. <br/><br/>**Resolution:**  Portworx nodes now delete the application pods to recover the application. |
| PWX-10575 | On AKS clusters with VM scale sets, if a Portworx node with cloud drives failed to bootstrap, detach operations also failed.<br/><br/>**User Impact:** Cloud drives remained attached to non-existent Portworx nodes.<br/><br/>**Resolution:** Portworx now properly detaches cloud drives if it fails to bootstrap a node. |
| PWX-10525 | Portworx frequently queried etcd to retrieve the storage spec and check storage pool status and pending drive operations. <br/><br/>**User Impact:** These frequent queries placed an unnecessary load on etcd, resulting in higher than expected resource usage. <br/><br/>**Resolution:** This fix limits the periodic calls and makes them only when necessary: on a version update. |
| PWX-10455 | A failure during a volume create operation can result in a partially formatted volume. A subsequent attach on this volume will retry the formatting operation. In the case of xfs volumes, this formatting operation can fail if the new operation finds an xfs signature on the volume from the previous incomplete operation. <br/><br/>**User Impact:** Partially formatted xfs volumes could not be attached.<br/><br/>**Resolution:** Portworx now uses the force flag when retrying the format operation. |
| PWX-10657 | The etcdv3 client Portworx uses currently contains the following critical bug: https://github.com/etcd-io/etcd/pull/10911. When connected to a secure etcd cluster, if the first endpoint goes offline, the etcd client does not failover and fails to create a new connection. <br/><br/>**User Impact:** Portworx restarts and does not reconnect to the etcd cluster. <br/><br/>**Resolution:** After restarting, Portworx now reshuffles the list of endpoints so that the etcd client reconnects to the cluster. |
| PWX-10701 | In the `pxctl cluster options update` command, Portworx did not use the configured value associated with the `SnapReservePercent` field for overcommit rules if no label selectors were specified. <br/><br/> **User Impact:** Users could not change from the default `SnapReservePercent` value. <br/><br/> **Resolution:** The `SnapReservePercent` value can now be properly configured. |
| PWX-10685 | Portworx accepted invalid inputs to the `pxctl sv drive add --operation status` command. <br/><br/>**User Impact:** Users adding cloud drives were unable to see the status of their add operations.<br/><br/>**Resolution:** Portworx now allows only device paths in `pxctl service drive add --operation status` command. |
| PWX-10632 | With the new BlueStore backend, Ceph no longer uses an ext4 formatted backend. As a result, Ceph doesn't mount the drives and Bluestore opens the devices without the `o_excl` flag.<br/><br/>**User Impact:** When installing with the `-a` option, Portworx saw the device as "not in use" and picked it up as its storage device. <br/><br/>**Resolution:** Portworx now uses additional filters based on the device name and on-disk signature to prevent this. |


## 2.3.1.2

December 12, 2019

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10681 | For Portworx deployments using an internal KVDB with kubelet running as a docker container,  a crash or other interruption which downs both Docker and Portworx can leave an outdated socket file on the node. On restart, Docker attempts to reconnect to Portworx, but Portworx waits on kubelet causing a cyclic dependency.<br/><br/>**User Impact:** Crashes downing both Portworx and Docker without the chance for cleanup rendered both services unable to recover. <br/><br/>**Resolution:** This fix attempts to address this cyclic dependency. Portworx responds to the outdated socket requests as `not available`, allowing Docker to progress through startup. |



## 2.3.1

November 18, 2019

### New Features

* The `pxctl service pool expand` command is now available, allowing you to expand storage pools by adding drives and consuming unused drive capacity. See the [Expand your storage pool size](/portworx-install-with-kubernetes/storage-operations/create-pvcs/expand-storage-pool/) section of the documentation for more information.

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
| PWX-10148 | If you're using Portworx on Microsoft Azure, Portworx can now expand storage pools by resizing disks. |
| PWX-10332 | Portworx now provides more descriptive error messages for pool expansion failures. |
| PWX-10442 | Added a new flag to the `volume list` command, allowing you to list your volumes per pool UUID: `pxctl volume list --pool-uid <uuid>` |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10414 | Storage pools sometimes fail to come back online after a disk is added as part of a pool expand operation.<br/><br/>**User Impact:** Impacted storage pools may remain down, impacting apps. |

## 2.3

November 12, 2019

### New Features

* Introducing new ways to control [volume provisioning](/portworx-install-with-kubernetes/storage-operations/create-pvcs/control-volume-provisioning/): customize provisioning ratios, disable thin provisioning, or disable provisioning entirely.

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
|PWX-10275| The `pxctl service pool update <pool_ID> --labels` command functionality has improved. Previously, entering the command would overwrite any existing labels. Users wishing to add a label would have to keep track of and repeat the existing labels they wanted to persist. With the improved functionality, Portworx now behaves as follows: <ul><li>If the label does not exist, Portworx adds it to the current set</li><li>If label already exists, Portworx replaces its value</li><li>If you pass a label with a blank value, Portworx removes the label</li></ul>|

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
|PWX-10155| Portworx storage pool labels do not inherit Kubernetes node labels. <br/><br/> **User Impact:** PVC creation relying on Kubernetes node labels fails.|
|PWX-10239| Entering the `pxctl service drive add -o status` command with a `--spec` flag included causes Portworx to incorrectly add drives. <br/><br/>**User Impact:** Users entering a status command with the conflicting `--spec` flag can erroneously add new drives. <br/><br/> **Resolution:** With 2.3, Portworx no longer accepts these malformed commands as drive add operations. |
|PSP-1978| Portworx occasionally causes a read/write operation to wait indefinitely on workloads with a large number of overlapping writes. <br/><br/> **User Impact:** Impacted volumes enter a read-only state or become unresponsive. |

## 2.2.0.5

December 19, 2019

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10657 | The etcdv3 client Portworx uses currently contains the following critical bug: https://github.com/etcd-io/etcd/pull/10911. When connected to a secure etcd cluster, if the first endpoint goes offline, the etcd client does not failover and fails to create a new connection. <br/><br/>**User Impact:** Portworx restarts and does not reconnect to the etcd cluster. <br/><br/>**Resolution:** After restarting, Portworx now reshuffles the list of endpoints so that the etcd client reconnects to the cluster. |
| PWX-10456 | Portworx Inc. currently packages filesystem dependencies required for Linux kernels into an archive in the Portworx container. Under this current scheme, Portworx does not contain new versions of Linux kernels released after it in the archive. <br/><br/>**User Impact:** Portworx fails to install on clusters using newer versions of RHEL 8 kernels. <br/><br/>**Resolution:** During installation, Portworx now checks mirrors.portworx.com for the latest filesystem dependencies required for running Linux kernels if it cannot find them locally. |

## 2.2.0.4

December 12, 2019

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10681 | For Portworx deployments using an internal KVDB with kubelet running as a docker container,  a crash or other interruption which downs both Docker and Portworx can leave an outdated socket file on the node. On restart, Docker attempts to reconnect to Portworx, but Portworx waits on kubelet causing a cyclic dependency.<br/><br/>**User Impact:** Crashes downing both Portworx and Docker without the chance for cleanup rendered both services unable to recover. <br/><br/>**Resolution:** This fix attempts to address this cyclic dependency. Portworx responds to the outdated socket requests as `not available`, allowing Docker to progress through startup. |

## 2.2.0.3

December 10, 2019

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10661 | Redacted VMware vSphere environment variable values from Portworx logs. |

## 2.2.0.2

November 27, 2019

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10525 | Portworx periodically queries etcd to retrieve the storage spec and check storage pool status and pending drive operations. This fix limits the periodic calls and makes them only when necessary: on a version update. |

## 2.2.0.1

October 25, 2019

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
| PWX-10125 | The Portworx `pxctl service` CLI command now supports [pool deletion](/reference/cli/service#pxctl-service-pool-delete). |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10204 | For Portworx version 2.2.0 on IBM Cloud: If users install Portworx outside of the catalog, Portworx incorrectly starts the metering agent and cannot report usage to the billing server. <br/><br/> **User Impact:** After 72 hours, users' clusters enter maintenance mode |

## 2.2

September 30, 2019

### New Features

* Introducing [Storage pool caching](/concepts/pool-caching/), this feature is available on new clusters only.
* Portworx now features [stateful application backup and cloning](/portworx-install-with-kubernetes/storage-operations/stateful-applications/), allowing you new ways to manage your stateful applications.
* Visit [PX-Central](https://central.portworx.com), a place where you can learn all about getting started with Portworx.
* New [jq filtering documentation](/reference/cli/filtering-output-with-jq/) demonstrates how you can filter `pxctl` output.
* The [Portworx CSI](/portworx-install-with-kubernetes/storage-operations/csi/) driver is now generally available for Kubernetes 1.13 and higher.

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
| PWX-9026 | Previously, to enable sharedv4 volumes while installing Portworx, users were asked to provide the  `ENABLE_SHARED_AND_SHARED_v4` environment variable. <br/><br/>With 2.2, this environment variable is no longer required and sharedv4 volumes are enabled by default. |
| PWX-8165 | The `pxctl cluster provision-status` command with the `--show-labels` flag now displays storage pool labels. |
| PWX-9956 | When encrypting volumes with CSI, users can pass the secret information used for volume encryption through storage class templatized parameters. |
| PWX-9888 | When a Portworx volume is resized, the volume usage metrics are now immediately updated in Prometheus. |
| PWX-9831 | Users can use custom labels to designate nodes as KVdb nodes through the `PX_METADATA_NODE_LABEL` environment variable. |
| PWX-9769 | Users can specify the base path for the Vault secret store using the `VAULT_BASE_PATH` environment variable. |
| PWX-9727 | With 2.2, Portworx raises an alert every time a pool is resized. |
| PWX-9481 | Additional `State` column for the `pxctl clouddrive list` and `pxctl clouddrive inspect` commands makes it easier to see the state of a particular drive. |
| PWX-8951 | The `pxctl` command-line utility now allows users to update the credentials and the cloudsnap schedule for a volume. |
| PWX-9976 | With 2.2, users can update a node's CloudDriveSet labels by running the `pxctl clouddrive update-labels --nodeid <node-id>` command. This is useful for when the `px/metadata-node` label must be set to `true` on a node which is part of an operational cluster. |
| PWX-8534 | The `pxctl cloudsnap list` command provides pagination and the users can now specify filters for listing only certain types of backups. By default, migration-related backups are not displayed. |

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-9991 | Using Talisman to upgrade Portworx from version 2.0.x to 2.1 may create a DaemonSet called `portworx-api` with a wrong IP address. As a result, the DaemonSet is not present on the host network. <br/><br/> **User Impact:** This prevented Stork from finding the Portworx service. In turn, users experienced issues while trying to create cluster pairs.<br/><br/> **Resolution:** With 2.2, the upgrade process creates the DaemonSet with the correct IP address. |
| PWX-9777 | If the size of the timestamp file exceeds 10G, Portworx may unexpectedly restart and become stuck in a restart loop. <br/><br/> **User Impact:** Users could not access volumes. |
| PWX-9765 | A recent update to the IBM IAM service requires every client to set the "Content-Length" header in their HTPP requests. <br/><br/> **User Impact:** This caused users to see an `BXNIM0109E:Property missing or empty.` error. <br/><br/> **Resolution:** With 2.2, Portworx sets the "Content-Length" header in every request. |
| PWX-9842 | Openshift on IKS: Pods may get stuck in the `terminating` state during teardown. <br/><br/> **User Impact:** This left stale paths for the volumes, causing the pod teardown to get stuck. |
| PWX-9964 | Under certain circumstances, the volume delete operation may fail. <br/><br/> **User Impact:** Users may see a `Client.Timeout exceeded while awaiting headers` error, and the delete operation may get stuck for approximately 5 minutes. |
| PWX-9889 | Under certain circumstances, Portworx exposes empty volume usage metrics to Prometheus. <br/><br/> **User Impact:** Users are unable to see the correct volume usage metrics in Prometheus. |
| PWX-9883 | When running Portworx with the internal KVdb, the Portworx service may restart on the online nodes during a KVdb failover. <br/><br/> **User Impact:** Users see an `Etcd cluster not reachable` error. |
| PWX-9855 | Rebooting the internal KVdb nodes within a short interval resulted in the configmap entries getting cleaned up. <br/><br/> **User Impact:** The internal KVdb doesn't start, and the cluster goes out of quorum. <br/><br/> **Resolution:** Check the node labels before performing a KVdb node failover. If the node labels don't allow the node to act as a KVdb node, then don't remove the offline KVdb node from the existing cluster. |
| PWX-9826 | If all the nodes are rebooted at the same time, an application node may try to start the internal KVdb, even though it doesn't have the `px/metadata-node=true` label. <br/><br/> **User Impact:** A storage cloud-drive may get attached to a KVdb node or vice versa. <br/><br/> **Resolution:** Make sure that the KVdb drives are only attached to the designated KVdb nodes, and the application nodes don't attach a `DriveSet` belonging to a KVdb node. |
| PWX-9334 | A bug in the Grafana dashboard caused storageless nodes to display as `down` in Grafana. |
| PWX-10031 | If a migration is performed while only the source cluster is licensed for Disaster recovery, Portworx marks the migration as successful even if the resources are not migrated correctly. <br/><br/> **User Impact:** The migrated volume is empty |
| PWX-10000 | The `pxctl volume usage` command errors out on nodes with more than 100 volumes attached. <br/><br/> **User Impact:** Users see the following error message: `Error: Get http://localhost:9001/v1/osd-volumes/usage/<VOL_ID>: net/http: request canceled (Client.Timeout exceeded while awaiting headers)`. |
| PWX-6894 | For sharedv4 volumes, Portworx provides multi-RW access to the volumes by maintaining a single server and multiple clients. If this type of server goes down, the clients receive an `Unmount` request for the volume. This results in a server with a dangling client reference. <br/><br/> **User Impact:** The sharedv4 volumes might end up attached even if there is no consumer. |
| PWX-9974 | Fixed an issue in which the OpenStorage SDK sends the redirect flag for every request to detach a volume. <br/><br/> **User Impact:** Under certain circumstances, the operation of deleting or detaching a volume could timeout after 5 minutes. |
| PWX-9625 | Installing Portworx using a Helm chart on Kubernetes 1.14.3 fails. <br/><br/> **User Impact:** The user sees several helper pods failing because they try to pull an image which doesn't exist. <br/><br/> **Resolution:** Fixed by replacing the `kubectl` repo with `https://hub.docker.com/r/bitnami/kubectl`. |
| PWX-10061 | When running Portworx on Kubernetes, the upgrade process can reset the custom port settings in the `portworx-service` spec to their default values. <br/><br/> **User Impact:** Users see an `HTTP error 404` error in `kubelet` while trying to mount a volume. |


### Known Issues

Portworx is aware of the following issues, check future release notes for fixes on these issues:

|**Issue Number**|**Issue Description**|**Workaround**|
|----|----|----|
| PWX-10049 | CSI: Due to an issue Kubernetes 1.13, if the Kubelet or Portworx goes offline unexpectedly on a node where a volume is attached, the Kubelet will leave orphaned pod directories under `/var/lib/kubelet/pods/*`. The kubelet logs will report these errors every 2 seconds unless this directory is manually cleaned up. | Move or delete the orphaned pod's directory to stop these logs from showing up. |
| PWX-10057 | CSI: In Kubernetes 1.14 with the Portworx CSI driver, unmount may fail intermittently if a volume is attached to a node where Portworx is down. | If unmount fails, retry once Portworx is back online. |
| PWX-10056 | PX-Security: With security enabled, the `pxctl cloudmigrate status` command returns a blank result even there is cloud migration going on. | Use the `pxctl cloudmigrate status --task_id <your_cloud_migration_task_ID>` command to view the migration status. |
| PWX-8421 | Setting collaborator access on a snapshot using `pxctl` may return an error. | `pxctl` properly updates collaborator access, despite returning an error. |

## 2.1.7

December 12, 2019

### Fixes

The following issues have been fixed:

|**Issue Number**|**Issue Description**|
|----|----|
| PWX-10681 | For Portworx deployments using an internal KVDB with kubelet running as a docker container,  a crash or other interruption which downs both Docker and Portworx can leave an outdated socket file on the node. On restart, Docker attempts to reconnect to Portworx, but Portworx waits on kubelet causing a cyclic dependency.<br/><br/>**User Impact:** Crashes downing both Portworx and Docker without the chance for cleanup rendered both services unable to recover. <br/><br/>**Resolution:** This fix attempts to address this cyclic dependency. Portworx responds to the outdated socket requests as `not available`, allowing Docker to progress through startup. |

## 2.1.5

September 13, 2019

### Fixes
The following issues have been fixed in the 2.1.5 release:

|**Issue Number**|**Issue Description**|
|----|----|
|PWX-9911 |When running PX-DR, old cloudsnaps might not have been deleted from the objectstore since deletions were triggered only on full backups. <br/><br/>**User impact:** Over time, the objectstore on the PX-DR destination cluster may run out of space. <br/><br/>**Resolution:** With 2.1.5, the next DR cleans up old cloudsnaps and frees up space in the objectstore. |
|PWX-9892 |Asynchronous DR causes a large number of alerts composed of long strings, which resulted in high memory usage. <br/><br/>**User impact:** ETCD disk usage was unnecessarily high.|
|PWX-9873 |The DC/OS ACS token used to communicate with DC/OS secrets APIs expires every 5 days, and the auth workflow does not refresh this token when it expires. <br/><br/>**User impact:** This caused users to see an `Unauthorized` error, which required them to restart Portworx.|
|PWX-9811 |In PKS, unset regions impact volume provisioning. <br/><br/>**User impact:** Volumes would be improperly provisioned into a single region. <br/><br/>**Resolution:** With 2.1.5, an unset region will be set to "default". |

## 2.1.4

August 26, 2019

### Fixes
The following issues have been fixed in the 2.1.4 release:

|**Issue Number**|**Issue Description**|
|----|----|
|PWX-9781 |Cloudsnap backup operations may fail during catalog collection. <br/><br/>**User impact:** User operations relying on Cloudsnap may fail. <br/><br/>**Resolution:** With 2.1.4, catalog collection has been disabled. |

## 2.1.3

August 8, 2019

### Improvements
Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Number**|**Improvement Description**|
|----|----|
|PWX-8793|In order to migrate volumes encrypted with an AWS KMS cluster-wide secret between clusters, both clusters must have the same cluster-wide secret.<br/><br/>With 2.1.3, Portworx introduces new CLI commands. These commands allow you to dump the cluster-wide secret from one cluster in order to upload the same cluster-wide secret to the destination cluster where encrypted volumes will be migrated. For more information, visit the [Dump and upload cluster-wide secrets](/reference/cli/dump-upload-cluster-wide-secret/) article.|

### Fixes
The following issues have been fixed in the 2.1.3 release:

|**Issue Number**|**Issue Description**|
|----|----|
|PWX-8902 |On older versions of Kubernetes configured to use the CRI-O container runtime on CoreOS/RHEL nodes, volume mount operations failed with the following error message: `selinux is enabled on docker. Disable selinux by removing --selinux-enabled from dockerd arguments`<br/><br/>**User impact:** Kubernetes applications running on this particular configuration attempting to use a shared volume never receive their volume and fail to fully start.<br/><br/>**Resolution:** With 2.1.3, Kubernetes application start as expected.|
|PWX-9610 |Portworx used invalid characters for Prometheus metric labels. <br/><br/>**User impact:** Customers using Prometheus experienced errors when attempting to view metrics.<br/><br/>**Resolution:** With 2.1.3, Portworx replaces invalid '/' characters with '_' characters when serving metrics to Prometheus. |
|PWX-9632 |Portworx occasionally detected a public network interface, causing the internal ETCD to attempt to use a public IP address to communicate over blocked ports.<br/><br/>**User impact:** Nodes were unable to form a quorum.<br/><br/>**Resolution:** With 2.1.3, Portworx no longer detects public network interfaces.|

### Known Issues
Portworx is aware of the following issues, check future release notes for fixes on these issues:

|**Issue Number**|**Issue Description**|**Workaround**|
|----|----|----|
|PWX-9607 | The `pxctl volume usage` command may fail, causing the storage layer to become unresponsive and freezing storage I/O on the nodes where the volume is provisioned.| With 2.1.3, this command has been hidden. <br/><br/>If you're still on 2.1.2, avoid entering this command. If storage does become unresponsive as a result of `pxctl volume usage`, reboot the nodes on which your volume has been provisioned.|

## 2.1.2

July 24, 2019

### Key Features

1. [Cloud drive support for Microsoft Azure](/portworx-install-with-kubernetes/cloud/azure/aks/)
2. [Enhanced Volume placement strategies for advanced volume provisioning rules](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placement-strategies/)
3. Support for Red Hat Enterprise Linux 8 with CRI-O

### Enhancements

**PWX-8635** - Add support for the CRI-O container runtime.

_User Impact:_ Portworx has added support for the CRI-O container runtime, with the some log file limitations:

  * The progress bar while downloading images is not available.
  * Progress information while installing Portworx binaries is not available.

**PWX-8665** - Support for optimized restores as a cluster option.

_User Impact:_  Users can now enable optimized restores as a cluster level setting using the CLI.

**PWX-9061** - Add ability to remove path-style enforcement for AWS S3.

_User Impact:_ With 2.1.2, Portworx now supports the disabling of path-style enforcement for S3 with the `--disable-path-style` parameter.

### Key Fixes

**PWX-9352** - Upgrading from 2.0.3.7 to 2.1.1 fails.

_User Impact:_  If you have internal KVDB clusters, upgrading from 2.0.3.7 to 2.1.1 is not supported. Portworx recommends upgrading from 2.0.3.7 to 2.1.2.

**PWX-8730** - Allow storageless nodes to join when licenses have been exhausted if offline storageless nodes remain.

_User Impact:_  Previously, rolling upgrades of customer environments in cloud auto-scaling groups may have exceeded licensing quota if storageless nodes were created before offline nodes were removed from the cluster. With 2.1.2, offline nodes no longer count against licensing count.

_Recommendations:_ Upgrade to 2.1.2 to support rolling upgrades in cloud auto-scaling environments. If you are unable to upgrade to 2.1.2, you can work with Portworx support to get temporary licenses that increase the node count until an upgrade to 2.1.2 can be planned.

**PWX-9042** - Secrets can be overwritten with certain commands.

_User Impact:_ with 2.1.2, It is no longer possible to unintentionally overwrite secrets using a combination of the `pxctl secrets set-cluster-key` and `pxctl generate secret` commands.

**PWX-8953** -   (Consul) KVDB does not pass the CA certificate file to the Consul client.

_User Impact:_ With 2.1.2, CAFile is now properly sent to the Consul client.

**PWX-8966** - (ASG) Limit the maximum number of drives you can attach to a node.

_User Impact:_  Previously, attempting to attach too many drives results resulted in errors. With 2.1.2, Portworx introduces a maximum limit of 12 drives per node, and will respond to attempts to add more than 12 drives with the following error: `cannot provide more than 12 number of drives per node`.

**PWX-7374** - AWS SC1 and ST1 EBS volumes are unsupported.

_User Impact:_ It was previously not possible to add SC1 or ST1 EBS volumes using the `pxctl service drive add` command. With 2.1.2, Portworx now supports SC1 and ST1 EBS drive types.

**PWX-8792** - Add backoffs to AWS CloudDrive API calls.

_User Impact:_ With 2.1.2, Portworx now slows calls to the AWS Cloud Drive API at increasingly long intervals if it encounters resource limit errors.

**PWX-8701** - The internal KVDB should use DNS names for peer urls.

_User Impact:_ The internal KVDB tracks peer URLs as potentially ephemeral IP addresses. If the entire cluster becomes unavailable in an outage, Portworx may be unable to reconnect. With 2.1.2, internal KVDB now keeps track of nodes using a DNS, and can therefore reconnect in the event of a total cluster outage.

**PWX-8904** - Introduce timeout on storage requests to avoid possible hung situations when Portworx starts.

_User Impact:_ Previously, Portworx may have failed to start, displaying no active I/O operations. With 2.1.2, storage requests now timeout to avoid possible hung situations on node start.

**PWX-8606** - PVC creation fails if no enforcement type is specified in `VolumePlacementStrategy`.

_User Impact:_  Previously, if you did not specify an enforcement type in `VolumePlacementStrategy`, PVC creation failed. With 2.1.2, Portworx will default to `enforcement: required` if you do not specify an enforcement type.

**PWX-8959** - The Snapshot API does not return a typed error if a snapshot already exists.

_User Impact:_ With 2.1.2, this error message is improved. If you try to create a new snapshot where one already exists, a clearly typed error is now returned.

**PWX-9126** - The `nodiscard` option is impacted by volume resize.

_User Impact:_ Previously, resizing a volume sometimes reset a volume’s `nodiscard` option configuration. With 2.1.2, this has been fixed.

**PWX-8690** - Wipe and upgrade scripts fail on Kubernetes 1.14.

_User Impact:_ Due to a feature deprecation with Kubernetes 1.14, wipe and upgrade scripts did not work. With 2.1.2, The `px-wipe` command now correctly removes Portworx pods on Kubernetes 1.14.

**PWX-9175** - Portworx fails to detect the device path on certain types of AWS ec2 instances.

_User Impact:_ With 2.1.2, Portworx no longer fails to detect the device path on certain types of AWS ec2 instances and operating system combinations.

**PWX-7851** - Storage nodes could be removed by the Kubernetes autoscaler.

_User Impact:_ With 2.1.2, Portworx pods are annotated to prevent node removal by the Kubernetes autoscaler.

**PWX-7493** - Portworx selects undesired network interfaces during autodetection.

_User Impact:_ With 2.1.2, Portworx will avoid selecting the undesired network interfaces during configuration.

**PWX-9053** - The pxctl service node wipe command fails to wipe MDRAID devices.

_User Impact:_ With 2.1.2, MDRAID devices are now correctly wiped with the node wipe command.

**PWX-9046** - Portworx doesn’t recognize MDRAID partitions as journal devices.

_User Impact:_ With 2.1.2, Portworx now recognizes MDRAID partitions as journal devices.

**PWX-9054** - Portworx sometimes fails to detect MDRAID partitions.

_User Impact:_ With 2.1.2, Portworx now detects MDRAID partitions when installed with the `-A` option.

**PWX-8938** - Add “sync” and “noac” sharedv4 mount options.

_User Impact:_ With 2.1.2,  “sync” and “noac” sharedv4 mount options are now available.

**PWX-8893** - Add support for `max_storage_nodes_per_zone` on AKS clusters on Microsoft Azure.

_User Impact:_ With 2.1.2, Portworx supports the max_storage_nodes_per_zone parameter, allowing it to limit storage nodes on AKS availability sets.

**PWX-9263** - Volumes can now be created with the XFS filesystem without needing to provide the "force_unsupported_fs_type" option.

_User Impact:_ Previously, provisioning an XFS volume erroneously created an EXT 4 formatted volume. With 2.1.2, provisioning an XFS volume now creates a properly formatted XFS volume.

**PWX-8712** - Verify completion of a backup before marking it as complete.

_User Impact:_ With 2.1.2, Portworx now verifies that a backup operation has completed before recording a backup as completed.

**PWX-8733** - During upgrade, pods using volume subpaths produce errors.

_User Impact:_ With 2.1.2, pods using volume subpaths are correctly detected and bounced.

**PWX-9476** - OCI-Monitor should not restart the Portworx service unless required.

_User Impact:_ Previously, if the OCI-Monitor restarted Portworx any time it detected a change in the configuration file. With 2.1.2, the OCI-Monitor will only restart Portworx if it’s necessary.

### Errata

**PWX-9473** - Portworx fails to attach a cloud drive to an Azure AKS scale set VM.

_User Impact:_ Portworx fails to attach a cloud drive with the following error messages: `Failed to detach disk...`, and `Failed to attach drive...`

_Recommendations:_ Portworx is working with Microsoft to resolve this issue, in the meantime, we recommend deleting the impacted VM manually in Azure and allowing it to redeploy.

## 2.1.1

May 4, 2019

### Key Fixes

* PWX-8668 - K8S: Pods get stuck again on "Terminating 0/1". Failing to unmount shared volumes, because they are not found
* PWX-8652 - AWS: Allow specifying custom tags for EBS volumes in spec
* PWX-8643 - Storage pool does not recover out of storage full condition after deleting volumes
* PWX-8529 - Cloudsnap restore very slow for backups that have dependent incremental with large data sets

## 2.1.0.1

May 22, 2019

### Key Fixes

PWX-8870 - PX Metro DR didn't mark a node as offline

## 2.1.0

April 19, 2019

### Key Features and Enhancements

* PX-Security
  * [General Concepts](/concepts/authorization)
  * [Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization)
  * [CLI Volume access](/reference/cli/volume-access)
  * [CLI Authorization](/reference/cli/authorization)
  * [CLI Role](/reference/cli/role)
* [PX-DR](/portworx-install-with-kubernetes/disaster-recovery)
  * [Metro DR](/portworx-install-with-kubernetes/disaster-recovery/px-metro)
  * [Asynchronous DR](/portworx-install-with-kubernetes/disaster-recovery/async-dr)
* [Automated application level scheduled snaps and cloudsnaps](/portworx-install-with-kubernetes/storage-operations/create-snapshots/scheduled)
* [Automated app-consistent cluster to cluster migration](/portworx-install-with-kubernetes/migration/kubemotion/#pre-and-post-exec-rules)
* [Optimized incremental cloudsnap restores](/reference/cli/cloud-snaps/#restore-from-a-cloud-backup)

### Key Fixes

* PWX-7160 - Fix issues with cloudsnaps to IBM Objectstore
* PWX-7481 - Shared volume failed to detach with an error that the volume is mounted. But the volume was not mounted
* PWX-7650 - Portworx install errors w/ "tar: .: file changed as we read it"
* PWX-7794 - License: Aggressive node-decommissions and "Cluster max capacity" error handling
* PWX-7869 - Cloudsnaps: Handle cloud backup deletes in background
* PWX-7891 - pxctl service nw --all failed to delete multi-path devices
* PWX-7951 - In Kubernetes OCI-Mon restarts during updates may leave Portworx down
* PWX-7963 - Cloudsnap restore for xfs volumes has wrong fs type
* PWX-7968 - Cloudsnaps cleanup fails because of missing start timestamp in metadata
* PWX-7989 - Skip cleanup when a pre-existing node fails to join due to licensing
* PWX-8025 - Alert for storage full is deleted even though the condition still exists
* PWX-8033 - DC/OS portworx-mongo now works with nested folders
* PWX-8055 - pxctl import: copy links after all regular files have been copied
* PWX-8060 - Cloudsnap restores will fail when the volume is heavily fragmented
* PWX-8064 - Reducing the HA level of an aggregated volume may cause any active cloud backups on the volume to fail. New cloud backup can be restarted once the HA level has been reduced on the volume
* PWX-8261 - Startup issue with Debian 9 (4.19.0-0.bpo.2-cloud-amd64)
* PWX-8297 - K8S: OCI-Mon must force-pull px-enterprise b4 reinstalling incomplete Portworx
* PWX-8311 - IKS: OCI Monitor not starting Portworx when both Docker and ContainerD services running
* PWX-8334 - Fixed install progress-bar
* PWX-8335 - Handle mpath device partitions in nodewipe
* PWX-8403 - Error when trying to mount a sharedv4 volume with encryption. The first pod comes up okay, but second and subsequent pods mount results in failure
* PWX-8472 - OpenShift: Portworx mounts leak. Each portworx-service restart will increase the number of mounts
* PWX-8504 - Cloudsnaps: No incremental backups created for cloud backups that have user tags( created by external schedulers)

### Errata

* PWX-8470: ASG: CLI does not update metadata device name, if after restart device name changes

## 2.0.3.8

### Key Fixes

**PWX-9486** - Changes to Portworx runtime configuration.

_User Impact:_ This fix ensures consistent sync times on the backend.

## 2.0.3.7

June 19, 2019

{{<info>}}
Portworx 2.0.3.7 works with Stork 2.1.2. Here are the [release notes](https://github.com/libopenstorage/stork/releases/tag/v2.1.2) for Stork 2.1.2.
{{</info>}}

### Key Features and Enhancements

**Feature: PWX-7549** - Provide the ability to add multiple drives to a Portworx node in a single command.

_Customer Impact_:  None. This is an enhancement as previously Portworx only allowed only one drive to be added at a time.

_Recommendations_: Add only one drive at a time or upgrade to 2.0.3.7 to be able to multiple drives.

### Key Fixes

**Issue: PWX-9203** - Connections get reset in networks with long idle time with bursty traffic

_Customer Impact_: In very rare cases, in specific network setups, the connections between the node were seen to be disrupted after many hours of idle time.

_Recommendations_: 2.0.3.7 implements improved  connection keep-alives to keep node-to-node connections active in case of long idle times

**Issue: PWX-9126** - If a volume has the 'nodiscard' option set after the volume gets resized, the 'nodiscard' is not retained.

_Customer Impact_: For customers who have used this option to increase the performance, the performance may drop after a volume gets resized.

_Recommendations_: None. Recommend upgrading to 2.0.3.7

**Issue: PWX-9118** - Adding an LVM drive partition as journal device failed.

_Customer Impact_: Adding a journal device which is LVM drive partition will fail but the error is not clear in the logs. In general, it is not recommended to use LVM partitions as journal devices because of the performance limitations of such devices.

_Recommendations_: Don't use LVM partitions as a journal device. Upgrade to 2.0.3.7 for better handling.

**Issue: PWX-9055** - Installing Portworx with an LVM volume that has a similar name to another LVM volume will deactivate the other LVM volume (not used by Portworx). For e.g, if Portworx is asked use to /dev/mapper/volone and there is another LVM volume with the name /dev/mapper/volone1, volone1 would get deactivated.

_Customer Impact_: In this case, if the customer was using the raw LVM volume for another application, that volume will be deactivated.

_Recommendations_: Portworx recommends inspecting the system beforehand and to use volume names for LVM volumes that do not overlap with the existing volumes. To completely avoid the issue, Portworx recommends upgrading to 2.0.3.7.

**Issue: PWX-8717** - Adding a journal device to a storage-less node right after a storage device was added results in Portworx crashing and restarting.

_Customer Impact_: When a user tries to add a journal device to a storage-less node right after adding a storage device,  Portworx might crash and restart. In general, there is no application error as Portworx restarts within the 10 min device timeout interval, but there may be a very brief slow down of the I/Os.

_Recomendations_: The workaround is to restart Portworx after a storage device was added and then add a journal device. Upgrading to 2.0.3.7 will eliminate the need for a restart.

**Issue: PWX-9054** - Using the `-A` option during install does not recognize mdraid partitions.

_Customer Impact_: If the storage disks provided to Portworx during install are from mdraid partitions, Portworx will not recognize them and will come up in storageless mode.

_Recommendations_: There is no workaround. Upgrading to 2.0.3.7 will enable adding mdraid partitions

**Issue: PWX-8904** - Restarting Portworx node could result in not being able to complete the startup sequence.

_Customer Impact_: This was seen in environments where there was heavy I/O with shared and non-shared volumes. Also, there were lots of replicas on the node to which a lot of traffic was being routed to. This resulted in a scenario where the internal credits were exhausted. 2.0.3.7 increased the credits and resource allocation.

_Recommendations_: Upgrading to 2.0.3.7 resolves this issue.

**Issue: PWX-9017** - De-couple OCI-mon constraints from Portworx systemd service limits

_Customer Impact_: With previous releases, if the user changes the oci-mon system constraints/limits, it will get passed on to Portworx systemd service.

_Recommendations_: This is addressed in 2.0.3.7 where the oci-mon limits are no longer passed on Portworx systemd service

**Issue: PWX-8846**  - Storage-less node ended up with stuck I/Os and needed to be restarted.

_Customer Impact_: A storage-less node stopped processing I/Os and had to be restarted to have the resources released.

_Recommendations_: Storage-less node must be restarted to release the resources so application I/O can begin to run. Resources used by volumes which are detached when the node was down are not released when the node comes back online. This was resolved so these resources are now properly released to the global internal resource pool in Portworx.

**Issue: PWX-9042** - Do not allow overwriting of secrets

_Customer Impact_: Users can potentially overwrite their encrypted volume secrets if they end up using the same name for the new secret.

_Recommendations_: Users must double-check if they already have the same name that they are trying to add new secrets to the same cluster. 2.0.3.7 implemented a check to look for existing names before accepting a new secret. This prevents the secret from being overwritten.

## 2.0.3.6

May 30, 2019

### Key Fixes

* PWX-8740 - Cloudsnaps: Do not create multiple grpc clients to px-storage
* PWX-8299 - Core with 'concurrent map writes' when object store on the remote cluster was unreachable

## 2.0.3.5

May 28, 2019

### Key Fixes

* PWX-5885 - px-runc install is missing option to specify raidlevel
* PWX-7851 - Add pod annotation to prevent scale down of storage nodes in K8s when using autoscaler
* PWX-8701 - Internal Kvdb: Use DNS names for peer URLs instead of IPs for internal kvdb
* PWX-8712 - Cloudsnaps: Verify uploaded objects before marking backup as done
* PWX-8715 - Node index generation fix to avoid same node index generation
* PWX-8733 - Post upgrade to 2.0.3.4: shared volumes were errored because the server endpoint wasn’t there anymore
* PWX-8917 - OCI-Mon: Portworx service not restarted after cpu/mem limits updated

## 2.0.3.4

April 24, 2019

### Key Fixes

* PWX-8472 - OpenShift: Portworx mounts leak. Each portworx-service restart will increase the number of mounts
* PWX-8529 - Fix Cloudsnap restore performance for backups that have dependent incremental with large data sets
* PWX-8652 - AWS: Allow specifying custom tags for EBS volumes in spec

## 2.0.3.3

April 5, 2019

### Key Fixes

* Portworx available on GOOGLE CLOUD PLATFORM MARKETPLACE https://cloud.google.com/marketplace/
* PWX-8451 - Block adding metadata device when running with internal kvdb
* PWX-8345 - Node wipe and upgrade doesn't work if Portworx is installed in a namespace other than kube-system
* PWX-8045 - Cloudmigrate fails if credentials use a custom bucket name
* PWX-7891 - pxctl service node-wipe --all failed to delete multi-path devices
* PWX-8261 - Allow fresh install of Portworx on Linux Kernel version 4.9.0-7-amd64 and 4.9.0-8-amd64  

## 2.0.3.2

March 22, 2019

### Key Fixes

* PWX-8062 - Portworx cluster running on k8s does not report volumes metrics
* PWX-8136 - Disable kvproxy audit as it causes the etcd client to trigger unnecessary API requests
* PWX-8098 - Portworx fails to start after reboot on a system with LVM drives and auto-configured journal device

### Errata

* PWX-8161 - If an LVM partition is added as journal device after node initialization, any subsequent system reboot will need the LVM partition to be made visible before starting Portworx. This can be done by running "partprobe"

## 2.0.3.1

March 19, 2019

### Key Fixes

* PWX-8063 - Startup issue with 4.19.0-0.bpo.2-cloud-amd64
* PWX-8060 - Cloud backup restore fails with JSON unmarshalling error
* PWX-7989 - Fix licensing issue which was leading to reducing the number of nodes allowed in the cluster. Differentiate between NEW and PRE-EXISTING node failing to join the cluster, and do not clean up if PRE-EXISTING nodes were the ones causing the failures.
* PWX-7980 - Do not cleanup CloudDrives when the drives are initialized and have labels
* PWX-7968 - Cloudsnaps cleanup fails because of missing start timestamp in metadata
* PWX-7963 - Cloudsnap restore for xfs volumes has wrong fs type
* PWX-7794 - LIC: Aggressive node-decommissions and "Cluster max capacity" error handling

## 2.0.3

March 8, 2019

### Key Features and Enhancements

* SharedV4 support for DC/OS
* SharedV4 volume encryption support
* Support DC/OS Zookeeper for discovery service when using internal kvdb in DC/OS configurations
* Volume Policy Management Support
* Support Azure Key Vault for Secret Store
* Fix Kubernetes CVE for RUNC

### Key Fixes

* PWX-5657 - Fix a corner case where increasing the replication factor of a volume can take much longer when there are multiple levels of volume clones
* PWX-5762 - Add support for Azure Key Vault
* PWX-6868 - Prometheus framework update  to add Portworx support
* PWX-7448 - Show proper error for incorrect pxctl commands
* PWX-7468 - node-wiper script to wipe the namespace created by k8s secrets
* PWX-7481 - Shared volume failed to detach with an error that the Volume is mounted while Volume was not mounted
* PWX-7485 - Display an appropriate message when cluster-wide diags can not be collected
* PWX-7491 - Drive provisioning fixes for issues where extra drives were created than what was specified in the spec.
* PWX-7512 - Speed up Portworx install in DC/OS clusters by installing in each node in parallel.
* PWX-7513 - In DC/OS, Portworx tasks should restart if they go in LOST state
* PWX-7516 - The portworx-prometheus framework version need to be corrected.
* PWX-7571 - CloudSnap : Restore fails sometimes with "failed to get metadata of the backup from cloud"
* PWX-7595 - Handle spurious storage pool Full/offline condition
* PWX-7596 - Portworx creates node labels for every PVs, causing prometheus federation scraping issues
* PWX-7604 - Anonymize the secrets for Key Management Systems
* PWX-7605 - DCOS Portworx-Prometheus pod replace does not work as expected
* PWX-7619 - Make KVDB URLs optional
* PWX-7628 - Alertmanager does not run after installing Portworx 2.0.2
* PWX-7639 - DCOS Portworx framework should install with default options from config.json.
* PWX-7650 - Portworx install errors w/ "tar: .: file changed as we read it"
* PWX-7656 - Shared v4 failover operation fails if the management and data interface of px service is different
* PWX-7661 - [stork] Snapshot status not being updated for all cloudsnaps in groupsnapshot
* PWX-7686 - Enable Portworx to install in AWS instances when auto journaling is enabled.
* PWX-7743 - Prevent Portworx install if only the journal disk is given in the install script and no data disks were given.
* PWX-7766 - When a groupsnapshot request times out, allow for the snapshot scheduler to retry in the next interval or ask the user to retry if it is a manual request
* PWX-7773 - runc CVE-2019-5736 fix #3169

## 2.0.2.3

March 3, 2019

### Key Fixes

* PWX-7919 - Geography updates loading etcd causing high CPU usage

## 2.0.2.2

February 23, 2019

### Key Fixes

* PWX-7664 - When a node running 1.7 with empty journal log gets upgraded to 2.0 and the upgraded node is restarted, the node doesn't fully restart on next boot

## 2.0.2.1

February 8, 2019

### Key Fixes

* PWX-7510 - Remove any secretes info from the diags
* PWX-7214 - licensing engine config update improvements

## 2.0.2

January 26, 2019

### Key Features and Enhancements

* PWX-7207 - Allow docker with SELinux for newer Kubernetes versions
* PWX-7208 - Google Cloud KMS integration

### Key Fixes

* PWX-6770 - Restart docker apps using shared volumes on DCOS
* PWX-7006 - Cloud migration cancel didn't cancel all the volume migrations
* PWX-7007 - Add an alert when Cloud migration task is canceled
* PWX-7179 - Pool io priority for KOPS io1 volume should be correctly displayed
* PWX-7199 - Enable capacity usage command for centos kernel >= 3.10.0-862
* PWX-7226 - DCOS Portworx: Manually updated values in /etc/pwx/config.json does not persist
* PWX-7267 - Hide unknown/non-handled licenses
* PWX-7271 - 'pxctl secrets gcloud list-secrets' shows unnecessary line in the console output
* PWX-7280 - Logs getting flooded with "18 is not 14len(values)" after upgrading the kernel to 4.20.0-1
* PWX-7304 - Handle journal device "read-only" cases
* PWX-7348 - Handle journal device "offline" cases
* PWX-7364 - Px boot stuck at ns mount
* PWX-7366 - Portworx service restart issues including "missing mountpoint", or "cannot open file/directory"
* PWX-7407 - OCI Monitor: Initiates cordoning even when px.ko was not loaded
* PWX-7466 - K8S/Upgrade: Talisman does not support CRI/Containerd

## 2.0.1.1

January 19, 2019

### Key Fixes

* PWX-7431 - Strip the labels on a config map to fit 63 characters.
* PWX-7411 - Portworx does not come up after upgrade to 2.0.1 when an auto-detecting network interface

## 2.0.1

December 20, 2018

### Key Fixes

* PWX-7159 - Persist kvdb backups outside of the host filesystem
* PWX-7225 - AMI based ASG install does not pick up user config
* PWX-7097 - `pxctl service kvdb` should display correct cluster status after nodes are decommissioned
* PWX-7124 - Volume migration fails when the volume has an attached snapshot policy
* PWX-7101 - Enable task ID-based sorting for `pxctl cloudmigrate` commands
* PWX-7121 - Creating a paired cluster results in core files in the destination cluster
* PWX-7110 - Delete paired cluster credentials when the cluster pair is deleted
* PWX-7031 - Cluster migration restore status does not reflect the cloudsnap status when cloudsnap has failed
* PWX-7090 - Core files generated when a node is decommissioned with replicas on the node
* PWX-7211 - Fix daemonset affinity in openshift specs
* PWX-6836 - Don't allow deletion of the Portworx configuration data when the Portworx services are still running in the system
* PWX-7134 - SSD/NVME drives are displayed as STORAGE_MEDIUM_MAGNETIC
* PWX-7089 - Intermittent failures in `pxctl cloudsnap list`
* PWX-6852 - If Portworx starts before Docker is started, the `SchedulerName` field in pxctl CLI shows as N/A
* PWX-7129 - Add an option to improve filesystem space utilization in case of SSD/NVMe drives
* PWX-7011 - Cluster pairing for cluster migration fails when one of the nodes in the destination cluster is down
* PWX-7120 - Cloudsnap restore failures cannot be viewed through `pxctl cloudsnap status`

## 2.0.0.1

December 7, 2018

### Key Fixes

* PWX-7131 - Fix an issue with some of the alerts IDs mismatching with the description as part of the upgrade
  from the 1.x version to 2.0.
* PWX-7122 - Volume restores would occasionally fail when restoring from backups that were done with Portworx 1.x versions.

## 2.0.0

December 4, 2018

### Key Features and Enhancements

* PX-Motion - Migration of applications and data between clusters. Application migration is Kubernetes only.
* PX-Central - Single pane of glass for management, monitoring, and metadata services across multiple
   Portworx clusters on Kubernetes
* Lighthouse 2.0 - Supports PX-motion with connection to Kubernetes cluster for application and namespace migration.
* Shared volumes (v4) for Kubernetes
* Support Cloudsnaps for Aggregated volumes
* ‘Extent’ based cloudsnaps - Restartable Cloudsnaps if a large volume cloudsnap gets interrupted
* Support Journal device for Repl=1 volumes
* PX-kvdb (etcd) supported internally with Portworx cluster deployment

### Key Fixes

* PWX-6458: When decreasing HA of a volume, recover snapshot space unused.
* PWX-5686: Implement accounting and display of space utilized by snapshots and clones.
* PWX-6949: Decommissioned node getting listed from one node in the cluster and not from the other
* PWX-6617: PDM: Dump the cloud drive keys when Portworx loses kvdb connectivity.
* PWX-5876: Volume should get detached when out of quorum or pool down.

### Errata

* PWX-7011: Cluster pair creation failing, because of destination Portworx node is marked down
  Workaround: Restart the Portworx node and attempt the cluster pairing again

* PWX-7041: CloudSnap Backup Failed for Pause/Resume by PX Restart - All replicas are down

  Workaround: This is a variant of the previous errata.
  For volume with replication factor set to 1, Cloudsnap backup does not resume after the node with replica goes down.

## 1.7.6

**Release Notes:** February 7, 2019

### Key Fixes

* PWX-7304 - Portworx keeps restarting if journal device made read-only
* PWX-7348 - Portworx keeps restarting, VM reboot after journal device made “offline”
* PWX-7453 - cloudsnap cleanup didn't complete properly in cases where errors were encountered when transmitting the diffs
* PWX-7481 - Shared volume mounts fail when clients connections abruptly lost and not cleaned up properly
* PWX-7600 - Volume mount status might be incorrectly displayed when the node where the volume is attached hits a storage full condition and replicas on that node are moved to a new node


## 1.7.5

January 15, 2019

### Key Fixes

* PWX-7364 Namespace stuck volume issue
* PWX-7299 export pool_status as a stat for prometheus
* PWX-7267 LIC: Hide unknown/non-handled licenses
* PWX-7212 Cloudsnap-Restore: Increase restore verbose level for error cases
* PWX-7179 io1 volume added to KOPS cluster gets displayed as STORAGE_MEDIUM_MAGNETIC
* PWX-7033 Objectstore endpoint failover not happening

## 1.7.4

January 7, 2019

### Key Fixes

* PWX-7292 For all storage errors retry 3 times before making pool offline
* PWX-7291 Detect SSD based pools and mount with nossd if kernel version is less than 4.15
* PWX-7214 LIC: Goroutine leak at license watch re-subscription
* PWX-7143 LIC: Should hard-code "absolute maximums" into License evaluations
* PWX-7142 LIC: SuperMicro misinterpreted as VM [roblox]

## 1.7.3

December 13, 2018

### Key Features and Enhancements

* Provide a runtime option to enable more compact data out of flash media to avoid disk fragmentation

### Key Fixes

* Fix an issue with NVMe/SSD disks being shown as Magnetic disks

## 1.7.2

December 5, 2018

### Key Features and Enhancements

* Default queue depth for all volumes (new, coming from older release) set to 128
* Advanced runtime options for write amplification reduction

### Key Fixes

* PWX-6928: Store bucket name in cloudsnap object
* PWX-6904: Fix bucket name for cloudsnap ID while reporting status
* PWX-7071: Do not use GFP_ATOMIC allocation

## 1.7.1.1

November 7, 2018

### Key Fixes

* Fix to add/remove node labels in Kubernetes to indicate where volume replicas are placed

## 1.7.1

November 7, 2018

### Key Features and Enhancements

* Restart docker containers using shared volumes for DC/OS to enable automatic re-attach of the containers on Portworx upgrades
* Preserve Kubernetes agent node ids across agent restarts when Kubernetes agents are running statelessly in
  auto-scaling based environments

## 1.7.0

November 3, 2018

### Key Features and Enhancements

* IBM Kubernetes Service (IKS) Support
* IBM Key Protect Support for Encrypted Volumes
* Containerd runtime Interface (CRI) support
* Automatic VM Datastore provisioning for CentOS ESXi VMs
* Tiered Snapshots for storing volume snapshots on only lower-cost media
* Encryption support for shared volumes

### Key Fixes

* PWX-6616 - Fix shared volume mounts going read-only kubernetes in few corner cases
* PWX-6551 - px_volume_read_bytes and px_volume_written_bytes are not available in 1.6.2
* PWX-6479 - Debian 8: Portworx fails to come up if sharedv4 is enabled
* PWX-6560 - PVC creation fails with "Already exists" perpetually
* PWX-6527 - Clean up orphaned volume paths as PVC are attached and detached over a period of time
* PWX-6425 - Cloudnsap schedule option to do full backup always.
* PWX-6408 - Node alerts: Include hostname/IP in addition to node id
* PWX-5963 - Report volumes with no snapshots

## 1.6.1.4

October 19, 2018

This is a minor patch release with the following fixes/enhancements.

* PWX-6655 - Fix to allow storageless nodes to reuse their node ids in k8s
* PWX-6410 - Fix a bug where Portworx may detach unused loopback devices that are not owned by Portworx on restarts.
* PWX-6713 - Allow update of per volume queue depth

## 1.6.1.3

October 26, 2018

 This is a minor patch release with the following fixes/enhancements.

 * PWX-6697: Add support for automatic provisioning of disks on VMware virtual machines on non-Kubernetes clusters and Kubernetes clusters without vSphere Cloud Provider

## 1.6.1.2

October 23, 2018

This is a minor patch release with the following fixes/enhancements.

* PWX-6567 - Provide a parameter to disable discards during volume create
* PWX-6559 - Provide the ability to map services listening on port 9001 to another port

## 1.6.1.1

October 11, 2018

This is a minor patch release with fixes issues around volume unmounts as well as pending commands to docker.

* PWX-6494 - Fix rare spurious volume unmounts of attached volumes in case of Portworx service restart under heavy load
* PWX-6559 - Add a timeout for all commands to docker so they timeout if docker hangs or crashes.

## 1.6.1

October 2, 2018


### Key Features and Enhancements

* Per volume queue depth to ensure volume level quality of service
* Large discard sizes up to 10MB support faster file deletes. NOTE: You will need a px-fuse driver update to use
  this setting.  Portworx 1.6.1 will continue to work with old discard size of 1MB if no driver update was done. This is a
  backward compatible change
* Enable option to always perform a full clone back up for Cloudsnap
* Reduce scheduled snapshot intervals to support snapping every 15 mins from the current limit of 1 hour

### Key Fixes

* Fix replica provisioning across availability zones for clusters running on DC/OS in a public cloud

## 1.6.0

September 20, 2018

### Key Features and Enhancements

* OpenStorage SDK support. Link to [SDK](https://libopenstorage.github.io/w/)
* Dynamic VM datastore provisioning support Kubernetes on vSphere/ESX environment
* Pivotal Kubernetes Service (PKS) support with automated storage management for [PKS](/portworx-install-with-kubernetes/cloud/install-pks)

### Errata

* PWX-6198 - SDK Cloud backup and credentials services is still undergoing tests
* PWX-6159 - Intermittent detach volume error seen by when calling the SDK Detach call
* PWX-6056 - Expected error not found when using Stats on a non-existent volume


## 1.5.1

September 14, 2018

### Key Fixes

* PWX-6115 - Consul integration fixes to reduce CPU utilization
* PWX-6049 - Improved detection and handling cloud instance store drives in AWS
* PWX-6197 - Fix issues with max drive per zone in GCP
* When a storagless node loses connectivity to the remaining nodes, it should bring itself down.
* PWX-6208 - Fix GCP provider issues for dynamic disk provisioning in GCP/GKE
* PWX-5815 - Enable running `pxctl` from oci-monitor PODs in k8s
* PWX-6295 - Fix LocalNode provisioning pattern when provisioning volumes with greater than 1 replication factor
* PWX-6277 - Portworx fails to run sharedv4 volume support for Fedora
* PWX-6268 - Portworx does not come up in Amazon Linux V2 AMIs
* PWX-6229 - Portworx does not initialize fully in a GKE multi-zone cluster during a fresh install


## 1.5.0

August 21, 2018

{{<info>}}
Important note: Consul integration with 1.5.0 has a bug which results in Portworx querying a Consul Cluster too often for a non-existent key. We will be pushing out a 1.5.1 release with a fix by 08/31/2018
{{</info>}}

### Key Features and Enhancements

* Eliminate private.json for stateless installs
* Handle consul leader failures when running with consul as the preferred k/v store
* When a node is offline for longer than the user-configured timeout, move the replicas in that node out to
  other nodes with free space
* Improvements to AWS Auto-scaling Group handling with KOPS
* Lighthouse Volume Analyzer View Support
* Enable volume resize for volumes that are not attached
* Periodic, light-weight pool rebalance for proactive capacity management

### Key Fixes

 * PWX-5800 - In AWS Autoscaling mode, Portworx nodes with no storage should always try to attach available drives on restart
 * PWX-5827 - Allow adding cloud drives using pxctl service drive add commands
 * PWX-5915 - Add PX-DO-NOT-DELETE prefix to all cloud drive names
 * PWX-6117 - Fix `pxctl cloudsnap status --local` command failing to execute
 * PWX-5919 - Improve node decommission handling for volumes that are not in quorum
 * PWX-5824 - Improve geo variable handling for kubernetes and DC/OS
 * PWX-5902 - Support SuSE CaaS platform
 * PWX-5815 - Enable diags collection via oci-monitor when shell access to the minions not allowed
 * PWX-5816 - Incorrect bucket names will force a full backup instead of incremental backup
 * PWX-5904 - Remove db_remote and random profiles from io_profile help
 * PWX-5821 - Fix panics seen zone and rack labels are supplied on volume create



## 1.4.2.2

August 11, 2018

This is a patch release that adds the capability to switch from shared to sharedv4 one volume at a time. Please contact Portworx support before switching the volume types.


## 1.4.2

July 21, 2018

### Key Features and Enhancements

* Use [PX-Central](https://central.portworx.com) for K8S spec generation.

### Key Fixes

* PWX-5681 - Portworx service to handle journald restarts
* PWX-5814 - Fix automatic diag uploads
* PWX-5818 - Fix diag uploads via `pxctl service diags` when running under k8s environments

## 1.4.0

July 4, 2018

If you are on any of the 1.4 RC builds, you will need to do a fresh install. Please reach out to us at support@portworx.com or on the slack to help assess upgrade options from 1.4 RC builds.

All customers on 1.3.x release will be able to upgrade to 1.4

All customers on 1.2.x release will be able to upgrade to 1.4 but in a few specific cases might need a node reboot after the upgrade. Please reach out to support for help with an upgrade or if there are any questions if you are running 1.2.x in production.

### Key Features and Enhancements

* 3DSnaps - Ability to take [application-consistent](/portworx-install-with-kubernetes/storage-operations/create-snapshots)
  snapshots cluster wide (Available in 05/14 GA version)
  * Volume Group snapshots - Ability to take crash-consistent snapshots on group of volumes based on a user-defined label
* GCP/GKE automated disk management based on [disk templates](/portworx-install-with-kubernetes/cloud/gcp/gke/)
* [Kubernetes per volume secret support](/portworx-install-with-kubernetes/storage-operations/create-pvcs/create-encrypted-pvcs) to enable
  volume encryption keys per Kubernetes PVC and using the Kubernetes secrets for key storage
* DC/OS vault integration - Use [Vault integrated with DC/OS](/install-with-other/dcos)
* Support Pool Resize - Available in Maintenance Mode only
* Container Storage Interface (CSI) [Tech Preview](/portworx-install-with-kubernetes/storage-operations/csi)
* Support port mapping used by Portworx from 9001-9015 to a custom port number range by passing the starting
  port number in [install arguments](/install-with-other/docker/standalone)
* Provide ability to do a [license transfer](/reference/knowledge-base/px-licensing) from one cluster to another cluster
* Add support for [cloudsnap deletes](/reference/cli/cloud-snaps#deleting-a-cloud-backup)

### Key Fixes

* PWX-5360 - Handle disk partitions in node wipe command
* PWX-5351 - Reduce the `pxctl volume list` time taken when a large number of volumes are present
* PWX-5365 - Fix cases where cloudsnap progress appears stopped because of time synchronization
* PWX-5271 - Set default journal device size to 2GB
* PWX-5341 - Prune out trailing `/` in storage device name before using it
* PWX-5214 - Use device UUID when checking for valid mounts when using device-mapper devices instead of the device names
* PWX-5242 - Provide facility to add metadata journal devices to an existing cluster
* PWX-5287 - Clean up px_env variables as well when using node wipe command
* PWX-5322 - Unmount shared volume on shared volume source mount only on Portworx restarts
* PWX-5319 - Use excl open for open device checks
* PWX-4897 - Allow more time for the resync to complete before changing the replication status
* PWX-5295 - Fix a nil pointer access during cloudsnap credential delete
* PWX-5006 - Tune data written between successive syncs depending on ingress write speed
* PWX-5203 - Cancel any in-progress ha increase operations that are pending on the node if the node is decommissioned
* PWX-5138 - Add startup options for air-gapped deployments
* PWX-4816 - Check for and add lvm devices when handling -a option for device list
* PWX-4609 - Allow canceling of replication increase operations for attached volumes
* PWX-4765 - Fix resource contention issues when running heavy load on multiple shared volumes on many nodes
* PWX-5039 - Fix PX OCI uninstall when shared volumes are in use
* PWX-5153 - In Rancher, automatically manage container volume mounts if one of the cluster node restarts

## 1.3.1.4

May 9, 2018

This is a minor update that improves degraded cluster performance when one or more nodes are down for a long time and brought back online that starts the resync process

## 1.3.1.2

May 2, 2018

This is a minor update to fix install issues with RHEL Atomic and other fixes.

* RHEL Atomic install fixes
* Clean up any existing diag files before running the diags command again
* `pxctl upgrade` fixes to pull the latest image information from install.portworx.com
* improvements in attached device detection logic in some cloud environments

## 1.3.1.1

April 16, 2018

This is a minor update to the previous 1.3.1 release

* Fix to make node resync process yield better to the application I/O when some of the nodes are down for a longer period of time and brought back up thereby triggering the resync process.

## 1.3.1

April 13, 2018

This is a patch release with shared volume performance and stability fixes

#### Key Fixes

* Fix namespace client crashes when client list is generated when few client nodes are down.
* Allow read/write snapshots in k8s annotations
* Make adding and removing k8s node labels asynchronous to help with large number volume creations in parallel
* Fix Portworx crash when a snapshot is taken at the same time as a node being marked down because of network failures
* Fix nodes option in docker inline volume create and supply nodes value as semicolon-separated values

## 1.3.0.1

April 6, 2018

This is a patch update with the following fix

* PWX-5115 - Fix `nodes` option in [docker inline volume create](/install-with-other/docker/how-to/volume-plugin) and supply nodes value as semicolon separated values

## 1.3.0

March 6, 2018

_**Upgrade Note 1**_: Upgrade to 1.3 requires a node restart in non-k8s environments. In k8s environments, the cluster does a rolling upgrade

_**Upgrade Note 2**_: Ensure all nodes in Portworx cluster are running 1.3 version before increasing replication factor for the volumes

_**Upgrade Note 3**_: Container information parsing code has been disabled and hence the PX-Lighthouse up to 1.1.7 version will not show the container information page. This feature will be back in future releases and with the new lighthouse

### Key Features and Enhancements

* Volume create command additions to include volume clone command and integrate snap commands
* Improved snapshot workflows
  * Clones - full volume copy created from a snapshot
  * Changes to snapshot CLI.
  * Creating scheduled snapshots policies per volume
  * _**Important**_ From 1.3 onwards, all snapshots are read-only. If the user wishes to create a read/write snapshot, a volume clone can be created from the snapshot
* Improved resync performance when a node is down for a long time and restarted with accumulated data in the surviving nodes
* Improved performance for database workloads by separating transaction logs to a separate journal device
* Added Portworx signature to drives so drives cannot be accidentally re-used even if the cluster has been deleted.
* Per volume cache attributes for shared volumes
* https support for API end-points
* Portworx Open-Storage scaling groups support for AWS ASG - Workflow improvements
  * Allow specifying input EBS volumes in the format “type=gp2,size=100”. \(this is documented\)
  * Instead of adding labels to EBS volumes, Portworx now stores all the information related to them in kvdb. All the EBS volumes it creates and attaches are listed in kvdb and this information is then used to find out EBS volumes being used by Portworx nodes
  * Added command `pxctl cloud list` to list all the drives created via ASG
* Integrated kvdb - Early Access - Limited Release for small clusters less than 10 nodes

#### New CLI Additions and changes to existing ones

* Added `pxctl service node-wipe` to wipe Portworx metadata from a decommisioned node in the cluster
* Change `snap_interval` parameter to `periodic` in `pxctl volume` commands
* Add schduler information in `pxctl status` display
* Add info about cloud volumes CLI [k8s](/cloud-references/auto-disk-provisioning/gcp) , [others](/portworx-install-with-kubernetes/cloud/aws/aws-asg)
* `pxctl service add --journal -d <device>` to add journal device support

### Key Fixes

* PWX-4518 - Add a confirmation prompt for `pxctl volume delete` operations
* PWX-4655 - Improve “PX Cluster Not In Quorum” Message in `pxctl status` to give additional information.
* PWX-4504 - Show all the volumes present in the node in the CLI
* PWX-4475 - Parse io\_profile in inline volume spec
* PWX-4479 - Fix io\_priority versions when labeling cloudsnaps
* PWX-4378 - Add read/write latency stats to the volume statistics
* PWX-4923 - Add vol\_ prefix to read/write volume latency statistics
* PWX-4288 - Handle app container restarts attached to a shared volume if the mount path was unmounted via unmount command
* PWX-4372 - Gracefully handle trial license expiry and Portworx cluster reinstall
* PWX-4544 - PX OCI install is unable to proceed with aquasec container installed
* PWX-4531 - Add OS Distribution and Kernel version display in `pxctl status`
* PWX-4547 - cloudsnap display catalog with volume name hits “runtime error: index out of range”
* PWX-4585 - handle kvdb server timeouts with an improved retry mechanism
* PWX-4665 - Do not allow drive add to a pool if a rebalance operation is already in progress
* PWX-4691 - Do not allow snapshots on down nodes or if the node is in maintenance mode
* PWX-4397 - Set the correct zone information for all replica-sets
* PWX-4375 - Add `pxctl upgrade` support for OCI containers
* PWX-4733 - Remove Swarm Node ID check dependencies for Portworx bring up
* PWX-4484 - Limit replication factor increases to a limit of three at a time within a cluster and one per node
* PWX-4090 - Reserve space in each pool to handle rebalance operations
* PWX-4544 - Handle ./aquasec file during OCI-Install so Portworx can be installed in environments with aquasec
* PWX-4497 - Enable minio to mount shared volumes
* PWX-4551 - Improve `pxctl volume inspect` to show pools on which volumes are allocated, replica nodes and replication add
* PWX-4884 - Prevent replication factor increases if all the nodes in the cluster are not running 1.3.0
* PWX-4504 - Show all the volumes present on a node in CLI with a `--node` option
* PWX-4824 - `pxctl volume inspect` doesn’t show replication set information properly when one node is out of quorum
* PWX-4784 - Support SELinux in 4.12.x kernels and above by setting SELinux context correctly
* PWX-4812 - Handle Kernel upgrades correctly
* PWX-4814 - Synchronize snapshot operations per node
* PWX-4471 - Enhancements to OCI Mount propagation to automount relevant scheduler dirs
* PWX-4721 - When a large number of volumes are cloud snapped at the same time, Portworx container hits a panic
* PWX-4789 - Handle cloudsnaps errors when the schedule has been moved or deleted
* PWX-4709 - Support for adding CloudDrive \(EBS volume\) to an existing node in a cluster
* PWX-4777 - Fix issues with `pxctl volume inspect` on shared volumes hanging when a large number of volume inspects are done
* PWX-4525 - `pxctl status` shows an invalid cluster summary in some nodes when performing an upgrade from 1.2 to 1.3
* PWX-3071 - Provide the ability to force detach a remotely mounted Portworx volume from a single node when the node is down
* PWX-4772 - Handle storage full conditions more gracefully when the backing store for a px volume gets full
* PWX-4757 - Improve Portworx initialization during boot to handle out of quorum volumes gracefully.
* PWX-4747 - Improve a simultaneous large number of volume creates and volume attach/detach in multiple nodes
* PWX-4467 - Fix hangs when successive volume inspects come to the same volume with cloudsnap in progress
* PWX-4420 - Fix race between POD delete and volume unmounts
* PWX-4206 - Under certain conditions, creating a snap using k8s PVC creates a new volume instead of a snapshot
* PWX-4207 - Fix nil pointer dereferences when creating snapshots via k8s

### Errata

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running “pxctl service m –exit”, the message “Maintenance operation is in progress, cancel the operation or wait for completion” doesn’t specify which operation hasn’t completed. Workaround: Use pxctl to query the status of all three drive operations \(add, replace, rebalance\). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error “Failed to update k8s node”. A node label isn’t needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation’s file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message “Replace cancel failed - Not in progress”. However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive to replace operation to finish. The replace operation might be in a state where it can’t be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that’s about 100 nodes or greater: If the entire cluster goes down with all the nodes offline, as nodes come online a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.
* Key Management with AWS KMS doesn’t work anymore because of API changes in the AWS side. Will be fixed in an upcoming release. Refer to this link for additional details. https://github.com/aws/aws-cli/issues/1043
* When shared volumes are configured with io\_profile=cms, it results in the px-ns process restarting occasionally.

## 1.2.23

April 20, 2018

This is a minor update that fixes a panic seen in some k8s environments when the user upgraded from an older version of Portworx to 1.2.22

PWX-5107 - Check if node spec is present before adding the node for volume state change events

## 1.2.22

February 28, 2018

### Key Features and Enhancements

* Support SELinux enable in kernels 4.12.x and above
* Support automatic kernel upgrades. If you expect your environment to upgrade kernels automatically, Portworx recommends upgrading to 1.2.22.0

## 1.2.20.0

February 15, 2018

* Minor update to enhance write performance for remote mounts with shared volumes
* 4.15.3 Linux kernel support

### Errata \(Errata remains the same from 1.2.11.0 release\)

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running “pxctl service m –exit”, the message “Maintenance operation is in progress, cancel the operation or wait for completion” doesn’t specify which operation hasn’t completed. Workaround: Use pxctl to query the status of all three drive operations \(add, replace, rebalance\). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error “Failed to update k8s node”. A node label isn’t needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message “Failed to open snap for backup”. Logs indicate that the backup wasn’t found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation’s file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message “Replace cancel failed - Not in progress”. However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive to replace operation to finish. The replace operation might be in a state where it can’t be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that’s about 100 nodes or greater: If the entire cluster goes down with all the nodes offline, as nodes come online a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.
* Key Management with AWS KMS doesn’t work anymore because of API changes in the AWS side. Will be fixed in an upcoming release. Refer to this link for additional details. https://github.com/aws/aws-cli/issues/1043
* PWX-4721 - When cloud-snap is performed on a large number of volumes, it results in a Portworx container restart. A workaround is to run cloudsnaps on up to 10 volumes concurrently.

## 1.2.18.0

February 13, 2018

### Key Features and Enhancements

* Improve file import and untar performance when shared volumes are used by Wordpress and tune for WordPress plugin behavior

### Errata \(Errata remains the same from 1.2.11.0 release\)

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running “pxctl service m –exit”, the message “Maintenance operation is in progress, cancel the operation or wait for completion” doesn’t specify which operation hasn’t completed. Workaround: Use pxctl to query the status of all three drive operations \(add, replace, rebalance\). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error “Failed to update k8s node”. A node label isn’t needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message “Failed to open snap for backup”. Logs indicate that the backup wasn’t found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation’s file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message “Replace cancel failed - Not in progress”. However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive to replace operation to finish. The replace operation might be in a state where it can’t be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that’s about 100 nodes or greater: If the entire cluster goes down with all the nodes offline, as nodes come online a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.
* Key Management with AWS KMS doesn’t work anymore because of API changes in the AWS side. Will be fixed in an upcoming release. Refer to this link for additional details. https://github.com/aws/aws-cli/issues/1043

## 1.2.16.2

March 19, 2018

* This is a minor update that fixes volume size not updating whenever the content of the encrypted volume is deleted

## 1.2.16.1

March 2, 2018

This is a minor update which adds a new flag to limit or disable the generation of core files \(`-e PXCORESIZE=<size>`\). A value of 0 will disable cores

## 1.2.16.0

February 5, 2018

This is a minor update with performance enhancements for shared volumes to support a large number of directories and files.

### Key Fixes

* Shared volume access latency improvements when managing filesystems with a large number of directories and files

### Errata \(Errata remains the same from 1.2.11.0 release\)

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running “pxctl service m –exit”, the message “Maintenance operation is in progress, cancel the operation or wait for completion” doesn’t specify which operation hasn’t completed. Workaround: Use pxctl to query the status of all three drive operations \(add, replace, rebalance\). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error “Failed to update k8s node”. A node label isn’t needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message “Failed to open snap for backup”. Logs indicate that the backup wasn’t found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation’s file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message “Replace cancel failed - Not in progress”. However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive to replace operation to finish. The replace operation might be in a state where it can’t be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that’s about 100 nodes or greater: If the entire cluster goes down with all the nodes offline, as nodes come online a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.

## 1.2.14

January 17, 2018

This is a minor update to support the older Linux kernel versions \(4.4.0.x\) that ships with Ubuntu distributions

## 1.2.12.1

January 8, 2018

This is a minor update to support Openshift with SELinux enabled as well as verify with SPECTRE/Meltdown kernel patches

* Verified with the latest kernel patches for SPECTRE/Meltdown issue for all major Linux distros

## 1.2.12.0

December 22, 2017

This is a minor update to enhance metadata performance on a shared namespace volume.

### Key Fixes

* Readdir performance for directories with a large number of files \(greater 128K file count in a single directory\)
* Portworx running on AWS AutoScalingGroup now handles existing devices attached with names such as `/dev/xvdcw` which have an extra letter at the end.
* Occasionally, containers that use shared volumes could get a “transport end point disconnected” error when Portworx restarts. This has been resolved.
* Fixed an issue where Portworx failed to resolve Kubernetes services by their DNS names if the user sets the Portworx DaemonSet DNS Policy as `ClusterFirstWithHostNet`.
* PWX- 4078 When Portworx runs in 100s of nodes, a few nodes show high memory usage.

## 1.2.11.10

December 19, 2017

This is a minor update to address an issue with installing a reboot service while upgrading a runC container.

### Key Fixes

* When upgrading a runC container, the new version will correctly install a reboot service. A reboot service \(systemd service\) is needed to reduce the wait time before a Portworx device returns with a timeout when the Portworx service is down. Without this reboot service, a node can take 10 minutes to reboot.

## 1.2.11.9

December 18, 2017

### Key Fixes

Pass volume name as part of the metrics endpoint so Prometheus/Grafana can display with volume name

* Add current ha level of the volume and io\_priority of the volumes to the metrics endpoint
* Abort all pending I/Os the pxd device during a reboot so speed up reboots
* Move the px-ns internal port from 7000 to 9013
* Remove the unnecessary warning string “Data is not local to the node”
* Add px\_ prefix to all volume labels

### Errata

* Do not manually unmount a volume by using Linux `umount` command for shared volume mounts. This errata applies to the previous versions of Portworx as well.

## 1.2.11.8

December 11, 2017

### Key Fixes

* Fix resync mechanism for read-only snapshots
* Improve log space utilization by removing old log files based on space usage

### Errata

* Do not manually unmount a volume by using Linux `umount` command for shared volume mounts. This errata applies to the previous versions of Portworx as well.

## 1.2.11.7

December 7, 2017

### Key Fixes

* Suppress un-necessary log prints about cache flush
* PWX-4272 Handle remote host shutdowns gracefully for shared volumes. In the past, this could leave stray TCP connections.

### Errata

* Do not manually unmount a volume by using Linux `umount` command for shared volume mounts. This errata applies to the previous versions of Portworx as well.

## 1.2.11.6

November 28, 2017

### Key Fixes

* Provide the capability to drop system cache on-demand \(for select workloads and large memory system\) and turn it off by default

## 1.2.11.5

November 22, 2017

### Key Features and Enhancements

* PWX-4178 Perform snapshots in kubernetes via [annotations](/portworx-install-with-kubernetes/storage-operations/create-snapshots/on-demand/snaps-annotations)

## 1.2.11.4

November 20, 2017

### Key Features and Enhancements

* PX-Enterprise container is now available in [OCI Format](/install-with-other/docker/standalone)
* Enhancements for db workloads to handle slow media

### Key Fixes

* PWX-4224 Ignore `sticky` flag when purging old snapshots after a cloudsnap is completed.
* PWX-4220 `pxctl status` shows the first interface IP address instead of the mgmt. IP

## 1.2.11.3

November 16, 2017

### Key Fixes

* Shared volume performance improvements
* Do not take an inline snap in k8s when no valid candidate pvcs are found

### 1.2.11.2

November 11, 2017

### Key Fixes

* Increase file descriptors to support a large number of shared volumes

## 1.2.11.1

November 7, 2017

### Key Fixes

* Fix file descriptors not being released after reporting containers attached to a shared volume

## 1.2.11

October 31, 2017

### Key Features and Enhancements

* You can now update volume labels. The pxctl volume update command has a new option, –label pairs. Specify a list of comma-separated name=value pairs. For example, if the current labels are x1=v1,x2=v2:

  The option “–labels x1=v4” results in the labels x1=v4,x2=v2.

  The option “–labels x1=” results in the labels x2=v2 \(removes a label\).

* Improvements to alerts:
  * Additional alerts indicate the cluster status in much more finer detail. This document has more details on all the alerts posted by Portworx: [Here](/install-with-other/operate-and-maintain/monitoring/alerting)
  * Rate limiting for alerts so that an alert isn’t repeatedly posted within a short timeframe.
* You can now update the io\_profile field by using the `pxctl volume update` command so the parameter can be enabled for existing volumes.

### Key Fixes

* PWX-3146 Portworx module dependencies fail to load for openSUSE Leap 42.2, Kernel 4.4.57-18.3-default.
* PWX-3362 If a node is in maintenance mode because of disk errors, the node isn’t switched to a storage-less node. As a result, other resources on the node \(such as CPU and memory\) aren’t usable.
* PWX-3448 When Portworx statistics are exported, they include the volume ID instead of the volume name.
* PWX-3472 When snapshots are triggered on a large number of volumes at the same time, the snap operation fails.
* PWX-3528 Volume create option parsing isn’t unified across Kubernetes, Docker, and pxctl.
* PWX-3544 Improvements to Portworx diagnostics - REST API to retrieve and upload diagnostics for a node or cluster. Diagnostics run using the REST API includes vmstat output and the output of pxctl cluster list and pxctl --json volume list. The diagnostics also include netstat -s before the node went down.
* PWX-3558 px-storage dumps core while running an HA increase on multiple volumes during stress.
* PWX-3577 When Portworx is running in a container environment, it should allow mounts on only those directories which are bind-mounted. Otherwise, Portworx hangs during a docker stop.
* PWX-3585 If Portworx stops before a container that’s using its volume stops, the container might get stuck in the D state \(I/O in kernel\). As a result, ‘systemctl stop docker’ takes 10 minutes as does system shutdown. The default PXD\_TIMEOUT to error out IOs is 10 minutes, but should be configurable.
* PWX-3591 Storage isn’t rebalanced after a drive add operation and before exiting maintenance mode.
* PWX-3600 Volume HA update operations on snapshots cannot be canceled.
* PWX-3602 Removing a node from a cluster fails with the message “Could not find any volumes that match ID\(s\)”.
* PWX-3606 Portworx metrics now include the following: Disk read and write latency stats, volume read and write latency stats, and per-process stats for CPU and virtual/resident memory.
* PWX-3612 When creating or updating a volume, disallow the ability to set both the “shared” and “scale” options.
* PWX-3614 A volume inspect returns the wrong error message when one node in the cluster is down: Could not find any volumes that match ID\(s\).
* PWX-3620 The volume inspect command doesn’t show the replication set status, such as whether the replication set has down members or is in a clean or resync state.
* PWX-3632 After a Kubernetes pod terminates and the Portworx volume unmount/cleanup fails, the kubelet logs include “Orphaned pod &lt;name&gt; found, but volume paths are still present on disk.”
* PWX-3648 After all nodes in a cluster go offline: If a node doesn’t restart when the other nodes restart, the other restarting nodes don’t mark that node as offline.
* PWX-3665 The Portworx live core collection hangs sometimes.
* PWX-3666 The pxctl service diags command doesn’t store all diagnostics for all nodes in the same location. All diagnostics should appear in /var/cores.
* PWX-3672 The watch function stops after a large time change, such as 7 hours, on the cluster.
* PWX-3678 The pxctl volume update command interprets the -s option as -shared instead of -size and displays the message “invalid shared flag”.
* PWX-3700 Multiple alerts appear after a drive add succeeds.
* PWX-3701 The alert raised when a node enters maintenance mode specifies the node index instead of the node ID.
* PWX-3704 After backing up a volume that’s in maintenance mode to the cloud, restoring the volume to any online node fails.
* PWX-3709 High CPU usage occurs while detaching a volume with MySQL in Docker Swarm mode.
* PWX-3743 In the service alerts output in the CLI, the Description items aren’t aligned.
* PWX-3746 When a Portworx upgrade requires a node reboot, the message “Upgrade done” shouldn’t print.
* PWX-3747 When a node exits from maintenance mode, it doesn’t generate an alert.
* PWX-3764 The px-runc install command on a core node fails to configure the PX OCI service and generates the error “invalid cross-device link”.
* PWX-3777 When running under Kubernetes, pods using a shared volume aren’t available after the volume becomes read-only.
* PWX-3778 After adding a drive to a storage-less node fails: A second attempt succeeds but there is no message that the drive add succeeded.
* PWX-3793 When running in Kubernetes, if an unmount fails for a shared volume with the error “volume not mounted”, the volume is stuck in a terminating state.
* PWX-3817 When running under Kubernetes, a WordPress pod is stuck in terminating for almost ten minutes.
* PWX-3820 When running Portworx as a Docker V2 plugin: After a service create –replicas command, a volume is mounted locally on a MySQL container instead of a Portworx container. The Swarm service fails with the error “404 Failed to locate volume: Cannot locate volume”. To avoid this issue, you can now specify the volume-driver with the service create command.
* PWX-3825 When a node is in storage down state because the pool is out of capacity: A drive add fails with the error “Drive add start failed. drive size &lt;size&gt; too big” during an attempt to add the same size disk.
* PWX-3829 Container status in the Portworx Lighthouse GUI isn’t updated properly from Portworx nodes.
* PWX-3843 Portworx stats include metrics for utilized and available bytes, but not for total bytes \(px\_cluster\_disk\_total\_bytes\). As a result, alerts can’t be generated in Prometheus for storage utilization.
* PWX-3844 When you add a snapshot schedule to a volume, the alert type is “Snapshot Interval update failure” instead of “Snapshot interval update success”.
* PWX-3850 If the allocated io\_priority differs from the requested io\_priority, no associated alert is generated.
* PWX-3851 When two Postgres pods attempted to use the same volume, one of the Postgres pods mounted a local volume instead of a Portworx volume.
* PWX-3859 After adding a volume template to an Auto Scaling Group and Portworx adds tags to the volume: If you stop that cluster and then start a new cluster with the same volume, without removing the tags, a message indicates that the cluster is already initialized. The message should indicate that it failed to attach template volumes because the tag is already used. You can then manually remove the tags from the stopped cluster.
* PWX-3862 A volume is stuck in the detaching state indefinitely due to an issue in etcd.
* PWX-3867 When running under Kubernetes, a pod using namespace volumes generates the messages “Orphaned pod &lt;pod&gt; found, but volume paths are still present on disk”.
* PWX-3868 A Portworx cluster shows an extra node when running with ASG templates enabled if the AWS API returns an error when the Portworx container is booting up.
* PWX-3871 Added support for dot and hyphen in source and destination names in Kubernetes inline spec for snapshots.
* PWX-3873 When running under Kubernetes, a volume detach fails on a regular volume, with the message “Failed to detach volume: Failed with status -16”, and px-storage dumps core.
* PWX-3875 After volume unmount and mount commands are issued in quick succession, sometimes the volume mount fails.
* PWX-3878 When running under Kubernetes, a Postgres pod gets stuck in a terminating state during when the POD gets deleted.
* PWX-3879 During volume creation on Kubernetes, node labels aren’t applied on Kubernetes nodes.
* PWX-3888 An HA increase doesn’t use the node value specified in the command if the node is from a different region.
* PWX-3895 The pxctl volume list command shows a volume but volume inspect cannot find it.
* PWX-3902 If a Portworx container is started with the API\_SERVER pointing to Lighthouse and etcd servers are also provided, the Portworx container doesn’t send statistics to Lighthouse.
* PWX-3906 Orphaned pod volume directories can remain in a Kubernetes cluster after an unmount.
* PWX-3912 During a container umount, namespace volumes might show the error “Device or resource busy”.
* PWX-3916 Portworx rack information isn’t updated when labels are applied to a Kubernetes node.
* PWX-3933 The size of a volume created by using a REST API call isn’t rounded to the 4K boundary.
* PWX-3935 Lighthouse doesn’t show container information when Portworx is run as a Docker V2 plugin.
* PWX-3936 A volume create doesn’t ignore storage-less nodes in a cluster and thus fails, because it doesn’t allocate the storage to available nodes.
* PWX-3946 On a node where a cloudsnap schedule is configured: If the node gets decommissioned, the schedule isn’t configured for the new replica set.
* PWX-3947 Simultaneous mount and unmount likely causes a race in teardown and setup.
* PWX-3968 If Portworx can’t find a volume template in an Auto Scaling Group, it dumps core and keeps restarting.
* PWX-3971 Portworx doesn’t install on an Azure Ubuntu 14 Distro with the 3.13.0-32-generic kernel.
* PWX-3972 When you start a multi-node, multi-zone Auto Scaling Group with a max-count specified, Portworx doesn’t start on all nodes.
* PWX-3974 When running under Kubernetes, a WordPress app writes data to the local filesystem after a shared volume remount failure \(due to RPC timeout errors\) during node start.
* PWX-3997 When running under Kubernetes, deleting Wordpress pods results in orphaned directories.
* PWX-4000 A drive add or replace fails when Portworx is in storage full/pool offline state.
* PWX-4012 When using shared volumes: During a WordPress plugin installation, the WordPress pod prompts for FTP site permissions. Portworx now passes the correct GID and UUID to WordPress.
* PWX-4049 Adding and removing Kubernetes node labels can fail during node updates.
* PWX-4051 Previous versions of Portworx logged too many “Etcd did not return any transaction responses” messages. That error is now rate-limited to log only a few times.
* PWX-4083 When volume is in a down state due to a create failure but is still attached without a shared volume export, the detach fails with the error “Mountpath is not mounted”.
* PWX-4085 When running under Kubernetes, too many instances of this message get generated: “Kubernetes node watch channel closed. Restarting the watch..”
* PWX-4131 Specifying -a or -A for providing disks to Portworx needs to handle mpath & raid drives/partitions as well

  **Errata**

* PWX-3982 After putting a node into maintenance mode, adding drives, and then running “pxctl service m –exit”, the message “Maintenance operation is in progress, cancel the operation or wait for completion” doesn’t specify which operation hasn’t completed. Workaround: Use pxctl to query the status of all three drive operations \(add, replace, rebalance\). pxctl then reports which drive operations are in progress and allows exiting from maintenance mode if all maintenance operations are completed.
* PWX-4014 The pxctl cloudsnap schedule command creates multiple backups for the scheduled time. This issue has no functional impact and will be resolved in the upcoming release.
* PWX-4016 When running under Kubernetes, adding a node label for a scheduled cloudsnap fails with the error “Failed to update k8s node”. A node label isn’t needed for cloudsnaps because they are read-only and used only for backup to the cloud.
* PWX-4017 An incremental cloudsnap backup command fails with the message “Failed to open snap for backup”. Logs indicate that the backup wasn’t found on at least on one of the nodes where the volume was provisioned. Workaround: Trigger another backup manually on the nodes that failed.
* PWX-4021 In case of a failure while a read-only snapshot create operation is in progress, Portworx might fail to come back up. This can happen if the failure coincides with snapshot creation’s file system freeze step, which is required to fence incoming IOs during the operation. To recover from this issue, reboot the node.
* PWX-4027 Canceling a service drive replace operation fails with the message “Replace cancel failed - Not in progress”. However, if you try to exit maintenance mode, the status message indicates that a maintenance operation is in progress. Workaround: Wait for the drive to replace operation to finish. The replace operation might be in a state where it can’t be canceled. Cancel operations are performed when possible.
* PWX-4039 When running Ubuntu on Azure, an XFS volume format fails. Do not use XFS volumes when running Ubuntu on Azure.
* PWX-4043 When a Portworx POD gets deleted in Kubernetes, no alerts are generated to indicate the POD deletion via kubectl.
* PWX-4050 For a Portworx cluster that’s about 100 nodes or greater: If the entire cluster goes down with all the nodes offline, as nodes come online a few nodes get restarted because they are marked offline. A short while after, the system converges and the entire cluster becomes operational. No user intervention required.

## 1.2.10.2

October 6, 2017

### Key Fixes

* Fix boot issues with Amazon Linux
* Fix issues with shared volume mount and unmount with multiple containers with kubernetes

## 1.2.10

September 18, 2017

### Key Fixes

* Fix issue when a node running Portworx goes down, it never gets marked down in the kvdb by other nodes.
* Fix issue when a container in Lighthouse UI always shows as running even after it has exited
* Auto re-attach containers mounting shared volumes when Portworx container is restarted.
* Add Linux immutable \(CAP\_LINUX\_IMMUTABLE\) when Portworx is running as Docker V2 Plugin
* Set autocache parameter for shared volumes
* On volume mount, make the path read-only if an unmount comes in if the POD gets deleted or Portworx is restarted during POD creation. On unmount,  delete the mount path.
* Remove the volume quorum check during volume mounts so the mount can be retried until the quorum is achieved
* Allow snapshot volume source to be provided as another Portworx volume ID and Snapshot ID
* Allow inline snapshot creation in Portworx Kubernetes volume driver using the Portworx Kubernetes volume spec
* Post log messages indicating when logging URL is changed
* Handle volume delete requests gracefully when Portworx container is starting up
* Handle service account access when Portworx is running as a container instead of a daemonset when running under kubernetes
* Implement a global lock for kubernetes filter such that all cluster-wide Kubernetes filter operations are coordinated through the lock
* Improvements in unmounting/detaching handling in kubernetes to handle different POD clean up behaviors for deployments and statefulsets

### Errata

* If two containers using the same shared volume are run in the same node using docker, when one container exits, the container’s connection to the volume will get disrupted as well. The workaround is to run containers using shared volume in two different Portworx nodes

## 1.2.9

August 23, 2017

{{<info>}}
**Important:**
If you are upgrading from an older version of Portworx (1.2.8 or older) and have Portworx volumes in the attached state, you will need node reboot after upgrade in order for the new version to take effect properly.
{{</info>}}

### Key Features and Enhancements

* Provide the ability to cancel a replication add or HA increase operation
* Automatically decommission a storage less node in the cluster if it has been offline for longer than 48 hours
* [Kubernetes snapshots driver for PX-Enterprise](/portworx-install-with-kubernetes/storage-operations/create-snapshots)
* Improve Kubernetes mount/unmount handling with POD failovers and moves

### Key Fixes

* Correct mountpath retrieval for encrypted volumes
* Fix cleanup path maintenance mode exit issue and clean up alerts
* Fix S3 provider for compatibility issues with legacy object storage providers not supporting ListObjectsV2 API correctly.
* Add more cloudsnap related alerts to indicate cloudsnap status and any cloudsnap operation failures.
* Fix config.json for Docker Plugin installs
* Read topology parameters on Portworx restart so RACK topology information is read correctly on restarts
* Retain environment variables when Portworx is upgraded via `pxctl upgrade` command
* Improve handling for encrypted scale volumes

### Errata

* When PX-Enterprise is run on a large number of nodes, there is potential memory leak and a few nodes show high memory usage. This issue is resolved in 1.2.12.0 onwards. The workaround is to restart the PX-Enterprise container

## 1.2.8

June 27, 2017

### Key Features and Enhancements

* License Tiers for PX-Enterprise

## 1.2.5 Release notes

June 16, 2017

### Key Features and Enhancements

* Increase volume limit to 16K volumes

### Key Fixes

* Fix issues with volume CLI hitting a panic when used the underlying devices are from LVM devices
* Fix px bootstrap issues with pre-existing snapshot schedules
* Remove alerts posted when volumes are mounted and unmounted
* Remove duplicate updates to kvdb

## 1.2.4

June 8, 2017

#### Key Features and Enhancements

* Support for –racks and –zones option when creating replicated volumes
* Improved replication node add speeds
* Node labels and scheduler convergence for docker swarm
* Linux Kernel 4.11 support
* Unique Cluster-specific bucket for each cluster for cloudsnaps
* Load balanced cloudsnap backups for replicated Portworx volumes
* One-time backup schedules for Cloudsnap
* Removed the requirement to have /etc/pwx/kubernetes.yaml in all k8s nodes

### Key Fixes

* `pxctl cloudsnap credentials` command has been moved under `pxctl credentials`
* Docker inline volume creation support for setting volume aggregation level
* –nodes support for docker inline volume spec
* Volume attach issues after a node restart when container attaching to a volume failed
* Portworx displays issues in Prometheus
* Cloudsnap scheduler display issues where the existing schedules were not seen by some users.
* Removed snapshots from being counted into to total volume count
* Removed non-px related metrics being pushed to Prometheus
* Added CLI feedback and success/failure alerts for `pxctl volume update` command
* Fixed issues with Cloudsnap backup status updates for container restarts

## 1.2.3

May 30, 2017

### Key Features and Enhancements

No new features in 1.2.3. This is a patch release.

### Key Fixes

* Performance improvements for database workloads

## 1.2.2

May 24, 2017

### Key Features and Enhancements

No new features in 1.2.2. This is a patch release.

### Key Fixes

* Fix device detection in AWS authenticated instances

## 1.2.1

May 9, 2017

### Key Features and Enhancements

No new features in 1.2.1. This is a patch release.

### Key Fixes

* Fix issues with pod failovers with encrypted volumes
* Improve performance with remote volume mounts
* Add compatibility for Linux 4.10+ kernels

## 1.2.0

April 27, 2017

### Key Features and Enhancements

* [AWS Auto-scaling integration with Portworx](/portworx-install-with-kubernetes/cloud/aws/aws-asg) managing EBS volumes for EC2 instances in AWS ASG
* [Multi-cloud Backup and Restore](/reference/cli/cloud-snaps) of Portworx volumes
* [Encrypted Volumes](/reference/cli/encrypted-volumes) with Data-at-rest and Data-in-flight encryption
* Docker V2 Plugin Support
* [Prometheus Integeration](/install-with-other/operate-and-maintain/monitoring/prometheus)
* [Hashicorp Vault](/key-management/vault), [AWS KMS integration](/portworx-install-with-kubernetes/cloud/aws) and Docker Secrets Integration
* [Dynamically resize](/reference/cli/updating-volumes) Portworx volumes with no application downtime
* Improved the security of the Portworx container

### Key Fixes

* Issues with volume auto-attach
* Improved network diagnostics on Portworx container start
* Added an alert when volume state transitions to read-only due to loss of quorum
* Display multiple attached hosts on shared volumes
* Improve shared volume container attach when the volume is in resync state
* Allow pxctl to run as a normal user
* Improved pxctl help text for commands like pxctl service
