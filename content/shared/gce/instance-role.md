Provide the instances running Portworx privileges to access the GCP API server. This is the preferred method since it requires the least amount of setup on each instance.

- **Compute Admin Role**

    The Compute Admin Role provides portworx access to the Google Cloud Storage APIs to provision persistent disks.

- **Cloud KMS predefined roles**

    Following predefined roles provide portworx access to the Google Cloud KMS APIs to manage secrets.

    ```
    roles/cloudkms.cryptoKeyEncrypterDecrypter
    roles/cloudkms.publicKeyViewer
    ```