---
title: "Generate shared secrets"
keywords: portworx, sharedsecret, generate, secret
---

This guide uses a model based on [shared secrets](/concepts/authorization/overview/#security-tokens) as the method to create and verify tokens. The goal is to store the shared secrets in a secure Kubernetes Secret object to then provide to Portworx.

1. Generate [secure secrets](/concepts/authorization/pre-install/#self-signing-tokens)
and save the values in [environment variables](/concepts/authorization/install/#environment-variables):

    ```text
    PORTWORX_AUTH_SYSTEM_KEY=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1) \
    PORTWORX_AUTH_STORK_KEY=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1) \
    PORTWORX_AUTH_SHARED_SECRET=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1)
    ```

2. Store these shared secrets securely in a Kubernetes secret called
`pxkeys` in the `kube-system` namespace:

    ```text
    kubectl -n kube-system create secret generic pxkeys \
        --from-literal=system-secret=$PORTWORX_AUTH_SYSTEM_KEY \
        --from-literal=stork-secret=$PORTWORX_AUTH_STORK_KEY \
        --from-literal=shared-secret=$PORTWORX_AUTH_SHARED_SECRET
    ```

3. Verify that the secret stored is correct by comparing `$PORTWORX_AUTH_SHARED_SECRET` with the value returned below:

    ```text
    kubectl -n kube-system get secret pxkeys -o json | jq -r '.data."shared-secret"' | base64 -d
    ```

Once you've completed the steps in this section, continue to the **Enable security in Portworx** section.
