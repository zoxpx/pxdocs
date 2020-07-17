---
title: Preparing To Enhance Security
description: Explains what information is needed when enabling PX-Security
keywords: installation, setup security, RBAC, Role Based Access Control, claims, JWT, JSON Web Token, OIDC, OpenID Connect, self generated
weight: 20
series: authorization
---

To enable PX-Security, you must first determine which source of tokens you will be
using. You can choose to leverage an OIDC provider, use self-signed tokens, or both.
See the [Overview](/concepts/authorization/overview) for details on the pros/cons of
each.

## OpenID Connect (OIDC)

An OpenID Connect (OIDC) service can be used to provide your users with tokens,
which are then be provided to Portworx for verification. Portworx needs to
connect to your OIDC provider to automatically download the public key. This
public key is used to verify that the signature of the JWT is valid.

To connect Portworx to an OIDC you will need the following information from your provider:

* OIDC client-id: This is the client name that has been setup for Portworx at the
  OIDC.
* OIDC issuer: The issuer is the address to the OIDC and *must* match the issuer
  value in the claims of each token generated.

### Mapping groups and roles

Tokens created by OIDC must also have a `groups` and `roles` claim as mentioned
in the [Overview](/concepts/authorization/overview) section. These sections provide
the permissions necessary to access certain APIs and resources.

You may need to configure your OIDC provider to _map_ information about your
users into the `roles` and `groups` section of the JWT token. Please refer to
your OIDC provider documentation on how to map values.

These claims are called _custom_ claims and depending on your OIDC, it may place
custom claims under a namespace.  Portworx supports both un-namespaced and
namespaced `roles` and `groups` in the JWT claims.

For example, an un-namespaced `role` would look as follows:

```json
{
  "roles" : [ "system.admin" ],
  "groups": [ "*" ]
}
```

While a namespaced role using a namespace of `https://myoidc.provider.com/` would
look as follows:

```json
{
  "https://myoidc.provider.com/roles" : [ "system.admin" ],
  "https://myoidc.provider.com/groups": [ "*" ]
}
```

Namespace information (if used) will need to be provided to Portworx as an
initialization parameters, when first enabling PX-Security.

## Self signing tokens

If you are using self-signed tokens, you then need to determine if you will be
using a shared-secret or an RSA or ECDSA public/private key pair.  Creating a
JWT is a standard process and there are many applications and libraries for multiple
languages to generate tokens.  For convenience, Portworx has added support to
[`pxctl`](/reference/cli/authorization/#generate-tokens) to generate tokens.

Self signed tokens must also contain the identifier of the _issuer_. This value
in the JWT claims is set as `iss` and is used by Portworx to determine if the
token is from a trusted token authority.

### Generating a shared secret

If you choose to use a shared secret for your self-signed tokens, here is a simple
way to generate a very secure secret:

```text
cat /dev/urandom | base64 | fold -w 64 | head -n 1
```

### Portworx cluster authorization

When PX-Security is enabled, Portworx itself will generate its own tokens
to securely communication with the cluster. For this reason, you will be asked to
provide a shared secret for the system.

{{<info>}}
This may be replaced by the installer for your container orchestrator.
Please see your container orchestrator authorization installation instructions for more information.
{{</info>}}

## Verification of a token authority

To confirm that a token has the correct information, after creating the token using
your preferred method, copy this token and paste it in [jwt.io](https://jwt.io).
Note the _payload_ section has all the necessary claims to provide the
appropriate permissions. Also note that the `iss`(Issuer), is correct. Portworx will use the value of `iss` to determine if the token comes from a trusted token authority.

Second, you can try out the token on a running Portworx system which has
PX-Security enabled. There are multiple ways to do this. One is to use
[`pxctl context`](/reference/cli/authorization) on a Portworx node. You can then run
a set of commands that confirm the token access. Another way is to use the REST
SDK Gateway by going to `http://<node ip>:9021/sdk` or `https://<node
ip>:9021/sdk` (depending on if TLS has been enabled for your Portworx system).
Once that loads, click on the `Authorize` button, and paste your token.
You can then execute a set of APIs to confirm the token access.

{{<info>}}
If Portworx was custom configured to operate on a different port-range (the default
is 9001-9022), the above default port of `9021` for the SDK REST Gateway will need
to be adjusted to within the new range.

Please consult your Portworx installation if this customization is in effect in your cluster.
{{</info>}}
