---
title: Instance role
keywords: portworx, gce, gke, gcp
description: Instance role
hidden: true
---
Provide the instances running Portworx privileges to access the GCP API server. This is the preferred method since it requires the least amount of setup on each instance.

- **Owner and Compute Admin Roles**

    These Roles provides Portworx access to the Google Cloud Storage APIs to provision persistent disks. Make sure the service account for the instances has these roles.

- **Cloud KMS predefined roles**

    Following predefined roles provide Portworx access to the Google Cloud KMS APIs to manage secrets.

    ```
    roles/cloudkms.cryptoKeyEncrypterDecrypter
    roles/cloudkms.publicKeyViewer
    ```
