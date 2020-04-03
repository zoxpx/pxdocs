---
title: Shared
hidden: true
keywords: portworx, kubernetes
description: Learn how to install Portworx with Kubenetes
---
### Generate the specs

To install Portworx with Kubernetes, you must first generate Kubernetes manifests that you will deploy in your cluster:

1. Navigate to <a href="https://central.portworx.com" target="tab">PX-Central</a> and log in, or create an account
2. Select **Install and Run** to open the Spec Generator

    ![Screenshot showing install and run](/img/pxcentral-install.png)

3. Select **New Spec**

    ![Screenshot showing new spec button](/img/pxcentral-spec.png)

4. Choose either **Portworx Enterprise** or **Portworx Essentials**, depending on which license you intend to use:

    ![Screenshot showing Portworx license selector](/img/pxcentral-license.png)

Portworx can also be installed using it's Helm chart by following instructions [here](/portworx-install-with-kubernetes/install-px-helm). The above method is recommended over helm as the wizard will guide you based on your environment.
