---
title: Multitenancy support with a shared secret
description: Multitenancy support in Kubernetes using namespace secrets for tenants
keywords: portworx, kubernetes, security, jwt, secret
weight: 20
series: ra-kubernetes-security
---

# Overview

Kubernetes provides a great way to isolate users using namespaces, but some
deployers want a more secure multitenant solution. While they can secure and isolate
tanants further by securing network access, they require that the storage system
also provide a level of security access to the volumes.

This following reference architecture provides a model where volume requests
are authenticated using tokens stored in the secret of the namespace of the
tenant.

This solution is currently supported in **CSI** only.


# Requirements 

The following reference architecture describes how to setup Portworx security
to support multitenancy in Kubernetes. This model requires that the [Securing
with a shared
secret](/cloud-references/security/kubernetes/shared-secret-model) reference
architecture has been implemented.

