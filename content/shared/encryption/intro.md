This guide will give you an overview of how to use Encryption feature for Portworx volumes. Under the hood Portworx uses libgcrypt library to interface with the dm-crypt module for creating, accessing and managing encrypted devices. Portworx uses the LUKS format of dm-crypt and AES-256 as the cipher with xts-plain64 as the cipher mode.

Portworx volume encryption protects both the data-at-rest as well as data-in-flight when the ecnrypted data is replicated across nodes, across data centers and across availability zones in clouds.

All the encrypted volumes are protected by a passphrase. Portworx uses this passphrase to encrypt the volumes. It is recommended to store these passphrases in a secure secret store.
