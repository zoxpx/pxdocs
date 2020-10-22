---
title: Secure your storage with a DaemonSet
description: Simple security setup using shared secrets and leveraging user authentication observed by Kubernetes
keywords: portworx, kubernetes, security, jwt, secret, sharedsecret
weight: 10
series: ra-kubernetes-security
---

# Overview

Kubernetes provides a great authentication model for its users, but storage
systems could be exposed to malicious requests. Portworx Security provides a
method to protect against such requests, further providing deployers with a complete secured system.

The following reference architecture describes how to setup Portworx security
to authenticate PVC requests from Kubernetes. This model leverages Kubernetes
user authentication, which secures access to Namespaces, Secrets, and
PersistentVolumes. With access already provided and secured by Kubernetes,
this reference architecture provides a model to secure the communication
between Kubernetes and Portworx. Securing Portworx also protects the storage
system from unwanted access from outside Kubernetes.

Perform the steps in the following sections to set up PX-Security according to this reference architecture:

# Prerequisites

* You must be running Portworx version 2.1 or greater on Kubernetes
* You must have the PX-Security feature enabled
