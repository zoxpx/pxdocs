---
title: Add licenses to your clusters using PX-Central on-prem
linkTitle: Add licenses using PX-Central on-prem
weight: 2
keywords: PX-Central, On-prem, license, GUI, k8s
description: Learn how to add licenses to your clusters using PX-Central On-prem.
noicon: true
series: k8s-op-maintain-1-1-0
hidden: true
---

Your PX-Central on-prem deployment includes a highly-available license server and backup server by default. From PX-Central, you can add and manage licenses for any of your attached Portworx clusters.

## Prerequisites

* You must have a valid Portworx license to add.
* At least one Portworx cluster must be added to PX-Central.

## Add a license to PX-Central

1. From the PX-Central landing page, select the **License** icon to navigate to the **License Entitlements** page:

    ![Select the license icon](/img/select-the-license-icon.png)

2. <!-- On the tile for your cluster, --> Select the **Licenses** link to go to the license management page:

    ![Select the licenses link](/img/select-the-licenses-link.png)

3. Select the **Import License** button:

    ![Select the import license button](/img/select-the-import-license-button.png)

4. Paste your license key into the **License Key** text field or upload it from a file, and then select the **Import License** button to add your license:

    ![Add your license](/img/add-your-license.png)

<!-- verification failed with "Auth failed" message, probably due to testing config. -->

## Related topics

* For information on how to connect a cluster to a license server using `pxctl`, refer to the [pxctl setls command reference](/reference/cli/license/#connect-to-a-license-server).
