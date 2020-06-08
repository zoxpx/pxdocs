---
title: Upgrade PX-Central on-premises
description: Upgrade your version of PX-Central on-premises
keywords: upgrade, 
weight: 10
noicon: true
series: k8s-op-maintain
---

Upgrade PX-Central on-premises by downloading and running an upgrade script:

1. Download the PX-Central upgrade script and make it executable:

    ```text
    curl -o upgrade.sh 'https://raw.githubusercontent.com/portworx/px-central-onprem/1.0.2/upgrade.sh' && chmod +x upgrade.sh
    ```

2. Run the script with any of [the options](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/upgrade/upgrade-script-reference/) required to upgrade PX-Central according to your needs. The following example runs the upgrade script with the default configuration:

    ```text
    ./upgrade.sh
    ```
