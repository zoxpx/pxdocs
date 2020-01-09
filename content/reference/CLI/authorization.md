---
title: Authorization using pxctl
linkTitle: Authorization
keywords: pxctl, command-line tool, cli, reference, authorization, auth-enabled, token, OIDC, self-signed, JWT, shared-secret, security
description: Learn to interact with your authorization-enabled Portworx cluster using pxctl
weight: 18
---

## Overview

This document outlines how to interact with an authorization-enabled Portworx cluster. The main way to do it is by using the `pxctl context` command. Also, you can integrate with an __OIDC provided token__ or __generate self-signed tokens__ through `pxctl`. See the [generate self-signed tokens](/reference/cli/self-signed-tokens) page for more details.

## Contexts

Portworx stores the following locally to your home directory, allowing you to switch between configurations with a few commands:

 - contexts
 - associated clusters
 - privileges
 - tokens

- contexts,
- associated clusters,
- privileges, and
- tokens

local to your home directory. This allows you to switch between these configurations with a few commands.

{{<info>}}
Since Portworx stores the context locally on each node, you must create your context on the node you're working on.
{{</info>}}

Run the `pxctl context` command with the `--help` flag to list the available subcommands and flags:

```text
/opt/pwx/bin/pxctl context --help
```

```output
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

### Create a context

You can create a new context by running the `pxctl context create` command and passing it the following arguments:

- the name of the context
- `--token` with the token Portworx must use for this context
- `--endpoint` with the endpoint for this conext

Here's an example of how you can create a new context:

```text
pxctl context create <context> --token <token> --endpoint <endpoint>
```

### Delete a context

To delete a context, run the `pxctl context delete` command with the name of the context as in the following example:

```text
pxctl context delete <context>
```

### List your contexts

Portworx stores your contexts in the `~/.pxctl/contextconfig` directory. Use the `pxctl context list` command to view them:

```text
pxctl context list
```

```output
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

### Select the current context

Once you've created your contexts, use the `pxctl context` command to switch between them. Under the hood, Portworx reads your current context and then uses the associated token for all commands.

{{<info>}}
Alternatively, you can use the global `--context` flag to run a single command with a given context.
{{</info>}}

Use the following command to set the current context:

```text
pxctl context set <context>
```

Unset the current context with:

```text
pxctl context unset
```

## Generate tokens

Portworx supports two methods of authorization:

- OIDC and
- self-signed.

To generate a token through your OIDC provider, see the documentation on generating bearer tokens on the website of the provider. The following links direct you to the most commonly used OIDC providers:

- [Keycloak](https://www.keycloak.org/docs/latest/server_development/index.html#admin-rest-api)
- [Auth0](https://auth0.com/docs/api/authentication#get-token)
- [Okta](https://developer.okta.com/docs/api/getting_started/getting_a_token/#token-expiration)

Note that, for self-signed tokens, you can use your own JWT compliant application. Furthermore, for convenience, the `pxctl` CLI tool provides a command for generating tokens. See the [self-signed tokens](/reference/cli/self-signed-tokens) page for more details.

## How to debug token issues

This section explains how to debug common token issues.

### Permission denied issues

**Problem symptom**: You see an unexpected `Permission denied` or other auth-related error.

**Find the root cause**: Take a look into your token permissions. Decode and verify your token with a JWT token decoding tool such as [jwt.io](https://jwt.io/)

{{<info>}}
The [jwt.io](https://jwt.io/) debugger does client-side validation and debugging. It does not store your token anywhere.
{{</info>}}

### Protocol error

**Problem symptom**: you see an error message similar to `rpc error: code = Internal desc = stream terminated by RST_STREAM with error code: PROTOCOL_ERROR`.

**Find the root cause**: Make sure your token doesn't contain a newline character. The `gRPC/http2` protocol doesn't allow newline characters.
that your token does not accidentally contain a newline character. This is due to gRPC/http2 not allowing newline characters.

## Related topics

* For information about enabling and managing Portworx authorization through Kubernetes, refer to the [Authorization](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/) page.

