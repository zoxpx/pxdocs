---
title: Upgrading Portworx on Kubernetes using Rancher 2.x
linkTitle: Upgrading Portworx
keywords: upgrade, Portworx, Rancher, Helm chart
description: Upgrade Portworx on Kubernetes using Rancher with a public catalog (Helm Chart)
noicon: true
---

## Purpose

This guide provides instructions for upgrading Portworx on Kubernetes using Rancher 2.x with a Helm chart available from the public catalog.

## Upgrading Portworx

Perform the following steps to upgrade Portworx:

1. From the top navigation bar, select **Apps**:

    ![Rancher apps page](/img/rancher-apps-page.png)

2. Click on the vertical ellipsis and select **Upgrade**:

    ![Rancher upgrade](/img/rancher-ve-upgrade.png)


3. Go to the **Advanced Settings** section and change the value of the **Portworx version to be deployed** input field (for e.g `2.5.1`):

    ![Rancher change PX version](/img/rancher-change-px-version.png)

4. Click Upgrade. Rancher will now upgrade `Portworx`:

    ![Rancher deploying](/img/rancher-deploying.png)


5. During upgrade, you can inspect the status by clicking the vertical ellipsis:

    ![Rancher deploying](/img/rancher-upgrade-inspect-status.png)

6. After the update completes, the status will be changed to `Active`:

    ![Rancher upgrade finished](/img/rancher-update-finished.png)
