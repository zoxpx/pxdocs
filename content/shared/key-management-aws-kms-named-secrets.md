---
title: Shared content for all AWS-KMS secret docs - named secrets
keywords: AWS, KMS, Amazon Web Services, Key Management Service, encryption
description: Shared content for all AWS-KMS secret docs - named secrets
hidden: true
---

Use the following CLI command to generate AWS KMS Data keys. Portworx associates each KMS Data Key with a unique name provided through the `--secret_id` argument.

To generate a new KMS Data Key, run the following command:

```text
pxctl secrets aws generate-kms-data-key --secret_id mysecret
```

The above command generates an AWS KMS Data Key and associates it with the name `mysecret`. To use this Data Key for encrypting volumes provide only the secret ID `mysecret` to Portworx while creating/attaching the volume.

{{<info>}}
**Important**:
You should not run the above command with the same `secret_id` if you have volumes using the `secret_id`
{{</info>}}

To list all the named secrets, use the following command:

```text
pxctl secrets aws list-secrets
```
