---
title: Alerts using pxctl
linkTitle: Alerts
keywords: portworx, pxctl, command-line tool, cli, reference, alerts, monitoring
description: Monitor the status of your cluster through alerts. Learn how to use pxctl to access these alerts.
weight: 17
---

_Portworx_ provides a way to monitor the status of your cluster through alerts.
In this document, we are going to show how to access these alerts using `pxctl`.

First, let's get an overview of the available commands:

```text
pxctl alerts --help
```

```output
px alerts

Usage:
  pxctl alerts [flags]
  pxctl alerts [command]

Aliases:
  alerts, a

Available Commands:
  info        show info on alerts
  purge       purge alerts
  show        show alerts

Flags:
  -h, --help   help for alerts

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

Use "pxctl alerts [command] --help" for more information about a command.
```

## Supported alerts

The following alerts are supported by _Portworx_:

```text
pxctl alerts info
```

```output
Type      ID                              Severity
VOLUME    VolumeOperationFailureAlarm     SEVERITY_TYPE_ALARM
VOLUME    IOOperation                     SEVERITY_TYPE_ALARM
VOLUME    VolumeSpaceLow                  SEVERITY_TYPE_ALARM
VOLUME    CloudsnapOperationFailure       SEVERITY_TYPE_ALARM
VOLUME    VolumeCreateFailure             SEVERITY_TYPE_ALARM
VOLUME    VolumeDeleteFailure             SEVERITY_TYPE_ALARM
VOLUME    VolumeMountFailure              SEVERITY_TYPE_ALARM
VOLUME    VolumeUnmountFailure            SEVERITY_TYPE_ALARM
VOLUME    VolumeHAUpdateFailure           SEVERITY_TYPE_ALARM
VOLUME    SnapshotCreateFailure           SEVERITY_TYPE_ALARM
VOLUME    SnapshotRestoreFailure          SEVERITY_TYPE_ALARM
VOLUME    SnapshotIntervalUpdateFailure   SEVERITY_TYPE_ALARM
VOLUME    SnapshotDeleteFailure           SEVERITY_TYPE_ALARM
VOLUME    CloudMigrationFailure           SEVERITY_TYPE_ALARM
VOLUME    VolumeStateChange               SEVERITY_TYPE_WARNING
VOLUME    VolumeOperationFailureWarn      SEVERITY_TYPE_WARNING
VOLUME    ReplAddVersionMismatch          SEVERITY_TYPE_WARNING
VOLUME    VolumeExtentDiffSlow            SEVERITY_TYPE_WARNING
VOLUME    VolumeExtentDiffOk              SEVERITY_TYPE_WARNING
VOLUME    VolumeOperationSuccess          SEVERITY_TYPE_NOTIFY
VOLUME    CloudsnapOperationUpdate        SEVERITY_TYPE_NOTIFY
VOLUME    CloudsnapOperationSuccess       SEVERITY_TYPE_NOTIFY
VOLUME    VolumeCreateSuccess             SEVERITY_TYPE_NOTIFY
VOLUME    VolumeDeleteSuccess             SEVERITY_TYPE_NOTIFY
VOLUME    VolumeMountSuccess              SEVERITY_TYPE_NOTIFY
VOLUME    VolumeUnmountSuccess            SEVERITY_TYPE_NOTIFY
VOLUME    VolumeHAUpdateSuccess           SEVERITY_TYPE_NOTIFY
VOLUME    SnapshotCreateSuccess           SEVERITY_TYPE_NOTIFY
VOLUME    SnapshotRestoreSuccess          SEVERITY_TYPE_NOTIFY
VOLUME    SnapshotIntervalUpdateSuccess   SEVERITY_TYPE_NOTIFY
VOLUME    SnapshotDeleteSuccess           SEVERITY_TYPE_NOTIFY
VOLUME    VolumeSpaceLowCleared           SEVERITY_TYPE_NOTIFY
VOLUME    CloudMigrationUpdate            SEVERITY_TYPE_NOTIFY
VOLUME    CloudMigrationSuccess           SEVERITY_TYPE_NOTIFY
CLUSTER    VolGroupOperationFailure       SEVERITY_TYPE_ALARM
CLUSTER    NodeStartFailure               SEVERITY_TYPE_ALARM
CLUSTER    NodeStateChange                SEVERITY_TYPE_ALARM
CLUSTER    NodeJournalHighUsage           SEVERITY_TYPE_ALARM
CLUSTER    ContainerOperationFailure      SEVERITY_TYPE_ALARM
CLUSTER    NodeDecommissionFailure        SEVERITY_TYPE_ALARM
CLUSTER    NodeInitFailure                SEVERITY_TYPE_ALARM
CLUSTER    ClusterPairFailure             SEVERITY_TYPE_ALARM
CLUSTER    MeteringAgentCritical          SEVERITY_TYPE_ALARM
CLUSTER    VolGroupStateChange            SEVERITY_TYPE_WARNING
CLUSTER    ContainerStateChange           SEVERITY_TYPE_WARNING
CLUSTER    NodeDecommissionPending        SEVERITY_TYPE_WARNING
CLUSTER    NodeMarkedDown                 SEVERITY_TYPE_WARNING
CLUSTER    LicenseExpiring                SEVERITY_TYPE_WARNING
CLUSTER    MeteringAgentWarning           SEVERITY_TYPE_WARNING
CLUSTER    VolGroupOperationSuccess       SEVERITY_TYPE_NOTIFY
CLUSTER    NodeStartSuccess               SEVERITY_TYPE_NOTIFY
CLUSTER    ContainerOperationSuccess      SEVERITY_TYPE_NOTIFY
CLUSTER    NodeDecommissionSuccess        SEVERITY_TYPE_NOTIFY
CLUSTER    ClusterPairSuccess             SEVERITY_TYPE_NOTIFY
CLUSTER    ClusterDomainAdded             SEVERITY_TYPE_NOTIFY
CLUSTER    ClusterDomainRemoved           SEVERITY_TYPE_NOTIFY
CLUSTER    ClusterDomainActivated         SEVERITY_TYPE_NOTIFY
CLUSTER    ClusterDomainDeactivated       SEVERITY_TYPE_NOTIFY
DRIVE      DriveOperationFailure          SEVERITY_TYPE_ALARM
DRIVE      DriveStateChange               SEVERITY_TYPE_WARNING
DRIVE      DriveStateChangeClear          SEVERITY_TYPE_WARNING
DRIVE      DriveOperationSuccess          SEVERITY_TYPE_NOTIFY
NODE       PXInitFailure                  SEVERITY_TYPE_ALARM
NODE       ClusterManagerFailure          SEVERITY_TYPE_ALARM
NODE       KernelDriverFailure            SEVERITY_TYPE_ALARM
NODE       CloudsnapScheduleFailure       SEVERITY_TYPE_ALARM
NODE       StorageFailure                 SEVERITY_TYPE_ALARM
NODE       ObjectstoreFailure             SEVERITY_TYPE_ALARM
NODE       PXStateChange                  SEVERITY_TYPE_WARNING
NODE       SharedV4SetupFailure           SEVERITY_TYPE_WARNING
NODE       PXInitSuccess                  SEVERITY_TYPE_NOTIFY
NODE       NodeScanCompletion             SEVERITY_TYPE_NOTIFY
NODE       PXReady                        SEVERITY_TYPE_NOTIFY
NODE       ObjectstoreSuccess             SEVERITY_TYPE_NOTIFY
NODE       ObjectstoreStateChange         SEVERITY_TYPE_NOTIFY
```

For more details on alerts, please see [this page](/install-with-other/operate-and-maintain/monitoring/portworx-alerts).

## Reported alerts

You can see what alerts have been reported with the following command:

```text
pxctl alerts show
```

```output
Type      ID            Resource                Severity    Count    LastSeen            FirstSeen            Description
VOLUME    VolumeCreateSuccess    445516405819839095            NOTIFY        1    May 28 16:51:43 UTC 2019    May 28 16:51:43 UTC 2019    Volume (Name: tesvol Id: 445516405819839095) created successfully.
CLUSTER    NodeStartFailure    173460ec-3f1f-4015-9fc1-34c2e165657f    ALARM        1    May 28 16:51:56 UTC 2019    May 28 16:51:56 UTC 2019    Node 70.0.76.50 Entering Maintenance mode: User Initiated
NODE    ObjectstoreSuccess    a64136b9-4dd2-4314-8ce6-b8429e2fca73    NOTIFY        1    May 28 16:51:58 UTC 2019    May 28 16:51:58 UTC 2019    Objectstore started successfully
CLUSTER    NodeStartSuccess    173460ec-3f1f-4015-9fc1-34c2e165657f    NOTIFY        1    May 28 16:52:36 UTC 2019    May 28 16:52:36 UTC 2019    Node 70.0.76.50 Exiting Maintenance mode.
```


## Purging alerts

To purge the list of alerts, type:

```text
pxctl alerts purge
```

Next, `pxctl` will prompt you to confirm whether you really want to delete those alerts:

```text
purge alerts? [y/n]:
```

Type `y` and the alerts will get purged.

Let's check:

```text
pxctl alerts show
```

```output
Type    ID    Resource    Severity    Count    LastSeen    FirstSeen    Description
```

{{<info>}}
_Portworx_ recommends setting up monitoring with Prometheus and AlertsManager. If you are using _Portworx_ with Kubernetes, head over to [this page](https://2.1.docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/). If you are using _Portworx_ with other orchestrators, check out [this page](/install-with-other/operate-and-maintain/monitoring/alerting/).
{{</info>}}
