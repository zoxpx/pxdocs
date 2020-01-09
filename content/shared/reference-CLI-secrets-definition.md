---
title: Portworx Secrets- Definition
hidden: true
keywords: portworx, pxctl, secrets, security
description: Explains what is a Portworx secret
---

With _Portworx_, secrets are neither stored locally nor displayed. Instead, the credentials are stored as part of the secret endpoint given to _Portworx_ for persisting authentication across reboots. You can manage your secrets through the `pxctl secrets` command. To see the list of available sub-commands and flags, run:


```text
pxctl secrets help
```

```output
Manage Secrets. Supported secret stores AWS KMS | Vault | DCOS Secrets | IBM Key Protect | Kubernetes Secrets | Google Cloud KMS

Usage:
  pxctl secrets [flags]
  pxctl secrets [command]

Available Commands:
  aws                        AWS secret-endpoint commands
  dump-cluster-wide-secret   Dumps the cluster-wide secret and the associated key for this cluster.
  gcloud                     Google Cloud KMS commands
  ibm                        IBM Key Protect commands
  kvdb                       kvdb secret-endpoint commands
  set-cluster-key            Sets an existing secret as a cluster-wide (default) secret to be used for volume encryption
  upload-cluster-wide-secret Uploads the provided key and secret as a cluster-wide (default) secret.

Flags:
  -h, --help   help for secrets

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

Use "pxctl secrets [command] --help" for more information about a command.
```
