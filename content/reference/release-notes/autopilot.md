---
layout: page
title: "Autopilot Release Notes"
description: Release notes for the Portworx Autopilot component.
keywords: portworx, release notes, components
weight: 350
series: release-notes
---

## 1.2.1

May 30, 2020

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Description**|
|----|
| The [PVC resize action](/portworx-install-with-kubernetes/autopilot/reference/#openstorage-io-action-volume-resize) no longer requires a Portworx Autopilot Capacity Management license |

## 1.2.0

March 20, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Description**|
|----|
| Added support for a new parameter, `scalesize`, under the storage pool expand action that allows you to increase storage pool capacity by a fixed amount. See details on all action parameters [here](/portworx-install-with-kubernetes/autopilot/reference/#openstorage-io-action-storagepool-expand). |
| Added validation for the AutopilotRule CRD |
| Added an alert event that occurs when Autopilot detects an action that cannot be performed due to license restrictions. See the [list of alerts](/portworx-install-with-kubernetes/autopilot/reference/#autopilot-events) for more information. |

## 1.1.0

February 19, 2020

### Improvements

Portworx has upgraded or enhanced functionality in the following areas:

|**Improvement Description**|
|----|
| Added a new CRD, called AutopilotRuleObject, which can be used to check for useful events in objects that autopilot monitors, such as PVCs and StoragePools. |
| Added basic metrics for monitoring Autopilot and Grafana dashboards to view them. To view Autopilot metrics, follow the steps in the [Prometheus and Grafana](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) article. |

### Fixes

The following issues have been fixed:

|**Issue Description**|
|----|
| When an Autopilot pod restarted while expanding a storage pool, it sometimes started expanding another storage pool.<br/><br/>**User impact:** If multiple pools for a volume started expansion together, the volume could go out of quorum.<br/><br/>**Resolution:** Autopilot pods now correctly wait for previous storage pool expansions to complete when they're restarted.|
| Deleting Autopilot rules or PVCs sometimes caused the Autopilot pod to crash<br/><br>**User impact:** If Autopilot crashed, it could start expanding another storage pool while one was already in being expanded.<br/><br/>**Resolution:** The Autopilot pod no longer crashes when rules or PVCs are deleted.|

## 1.0.0

November 18, 2019

Introducing Portworx Autopilot! See the [Autopilot](https://2.3.docs.portworx.com/portworx-install-with-kubernetes/autopilot/) section of the documentation for more information
