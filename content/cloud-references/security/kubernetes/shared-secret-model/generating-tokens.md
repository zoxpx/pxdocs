---
title: Generating tokens
description: A reference architecture to support Multitenancy with Portworx and CSI
keywords: portworx, security, ownership, tls, rbac, claims, jwt, oidc
weight: 30
series: ra-shared-secrets-model
---

Now that the system is up and running you can create tokens. You will need to
ssh to one of the nodes to use `pxctl` to generate tokens.

{{<info>}}
If you want to create your own application to generate tokens, you
can base it on our open source golang example library [openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth)
{{</info>}}

### Creating user files

You will need to create at least two user files. These files are used as
inputs to [`pxctl`](/reference/cli/authorization/#generate_tokens)
to create tokens. One will be the storage admin token used for `pxctl` to
communicate with Portworx, and the second will be for Kubernetes to
provision and manage volumes.

Create a file with the following information for the storage admin. The
storage admin is a special user token (like `root` in Linux) which has
access to all APIs and all resources as specified in the [documentation](/concepts/authorization/overview/#the-administrator-role).
In this example, you can call this file `admin.yaml`.

```yaml
name: Storage Administrator
email: the email of the storage admin
sub: ${uuid} or email of the storage admin
roles: ["system.admin"]
groups: ["*"]
```

{{<info>}}
The `sub` is the unique identifier for this user and most not be shared amongst
other tokens according to the JWT standard. This is the value used by Portworx
to track ownership of resources. If `email` is also used as the `sub` unique
identifier, please make sure it is not used by any other tokens.

More information on the rules of each of the value can be found on the
[openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth#usage) repo.
{{</info>}}

Now create a file for Kubernetes to communicate with Portworx. You can call
this file `kube.yaml`:

```yaml
name: Kubernetes User
email: the email of the kubernetes admin
sub: ${uuid} or email of the kubernetes admin
roles: ["system.user"]
groups: ["kubernetes"]
```

### Saving the tokens

Now you can create a tokens. Notice in the example below that we have set the
issuer to match the setting in the Portworx manifest to `portworx.com` as set
the value for `-jwt-issuer`. The example also sets the duration of the token
to one year. You may want to adjust it to a much shorter duration if you plan
on refreshing the token often.

The example below sets creates an admin token which is then output to the screen.
You will also need to have the _shared secret_ created above. In the example below,
the secret is saved in the environment variable `$PORTWORX_AUTH_SHARED_SECRET`.

```
/opt/pwx/bin/pxctl auth token generate \
  --auth-config=admin.yaml \
  --issuer=portworx.com \
  --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
  --token-duration=1y
```

With the admin token, you can now create a context for `pxctl` which will be
saved in `$HOME/.pxctl` of the node. For more information please
see [Context](/reference/cli/authorization/#context).

In the example below, the admin token is saved as the context `admin`:

```
/opt/pwx/bin/pxctl context create admin \
  --token=ey...3d
```

Now, you can also generate the token for Kubernetes:

```
/opt/pwx/bin/pxctl auth token generate \
  --auth-config=kube.yaml \
  --issuer=portworx.com \
  --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
  --token-duration=1y
```

This token will be used by Kubernetes for Portworx volume management
calls. You will need to save this token as a Kubernetes secret.
In the example below, it saves it as `portworx/px-k8s-user`:

```
kubectl -n portworx create secret generic px-k8s-user --from-literal=auth-token=ey...f3
```

Kubernetes storage classes can now be setup to use this secret to
get access to the token to communicate with Portworx.

{{<info>}}
If you want to can also add this token to the `pxctl` context so that
you can switch users running commands to Portworx.
{{</info>}}