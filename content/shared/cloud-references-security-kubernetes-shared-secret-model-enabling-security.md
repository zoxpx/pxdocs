---
title: "Enable security in Portworx"
keywords: authorization, portworx, security, rbac, jwt
hidden: true
---


This document guides you through enabling Portworx Security in your cluster by adding a single flag to your `StorageCluster` object.

## Prerequisites

* You must have Portworx Operator 1.4 or greater 

## Overview

The Operator includes first-class support for Portworx Security in the `StorageCluster` spec. This means that the operator will auto-generate the following for you if security is enabled:

* Shared Secret stored under the secret `px-shared-secret`
* Admin token stored under the secret `px-admin-token` 
* User token stored under the secret `px-user-token`

### Enabling Security in your cluster

1. Enable security under `spec.security` of your StorageCluster:

    ```text
    apiVersion: core.libopenstorage.org/v1
    kind: StorageCluster
    metadata:
      name: portworx
      namespace: kube-system
    spec:
      image: portworx/oci-monitor:2.6.0.1
      security:
        enabled: true
    ```

2. You can now apply the StorageCluster spec and wait until Portworx is ready. 

Once you've enabled security in Portworx, continue to the next section.
