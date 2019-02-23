---
title: Portworx VMware shared architecture
description: Portworx VMware shared architecture
keywords: portworx, VMware, vSphere ASG
hidden: true
---

Below diagram gives an overview of the Portworx architecture on vSphere using shared datastores.

* Portworx runs as a Daemonset hence each Kubernetes minion/worker will have the Portworx daemon running.
* Based on the given spec by the end user, Portworx on each node will create it's disk on the configured shared datastore(s) or datastore cluster(s).
* Portworx will aggregate all of the disks and form a single storage cluster. End users can carve PVCs (Persistent Volume Claims), PVs (Persistent Volumes) and Snapshots from this storage cluster.
* Portworx tracks and manages the disks that it creates. So in a failure event, if a new VM spins up, Portworx on the new VM will be able to attach to the same disk that was previously created by the node on the failed VM.

![Portworx architecture for PKS on vSphere using shared datastores or datastore clusters](/img/pks-vsphere-shared.png)