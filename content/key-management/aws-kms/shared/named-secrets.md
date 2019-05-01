Use the following CLI command to generate AWS KMS Data keys. _Portworx_ associates each KMS Data Key with a unique name provided through the `--secret_id` argument.

To generate a new KMS Data Key, run the following command:

```text
pxctl secrets aws generate-kms-data-key --secret_id mysecret
```

The above command generates an AWS KMS Data Key and associates it with the name `mysecret`. To use this Data Key for encrypting volumes provide only the secret ID `mysecret` to _Portworx_ while creating/attaching the volume.

To list all the named secrets, use the following command:

```text
pxctl secrets aws list-secrets
```
