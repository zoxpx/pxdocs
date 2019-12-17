---
title: Intro
keywords: portworx, encryption
description: Intro
hidden: true
---

This guide will give you an overview of how to use the encryption feature for Portworx volumes. Under the hood, Portworx uses the `libgcrypt` library to interface with the `dm-crypt` module for creating, accessing and managing encrypted devices. Portworx uses the `LUKS` format of `dm-crypt` and `AES-256` as the cipher with `xts-plain64` as the cipher mode.

All encrypted volumes are protected by a passphrase. Portworx uses this passphrase to encrypt the volume data at rest as well as in transit. It is recommended to store these passphrases in a secure secret store.

There are two ways in which you can provide the passphrase to Portworx:

**1. Per volume secret:** Use a **unique secret** for each encrypted volume

**2. Cluster-wide secret:** Use a default **common secret** for all encrypted volumes
