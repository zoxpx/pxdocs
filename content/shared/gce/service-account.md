---
title: Service account
keywords: portworx, gce, gke, gcp
description: Service account
hidden: true
---

Alternatively, you can give Portworx access to the GCP API server via an account file and environment variables. First, you will need to create a service account in GCP and download the account file.

To access the GCP API server, Portworx needs a service account with the following roles

- **Owner and Compute Admin Roles**

    These Roles provides Portworx access to the Google Cloud Storage APIs to provision persistent disks. Make sure the service account created below has these roles.

- **Cloud KMS predefined roles**

    Following predefined roles provide Portworx access to the Google Cloud KMS APIs to manage secrets.

    ```
    roles/cloudkms.cryptoKeyEncrypterDecrypter
    roles/cloudkms.publicKeyViewer
    ```

Follow these steps to create a service account and download its corresponding account file.

1. Create a service account in the "Service Account" section that has the above permissions.
2. Go to IAM & admin  -> Service Accounts -> (Instance Service Account) -> Select "Create Key" and download the `.json` file
