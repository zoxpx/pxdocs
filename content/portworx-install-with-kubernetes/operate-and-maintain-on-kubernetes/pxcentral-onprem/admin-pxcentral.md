---
title: Administer PX-Central on-premises
weight: 6
keywords: Install, PX-Central, On-prem, license, GUI, k8s
description: Learn how to install PX-Central On-prem.
noicon: true
series: k8s-op-maintain
---

## Reset your administrator password

You can reset the administrator password you specified during installation by downloading and running a reset script:

1. Download and the PX-Central password reset script:

    ```text
    curl -o px-central-password-reset.sh 'https://raw.githubusercontent.com/portworx/px-central-onprem/1.0.1/reset-password.sh'
    ```

2. Run the script, specifying the `--admin-password` option with your desired new password:

    ```text
    ./px-central-password-reset.sh --admin-password myNewPassword
    ```

## Uninstall PX-Central on-premises

Uninstall PX-Central by downloading and running a script which cleans up both Portworx and PX-Central.

{{<info>}}
**WARNING:** This script removes all Portworx and PX-Central installations on the Kubernetes cluster.
{{</info>}}

1. Download and the PX-Central install script:

    ```text
    curl -o px-central-cleanup.sh 'https://raw.githubusercontent.com/portworx/px-central-onprem/1.0.1/cleanup.sh'
    ```

2. Run the script to clean up Portworx and PX-Central:

    ```text
    ./px-central-cleanup.sh
    ```
