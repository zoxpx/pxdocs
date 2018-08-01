---
title: Create Encrypted PVCs
weight: 5
---

## Volume encryption

This document describes how to provision an encrypted volume using Kubernetes and Portworx. For more information on encryption, click on the link below.

{% page-ref page="../../reference/command-line/data-volumes/encrypted-volumes.md" %}

Before you start using PVC encryption, you need to setup a secrets provider to store your secret keys and configure Portworx to use it. Click on the link below for more information.

{% page-ref page="../../key-management/" %}

There are a couple of ways you can create an encrypted Portworx volume in Kubernetes:

1. [Encryption using StorageClass](https://docs.portworx.com/scheduler/kubernetes/storage-class-encryption.html)
2. [Encryption using PVC](https://docs.portworx.com/scheduler/kubernetes/pvc-encryption.html)

