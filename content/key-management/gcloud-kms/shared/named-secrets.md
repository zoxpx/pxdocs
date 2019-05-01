Use the following CLI command to create a new secret in Google Cloud KMS and provide it an identifier/name:

```text
pxctl secrets gcloud create-secret --secret_id mysecret --passphrase mysecretpassphrase
```

The above command will create a new key-value pair `mysecret=mysecretpassphrase`. _Portworx_ will use Google Cloud KMS to encrypt the passphrase `mysecretpassphrase` and store it in its internal metadata store. To use this passphrase for encrypting volumes provide only the secret ID `mysecret` to _Portworx_ while creating/attaching the volume.

To list all the named secrets use the following command:

```text
pxctl secrets gcloud list-secrets
```
