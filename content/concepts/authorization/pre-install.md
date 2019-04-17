---
title: Preparation For Installation
description: Explains how to get the information needed to setup security
keywords: portworx, security, ownership, tls, rbac, claims, jwt, oidc
weight: 20
series: authorization
---

To enable authorization you must first determine which type of authorization
model you will be using. You can choose to connect to an OIDC provider or use
self-signed tokens [Security Overview](/concepts/authorization/overview)) or
both.

## OpenID Connect (OIDC)
An OpenID Connect (OIDC) service can be used to provide your users with tokens,
which can then be provided to Portworx for verification. Portworx needs to
connect to your OIDC provider to automatically download the public key. This
public key is used to verify that the signature of the JWT is valid.

To connect Portworx to an OIDC you will need the following information from your
provider:

* OIDC Client Id: This is the client that has been setup for Portworx at the
  OIDC.
* OIDC Issuer: The issuer is the address to the OIDC and *must* match the issuer
  value in the claims of each token generated.

### Mapping groups and roles
Tokens created by OIDC must also have a `groups` and `roles` claim as mentioned
in the [Security Overview](/concepts/authorization/overview) section. These
sections provide the permissions necessary to access certain APIs and resources.

You may need to configure your OIDC provider to "map" information about your
users into the `roles` and `groups` section of the JWT token. Please refer with
your OIDC provider on how map values. These claims are called _custom_ claims
and depending on your OIDC, it may place custom claims under a namespace.
Portworx supports both un-namespaced and namespaced `roles` and `groups` in the
JWT claims. For example an un-namespaced `role` would look as follows:

```json
{
  "roles" : [ "system.admin" ],
  "groups": [ "*" ]
}
```

while a namespaced model using the namespace `https://myoidc.provider.com/`
    would look as follows:

```json
{
  "https://myoidc.provider.com/roles" : [ "system.admin" ],
  "https://myoidc.provider.com/groups": [ "*" ]
}
```

Namespace information can be provided to Portworx when enabling authorization
support.

## Self signing tokens
If you are using self-signed model, you then need to determine if you will be
using a shared-secret or a an RSA or ECDSA public/private key model.  Creating a
JWT is a standard and there are many applications and libraries for multiple
languages to generate tokens.  For simplicity, Portworx has added support to
[`pxctl`](/reference/cli/authorization/#generate_tokens) to generate tokens.

Self signed tokens must also contain an identifier of the _issuer_. This value
in the JWT claims is set as `iss` and is used by Portworx to determine if the
token is from a trusted token authority.

### Generating a shared secret
If you choose to use shared secret for your self-signed tokens, here is a simple
way to generate a very secure secret:

```text
cat /dev/urandom | base64 | fold -w 64 | head -n 1
```

### Portworx cluster authorization
When authorization is enabled, Portworx itself will generate its own tokens to
secure communications in the cluster. For this reason, you will be asked to
provide a shared secret for the system.

{{<info>}}
This may be replaced by the installer for your container orchestrator.
Please see your container orchestrator authorization installation instructions
for more information
{{</info>}}

## Verification of a token authority
To confirm that a token has the correct information, create a token using your
preferred method. Then copy this token and paste it in [jwt.io](https://jwt.io).
Note the _payload_ section has all the necessary claims to provide the
appropriate permissions. Also note that the `iss`(Issuer), is correct. Portworx
will use the value of `iss` to determine if the token comes from a trusted token
authority.

Second, you can try out the token on a running Portworx system which has
authorization enabled. There are multiple ways to do this. One is to use [`pxctl
context`](/reference/cli/authorization) on a Portworx node. You can then run a
set of commands that confirm the token access. Another way is to use the REST
SDK Gatway by going to `http://<node ip>:9021/sdk` or `https://<node
ip>:9021/sdk` depending if TLS has been enabled for your Portworx system or not.
Once the page has loaded, click on the `Authorize` button, and paste your token.
You can then execute a set of APIs to confirm the token access.

{{<info>}}
The default port of `9021` for the SDK REST Gateway may have been moved
to another port range.  Please consult your Portworx installation.
{{</info>}}

