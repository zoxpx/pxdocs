---
title: Portworx instructional videos
keywords: portworx, learning, lightboard
description: Learn about Portworx by watching informational Lightboard sessions.
weight: 2
linkTitle: Portworx instructional videos
series: kb
noicon: true
aliases:
  - /reference/knowledge-base/lightboard-sessions/
---

The following is a series of easy to digest lectures about Portworx. Videos are produced with a lightboard which offers a unique and clear perspective for users to learn about Portworx.

## Why Portworx

This short video will explain the Portworx value proposition along with some of the differentiating features such as data mobility, application awareness and infrastructure independence.

{{< youtube  dYPS_FgyXnI >}}

#### Resources

 - https://portworx.com/
 - [Intro to Portworx Platform](https://www.youtube.com/watch?v=SCuKEUCzDv0&t=1s)
 - [Aurea cost savings architects corner](https://portworx.com/architects-corner-aurea-beyond-limits-amazon-ebs-run-200-kubernetes-stateful-pods-per-host/)


## Portworx 101

Learn the basics of Portworx and how it can enable your stateful workloads. This video will discuss the largest fragments of the Portworx platform and how it creates a global namespace to enable virtual volumes for containers.

{{< youtube  AxCmtQcxJFo >}}

#### Resources

 - [Portworx Interactive Tutorials](/interactive-tutorials/)

## Understanding Storage Pools

Portworx achieves mobility for applications by dynamically managing pools of storage across a cluster of nodes. In this short video, learn how Portworx clusters infrastructure together into classified storage resource pools for applications.

{{< youtube  wlYIOrNGG6M >}}

#### Resources

 - [Class of Service Docs](/concepts/class-of-service/#explanation-of-class-of-service)

## Deployment Modes (Hyperconverged, Disaggregated)

Portworx deploys it’s full stack of software in a linux container. In this short video you will learn the two main deployment modes in which Portworx can be installed on your infrastructure.

{{< youtube  1ht17KDzn1s >}}

#### Resources

 - [Deployment Architectures Docs](/cloud-references/deployment-arch)
 - [Hyperconvergence Docs](/portworx-install-with-kubernetes/storage-operations/hyperconvergence/)

## Deploying Portworx on Kubernetes

In this video, learn how Portworx runs on any distribution of Kubernetes and what components are involved.

{{< youtube  qcTXGsYFbzQ >}}

#### Resources

 - [Install with Kubernetes](/portworx-install-with-kubernetes/)
 - [Try Installing Portworx on Kubernetes yourself](https://www.katacoda.com/portworx/scenarios/deploy-px-k8s)
 - [Access Kubernetes Spec Generator in PX-Central](https://central.portworx.com/)

## Understanding Volume Replication

 In this video, learn how Portworx provides high availability to your data rich application and how it does this by providing synchronous replication at the volume granular level.

{{< youtube  e82JoG7537I >}}

#### Resources

 - [Topology Info for Replication Placement Docs](/concepts/update-geography-info/)
 - [Dynamic Provisioning Parameters](/portworx-install-with-kubernetes/storage-operations/create-pvcs/dynamic-provisioning/)
 - [Example deploying MySQL with Portworx Replication](https://www.katacoda.com/portworx/scenarios/px-mysql)

## Volume snapshot types

Learn how Portworx provides data protection with snapshots. This short video will talk about the different types of snapshots available from Portworx for stateful applications.

{{< youtube  t2GMFIh_Vb4 >}}

#### Resources

 - [Snapshots Docs](/reference/cli/snapshots/)
 - [Create Snapshots on Kubernetes Docs](/portworx-install-with-kubernetes/storage-operations/create-snapshots/)
 - [Cloud Snapshots Docs](/reference/cli/cloud-snaps/)

## What is RTO and RPO

Understanding Recovery Time Objects (RTO) and Recovery Point Object (RPO) is vital for disaster recovery planning. Check out this short video to get a quick understanding of RTO and RPO and how Portworx solutions can help you.

{{< youtube  PwSI2sE5JoM >}}

#### Resources

 - [Disaster Recovery Configuration with Kubernetes Docs](/portworx-install-with-kubernetes/disaster-recovery/)
 - [RPO and RTO Blog](https://portworx.com/kubernetes-data-management-perspective-understanding-rto-rpo/)
 - [Zero PO Disaster Recovery Blog](https://portworx.com/achieving-zero-rpo-disaster-recovery-kubernetes/)

## Portworx Disaster Recovery

Disaster Recovery is a critical component of every data management solution. In this short video, learn about the disaster recovery solutions available from the Portworx platform.


{{< youtube  btEUzUYnHkY >}}

#### Resources

 - [Portworx Disaster Recovery Docs](/portworx-install-with-kubernetes/disaster-recovery/)
 - [Portworx Synchronous Disaster Recovery](/portworx-install-with-kubernetes/disaster-recovery/px-metro/)
 - [Portworx Asynchronous Disaster Recovery](/portworx-install-with-kubernetes/disaster-recovery/async-dr/)

## What are Shared Volumes

Shared volumes or volume shares allow multiple readers and writers for applications such as Wordpress and content management systems. In this video, get a better understanding of the different between ReadWriteOnce and ReadWriteMany.

{{< youtube  kYPSS4v34Pg >}}

#### Resources

 - [Portworx Shared Volumes Docs](/concepts/shared-volumes/)
 - [Portworx Shared volumes on Kubernets Tutorial](https://www.katacoda.com/portworx/scenarios/px-k8s-vol-shared)
 - [CLI Reference for Shared Volumes](/reference/cli/create-and-manage-volumes/#the-global-namespace)

## Capacity Management (AutoPilot)

Capacity management is a key aspect for application development and in complex microservices environments may mean manually resizing or editing the available disk space which to your application which can be tedious and complex. In this video you will learn about AutoPilot, which is a tool from Portworx that can automatically manage capacity of PVCs based on metrics available from Prometheus without any manual intervention or downtime.

{{< youtube  aIvEWYNPsD8 >}}

#### Resources

 - [Portworx Capacity Management Docs](/portworx-install-with-kubernetes/autopilot/)
 - [Portworx Capacity Management Reference](/portworx-install-with-kubernetes/autopilot/reference/)
 - [CockroachDB Demo](https://www.youtube.com/watch?v=vCnUczaSXDA)

## Introduction to Portworx on Red Hat Openshift

In this lightboard session viewers will learn the basics of running Potworx on OpenShift. Viewers will learn what resources Portworx consumes and requires as well as how to get started with container-granular dynamic provisioning for databases. Stay tuned for a follow up on Day 2 operations such as auto-scaling PVCs, Storage Pools, Backup & Restore and Disaster Recovery for Openshift.

{{< youtube  Bngko7corc0 >}}

#### Resources

 - [Install Portworx on OpenShift](/portworx-install-with-kubernetes/on-premise/openshift/)

## Data Locality with Stork (Storage Orchestrator for Kubernetes)

Stork is the Portworx’s storage scheduler for Kubernetes that helps achieve even tighter integration of Portworx with Kubernetes. It allows users to co-locate pods with their data, provides seamless migration of pods in case of storage errors and makes it easier to create and restore snapshots of Portworx volumes. In this video, we’ll explore how stork enables colocation of pods and their data.

{{< youtube  hoS6HUQMnB0 >}}

#### Resources

 - [Introducing STORK: Intelligent Storage Orchestration for Kubernetes](https://portworx.com/stork-storage-orchestration-kubernetes/)
 - [Using Stork with Portworx](/portworx-install-with-kubernetes/storage-operations/stork/)

## Application Aware Snapshots using Pre and Post Rules

Portworx supports specifying pre and post rules that are run on the application pods using the volumes being snapshotted. This allows users to quiesce the applications before the snapshot is taken and resume I/O after the snapshot is taken. We’ll walk through this workflow for configuring 3DSnaps involving creating rules and referencing the rules when creating the snapshots.

{{< youtube  ARB2cMDqoKQ >}}

#### Resources

 - [Create Pre and Post Rules for Snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/snaps-3d/#step-1-create-rules)

## Understand how PX-Autopilot can be used to automatically add disks to your storage pool

Users use an Autopilot Rule which a CRD within Kubernetes to tell Autopilot which objects to monitor such as the amount of available storage space left for PVCs. Then, based on these objects and their conditions, trigger corresponding actions to perform when conditions occur. We’ll walk through the general flow and architecture of how this works in this session.

{{< youtube  Jd1Teas-nAU >}}

#### Resources

 - [Working with AutoPilot Rules](/portworx-install-with-kubernetes/autopilot/how-to-use/working-with-rules/)

## Learn about Volume Placement Strategies like Volume Affinity and Anti-Affinity

When you provision volumes, Portworx places them throughout the cluster and across configured failure domains to provide fault tolerance. While this default manner of operation works well in many scenarios, you may wish to control how Portworx handles volume and replica provisioning more explicitly. You can do this by creating Volume Placement Strategies. In this session, we will talk about a series of rules which control volume and volume replica provisioning on nodes and pools in the cluster based on the labels they have.

{{< youtube  S9j3aJ5lQw0 >}}

#### Resources

 - [Volume Placement Strategies](/portworx-install-with-kubernetes/storage-operations/create-pvcs/volume-placement-strategies/)
 - [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

## Configuring your storage cluster

Configuring Portworx storage takes into account a number of different options. General options are available for types or storage, where the key-store is, what type of scheduler to use, what backing disk will be used, enabling security and much more. In this video, we will walk through some of the widely used options for configuring your Portworx storage cluster and common considerations when planning your Portworx deployment.

{{< youtube aPrjEa4FX3g >}}

## Redirect-on-Write Snapshots

Portworx snapshots are redirect-on-write snapshots and are thin clones. In this video, we’ll walk through what it means for snapshots to be “redirect-on-write” and how this compares to other common practices such as copy-on-write and why it helps improve overall performance of Portworx volumes.

{{< youtube _Bw9jgULnm8 >}}

## Topology Awareness

Portworx nodes can be made aware of the rack on which they are a placed as well as the zone and region in which they are present. Portworx can use this information to influence the volume replica placement decisions. You can also provide your cluster topology information to Portworx using Kubernetes node labels and this video will explain how these labels are used for replica placement.

{{< youtube Csr8HNi4nRw >}}

## Management and Visibility with PX Central On-prem

PX-Central is a graphical user interface that allows you to monitor and manage your Portworx clusters on-premises or in the cloud. In this lightboard we will walk through the differences with the SaaS version and explain the variations of what you can accomplish using PX Central.

{{< youtube Mr_mWdfpyHg >}}

## Overview of Backup and Recovery for Kubernetes

In this video, get an overview of PX-Backup, the backup and recovery solution for Kubernetes from Portworx. PX-Backup installs into Kubernetes clusters just like Portworx does today, and this makes the addition of the backup and restore service completely Kubernetes-native for the end user. Once the PX-Backup pods come online, you are ready to start backing up and restoring applications and data.

{{< youtube Nf1thpqqlWw >}}

## Portworx Essentials vs Portworx Enterprise

Select the best Portworx Enterprise Storage for you. In this video we’ll explain the differences between Portworx Essentials and Enterprise and when you would want to use one over the other.

{{< youtube z5KHbQJvHdc >}}

## Local High Availability, Backup & Restore and Disaster Recovery

Local High Availability, Backup and Restore, and Disaster Recovery are three capabilities that are the foundation of any enterprise data protection program and they are the essential elements to consider when evaluating a Kubernetes backup tool or solution. 

{{< youtube 2EjFYjUU1jc >}}

## Storage Policies for Volume Provisioning

Storage policies allow users to manage the storage policies of the Portworx cluster. Once defined, a storage policy ensures that the volumes being created on the Portworx cluster follow the same set of common specs/rules. This video will give an overview of how storage policies can be used and how Kubernetes environments can reference them within a StorageClass.

{{< youtube r-jWev8Lh60 >}}

## Monitoring and Logging for Kubernetes

Portworx runs as a DaemonSet on the Kubernetes cluster which ensures that it runs on each node as part of the Kubernetes cluster. To allow access to the logs of a failed node, pod or a container in Kubernetes we would have to adopt a complete logging solution. The need to access or view logs of failed container workloads means that we would need to enable storage and the logs should have a separate life cycle than that of the container that creates it. Elasticsearch, FluentD and Kibana allow us to setup a complete logging solution for accessing logs of the Portworx pods scheduled on the Kubernetes cluster.

{{< youtube EnNK03EZrSM >}}
