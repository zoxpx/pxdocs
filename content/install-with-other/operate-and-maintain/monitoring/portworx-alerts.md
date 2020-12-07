---
title: Portworx Alerts
keywords: portworx, alerts, alarms, warnings, notifications
description: How to monitor alerts with Portworx.
---

## Portworx Alerts

Portworx provides a way to monitor your cluster using alerts. It has a predefined set of alerts which are listed below. The alerts are broadly classified into the following types based on the Resource on which it is raised

1. Cluster
2. Nodes
3. Disks
4. Volumes
5. Pools

Each alert has a severity from one of the following levels:

1. INFO
2. WARNING
3. ALARM

### List of Alerts

| Name | ResourceType | Severity | Description | Metric |
| :--- | :--- | :--- | :--- | :--- |
| VolGroupOperationFailure | CLUSTER | ALARM | Triggered when a volume group operation fails. | px_alerts_volgroupoperationfailure_total |
| VolGroupOperationSuccess | CLUSTER | NOTIFY | Triggered when a volume group operation succeeds. | px_alerts_volgroupoperationsuccess_total |
| VolGroupStateChange | CLUSTER | WARNING | Triggered when a volume group’s state changes. | px_alerts_volgroupstatechange_total |
| ContainerOperationFailure | CLUSTER | ALARM | Container operation failed | px_alerts_containeroperationfailure_total |
| ContainerOperationSuccess | CLUSTER | ALARM | Container operation succeeded | px_alerts_containeroperationsuccess_total |
| ContainerStateChange | CLUSTER | ALARM | Container state changed | px_alerts_containerstatechange_total |
| LicenseExpiring | CLUSTER | WARNING | Warning triggers 7 days before the installed Portworx Enterprise or Trial license will expire (e.g. “PX-Enterprise license will expire in 6 days, 12:00”). It will also keep triggering after the license has expired (e.g. “Trial license expired 4 days, 06:22 ago”). | px_alerts_licenseexpiring_total |
| ClusterPairSuccess | CLUSTER | NOTIFY | Triggered when a cluster pair operation succeeds. | px_alerts_clusterpairsuccess_total |
| ClusterPairFailure | CLUSTER | ALARM | Triggered when a cluster pair operation fails. | px_alerts_clusterpairfailure_total |
| ClusterDomainAdded | CLUSTER | NOTIFY | Triggered when a cluster domain is added. | px_alerts_clusterdomainadded_total |
| ClusterDomainRemoved | CLUSTER | NOTIFY | Triggered when a cluster domain is removed. | px_alerts_clusterdomainremoved_total |
| ClusterDomainActivated | CLUSTER | NOTIFY | Triggered when a cluster domain is activated. | px_alerts_clusterdomainactivated_total |
| ClusterDomainDeactivated | CLUSTER | NOTIFY | Triggered when a cluster domain is deactivated. | px_alerts_clusterdomaindeactivated_total |
| MeteringAgentWarning | CLUSTER | WARNING | Triggered when the metering agent encounters a non-critical problem. | px_alerts_meteringagentwarning_total |
| MeteringAgentCritical | CLUSTER | ALARM | Triggered when the metering agent encounters a critical problem. | px_alerts_meteringagentcritical_total |
| ClusterLicenseUpdated | CLUSTER | NOTIFY | Triggered when a license is updated for a cluster. | px_alerts_clusterlicenseupdated_total |
| LicenseExpired | CLUSTER | ALARM | Triggered when the cluster license expires. | px_alerts_licenseexpired_total |
| LicenseLeaseExpiring | CLUSTER | WARNING | Triggered when the license lease is about to expire since the last lease refresh failed. | px_alerts_licenseleaseexpiring_total |
| LicenseLeaseExpired | CLUSTER | ALARM | Triggered when the license lease has expired since the last lease refresh failed. | px_alerts_licenseleaseexpired_total |
| RebalanceJobFinished | CLUSTER | ALARM | Rebalance job finished execution | px_alerts_rebalancejobfinished_total |
| RebalanceJobStarted | CLUSTER | ALARM | Rebalance job started execution | px_alerts_rebalancejobstarted_total |
| RebalanceJobPaused | CLUSTER | ALARM | Rebalance job paused execution | px_alerts_rebalancejobpaused_total |
| RebalanceJobCancelled | CLUSTER | ALARM | Rebalance job cancelled | px_alerts_rebalancejobcancelled_total |
| LicenseNodesOverAllocated | CLUSTER | ALARM | Too many nodes in cluster | px_alerts_licensenodesoverallocated_total |
| NodeStartFailure | NODE | ALARM | Triggered when a node in the Portworx cluster fails to start. | px_alerts_nodestartfailure_total |
| NodeStartSuccess | NODE | NOTIFY | Triggered when a node in the Portworx cluster successfully initializes. | px_alerts_nodestartsuccess_total |
| NodeStateChange | NODE | ALARM | Node state changed (i.e. it went down, came online etc.) | px_alerts_nodestatechange_total |
| NodeJournalHighUsage | NODE | ALARM | Triggered when a node’s timestamp journal usage is not within limits. | px_alerts_nodejournalhighusage_total |
| PXInitFailure | NODE | ALARM | Triggered when Portworx fails to initialize on a node. | px_alerts_pxinitfailure_total |
| PXInitSuccess | NODE | NOTIFY | Triggered when Portworx successfully initializes on a node. | px_alerts_pxinitsuccess_total |
| PXStateChange | NODE | WARNING | Triggered when the Portworx daemon shuts down in error. | px_alerts_pxstatechange_total |
| StorageVolumeMountDegraded | NODE | ALARM | Triggered when Portworx storage enters degraded mode on a node. | px_alerts_storagevolumemountdegraded_total |
| ClusterManagerFailure | NODE | ALARM | Triggered when Cluster manager on a Portworx node fails to start. The alert message will give more info about the specific error case. | px_alerts_clustermanagerfailure_total |
| KernelDriverFailure | NODE | ALARM | Triggered when an incorrect Portworx kernel module is detected. Indicates that Portworx is started with an incorrect version of the kernel module. | px_alerts_kerneldriverfailure_total |
| NodeDecommissionSuccess | NODE | NOTIFY | Triggered when a node is successfully decommissioned from Portworx cluster. | px_alerts_nodedecommissionsuccess_total |
| NodeDecommissionFailure | NODE | ALARM | Triggered when a node could not be decommissioned from Portworx cluster. | px_alerts_nodedecommissionfailure_total |
| NodeDecommissionPending | NODE | WARNING | Triggered when a node decommission is kept in pending state as it has data which is not replicated on other nodes. | px_alerts_nodedecommissionpending_total |
| NodeInitFailure | NODE | ALARM | Triggered when Portworx fails to initialize on a node. | px_alerts_nodeinitfailure_total |
| NodeScanCompletion | NODE | NOTIFY | Triggered when node media scan completes without error. | px_alerts_nodescancompletion_total |
| CloudsnapScheduleFailure | NODE | ALARM | Triggered if a cloudsnap schedule fails to configure. | px_alerts_cloudsnapschedulefailure_total |
| NodeMarkedDown | NODE | WARNING | Triggered when a Portworx node marks another node down as it is unable to connect to it. | px_alerts_nodemarkeddown_total |
| PXReady | NODE | NOTIFY | Triggered when Portworx is ready on a node. | px_alerts_pxready_total |
| StorageFailure | NODE | ALARM | Triggered when the provided storage drives could not be mounted by Portworx. | px_alerts_storagefailure_total |
| ObjectstoreFailure | NODE | ALARM | Triggered when an object store error is detected. | px_alerts_objectstorefailure_total |
| ObjectstoreSuccess | NODE | NOTIFY | Triggered upon a successful object store operation. | px_alerts_objectstoresuccess_total |
| ObjectstoreStateChange | NODE | NOTIFY | Triggered in response to a state change. | px_alerts_objectstorestatechange_total |
| SharedV4SetupFailure | NODE | WARNING | Triggered when the creation of a sharedv4 volume fails. | px_alerts_sharedv4setupfailure_total |
| NodeTimestampFailure | NODE | ALARM | Node timestamp journal failure | px_alerts_nodetimestampfailure_total |
| NodeJournalFailure | NODE | ALARM | Node journal failure | px_alerts_nodejournalfailure_total |
| StoragePoolFailure | NODE | ALARM | Storage Pool handling encountered an issue | px_alerts_storagepoolfailure_total |
| NodeDriverFailure | NODE | ALARM | Node Kernel Driver Failure | px_alerts_nodedriverfailure_total |
| StoragelessToStorageNodeTransitionFailure | NODE | ALARM | Triggered when a node fails to transition from a storageless type to a storage type. | px_alerts_storagelesstostoragenodetransitionfailure_total |
| StoragelessToStorageNodeTransitionSuccess | NODE | NOTIFY | Triggered when a node transitions from a storageless type to a storage type successfully. | px_alerts_storagelesstostoragenodetransitionsuccess_total |
| SecretsAuthFailed | NODE | WARNING | Secrets setup has failed | px_alerts_secretsauthfailed_total |
| LicenseServerDown | NODE | WARNING | Triggered when a node is unable to reach the license server. | px_alerts_licenseserverdown_total |
| FloatingLicenseSetupError | NODE | ALARM | Triggered when a node fails to setup a floating license. | px_alerts_floatinglicensesetuperror_total |
| NFSServerUnhealthy | NODE | WARNING | Triggered when the NFS server on this node is unhealthy. | px_alerts_nfsserverunhealthy_total |
| FileSystemDependency | NODE | ALARM | Triggered during Portworx installation if there’s a filesystem dependency failure. | px_alerts_filesystemdependency_total |
| RebootRequired | NODE | ALARM | Triggered when a node requires a reboot. | px_alerts_rebootrequired_total |
| TempFileSystemInitialization | NODE | ALARM | Triggered during Portworx installation if a node fails to initialize a temporary filesystem. | px_alerts_tempfilesysteminitialization_total |
| UnsupportedKernel | NODE | ALARM | Triggered during a Portworx installation if the node contains a kernel that is not supported by Portworx. | px_alerts_unsupportedkernel_total |
| InvalidDevice | NODE | ALARM | Triggered during Portworx installation if an invalid device is provided to Portworx as a storage device. | px_alerts_invaliddevice_total |
| NfsDependencyInstallFailure | NODE | ALARM | Triggered during Portworx installation if Portworx cannot install the NFS service. | px_alerts_nfsdependencyinstallfailure_total |
| NfsDependencyNotEnabled | NODE | ALARM | Triggered during Portworx installation if Portworx cannot enable the NFS service. | px_alerts_nfsdependencynotenabled_total |
| LicenseCheckFailed | NODE | ALARM | Triggered if a node fails a license check. | px_alerts_licensecheckfailed_total |
| PortworxStoppedOnNode | NODE | WARNING | Triggered if Portworx is stopped on a node. | px_alerts_portworxstoppedonnode_total |
| KvdbConnectionFailed | NODE | ALARM | Triggered if Portworx fails to connect to the KVDB. | px_alerts_kvdbconnectionfailed_total |
| InternalKvdbSetupFailed | NODE | ALARM | Triggered if Portworx fails to setup Internal KVDB on a node. | px_alerts_internalkvdbsetupfailed_total |
| PortworxMonitorImagePullFailed | NODE | ALARM | Triggered if Portworx fails to pull Portworx images during installation. | px_alerts_portworxmonitorimagepullfailed_total |
| PortworxMonitorPrePostExecutionFailed | NODE | ALARM | Triggered if Portworx fails to execute pre or post installation tasks. | px_alerts_portworxmonitorprepostexecutionfailed_total |
| PortworxMonitorMountValidationFailed | NODE | ALARM | Triggered if Portworx fails to validate mounts provided to Portworx container during installation. | px_alerts_portworxmonitormountvalidationfailed_total |
| PortworxMonitorSchedulerInitializationFailed | NODE | ALARM | Triggered if Portworx fails to initialize connection with scheduler during installation. | px_alerts_portworxmonitorschedulerinitializationfailed_total |
| PortworxMonitorServiceControlsInitializationFailed | NODE | ALARM | Triggered if Portworx fails to initialize the service controls during installation. | px_alerts_portworxmonitorservicecontrolsinitializationfailed_total |
| PortworxMonitorInstallFailed | NODE | ALARM | Triggered if Portworx installation fails. | px_alerts_portworxmonitorinstallfailed_total |
| MissingInputArgument | NODE | ALARM | Triggered if there’s a missing input install argument. | px_alerts_missinginputargument_total |
| PortworxMonitorImagePullInProgress | NODE | NOTIFY | Triggered when Portworx is pulling and extracting images during installation or upgrade. | px_alerts_portworxmonitorimagepullinprogress_total |
| InvalidArgument | NODE | ALARM | Invalid input argument | px_alerts_invalidargument_total |
| PXHostDependencyFailure | NODE | ALARM | Host does not meet dependencies for applied px configuration | px_alerts_pxhostdependencyfailure_total |
| KvdbConnectionWarning | NODE | WARNING | kvdb endpoint is not accessible | px_alerts_kvdbconnectionwarning_total |
| CallHomeFailure | NODE | ALARM | Call home failure | px_alerts_callhomefailure_total |
| CloudsnapSettingWarning | NODE | WARNING | Cloudsnap setting Warning | px_alerts_cloudsnapsettingwarning_total |
| Sharedv4ServerHighLoadWarn | NODE | WARNING | SharedV4 server high load detected | px_alerts_sharedv4serverhighloadwarn_total |
| NodeAttachmentsCordoned | NODE | NOTIFY | Volume attachments are disabled on this node | px_alerts_nodeattachmentscordoned_total |
| NodeAttachmentsUncordoned | NODE | NOTIFY | Volume attachments are re-enabled on this node | px_alerts_nodeattachmentsuncordoned_total |
| DrainAttachmentsJobStarted | NODE | NOTIFY | DrainAttachments job started execution | px_alerts_drainattachmentsjobstarted_total |
| DrainAttachmentsJobFinished | NODE | NOTIFY | DrainAttachments job finished execution | px_alerts_drainattachmentsjobfinished_total |
| DrainAttachmentsJobCancelled | NODE | ALARM | DrainAttachments job cancelled | px_alerts_drainattachmentsjobcancelled_total |
| CloudDriveTransferJobStarted | NODE | NOTIFY | CloudDriveTransfer job started execution | px_alerts_clouddrivetransferjobstarted_total |
| CloudDriveTransferJobInProgress | NODE | NOTIFY | CloudDriveTransfer job in progress | px_alerts_clouddrivetransferjobinprogress_total |
| CloudDriveTransferJobFinished | NODE | NOTIFY | CloudDriveTransfer job finished execution | px_alerts_clouddrivetransferjobfinished_total |
| CloudDriveTransferJobCancelled | NODE | ALARM | CloudDriveTransfer job cancelled | px_alerts_clouddrivetransferjobcancelled_total |
| DrainAttachmentsOperationWarning | NODE | WARNING | DrainAttachments operation warning | px_alerts_drainattachmentsoperationwarning_total |
| PoolExpandInProgress | POOL | NOTIFY | Triggered when a pool expand operation starts. | px_alerts_poolexpandinprogress_total |
| PoolExpandSuccessful | POOL | NOTIFY | Triggered when a pool expand operation succeeds. | px_alerts_poolexpandsuccessful_total |
| PoolExpandFailed | POOL | ALARM | Triggered when a pool expand operation fails. | px_alerts_poolexpandfailed_total |
| DriveOperationFailure | DRIVE | ALARM | Triggered when a driver operation such as add or replace fails. | px_alerts_driveoperationfailure_total |
| DriveOperationSuccess | DRIVE | NOTIFY | Triggered when a driver operation such as add or replace succeeds. | px_alerts_driveoperationsuccess_total |
| DriveStateChange | DRIVE | WARNING | Triggered when there is a change in the driver state viz. Free Disk space goes below the recommended level of 10%. | px_alerts_drivestatechange_total |
| DriveStateChangeClear | DRIVE | WARNING | Triggered when the drive’s state gets cleared. | px_alerts_drivestatechangeclear_total |
| CloudDriveCreateWarning | DRIVE | ALARM | Warning during cloud drive creation | px_alerts_clouddrivecreatewarning_total |
| VolumeOperationFailureAlarm | VOLUME | ALARM | Triggered when a volume operation fails. Volume operations could be resize, cloudsnap, etc. The alert message will give more info about the specific error case. | px_alerts_volumeoperationfailurealarm_total |
| VolumeOperationSuccess | VOLUME | NOTIFY | Triggered when a volume operation such as resize succeeds. | px_alerts_volumeoperationsuccess_total |
| VolumeStateChange | VOLUME | WARNING | Triggered when there is a change in the state of the volume. | px_alerts_volumestatechange_total |
| IOOperation | VOLUME | ALARM | Triggered when an IO operation such as Block Read/Block Write fails. | px_alerts_iooperation_total |
| VolumeOperationFailureWarn | VOLUME | WARNING | Triggered when a volume operation fails. Volume operations could be resize, cloudsnap, etc. The alert message will give more info about the specific error case. | px_alerts_volumeoperationfailurewarn_total |
| VolumeSpaceLow | VOLUME | ALARM | Triggered when the free space available in a volume goes below a threshold. | px_alerts_volumespacelow_total |
| ReplAddVersionMismatch | VOLUME | WARNING | Triggered when a volume HA update fails with version mismatch. | px_alerts_repladdversionmismatch_total |
| CloudsnapOperationUpdate | VOLUME | NOTIFY | Triggered if a cloudsnap schedule is changed successfully. | px_alerts_cloudsnapoperationupdate_total |
| CloudsnapOperationFailure | VOLUME | ALARM | Triggered when a cloudsnap operation fails. | px_alerts_cloudsnapoperationfailure_total |
| CloudsnapOperationSuccess | VOLUME | NOTIFY | Triggered when a cloudsnap operation succeeds. | px_alerts_cloudsnapoperationsuccess_total |
| VolumeCreateSuccess | VOLUME | NOTIFY | Triggered when a volume is successfully created. | px_alerts_volumecreatesuccess_total |
| VolumeCreateFailure | VOLUME | ALARM | Triggered when a volume creation fails. | px_alerts_volumecreatefailure_total |
| VolumeDeleteSuccess | VOLUME | NOTIFY | Triggered when a volume is successfully deleted. | px_alerts_volumedeletesuccess_total |
| VolumeDeleteFailure | VOLUME | ALARM | Triggered when a volume deletion fails. | px_alerts_volumedeletefailure_total |
| VolumeMountSuccess | VOLUME | NOTIFY | Triggered when a volume is successfully mounted at the requested path. | px_alerts_volumemountsuccess_total |
| VolumeMountFailure | VOLUME | ALARM | Triggered when a volume cannot be mounted at the requested path. | px_alerts_volumemountfailure_total |
| VolumeUnmountSuccess | VOLUME | NOTIFY | Triggered when a volume is successfully unmounted. | px_alerts_volumeunmountsuccess_total |
| VolumeUnmountFailure | VOLUME | ALARM | Triggered when a volume cannot be unmounted. The alert message provides more info about the specific error case. | px_alerts_volumeunmountfailure_total |
| VolumeHAUpdateSuccess | VOLUME | NOTIFY | Triggered when a volume’s replication factor (HA factor) is successfully updated. | px_alerts_volumehaupdatesuccess_total |
| VolumeHAUpdateFailure | VOLUME | ALARM | Triggered when an update to volume’s replication factor (HA factor) fails. | px_alerts_volumehaupdatefailure_total |
| SnapshotCreateSuccess | VOLUME | NOTIFY | Triggered when a volume is successfully created. | px_alerts_snapshotcreatesuccess_total |
| SnapshotCreateFailure | VOLUME | ALARM | Triggered when a volume snapshot creation fails. | px_alerts_snapshotcreatefailure_total |
| SnapshotRestoreSuccess | VOLUME | NOTIFY | Triggered when a snapshot is successfully restored on a volume. | px_alerts_snapshotrestoresuccess_total |
| SnapshotRestoreFailure | VOLUME | ALARM | Triggered when the operation of restoring a snapshot fails. | px_alerts_snapshotrestorefailure_total |
| SnapshotIntervalUpdateFailure | VOLUME | ALARM | Triggered when an update of the snapshot interval for a volume fails. | px_alerts_snapshotintervalupdatefailure_total |
| SnapshotIntervalUpdateSuccess | VOLUME | NOTIFY | Triggered when a snapshot interval of a volume is successfully updated. | px_alerts_snapshotintervalupdatesuccess_total |
| VolumeExtentDiffSlow | VOLUME | WARNING | Volume extent diff is taking too long. | px_alerts_volumeextentdiffslow_total |
| VolumeExtentDiffOk | VOLUME | WARNING | Volume extent diff is okay. | px_alerts_volumeextentdiffok_total |
| SnapshotDeleteSuccess | VOLUME | NOTIFY | Triggered when a snapshot is successfully deleted. | px_alerts_snapshotdeletesuccess_total |
| SnapshotDeleteFailure | VOLUME | ALARM | Triggered when a snapshot delete is successfully deleted. | px_alerts_snapshotdeletefailure_total |
| VolumeSpaceLowCleared | VOLUME | NOTIFY | Triggered when the free disk space goes above the recommended level of 10%. | px_alerts_volumespacelowcleared_total |
| CloudMigrationUpdate | VOLUME | NOTIFY | Triggered if a cloud migration is updated. | px_alerts_cloudmigrationupdate_total |
| CloudMigrationSuccess | VOLUME | NOTIFY | Triggered when a cloud migration operation succeeds. | px_alerts_cloudmigrationsuccess_total |
| CloudMigrationFailure | VOLUME | ALARM | Triggered when a cloud migration operation fails. | px_alerts_cloudmigrationfailure_total |
| CloudsnapOperationWarning | VOLUME | WARNING | Triggered when a cloud snap operation encounters a problem. | px_alerts_cloudsnapoperationwarning_total |
| IOOperationWarning | VOLUME | WARNING | Io operation warning | px_alerts_iooperationwarning_total |
| FilesystemCheckSuccess | VOLUME | NOTIFY | Filesystem-Check fixed filesystem errors in volume | px_alerts_filesystemchecksuccess_total |
| FilesystemCheckFailed | VOLUME | WARNING | Filesystem-Check failed to fix errors in volume | px_alerts_filesystemcheckfailed_total |
| FilesystemCheckFoundErrors | VOLUME | WARNING | Filesystem-Check found errors in the filesystem | px_alerts_filesystemcheckfounderrors_total |
| VolumeResizeSuccessful | VOLUME | NOTIFY | Volume resize operation successful | px_alerts_volumeresizesuccessful_total |
| VolumeResizeDeferred | VOLUME | NOTIFY | Volume resize operation deferred to next mount | px_alerts_volumeresizedeferred_total |
| VolumeResizeFailed | VOLUME | ALARM | Volume resize operation failed | px_alerts_volumeresizefailed_total |
