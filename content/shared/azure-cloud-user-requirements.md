---
title: CloudUserRequirements
description:
keywords:
hidden: true
---

1. Create a service principal in Azure AD

    ```text
    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/72c299a4-xxxx-xxxx-xxxx-6855109979d9"
    ```
    ```output
    {
      "appId": "1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde",
      "displayName": "azure-cli-2017-10-27-07-37-41",
      "name": "http://azure-cli-2017-10-27-07-37-41",
      "password": "ac49a307-xxxx-xxxx-xxxx-fa551e221170",
      "tenant": "ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce"
    }
    ```

2. Create a secret called `px-azure` to give Portworx access to Azure APIs by updating the following fields with the associated fields from the service principal you created in the step above:

    ```text
    kubectl create secret generic -n kube-system px-azure --from-literal=AZURE_TENANT_ID=<tenant> \
                                                          --from-literal=AZURE_CLIENT_ID=<appId> \
                                                          --from-literal=AZURE_CLIENT_SECRET=<password>
    ```
    ```output
    secret/px-azure created
    ```
