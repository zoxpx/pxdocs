---
title: Simple Security Setup
description: Simple security setup using self signed tokens
keywords: portworx, kubernetes, security, jwt, secret
weight: 1
series: kubernetes-security-ref-archs
---

The following describes how to setup Portworx security and authenticating Kubernetes as a client to Portworx. This model leverages user authentication executed by Kubernetes, then has secures the communication between Kubernetes and Portworx. This model protects the storage system from unwanted access from outside Kubernetes.

The following is based on Portworx 2.1.x+ with security.

## Generating secrets

This guide uses a model based on [_shared
secrets_](/concepts/authorization/overview/#security-tokens) as the method to
create and verify tokens. The goal is to store the shared secrets in a secure
Kubernetes Secret object to then provide to Portworx.

Let's generate a few [secure secrets](/concepts/authorization/pre-install/#self-signing-tokens)
and save the values in [environment variables](/concepts/authorization/install/#environment-variables):

```
PORTWORX_AUTH_SYSTEM_KEY=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1)
PORTWORX_AUTH_STORK_KEY=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1)
PORTWORX_AUTH_SHARED_SECRET=$(cat /dev/urandom | base64 | fold -w 64 | head -n 1)
```

Now we can store these shared secrets securely in a Kubernetes secret called
`pxkeys` in the `kube-system` namespace:

```
kubectl -n kube-system create secret generic pxkeys \
   --from-literal=system-secret=$PORTWORX_AUTH_SYSTEM_KEY \
   --from-literal=stork-secret=$PORTWORX_AUTH_STORK_KEY \
   --from-literal=shared-secret=$PORTWORX_AUTH_SHARED_SECRET
```

Before continuing, test that the secret stored is correct by comparing `$PORTWORX_AUTH_SHARED_SECRET`
with the value returned below:

```
kubectl -n kube-system get secret pxkeys -o json | jq -r '.data."shared-secret"' | base64 -d
```

## Create and download a Portworx install manifest

If you do not already have a manifest, please go to [PX-Central](https://central.portworx.com)
to generate and download a deployment yaml for your configuration. 
You will then need to edit the Portworx manifest yaml file as shown in
the [example](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/enable/#example).

This is necessary to instruct Kubernetes to create and provide Portworx with
environment variables whos values are retreived securely from the Secret object
created above.

When you edit the file, please use the checklist below assert that all the
have been done:

1. Stork shared key needs to be added to stork and to Portworx as shown in the [documentation](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/enable).
1. System key needs to be added to Portworx
1. Shared key needs to be added to Portworx
1. The Token issuer value needs to be added. The issuer is a string value which must identify the token generator. The token generator must set this value in the token itself under the `iss` claim. This value will be used by Portworx to identify the token generator. In this example, the issuer is set to `portworx.com`, but you are encouraged to change it to another name.

The following is an example of the `diff` of the changes to the Portworx manifest:

```diff
170c170
<              "-x", "kubernetes"]
---
>              "-x", "kubernetes", "-jwt_issuer", "portworx.com"]
178c178,192
<             
---
>             - name: "PORTWORX_AUTH_JWT_SHAREDSECRET"
>               valueFrom:
>                 secretKeyRef:
>                   name: pxkeys
>                   key: shared-secret
>             - name: "PORTWORX_AUTH_SYSTEM_KEY"
>               valueFrom:
>                 secretKeyRef:
>                   name: pxkeys
>                   key: system-secret
>             - name: "PORTWORX_AUTH_STORK_KEY"
>               valueFrom:
>                 secretKeyRef:
>                   name: pxkeys
>                   key: stork-secret
```

In the stork section, the Deployment template must have the following

```
>         - name: "PX_SHARED_SECRET"
>           valueFrom:
>             secretKeyRef:
>               name: pxkeys
>               key: stork-secret
```

You can now apply the manifest and wait until Portworx is ready.

## Generate tokens

Now that the system is up and running you can create tokens. You will need to
ssh to one of the nodes to use `pxctl` to generate tokens.

{{<info>}}
If you want to create your own application to generate tokens, you
can base it on our open source golang example library [openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth)
{{</info>}}

### Creating user files

You will need to create at least two user files. These files are used as
inputs to [`pxctl`](/reference/cli/authorization/#generate_tokens)
to create tokens. One will be the storage admin token used for `pxctl` to
communicate with Portworx, and the second will be for Kubernetes to
provision and manage volumes.

Create a file with the following information for the storage admin. The
storage admin is a special user token (like `root` in Linux) which has
access to all APIs and all resources as specified in the [documentation](/concepts/authorization/overview/#the-administrator-role).
In this example, you can call this file `admin.yaml`.

```yaml
name: Storage Administrator
email: the email of the storage admin
sub: ${uuid} or email of the storage admin
roles: ["system.admin"]
groups: ["*"]
```

{{<info>}}
The `sub` is the unique identifier for this user and most not be shared amongst
other tokens according to the JWT standard. This is the value used by Portworx
to track ownership of resources. If `email` is also used as the `sub` unique
identifier, please make sure it is not used by any other tokens.

More information on the rules of each of the value can be found on the
[openstorage-sdk-auth](https://github.com/libopenstorage/openstorage-sdk-auth#usage) repo.
{{</info>}}

Now create a file for Kubernetes to communicate with Portworx. You can call
this file `kube.yaml`:

```yaml
name: Kubernetes User
email: the email of the kubernetes admin
sub: ${uuid} or email of the kubernetes admin
roles: ["system.user"]
groups: ["kubernetes"]
```

### Saving the tokens

Now you can create a tokens. Notice in the example below that we have set the
issuer to match the setting in the Portworx manifest to `portworx.com` as set
the value for `-jwt-issuer`. The example also sets the duration of the token
to one year. You may want to adjust it to a much shorter duration if you plan
on refreshing the token often.

The example below sets creates an admin token which is then output to the screen.
You will also need to have the _shared secret_ created above. In the example below,
the secret is saved in the environment variable `$PORTWORX_AUTH_SHARED_SECRET`.

```
/opt/pwx/bin/pxctl auth token generate \
  --auth-config=admin.yaml \
  --issuer=portworx.com \
  --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
  --token-duration=1y
```

With the admin token, you can now create a context for `pxctl` which will be
saved in `$HOME/.pxctl` of the node. For more information please
see [Context](/reference/cli/authorization/#context).

In the example below, the admin token is saved as the context `admin`:

```
/opt/pwx/bin/pxctl context create admin \
  --token=ey...3d
```

Now, you can also generate the token for Kubernetes:

```
/opt/pwx/bin/pxctl auth token generate \
  --auth-config=kube.yaml \
  --issuer=portworx.com \
  --shared-secret=$PORTWORX_AUTH_SHARED_SECRET \
  --token-duration=1y
```

This token will be used by Kubernetes for Portworx volume management
calls. You will need to save this token as a Kubernetes secret.
In the example below, it saves it as `portworx/px-k8s-user`:

```
kubectl -n portworx create secret generic px-k8s-user --from-literal=auth-token=ey...f3
```

Kubernetes storage classes can now be setup to use this secret to
get access to the token to communicate with Portworx.

{{<info>}}
If you want to can also add this token to the `pxctl` context so that
you can switch users running commands to Portworx.
{{</info>}}

## Storage Class
Create a storage class to use secret:

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: px-storage
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
  openstorage.io/auth-secret-name: px-k8s-user
  openstorage.io/auth-secret-namespace: portworx
allowVolumeExpansion: true
```

## Example application
PVC:

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    volume.beta.kubernetes.io/storage-class: px-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

MySQL:
```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mysql
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
        version: "1"
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-data
```
