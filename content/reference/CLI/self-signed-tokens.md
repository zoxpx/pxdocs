---
title: Generate self-signed tokens using pxctl
linkTitle: Self-signed Tokens
keywords: portworx, container, Kubernetes, storage, auth, authorization, authentication, login, token, context, generate, self-signed, security
description: Learn to generate self-signed tokens using pxctl
weight: 19
---

With Portworx, you can use the `pxctl` command-line tool to generate a self-signed token. Run the following command to access the built-in help and see the available flags:

```text
pxctl auth token generate --help
```

```output
Generate a self signed token based on a specified configuration yaml. The configuration defines your identity, roles, and groups to be used when generating a token.
e.g.
     name: Jim Stevens
     sub: jstevens@portworx.com/jstevens
     email: jstevens@portworx.com
     roles: ["system.user"]
     groups: ["px-engineering", "kubernetes-csi"]

Usage:
  pxctl auth token generate [flags]

Examples:
pxctl auth token generate --auth-config=<authconfig.yaml> --issuer <issuer> --ecdsa-private-keyfile <ecdsa key file> OR --rsa-private-keyfile <rsa key file> OR --shared-secret <secret>

Flags:
      --auth-config string             (Required) Auth account information file providing email, name, etc.
      --ecdsa-private-keyfile string   ECDSA Private file to sign token
      --issuer string                  (Required) Issuer name of token. Do not use https:// in the issuer since it could indicate that this is an OpenID Connect issuer.
      --output string                  Output token to file instead of standard out
      --rsa-private-keyfile string     RSA Private file to sign token
      --shared-secret string           Shared secret to sign token
      --token-duration string          Duration of time where the token will be valid. Postfix the duration by using s for seconds, m for minutes, h for hours, d for days, and y for years. (default "1d")
  -h, --help                           help for generate

Global Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx
```

As seen above, the `pxctl` command-line tool allows you to generate self-signed tokens in the following ways:

- ECDSA
- RSA
- shared secret

For example, to generate a self-signed token with a shared secret, specify these flags:

- `--auth-config` with the path to the file providing account information
- `--shared-secret` with a string representing your shared secret.
- `--issuer` with the name of the issuer.
- `--output` with the name of the file

As an example, the following example generates a self-signed token:

```text
echo "name: Jim Stevens
email: jstevens@portworx.com
sub: jstevens@portworx.com/jstevens
roles: [\"system.user\"]
groups: [\"*\"]" > authconfig.yaml

pxctl auth token generate --auth-config=authconfig.yaml --issuer my_issuer \
    --shared-secret my_shared_secret \
    --output self-signed-token.txt
```

```output
Token written to output file: self-signed-token.txt
```

Use the `cat` command to view the content of the `self-signed-token.txt` file:

```text
cat self-signed-token.txt
```

```output
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImpzdGV2ZW5zQHBvcnR3b3J4LmNvbSIsImV4cCI6MTU2NzUzMDAyMiwiZ3JvdXBzIjpbIioiXSwiaWF0IjoxNTY3NDQzNjIyLCJpc3MiOiJteV9pc3N1ZXIiLCJuYW1lIjoiSmltIFN0ZXZlbnMiLCJyb2xlcyI6WyJzeXN0ZW0udXNlciJdLCJzdWIiOiJqc3RldmVuc0Bwb3J0d29yeC5jb20vanN0ZXZlbnMifQ.tdhwsn780hpHU73DwGjBNAz6UUCHNboqtAPZFVTb3Cw
```
