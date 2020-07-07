---
title: Shared content for all gcloud - named secrets
keywords: Google Cloud KMS, Key Management Service, gcloud
description: Shared content for all gcloud - named secrets
hidden: true
---

Use the following CLI command to create a new secret in Google Cloud KMS and provide it an identifier/name:

```text
pxctl secrets gcloud create-secret --secret_id mysecret --passphrase mysecretpassphrase
```

The above command will create a new key-value pair `mysecret=mysecretpassphrase`. Portworx will use Google Cloud KMS to encrypt the passphrase `mysecretpassphrase` and store it in its internal metadata store. To use this passphrase for encrypting volumes provide only the secret ID `mysecret` to Portworx while creating/attaching the volume.

To list all the named secrets use the following command:

```text
pxctl secrets gcloud list-secrets
```
