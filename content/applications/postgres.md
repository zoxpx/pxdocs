---
title: PostgreSQL
description: PostgreSQL Reference Architecture - Deploying Postgres with Portworx
keywords: portworx, postgres, database, reference
hidden: false
hidesections: true
disableprevnext: true
---

PostgreSQL, often called Postgres, is an open source object-relational database system. It is very popular, with a proven architecture and a robust feature set offering reliability and extensibility. It is often referred to as a cloud-native database, meaning it works very well in containerised environments. You can read more on the PostgreSQL website - [https://www.postgresql.org/about/](https://www.postgresql.org/about/).

When deployed in a container platform such as Kubernetes, it is often deployed as a statefulset, with each pod requiring a container volume. Postgres is often deployed using manifests or using a [Helm Chart](https://github.com/helm/charts/tree/master/stable/postgresql).

## Benefits of PostgreSQL with Portworx
Why do you need to run PostgreSQL with Portworx? There are two areas you should consider. Firstly, providing container volumes that meet enterprise storage requirements. Secondly, the lifecycle of PostgreSQL in multi-cluster / cloud / environment deployments.

- Portworx can **simplify your Postgres architecture** by providing rapid, in-cluster failover, without the need for many Postgres instances.
- Portworx provides in-cluster and off-site snapshots allowing you to **protect your Postgres data** with container volume granularity.
- 


