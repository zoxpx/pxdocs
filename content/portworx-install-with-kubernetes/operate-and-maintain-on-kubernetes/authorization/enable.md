---
title: Enabling Authorization
description: Enable Portworx authorization in Kubernetes
keywords: authorization, security, kubernetes, k8s
weight: 100
series: k8s-op-maintain-auth
---

Before proceeding with this document, please review the [Security](/concepts/authorization) model used by Portworx.

{{<info>}}
For a step by step setup of guide of how to enable Portworx authorization, please see
[Securing your Portworx system](/cloud-references/security/).
{{</info>}}

## Enabling authorization
{{<info>}}
The following will be a cluster level interruption event while all the
nodes in the system come back online with security enabled.
{{</info>}}

To enable authorization you must simply edit your Portworx `yaml` configuration
to add the appropriate information. You must first create a Kubernetes Secret which holds the values of the environment variables. Then populate the environment variables required from your Secret. Here is an example of how to
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
        key: system-secret
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
  [..."-jwt_issuer", "myissuer", ...]
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
          key: system-secret
    - name: "PORTWORX_AUTH_STORK_KEY"
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: stork-secret
...
```

You will now need to apply the change to update the Stork deployment and the Portworx DaemonSet. Wait until the update is complete and all pods are ready
with `1/1`.


## Upgrading to Authorization enabled

Prior to 2.6, users must be certain that all [PVCs have user tokens secrets](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/manage) associated with them. If this is not the case, Kubernetes users will not be able to use any Portworx PVCs or create new ones. This means that in order to upgrade to `auth enabled` without any disruption, the admin must add token secrets to all PVCs.

Starting with Portworx 2.6+, upgrading from `auth disabled` to `auth enabled` will not cause any issues for Kubernetes end users. This is because the [system guest role](/concepts/authorization/overview#guest-access) will allow Kubernetes users to create and use [public volumes](/concepts/authorization/overview#public-volumes). However, users are encouraged to make their volumes private by adding authorization to their PVCs.

Once the admin has ensured all necessary volumes are private and users are comfortable with PX Security, the [guest role may be disabled](/reference/cli/role/#disabling-the-system-guest-role) to tighten security even further.
