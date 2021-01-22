---
title: Upgrade PX-Central on-premises
description: Upgrade your version of PX-Central on-premises
keywords: Upgrade, PX-Central, On-prem, license, GUI, k8s
weight: 1
noicon: true
hideSections: true
---

If you've installed PX-Central using Helm, you can use Helm to upgrade it as well.

## Prerequisites

PX-Central must already be installed.

## Upgrade

1. Use the following `kubectl delete job` command to delete the post-install job:

    ```text
    kubectl delete job -npx-backup pxcentral-post-install-hook
    ```

2. Upgrade the chart to the latest version. Enter the `helm upgrade` command, using the `--set` flag to specify any custom values you used during install:

    ```text
    helm upgrade px-backup portworx/px-backup --namespace px-backup --set persistentStorage.storageClassName=<STORAGE-CLASS-NAME>,pxbackup.orgName=<PX-BACKUP-ORG-NAME>
    ```
