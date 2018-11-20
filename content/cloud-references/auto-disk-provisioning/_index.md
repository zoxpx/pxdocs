---
title: Automatic disk provisioning
description: Understand how Portworx provisions disks automatically on various cloud platforms
keywords: cloud,asg,aws,gcp,vsphere,disks
weight: 1
series: cloud-references
---

In cloud environments, Portworx can dynamically create disks based on an input disk template whenever a new instance spins up and use those disks for the Portworx cluster. 

Portworx fingerprints the disks and attaches them to an instance in the autoscaling cluster. In this way an ephemeral instance gets its own identity. 

## Why would I need this?

* Users don't have to manage the lifecycle of disks. Instead, they just have to provide disks specs and Portworx manages the disk lifecycle.
* When an instance terminates, the auto scaling group will automatically add a new instance to the cluster. Portworx gracefully handle this scenario by re-attaching the disks to it and give a new instance the old identity. This ensures that the instance’s data is retained with zero storage downtime.

## How do I set it up?

On Kubernetes, when generating the spec using https://install.portworx.com, the UI will prompt for the disk specs in the cloud section of the wizard.

Based on the cloud platform, you will need to provide access to Portworx to the cloud APIs. Continue to below sections for additional details.