---
title: "Step 3: Generate tokens"
keywords: multitenancy, generate, token, jwt, pxctl, authorization, security
weight: 30
---

Now that the system is up and running, you can create tokens.

{{<info>}}
If you want to create your own application to generate tokens, you
can base it on our open source golang example application [openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth)
{{</info>}}

SSH to one of your nodes and follow the steps below to use `pxctl` to generate tokens:

## Fetching the shared secret

Fetch the _shared secret_, which is stored in a
Kubernetes secret. Below, the secret is saved in the
environment variable `$PORTWORX_AUTH_SHARED_SECRET`.

1. Get the shared secret:

    ```text
    PORTWORX_AUTH_SHARED_SECRET=$(kubectl -n kube-system get \
          secret pxkeys -o json \
        | jq -r '.data."shared-secret"' \
        | base64 -d)
    ```

## Generate a storage admin token

[`pxctl`](/reference/cli/authorization/#generate-tokens) uses yaml
configuration files to create tokens. You must to create a token for the
[storage admin](/concepts/authorization/overview/#the-administrator-role)
used for `pxctl` to manage Portworx
(like _root_ in Linux)

1. Create a file called `admin.yaml` with the the following:

    ```text
    name: Storage Administrator
    email: the email of the storage admin
    sub: ${uuid} or email of the storage admin
    roles: ["system.admin"]
    groups: ["*"]
    ```

2. Create a token for the storage administrator using `admin.yaml`. In the example below:

    * The issuer matches the setting in the Portworx manifest of `portworx.com` as the set value for `-jwt-issuer`.
    * The example sets the duration of the token to one year -- You may want to adjust it to a much shorter duration if you plan on refreshing the token often.

    ```text
    ADMIN_TOKEN=$(/opt/pwx/bin/pxctl auth token generate \
        --auth-config=admin.yaml \
        --issuer=portworx.com \
        --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
        --token-duration=1y)
    ```

3. Save the storage admin token in the `pxctl` [context](/reference/cli/authorization/#contexts):

    ```text
    /opt/pwx/bin/pxctl context create admin --token=$ADMIN_TOKEN
    ```

## Generate tenant tokens

This model is based on isolating tenant accounts by namespaces. You will need
to create an account for the tenant in Kubernetes and restrict it to one or
more namespaces. You will then store the tenant's token in each namespace
they own.

The following steps provide instructions for creating and storing the token
in a namespace for the tenant:

1. Create a file called `tenant-name.yaml` with the the following:

    ```text
    name: <Tenant name>
    email: <Tenant email>
    sub: ${uuid} or email of the tenant
    roles: ["system.user"]
    groups: ["<groups the tenant participate if any"]
    ```

    {{<info>}}
**NOTE:** The `sub` is the unique identifier for this user and most not be shared amongst
other tokens according to the JWT standard. This is the value used by Portworx
to track ownership of resources. If `email` is also used as the `sub` unique
identifier, please make sure it is not used by any other tokens.

You can find more information on the rules of each of the value on the
[openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth#usage) repo.
    {{</info>}}


2. Create a token for the Kubernetes using `tenant-name.yaml`:

    ```text
    TENANT_TOKEN=$(/opt/pwx/bin/pxctl auth token generate \
        --auth-config=tenant-name.yaml \
        --issuer=portworx.com \
        --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
        --token-duration=1y)
    ```

3. Save the tenant Kubernetes token in a secret called `<tenant namespace>/px-k8s-user`:

    ```text
    kubectl -n <tenant namespace> create secret \
      generic px-k8s-user --from-literal=auth-token=$TENANT_TOKEN
    ```

Kubernetes storage classes can now be set up to use this secret to
get access to the token to communicate with Portworx.

Once you have completed the steps in this section, continue to the **Set up the StorageClass**
section.
