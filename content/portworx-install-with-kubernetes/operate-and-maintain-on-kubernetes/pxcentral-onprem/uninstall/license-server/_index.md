---
title: Uninstall the license server component
weight: 2
keywords: Uninstall, PX-Central, On-prem, license, GUI, k8s, license server
description: Learn how to uninstall the license server component
noicon: true
---

If you've installed the license server component using Helm, you can use Helm to uninstall it as well.

## Prerequisites

The license server component must already be installed.

## Uninstall

Enter the following command to uninstall the license server component, replacing `<release-name>` with the name of your release:

```text
helm delete <release-name> --namespace px-backup
```