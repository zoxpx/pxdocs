---
title: Role-Based Access Control
weight: 1
hidesections: true
description: Understanding Portworx role-based access control (RBAC)
series: concepts
keywords: portworx, container, storage, security, oidc, jwt, token, rbac
---

PX-Security is a critical component of the Portworx platform that provides:

  - Cluster-wide encryption
  - Namespace-granular or Storage-class BYOK encryption
  - Role-based access control (RBAC) for authorization, authentication, and ownership
  - Support for integration with AD and LDAP. Note that this integration is not available out of the box, but you can implement it through your OIDC solution.

This section describes the role-based access control (RBAC) model used by Portworx.

{{<homelist series="authorization">}}
