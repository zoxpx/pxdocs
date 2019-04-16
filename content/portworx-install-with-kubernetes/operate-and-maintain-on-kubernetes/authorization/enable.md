---
title: Enabling Authorization
description: Enable Portworx authoriztion in Kubernetes
keywords: portworx, kubernetes, security, authorization, jwt, shared secret
weight: 100
series: k8s-op-maintain-auth
---

Before proceeding with this installation, please review the
[Security](/concepts/authorization) model used by Portworx.

## Enabling authorization
{{<info>}}
The following will be a cluster level interruption event while all the
nodes in the system come back online with security enabled
{{</info>}}

To enable authorization you must simply edit your Portworx `yaml` configuration
to add the appropriate information. You must first create a Kubernetes Secret
which holds the values of the environment variables. Then populate the
environment variables required from your Secret. Here is an example of how to
setup an environment variable from a Secret:

* Create a secret:

```text
kubectl create secret generic mysecret \
  --from-literal=system-secret='RmlqRSfh9'
```

* Then we can access the key as follows:

```text
...
  - name: "PORTWORX_AUTH_SYSTEM_KEY"
    valueFrom:
      secretKeyRef:
        name: mysecret
        key: system-key
...
```

### Example
The following example shows how to enable Portworx authorization to verify
self-signed tokens. The example uses a shared secret to validate tokens from an
issuer called `myissuer`.

* Save the sensitive information in a secret

```text
kubectl create secret generic mysecret \
  --from-literal=system-secret='RmlqRSfh9' \
  --from-literal=shared-secret='hnuiUDFHf' \
  --from-literal=stork-secret='hn23nfsFD'
```

* The Portworx `yaml` configuration would look like this:

```text
...
  name: stork
  env:
    - name: "PX_SHARED_SECRET"
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: stork-secret

...
  name: portworx
  args:
  [..."--jwt-issuer", "myissuer", ...]
  env:
    - name: "PORTWORX_AUTH_JWT_SHAREDSECRET"
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: shared-secret
    - name: "PORTWORX_AUTH_SYSTEM_KEY"
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: system-key
    - name: "PORTWORX_AUTH_STORK_KEY"
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: stork-secret
...
```

You will now need to apply the change to update the stork Deployment and the
Portworx DaemonSet. Wait until the update is complete and all pods are ready
with `1/1`.
