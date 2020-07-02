---
title: "Enable security in Portworx"
keywords: authorization, portworx, security, rbac, jwt
---


This document guides you through editing the Portworx manifest YAML file as shown in
the Enabling authorization section [example](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/enable/#example).

This procedure instructs Kubernetes to create and provide Portworx with
environment variables whose values are retrieved securely from the Secret object
created in the Generate shared secrets section.

## Prerequisites

* If you do not already have a manifest, visit [PX-Central](https://central.portworx.com)
to generate and download a deployment YAML for your configuration.
* You must have a value for the [token issuer](/concepts/authorization/install/#configuration). The issuer is a string value which must identify the token generator. This value will be used by Portworx to identify the token generator. In the examples below the issuer is set to `portworx.com`, but you are encouraged to change it.

## Using Portworx DaemonSet

If you are deploying Portworx without the Portworx operator, then perform the following steps to enable security in Portworx:

<!-- the way this was written has me questioning whether I'm supposed to have done something already. Do users 'edit the Portworx YAML manifest' as part of these steps, or somewhere before them? -->

1. Add issuer to the `portworx` DaemonSet under `portworx/oci-monitor` container args:

    ```
       ... "-jwt_issuer", "portworx.com"]
    ```

2. Add references to the shared keys as environment variables to
`portworx/oci-monitor`:

    ```text
        - name: "PORTWORX_AUTH_JWT_SHAREDSECRET"
          valueFrom:
            secretKeyRef:
              name: pxkeys
              key: shared-secret
        - name: "PORTWORX_AUTH_SYSTEM_KEY"
          valueFrom:
            secretKeyRef:
              name: pxkeys
              key: system-secret
        - name: "PORTWORX_AUTH_STORK_KEY"
          valueFrom:
            secretKeyRef:
              name: pxkeys
              key: stork-secret
    ```

3. Add references to the shared key to `openstorage/stork`:

    ```text
        - name: "PX_SHARED_SECRET"
          valueFrom:
            secretKeyRef:
              name: pxkeys
              key: stork-secret
    ```

4. You can now apply the manifest and wait until Portworx is ready.

## Using Portworx Operator

If you are deploying Portworx using the Portworx operator, then perform the following steps to enable security:

1. Add issuer and references to the shared keys as environment variables under `spec.env` of your StorageCluster:

    ```text
       apiVersion: core.libopenstorage.org/v1alpha1
       kind: StorageCluster
       metadata:
         name: px-cluster
         namespace: kube-system
       spec:
         ...
         env:
         - name: "PORTWORX_AUTH_JWT_ISSUER"
           value: "portworx.com"
         - name: "PORTWORX_AUTH_JWT_SHAREDSECRET"
           valueFrom:
             secretKeyRef:
               name: pxkeys
               key: shared-secret
         - name: "PORTWORX_AUTH_SYSTEM_KEY"
           valueFrom:
             secretKeyRef:
               name: pxkeys
               key: system-secret
         - name: "PORTWORX_AUTH_STORK_KEY"
           valueFrom:
             secretKeyRef:
               name: pxkeys
               key: stork-secret
    ```

2. Add references to the shared key under `spec.stork.env` section of your StorageCluster:

    ```text
       apiVersion: core.libopenstorage.org/v1alpha1
       kind: StorageCluster
       metadata:
         name: px-cluster
         namespace: kube-system
       spec:
         ...
         stork:
           enabled: true
           env:
           - name: "PX_SHARED_SECRET"
             valueFrom:
               secretKeyRef:
                 name: pxkeys
                 key: stork-secret
    ```

3. You can now apply the `StorageCluster` spec and wait until Portworx is ready.

<!-- are there any instructions for this? -->

Once you've enabled security in Portworx, continue to the **Generate tokens** section.
