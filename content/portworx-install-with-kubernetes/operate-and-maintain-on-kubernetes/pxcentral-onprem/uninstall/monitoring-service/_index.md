---
title: Uninstall the monitoring service
weight: 3
keywords: Uninstall, PX-Central, On-prem, license, GUI, k8s, monitoring service
description: Learn how to uninstall the monitoring service
noicon: true
---

If you've installed the monitoring service using Helm, you can use Helm to uninstall it as well.

## Prerequisites

The monitoring service must already be installed.

## Uninstall

Enter the following command to uninstall the monitoring service, replacing `<release-name>` with the name of your release:

```text
helm delete <release-name> --namespace px-backup
```