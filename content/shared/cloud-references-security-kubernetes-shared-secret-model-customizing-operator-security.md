---
title: "Customize Security in Portworx"
keywords: authorization, portworx, security, rbac, jwt
hidden: true
---

This optional document guides you through customizing your Portworx Operator Security install to fit specific needs.

## Prerequisites

* Portworx Operator 1.4 or later
* Portworx Security enabled

### Add a custom issuer, shared secret, and tokenLifetime to your StorageCluster

Add your issuer, tokenLifetime, and sharedSecret Kubernetes secret name to the `spec.security.auth.selfSigned` object in your StorageCluster:

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: px-cluster
  namespace: kube-system
spec:
  security:
    enabled: true
    auth:
      selfSigned:
        issuer: "portworx.com"
        sharedSecret: "px-shared-secret"
        tokenLifetime: "1h"
```

### Disable guest role access

Starting with Portworx 2.6.0 and later, the [system guest role](/concepts/authorization/overview#guest-access) is enabled by default. To turn off this feature, you can disable it in the StorageCluster spec:

{{<info>}}
**NOTE:** Once the guest role is disabled, volumes created without a token will not be accessible without a token.
{{</info>}}

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: px-cluster
  namespace: kube-system
spec:
  security:
    enabled: true
    auth:
      guestAccess: 'Disabled'
```



### Managing the guest role yourself
You can exercise finer control over the system.guest role by setting it `managed` mode. This instructs the Operator to stop updating the [system guest role](/concepts/authorization/overview#guest-access), allowing you to [customize it yourself](/reference/cli/role/#re-enabling-the-system-guest-role).

To enter `managed` mode, set the value of the `spec.security.auth.guestAccess` field to `managed`:

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: px-cluster
  namespace: kube-system
spec:
  security:
    enabled: true
    auth:
      guestAccess: 'Managed'
```

### Increasing token lifetime

Additionally, JWT token lifetime can be specified. The operator will generate a token with this token lifetime and refresh it for the user accordingly. 

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: px-cluster
  namespace: kube-system
spec:
  security:
    enabled: true
    auth:
      tokenLifetime: '4h'
```

