---
title: Upgrade the monitoring service
weight: 3
keywords: Upgrade, PX-Central, On-prem, license, GUI, k8s, monitoring service
description: Learn how to upgrade the monitoring sercice
noicon: true
hidden: true
---

If you've installed the monitoring service using Helm, you can use Helm to upgrade it as well.

## Prerequisites

The monitoring service must already be installed.

## Upgrade

Enter the following command to upgrade the monitoring service, replacing `<release-name>` with the name of your release:

```text
helm upgrade <release-name> portworx/px-monitor --namespace px-backup
```
