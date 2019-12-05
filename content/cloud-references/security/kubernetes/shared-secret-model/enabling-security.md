---
title: Installing Portworx with Security
description: A reference architecture to support Multitenancy with Portworx and CSI
keywords: portworx, security, ownership, tls, rbac, claims, jwt, oidc
weight: 20
series: ra-shared-secrets-model
---

If you do not already have a manifest, please go to [PX-Central](https://central.portworx.com)
to generate and download a deployment yaml for your configuration. 
You will then need to edit the Portworx manifest yaml file as shown in
the [example](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/enable/#example).

This is necessary to instruct Kubernetes to create and provide Portworx with
environment variables whos values are retreived securely from the Secret object
created above.

When you edit the file, please use the checklist below assert that all the
have been done:

1. Stork shared key needs to be added to stork and to Portworx as shown in the [documentation](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/enable).
1. System key needs to be added to Portworx
1. Shared key needs to be added to Portworx
1. The Token issuer value needs to be added. The issuer is a string value which must identify the token generator. The token generator must set this value in the token itself under the `iss` claim. This value will be used by Portworx to identify the token generator. In this example, the issuer is set to `portworx.com`, but you are encouraged to change it to another name.

The following is an example of the `diff` of the changes to the Portworx manifest:

```diff
170c170
<              "-x", "kubernetes"]
---
>              "-x", "kubernetes", "-jwt_issuer", "portworx.com"]
178c178,192
<             
---
>             - name: "PORTWORX_AUTH_JWT_SHAREDSECRET"
>               valueFrom:
>                 secretKeyRef:
>                   name: pxkeys
>                   key: shared-secret
>             - name: "PORTWORX_AUTH_SYSTEM_KEY"
>               valueFrom:
>                 secretKeyRef:
>                   name: pxkeys
>                   key: system-secret
>             - name: "PORTWORX_AUTH_STORK_KEY"
>               valueFrom:
>                 secretKeyRef:
>                   name: pxkeys
>                   key: stork-secret
```

In the stork section, the Deployment template must have the following

```
>         - name: "PX_SHARED_SECRET"
>           valueFrom:
>             secretKeyRef:
>               name: pxkeys
>               key: stork-secret
```

You can now apply the manifest and wait until Portworx is ready.
