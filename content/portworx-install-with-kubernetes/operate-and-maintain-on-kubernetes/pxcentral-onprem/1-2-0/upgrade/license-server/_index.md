---
title: Upgrade the license server component
weight: 2
keywords: Upgrade, PX-Central, On-prem, license, GUI, k8s, license server
description: Learn how to upgrade the license server component
noicon: true
hidden: true
---

If you've installed the license server component using Helm, you can use Helm to upgrade it as well.

## Prerequisites

The license server component must already be installed.

## Upgrade

Enter the following command to upgrade the license server component, replacing `<release-name>` with the name of your release:

```text
helm upgrade <release-name> portworx/px-license-server --namespace px-backup
```

