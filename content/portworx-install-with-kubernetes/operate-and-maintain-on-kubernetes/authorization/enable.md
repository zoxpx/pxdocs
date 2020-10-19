---
title: Enabling Authorization
description: Enable Portworx authorization in Kubernetes
keywords: authorization, security, kubernetes, k8s
weight: 100
series: k8s-op-maintain-auth
---

Before proceeding with this document, please review the [Security](/concepts/authorization) model used by Portworx.

{{<info>}}
**NOTE:**

* For a step by step setup of guide of how to enable Portworx authorization, please see [Securing your Portworx system](/cloud-references/security/).
* The following will be a cluster level interruption event while all the
nodes in the system come back online with security enabled.
{{</info>}}


## Enabling authorization with the Portworx Operator

With the release of Portworx Operator 1.4, you can easily set up security in your `StorageCluster` spec with a single flag:

```text
apiVersion: core.libopenstorage.org/v1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  image: portworx/oci-monitor:2.6.0.1
  security:
    enabled: true
```

For a detailed guide of installing Portworx Security with the Operator, please see [Securing your storage with the Operator](/cloud-references/security/kubernetes/shared-secret-model-operator/).


### Migrating from Portworx Manifest to StorageCluster Security spec

In order for Portworx to start with security enabled, it requires a few different environment variables. If you wish to start using the `StorageCluster` security spec, here is how you can migrate your environment variables to spec fields. 

1. First, familiarize yourself with the Security spec in the [StorageCluster](/reference/crd/storage-cluster) article.

2. Create a Kubernetes secret for your shared-secret:
```
kubectl create secret generic -n kube-system px-shared-secret \
  --from-literal=shared-secret=$EXISTING_SHARED_SECRET_VALUE
```

3. Add the following `spec.security` section in your `StorageCluster`:

    ```text
    apiVersion: core.libopenstorage.org/v1
    kind: StorageCluster
    metadata:
      name: px-cluster
      namespace: kube-system
    spec:
      security:
        enabled: true
        auth:
          selfSigned:
            issuer: '<value from your PORTWORX_AUTH_JWT_ISSUER environment variable>'
            sharedSecret: 'px-shared-secret'
    ```

4. Remove the `PORTWORX_AUTH_JWT_ISSUER` and `PORTWORX_AUTH_JWT_SHAREDSECRET` env variables from your StorageCluster env spec.

5. You can now apply the StorageCluster spec and wait until Portworx is ready.

### Migrating to auto-generated Portworx Security system secrets

Another feature of Portworx Operator Security is that you can allow the Operator to auto-generate all required system secrets. This can greatly decrease the complexity of your PX Security deployment. The auto-generated secrets are random 64 character strings and are base64 encoded. This is a zero downtime migration and can be achieved with the following `StorageCluster` changes:

1. Add the following to your `StorageCluster` security spec:

    ```text
    apiVersion: core.libopenstorage.org/v1
    kind: StorageCluster
    metadata:
      name: px-cluster
      namespace: kube-system
    spec:
      security:
        enabled: true
        auth:
          selfSigned:
            issuer: '<value from your PORTWORX_AUTH_JWT_ISSUER environment variable>'
            sharedSecret: 'px-shared-secret'
    ```

2. Remove the `PORTWORX_AUTH_SYSTEM_KEY` and `PORTWORX_AUTH_STORK_KEY` environment variables in your `StorageCluster` spec.env.

3. Remove the `PX_SHARED_SECRET` environment variable in your `StorageCluster` spec.stork.env

After applying the above `StorageCluster`, Portworx will restart with Security enabled using an auto-generated system secret and stork secret. These two secrets are used for internal Portworx communication between nodes and services.

## Enabling authorization with a Portworx Manifest

To enable authorization you must simply edit your Portworx `yaml` configuration
to add the appropriate information. You must first create a Kubernetes Secret which holds the values of the environment variables. Then populate the environment variables required from your Secret. Here is an example of how to
setup an environment variable from a Secret:

1. Generate the following random secret keys:

    ```text
    PORTWORX_AUTH_SYSTEM_KEY=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1) \
    PORTWORX_AUTH_STORK_KEY=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1) \
    PORTWORX_AUTH_SHARED_SECRET=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1)
    ```

2. Create a secret for all Portworx Security keys: 

    ```text
    kubectl create secret generic pxkeys \
      --from-literal=system-secret=$PORTWORX_AUTH_SYSTEM_KEY \
      --from-literal=shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
      --from-literal=stork-secret=$PORTWORX_AUTH_SHARED_SECRET
    ```

3. Edit your Portworx manifest YAML to include the following:

    ```text
    ...
      name: stork
      env:
        - name: "PX_SHARED_SECRET"
          valueFrom:
            secretKeyRef:
              name: pxkeys
              key: stork-secret
    ...
      name: portworx
      args:
      [..."-jwt_issuer", "myissuer", ...]
      env:
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
    ...
    ```

## Upgrading to Authorization enabled

Prior to 2.6, users must be certain that all [PVCs have user tokens secrets](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/manage) associated with them. If this is not the case, Kubernetes users will not be able to use any Portworx PVCs or create new ones. This means that in order to upgrade to `auth enabled` without any disruption, the admin must add token secrets to all PVCs.

Starting with Portworx 2.6+, upgrading from `auth disabled` to `auth enabled` will not cause any issues for Kubernetes end users. This is because the [system guest role](/concepts/authorization/overview#guest-access) will allow Kubernetes users to create and use [public volumes](/concepts/authorization/overview#public-volumes). However, users are encouraged to make their volumes private by adding authorization to their PVCs.

## Step by step guide

For a step by step guide of how to enable Portworx authorization, please see
[Securing your Portworx system](/cloud-references/security/).
