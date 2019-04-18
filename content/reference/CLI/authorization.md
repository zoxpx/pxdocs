---
title: Authorization using pxctl
linkTitle: Authorization
keywords: portworx, container, Kubernetes, storage, auth, authz, authorization, authentication, login, token, oidc, context, generate, self-signed, jwt, shared-secret, security
description: Learn to enable auth in your px cluster
weight: 18
---

## Overview

This document outlines how to interact with an auth-enabled _PX_ cluster. The main way to do it is by using the `pxctl context` commands. In addition, you can integrate with an __OIDC provided token__ or __generate self-signed tokens__ through `pxctl`.

## Context

`pxctl` allows you to store contexts and associated clusters, privileges, and tokens local to your home directory. This way, you can easily switch between these configurations with a few commands.

{{<info>}}
Since `pxctl context` is stored locally per node, you will need to create your context on the node you're working on. 
{{</info>}}

To find out the available commands, type:

```text
/opt/pwx/bin/pxctl context --help
```

```
Portworx pxctl context commands for setting authentication and connection info

Usage:
  pxctl context [flags]
  pxctl context [command]

Available Commands:
  create      create a context
  delete      delete a context
  list        list all contexts
  set         set the current context
  unset       unset the current context

```

### Context management

You can easily create and delete contexts with the following commands:

__Creating or updating a context:__

```text
pxctl context create <context> --token <token> --endpoint <endpoint>
```

__Deleting a context:__

```text
pxctl context delete <context>
```

__Listing your contexts:__

Your contexts live in `~/.pxctl/contextconfig`. You can easily view them with the `list` subcommand:

```text
pxctl context list
```

```
contextconfig:
  current: user
  configurations:
  - context: user
    token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImpzdGV2ZW5zQHBvcnR3b3J4LmNvbSIsImV4cCI6MTU1MzcyNTMyMSwiZ3JvdXBzIjpbInB4LWVuZ2luZWVyaW5nIiwia3ViZXJuZXRlcy1jc2kiXSwiaWF0IjoxNTUzNjM4OTIxLCJpc3MiOiJwb3J0d29yeC5jb20iLCJuYW1lIjoiSmltIFN0ZXZlbnMiLCJyb2xlcyI6WyJzeXN0ZW0udXNlciJdLCJzdWIiOiJqc3RldmVuc0Bwb3J0d29yeC5jb20vanN0ZXZlbnMifQ.pZDbCIL7ldcImvIaNSjk18Ah3LqxX63MV378NiauRwk
    identity:
      subject: jstevens@portworx.com/jstevens
      name: Jim Stevens
      email: jstevens@portworx.com
    endpoint: http://localhost:9001
```


### Current context

Now that you've created your contexts, you can easily switch between them with the commands below. `pxctl` will automatically read your currently set context and use the associated token for all commands.

Alternatively, you can use the global `--context` flag to run a single command with a given context.

__Setting current context:__

```text
pxctl context set <context>
```

__Unsetting current context:__

```text
pxctl context unset
```

## Generating tokens {#generate_tokens}
_PX_ supports two methods of authorization: OIDC and self-signed.

For generating a token through your OIDC provider, see your provider's
documentation on generating bearer tokens. The following are some of the
supported OIDCs:

* [Keycloak](https://www.keycloak.org/docs/1.9/server_development_guide/topics/admin-rest-api.html)
* [Auth0](https://auth0.com/docs/api/authentication#get-token)
* [Okta](https://developer.okta.com/docs/api/getting_started/getting_a_token/#token-expiration)

For self-signed, you can use your own JWT compliant application, or for
convenience, `pxctl` has a command for generating tokens.

__Generating self-signed tokens:__

`pxctl` allows you to generate self-signed tokens in a few different ways:
ECDSA, RSA, and Shared-Secret. In addition to these parameters, you must pass an
issuer and `authconfig.yaml`. See below for an example with configuration
`authconfig.yaml`.

```text
pxctl auth token generate --auth-config=<authconfig.yaml> --issuer <issuer> \
    --ecdsa-private-keyfile <ecdsa key file> OR \
    --rsa-private-keyfile <rsa key file> OR \
    --shared-secret <secret>
```

__Sample configuration (authconfig.yaml):__

```text
name: Jim Stevens
email: jstevens@portworx.com
sub: jstevens@portworx.com/jstevens
roles: ["system.user"]
groups: ["*"]
```

## Debugging token issues

### Permission denied issues
You may have gotten an unexpected `"Permission denied"` or other auth-related error. To take a look into your token permissions, you can always decode it with a JWT token decoding tool such as [jwt.io](https://jwt.io/)

{{<info>}}
[jwt.io](https://jwt.io/) does client-side validation and debugging. It does not store your token anywhere.
{{</info>}}


### Protocol error 
If you're seeing the below error: 

`rpc error: code = Internal desc = stream terminated by RST_STREAM with error code: PROTOCOL_ERROR`

Make sure that your token does not accidentally contain a newline character. This is due to gRPC/http2 not allowing newline characters.