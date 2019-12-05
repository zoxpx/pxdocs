---
title: Securing with a shared secret
description: Simple security setup using shared secrets and leveraging user authentication observed by Kubernetes
keywords: portworx, kubernetes, security, jwt, secret
weight: 10
series: ra-kubernetes-security
---

The following reference architecture describes how to setup Portworx security
to authenticate PVC requests from Kubernetes. This model leverages Kubernetes
user authentication, which secures access to Namespaces, Secrets, and
PersistentVolumes. With access already provided and secured by Kubernetes,
this reference architecture provides a model to secure the communication
between Kubernetes and Portworx. Securing Portworx also protects the storage
system from unwanted access from outside Kubernetes.

The following is based on Portworx 2.1.x+ with security.
