---
title: Multitenancy using namespaces
description: Multitenancy support in Kubernetes using namespace secrets to store tokens for tenants
keywords: portworx, multitenancy, kubernetes, sharedsecret
weight: 20
series: ra-kubernetes-security
---

# Overview

Kubernetes provides a great way to isolate account resources using
namespaces, but you may want a more secure multitenant solution. Portworx
can greatly enhance the multitenant model by providing resource access
control for application volumes.

The following reference architecture provides a model where volume access
is authenticated using tokens stored in the secret of the namespace of the
tenant.

{{<info>}}
**NOTE:** This solution is currently supported in **CSI** only.
{{</info>}}

# Prerequisites

* You must be running Portworx version 2.1 or greater on Kubernetes
* You must have the PX-Security feature enabled
* You must have CSI enabled
