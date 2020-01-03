---
title: "Autopilot"
linkTitle: "Autopilot"
keywords: autopilot
description: Rule based engine to manage your Kubernetes cluster
hidesections: true
---

Autopilot is a rule-based engine that responds to changes from a monitoring source. Autopilot allows you to specify monitoring conditions along with actions it should take when those conditions occur.

![Autopilot Overview](/img/autopilot-overview.gif)

With Autopilot, your cluster can react dynamically without your intervention to events such as:

* Resizing PVCs when it is running out of capacity
* Scaling Portworx storage pools to accomodate increasing usage

The following sections will cover everything from installation to end-to-end examples.

{{<homelist series="autopilot-home">}}

<!--
Who uses autopilot?
  Administrators
Why should they care? How does it make their life easier?
-->
