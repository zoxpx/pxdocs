---
layout: page
title: "Autopilot Release Notes"
description: Release notes for the Portworx Autopilot component.
keywords: portworx, release notes, components
weight: 350
series: release-notes
---

## 1.1.0

February 19, 2010

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
