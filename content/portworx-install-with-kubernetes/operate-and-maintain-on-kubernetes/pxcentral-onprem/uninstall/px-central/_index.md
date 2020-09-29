---
title: Uninstall PX-Central on-premises
description: Uninstall PX-Central on-premises
keywords: Upgrade, PX-Central, On-prem, license, GUI, k8s
weight: 1
noicon: true
hideSections: true
---

If you've installed PX-Central using Helm, you can use Helm to uninstall it as well.

## Prerequisites

PX-Central must already be installed.

## Uninstall

1. Delete the Helm chart, by entering the following command:

    ```text
    helm delete px-backup --namespace px-backup
    ```
2. Use the `kubectl delete` command to clean up secrets and the PVC created by PX-Backup:

    ```text
    kubectl delete ns px-backup
    ```