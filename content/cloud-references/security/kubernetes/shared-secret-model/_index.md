---
title: Securing with a shared secret
description: Simple security setup using shared secrets and leveraging user authentication observed by Kubernetes
keywords: portworx, kubernetes, security, jwt, secret
weight: 10
series: ra-kubernetes-security
---

The following describes how to setup Portworx security and authenticating Kubernetes as a client to Portworx. This model leverages user authentication executed by Kubernetes, then has secures the communication between Kubernetes and Portworx. This model protects the storage system from unwanted access from outside Kubernetes.

The following is based on Portworx 2.1.x+ with security.
