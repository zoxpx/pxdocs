---
title: Enabling PX-Security
description: Explains how to enable PX-Security in Portworx
keywords: enable authorization, security, RBAC, Role Based Access Control, JWT, JSON Web Token, OIDC, OpenID Connect, self-signed, claims, upgrade to auth, auth enabled cluster
weight: 30
series: authorization
---

This page provides guidance for enabling PX-Security in Portworx. 

For specific details on enabling PX-Security in Portworx for a specific container
orchestration system, refer to the relevant installation instructions on this
site for the given orchestration system.

## Requirements
To enable authorization in Portworx, administrators must provide the following
information:

1. System shared key for secure cluster communications.
1. If using Kubernetes and Stork, a Stork shared key for secure communications
1. A trusted authorization model for users; either self-signed, OIDC, or both.
    * If OIDC is used, then the following must be provided:
        1. OIDC Issuer
        1. OIDC Client id
    * If self-signed token model is used, then the following must be provided:
        1. JWT issuer
        1. JWT shared secret or JWT public key

## Setup Parameters

The parameters above are required and must be provided to Portworx to enable
PX-Security.

Sensitive information like shared secrets can only be provided as environment
variables.  These variables can be provided by _secrets_ through your container
orchestration system.


### Environment variables

The following environment variables may be provided to enable PX-Security:

| Environment Variable | Required? | Description |
| -------------------- | --------- | ----------- |
| `PORTWORX_AUTH_SYSTEM_KEY` | Yes | Shared secret used by Portworx to generate tokens for cluster communications |
| `PORTWORX_AUTH_STORK_KEY` | Yes when using Stork | Share secret used by Stork to generate tokens to communicate with Portworx. The shared secret must match the value of `PX_SHARED_SECRET` environment variable in Stork. |
| `PORTWORX_AUTH_JWT_SHAREDSECRET` | Optional | Self-generated token shared secret, if any |

### Configuration

All other non-sensitive information can be provided to `px-runc` as command-line 
parameters with the following arguments:

| Name | Description |
| ---- | ----------- |
| `-oidc_issuer <URL>` | Location of OIDC service (e.g. `https://accounts.google.com`). This *must* match the `iss` value in token claims |
| `-oidc_client_id <id>` | Client ID provided by the OIDC |
| `-oidc_custom_claim_namespace <namespace>` | OIDC namespace for custom claims |
| `-jwt_issuer <issuer>` | JSON Web Token issuer (e.g. openstorage.io). This is the token issuer for your self-signed tokens. It must match the `iss` value in token claims |
| `-jwt_rsa_pubkey_file <file path>` | JSON Web Token RSA Public file path |
| `-jwt_ecds_pubkey_file <file path>` | JSON Web Token ECDS Public file path |
| `-username_claim <claim>` | Name of the claim in the token to be used as the unique ID of the user (<claim> can be `sub`, `email` or `name`, default: `sub`) |

## Enabling PX-Security on an existing Portworx cluster

The following steps are required to enable PX-Security an existing Portworx cluster that has not had PX-Security setup:

1. Make sure to add the configuration setup as documented above on each node
2. Ensure that *all* nodes participating in the Portworx cluster have PX-Security
enabled. Mixing nodes with it enabled and disabled will prevent the cluster from
being fully secure.
3. If you plan to pair and migrate your clusters, then you must also generate a new
cluster token. You can do this by executing 

    ```text
    pxctl cluster token reset
    ```

## Related videos 

### Use OpenID Connect with roles and groups to authorize users

{{< youtube  F9LVUWTeqBE >}}
