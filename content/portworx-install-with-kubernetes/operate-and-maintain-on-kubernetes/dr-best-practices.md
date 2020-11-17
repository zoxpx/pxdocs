---
title: Portworx Disaster Recovery
hidden: true
keywords: disaster recovery, disaster proof, site failure, node failure, power failure, application error, kubernetes, k8s
description: Disaster Recovery Best Practices for Production Deployments.
---

{{< pxEnterprise >}} comes with many data services features that enable production customers to deploy containerized workloads through many container orchestrators.

This page describes how to configure Portworx for high availability and disaster recovery so customers can easily recover from site-wide failures.

Following are some of the recommended best practices for disaster-preparedness and recovery.

### Recovering application data in Portworx volumes

#### Protecting against node failures

Portworx supports replicated volumes where a given volume's data can be replicated up to 3 copies (including the local copy). For applications that need to be highly available and resistant to any failure in the node (CPU failure, Memory failure, Drive Failure, Kernel Crash, Node Power Loss), {{<companyName>}} recommends customers deploy applications on replicated volumes. Volumes with replication factor as two is generally recommended. Volumes with replication factor set as three can be used for maximum availability. See [here](/concepts) for more information on how to configure volumes with replication via `pxctl`.

You can also refer to the page of container orchestrator of your choice to see how you can pass this inline in Kubernetes, DC/OS or Docker SWarm/UCP when a container using Portworx volumes gets mounted via these orchestrators. Go [here](./) for more information.

Also, the case of deployment in on-prem datacenters, Portworx can take in the rack id parameter and place the replicas across racks to tolerate rack power failures. Please refer [here](/concepts/update-geography-info) to learn how to set this up.

#### Recovering data from application errors

* Always ensure Portworx volumes are enabled with snapshot schedules so each volume is periodically snapshotted. {{<companyName>}} recommends setting up an hourly snapshot schedule. Follow this page to see how to setup a [snapshot schedule](/reference/cli/snapshots)

* The scheduled snaps have a five snapshot limit and they roll-over
* If the user wishes to retain more snapshots, then the snapshots can be scripted via the `pxctl snap` commands and the user can take up to 64 snapshots per volume. In this case, the older snapshots will have to be manually deleted. Visit [snapshots](/reference/cli/snapshots) for learning more about snapshots.

#### Recovering data from cluster failures

* Portworx can periodically upload snapshots to cloud provider of choice, roll up all the snaps up and import that as a volume in the same Portworx cluster or another Portworx cluster. More information about Cloudsnaps is documented [here](/reference/cli/cloud-snaps)
* {{<companyName>}} recommends setting up Cloudsnaps atleast once a day and configure the snaps to be uploaded to a cloud provider or a object store that supports S3 protocol. Portworx current supports AWS S3, Azure Blob Store and Google Drive as the cloudstorage providers.
