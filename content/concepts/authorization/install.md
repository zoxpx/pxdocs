---
title: Enabling Authorization
description: Explains how to enable authorization in Portworx
keywords: portworx, security, ownership, tls, rbac, claims, jwt, oidc
weight: 30
series: authorization
---

This page will explain how to enable authorization in Portworx installing in a
generic way. For specific step on how to enable authorization in Portworx for a
container orchestration system, please refer to the appropriate installation
instructions in this document site.

## Requirements
To enable authorization in Portworx, administrators must provide the following
information:

1. System shared key for secure cluster communications
1. If using Kubernetes and stork, a stork shared key for secure communications
1. A trusted authorization model for users; either self-signed, OIDC, or both.
    * If OIDC is used, then the following must be provided:
        1. OIDC Issuer
        1. OIDC Client id
    * If self-signed token model is used, then the following must be provided:
        1. JWT issuer
        1. JWT shared secret or JWT public key

## Setup
The information above must be provided to Portworx configuration. Sensitive
information like shared secrets can only be provided as environment variables.
These variables can then be filled in automatically by _Secrets_ coming from
your container orchestration system.

### Environment variables
The following environment variables can be provided to enable authorization:

| Environment Variable | Required | Description |
| -------------------- | -------- | ----------- |
| `PORTWORX_AUTH_SYSTEM_KEY` | Yes | Shared secret used by Portworx to generate tokens for cluster communications |
| `PORTWORX_AUTH_STORK_KEY` | Yes when using stork | Share secret used by stork to generate tokens to communicate with Portworx. The shared secret must match the value of `PX_SHARED_SECRET` environment variable in stork. |
| `PORTWORX_AUTH_JWT_SHAREDSECRET` | Optional | Self-generated token shared secret, if any |

### Configuration
All other non-sensitive information can be provided to `px-runc` using the
following command line arguments:

| Name | Description |
| ---- | ----------- |
| `oidc_issuer   <URL>` | Location of OIDC service (e.g. `https://accounts.google.com`). This must match the `iss` value in the claims of the tokens. |
| `oidc_client_id <id>` | Client id provided by the OIDC |
| `oidc_custom_claim_namespace <namespace>` | OIDC namespace for custom claims |
| `jwt_issuer <issuer>` | JSON Web Token issuer (e.g. openstorage.io). This is the token issuer for your self-signed tokens. It must match the `iss` value in the claims of the tokens. |
| `jwt_rsa_pubkey_file <file path>` | JSON Web Token RSA Public file path |
| `jwt_ecds_pubkey_file <file path>` | JSON Web Token ECDS Public file path |
| `username_claim <claim>` | Claim key from the token to use as the unique id of the user (<claim> is sub, email or name, default: sub) |

## Upgrading from non-auth to auth
A few steps must be taken to upgrade a cluster from non-auth to auth:

1. Make sure to add auth configurations as documented above
2. A new cluster token must be generated if you plan on performing cluster pairing and migrations. This can be done by executing `pxctl cluster token reset`.
3. Ensure that all nodes are configured as auth-enabled. Mixed clusters of auth and non-auth nodes will allow for security vulnerabilities.