---
title: Stateful applications
weight: 3
keywords: portworx, kubernetes, PVCs
description: Learn essential concepts about running stateful applications using persistent volumes on Kubernetes
---

When working on stateful applications on Kubernetes, users typically deal with Deployments and Statefulsets.

## Deployments

A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)) is the most common controller provides declarative way to manage your pods.

You describe a desired state in a Deployment object, and the Deployment controller changes the actual state to the desired state at a controlled rate.

## Statefulsets

A [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

A StatefulSet operates under the same pattern as any other Controller. You define your desired state in a StatefulSet object, and the StatefulSet controller makes any necessary updates to get there from the current state.

Elasticsearch, Kafka, Cassandra etc are examples of distributed systems that can take advantage of StatefulSets.
