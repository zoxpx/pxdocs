---
title: Synchronous DR for Kubernetes
linkTitle: Metro DR
keywords: Synchronous DR, disaster recovery, kubernetes, k8s, cloud, backup, restore, snapshot, migration
description: How to achieve DR across two Kubernetes clusters spanning a Metropolitan Area Network (MAN)
weight: 1
---

Portworx supports synchronous DR when installed as a single stretch cluster across multiple Kubernetes clusters. The Kubernetes clusters need to span across a metropolitan area network with a maximum latency of 10ms.
This document explains how to install such a stretch Portworx cluster and achieve synchronous DR. It will demonstrate how to failover and failback applications between two Kubernetes clusters.
Here are the steps you should follow:
