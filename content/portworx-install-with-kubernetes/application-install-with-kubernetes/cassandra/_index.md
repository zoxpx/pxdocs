---
title: Cassandra with Portworx on Kubernetes
linkTitle: Cassandra
keywords: install, cassandra, kubernetes, k8s, scaling, failover, statefulset, headless service
description: Deploy Cassandra with Portworx on Kubernetes.
weight: 1
aliases:
  - /scheduler/kubernetes/cassandra-k8s
  - /scheduler/kubernetes/cassandra-k8s.html
---

This reference architecture document shows how you can deploy Cassandra, a distributed NoSQL database management system, with Portworx on Kubernetes. You will install Cassandra as a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/), which requires a headless service to provide network identity to the Pods it creates. Note that a headless service does not require load balancing and a single cluster IP address. For more details about headless services, see the [Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) section of the Kubernetes documentation.

The following diagram shows the main components of a Cassandra with Portworx deployment running on top of Kubernetes:

![cassandra-with-portworx-on-kubernetes](/img/cassandra-with-portworx-on-kubernetes.png)

