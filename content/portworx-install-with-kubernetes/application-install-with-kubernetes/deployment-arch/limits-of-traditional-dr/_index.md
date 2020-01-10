---
title: The limits of traditional DR for Kubernetes applications
linkTitle: The limits of traditional DR
description: The limits of traditional DR for Kubernetes applications
keywords: Portworx, stateful applications, Kubernetes, k8s, deployment, architecture, HA, high-availability, DR, disaster recovery
weight: 3
---

Traditional backup and restore solutions for applications are implemented at the virtual machine (VM) level. This works when a single application runs on a single VM. Backing up the VM is synonymous with backing up the application. Containerized applications like those that run on Kubernetes, however, are much different. A single VM runs many pods, and not all of these pods are part of the same application. Likewise, a single application is spread over many VMs. This distribution of application components over a cluster of servers is the basic architectural pattern for containerized applications, so it is easy to see why backing up a VM is no longer sufficient. Backing up a VM proves both too much and too little data for effective disaster recovery. If I want to back up App 1, my VM backup might contain data for App 2 and App 3 as well. On the other hand, even if I backup the entire server, parts of App 1 are running on different VMs that are not captured by a single VM-based backup.

To solve this problem, DR for Kubernetes requires a solution that is:

* Container-granular
* Kubernetes namespace-aware
* Application consistent
* Capable of backing up data AND application configuration
* Optimized for your data center architecture with synchronous and asynchronous options

Portworx provides all this with PX-DR.

## Container-granular DR for Kubernetes

PX-DR is a container-granular approach to DR. That is, instead of backing up everything that runs on a VM or bare metal server, it gives users the ability to backup specific pods or groups of pods running on specific hosts.

In the below diagram, we see a three-node Kubernetes cluster with a three-node Cassandra ring and three individual MySQL databases.

![Container-granular DR for Kubernetes](/img/deployment-architectures-container-granular-dr-for-kubernetes-1.png)

With PX-DR we can zero in on just the pods that we want to back up. For instance, we can back up just the three-node Cassandra ring or just one of the MySQL databases. By offering container-granularity, we avoid costly and error-prone ETL procedures that would be required if we backed up all three VMs in their entirety. By only backing up the specific applications desired, we minimize storage costs and keep recovery time objectives (RTO) low.

![Container-granular DR for Kubernetes](/img/deployment-architectures-container-granular-dr-for-kubernetes-2.png)

## DR for an entire Kubernetes namespace

The concept of container-granularity can be extended to entire namespaces. Namespaces within Kubernetes typically run multiple applications that are related in some way. For instance, an enterprise might have a namespace dedicated to a particular division.  Often, we want to back up the entire namespace, not just a single application running in that namespace. Traditional backup solutions run into the same problems outlined above. Namespaces bridge VM-boundaries. PX-DR gives you the ability to back up entire namespaces, no matter where the namespace’s pods run.

## Application-consistent backups for Kubernetes

PX-DR is also application consistent. Take the above example of three Cassandra pods in a distributed system. Snapshotting them in a way that allows for application recovery without risk of data corruption requires that all pods remain locked during the snapshot operation. VM-based snapshots cannot achieve this. Nor can serially-executed individual snapshots. Portworx provides a Kubernetes group snapshot rules engine that allows operators to automatically execute the pre- and post- snapshot commands required for each particular data service. For Cassandra, for instance, we must run the `nodetool flush` command to take an application-consistent snapshot of multiple Cassandra containers.

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Rule
metadata:
  name: cassandra-presnap-rule
spec:
  - podSelector:
      app: cassandra
    actions:
    - type: command
      value: nodetool flush
```

## Backing up data AND application configuration for Kubernetes applications

We’ve now established the importance of container-granularity, namespace awareness, and application-consistent backups. Now, let’s look at why DR for Kubernetes requires a solution for both data and application configuration.

Backing up and recovering an application on Kubernetes requires two things: data and configuration. If we only backup the data, then recovering our application will take a long time, because we will have to rebuild the application configuration in place, increasing RTO. If we only backup the app config– all those `YAML` files that define our deployments, our service accounts, our PVCs– then we can spin up our application, but we won’t have our application data. Neither is sufficient. PX-DR captures both application configuration and data in a single Kubernetes command, making recovering our Kubernetes application after a failure as easy as scaling up the application pods in the DR site.

![Backing up data AND application configuration for Kubernetes applications](/img/deployment-architectures-backing-up-data-and-application-configuration-for-k8s-apps.png)
