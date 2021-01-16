---
title: Install the monitoring service
weight: 3
keywords: Install, PX-Central, On-prem, license, GUI, k8s, license server
description: Learn how to install the monitoring service.
noicon: true
hidden: true
---

Follow the steps in this section to install the monitoring service.

## Prerequisites

* You must first deploy the PX-Backup chart, and all components should be in running state.


* If you're running Portworx on Openshfift, then you must add a new  service account to the `privileged` SCC. Enter the `oc edit scc privileged` command and add the following line to the `users` section, replacing `<YOUR_NAMESPACE>` with your namespace:

    ```text
    system:serviceaccount:<YOUR_NAMESPACE>:px-monitor
    ```

## Install the monitoring service

1. Generate the install spec through the **License Server and Monitoring** [spec generator](https://central.portworx.com/specGen/px-central-on-prem-wizard), and enter the following information:

    * **PX-Backup UI Endpoint**: The external IP address of the `px-backup-ui` service
    * **OIDC client secret**: Your OIDC client secret. Use either the `kubectl get cm` or the `kubectl get secret` command to retrieve it, replacing `<RELEASE-NAMESPACE>` with your namespace:

        ```text
        kubectl get cm --namespace <RELEASE-NAMESPACE> pxcentral-ui-configmap -o jsonpath={.data.OIDC_CLIENT_SECRET}
        ```

        or

        ```
        kubectl get secret --namespace <RELEASE_NAMESPACE> pxc-backup-secret -o jsonpath={.data.OIDC_CLIENT_SECRET} | base64 --decode
        ```

    If you're using Portworx for the PX-Central installation, select the **Use storage class** checkbox under the **Storage** section of the **Spec Details** tab, and enter the name of the storage class you used to install PX-Central.

    If your cluster is air-gapped, select the **Air Gapped** checkbox, and enter the following information:

      * **Custom Registry**: The hostname of your custom registry
      * **Image Repository**: The path to the required Docker images
      * **Image Pull Secret(s)**: A comma-separated list of your image pull secrets.

2. Using Helm, add the {{< pxEnterprise >}} repo to your cluster and update it:
    <!-- I may instead just push these two steps together and refer users to the spec generator -->

    ```text
    helm repo add portworx http://charts.portworx.io/ && helm repo update
    ```

3. Install the monitoring service using either the `--set` flag or the `values.yml` file provided in the **Step 2** section of the **Complete** tab of the spec generator.
