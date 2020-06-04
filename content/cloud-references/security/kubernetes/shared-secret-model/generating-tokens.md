---
title: "Step 3: Generate tokens"
keywords: generate, token, jwt, pxctl, authorization, security
weight: 30
series: ra-shared-secrets-model
---

Now that the system is up and running you can create tokens.

{{<info>}}
If you want to create your own application to generate tokens, you
can base it on the `libopenstorage` open source golang example application [openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth).
{{</info>}}

SSH to one of your nodes and follow the steps below to use `pxctl` to generate tokens:

## Create user files

[`pxctl`](/reference/cli/authorization/#generate-tokens) uses YAML
configuration files to create tokens. You will be creating two files, one for the [storage admin](/concepts/authorization/overview/#the-administrator-role) token used for `pxctl` to communicate with Portworx
(like _root_ in Linux), and the second for Kubernetes to provision
and manage volumes.

1. Create a file called `admin.yaml` with the the following:

    ```text
    name: Storage Administrator
    email: the email of the storage admin
    sub: ${uuid} or email of the storage admin
    roles: ["system.admin"]
    groups: ["*"]
    ```

2. Create a file called `kubernetes.yaml` with the the following:

    ```text
    name: Kubernetes
    email: the email of the kubernetes admin
    sub: ${uuid} or email of the kubernetes admin
    roles: ["system.user"]
    groups: ["kubernetes"]
    ```

    {{<info>}}
The `sub` is the unique identifier for this user and must not be shared amongst
other tokens according to the JWT standard. This is the value used by Portworx
to track ownership of resources. If `email` is also used as the `sub` unique
identifier, please make sure it is not used by any other tokens.

For more information on the rules of each of the values, visit the
[openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth#usage) repo.
    {{</info>}}

## Generate tokens

Now you can create a token. Notice in the example below that they have set the
issuer to match the setting in the Portworx manifest to `portworx.com` as set
the value for `-jwt-issuer`. The example also sets the duration of the token
to one year. You may want to adjust it to a much shorter duration if you plan
on refreshing the token often.

<!-- this isn't really concept information, so much as it's notes to the task, consider moving this information directly to the steps that occur with it. -->

You will also need to have the _shared secret_ created above. In the example below,
the secret is saved in the environment variable `$PORTWORX_AUTH_SHARED_SECRET`.

1. Get the shared secret:

    ```text
    PORTWORX_AUTH_SHARED_SECRET=$(kubectl -n kube-system get secret pxkeys -o json \
        | jq -r '.data."shared-secret"' \
        | base64 -d)
    ```

2. Create a token for the storage administrator using `admin.yaml`:

    ```text
    ADMIN_TOKEN=$(/opt/pwx/bin/pxctl auth token generate \
        --auth-config=admin.yaml \
        --issuer=portworx.com \
        --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
        --token-duration=1y)
    ```

3. Create a token for the Kubernetes using `kubernetes.yaml`:

    ```text
    KUBE_TOKEN=$(/opt/pwx/bin/pxctl auth token generate \
        --auth-config=kube.yaml \
        --issuer=portworx.com \
        --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
        --token-duration=1y)
    ```

3. Save the storage admin token in the `pxctl` [context](/reference/cli/authorization/#contexts):

    ```text
    /opt/pwx/bin/pxctl context create admin --token=$ADMIN_TOKEN
    ```

4. Save the Kubernetes token in a secret called `portworx/px-k8s-user`:

    ```text
    kubectl -n portworx create secret \
      generic px-k8s-user --from-literal=auth-token=$KUBE_TOKEN
    ```

You can now set up Kubernetes storage classes to use this secret to
get access to the token to communicate with Portworx.

<!-- too much word repetition, reword -->

Once you have completed the steps in this section, continue to the **Storage class setup**
section.
