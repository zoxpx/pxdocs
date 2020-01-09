---
title: Manage your secrets using pxctl
linkTitle: Manage secrets
keywords: portworx, container, Kubernetes, storage, Docker, k8s, AWS KMS, Kubernetes Secrets, Google Cloud KMS
description: Manage your secrets using pxctl
weight: 9
---

This section provides instructions for managing your authentication credentials and endpoints with the `pxctl secrets` command. Currently, `pxctl` provides support for the following secret store providers:

- AWS KMS
- Google Cloud KMS
- DC/OS Secrets
- KVDB

{{% content "shared/reference-CLI-secrets-definition.md" %}}

Before using the `pxctl secrets` command to manage your secrets, make sure you've configured a secret store provider. See the [Secret store management](/key-management/) page for more details.

{{<info>}}
To use encrypted volumes and ACLs, you need to ensure that Portworx is authenticated with the secrets endpoint.
{{</info>}}

## AWS KMS

You can use the `pxctl` CLI tool to:

- Generate AWS KMS secrets
- List your AWS KMS secrets.

### Generate a secret

To generate a new KMS Data Key, run the `pxctl secrets aws generate-kms-data-key` command with the `--secret_id` flag as shown in the following example:

```text
pxctl secrets aws generate-kms-data-key --secret_id mysecret
```

```output
KMS Data Key successfully created.
```

### List your AWS KMS secrets

You can list your AWS KMS secrets with:

``` text
pxctl secrets aws list-secrets
```

For more details on how to create data keys in AWS KMS and use them to encrypt your Portworx volumes, see the [AWS KMS](/key-management/aws-kms) page.

## Google Cloud KMS

With `pxctl`, you can create and list Google Cloud KMS secrets.

### Create a new secret

You can create a new secret in Google Cloud KMS running `pxctl secrets gcloud create-secret` with the following flags:

- `secret-id` with the id of the secret.
- `passphrase` with the secret passphrase Portworx will associate with `secret-id`.

As an example, here's how you can generate a new secret in Google Cloud KMS:

```text
pxctl secrets gcloud create-secret --secret_id mysecret --passphrase mysecretpassphrase
```

```output
Created secret with id:  mysecret
```

This creates a new key-value pair `mysecret=mysecretpassphrase`. Portworx will use Google Cloud KMS to encrypt the passphrase `mysecretpassphrase` and store it in its internal metadata store. To use this passphrase for encrypting volumes, you have to provide the secret ID `mysecret` while creating/attaching the volume.

### List existing secrets

To list your secrets, run:

```text
pxctl secrets gcloud list-secrets
```


## DC/OS Secrets

For information on how to configure Portworx with DC/OS Secrets, see the [DCOS Secrets](/key-management/dc-os-secrets/) page.


## Kubernetes Secrets

To find out how to configure Portworx with Kubernetes Secrets, see the [Kubernetes Secrets](/key-management/kubernetes-secrets/) page.

## Vault

{{<info>}}
To install and configure Vault, see the [Vault install](https://www.vaultproject.io/docs/install/index.html) page.
{{</info>}}

For a step-by-step guide on how you can connect your Portworx cluster to a Vault endpoint and then use the Vault endpoint to store secrets, see the[Vault](/key-management/vault) page.

## KVDB

You can use the `pxctl` CLI utility to store, list and retrieve KVDB secrets.

### Store a secret

To store a secret in KVDB you can run the `pxctl secrets kvdb put-secret` command and pass it the following flags:

- `--secret_id` with the ID of the secret
- `--secret_value` with the value of the secret.

Here's an example:

```text
pxctl secrets kvdb put-secret --secret_id my_secret_id secret_id --secret_value my_secret_value
```

```output
Secret Put succeeded
```

### List existing secrets

Use the following commands to list your secrets:


```text
pxctl secrets kvdb list-secrets
```

```output
Secret ID
my_secret_id
```

### Retrieve a secret

You can retrieve a secret by running `pxctl secrets kvdb get-secret` with the `--secret_id` flag as follows:

```text
pxctl secrets kvdb get-secret --secret_id my_secret_id
```

```output
Secret: [my_secret_id]:[my_secret]
```

## IBM Key Protect

You can use `pxctl` to list the IDs of your IBM Key Protect secrets by running the following command:

```text
pxctl secrets ibm list-secrets
```

## Set a cluster-wide key

To set an existing secret as the default cluster-wide secret for volume encryption, run the `pxctl secrets set-cluster-key` command and pass it the following flags:

- `--secret` with the secret ID of an existing secret,
- `--overwrite` to overwrite the existing cluster-wide secret. Use this command with caution because any **existing volumes encrypted with the old secret will be unusable**.

The following example sets `my_secret_id` as the cluster-wide secret:

```text
pxctl secrets set-cluster-key --secret my_secret_id
```

## Dump and upload cluster-wide secrets

See the [dump and upload cluster-wide secrets](/reference/cli/dump-upload-cluster-wide-secret) page for details.
