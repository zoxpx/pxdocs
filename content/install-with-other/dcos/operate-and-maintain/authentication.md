---
title: Portworx Authorization with DC/OS
description: Learn how to enable auth and interact with your auth enabled Portworx cluster through DC/OS.
keywords: authorization, DCOS, DC/OS, Mesoshphere
weight: 3
linkTitle: Authorization with Portworx clusters
---

{{<info>}}
This document presents the **DC/OS** method of enabling authorization for your Portworx cluster. Please refer to the [Authorization](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/authorization/) page if you are running Portworx on Kubernetes.
{{</info>}}

Once your Portworx Cluster has been [setup as auth-enabled](/concepts/authorization/install), there are a few steps you must take to integrate DC/OS with your auth-protected cluster.

## Authorization with your Portworx Cluster
There are two ways you can authenticate with your cluster now that it is auth-enabled:

* Pass JWT token as a DC/OS Secret
* Pass raw JWT auth token in volume parameters/options

### DC/OS token_secret (recommended)
This is the recommended method for authenticating with your auth-enabled Portworx Cluster. You must pass the `token_secret` parameter/option during volume operations. Found below is an example of how you can create a DC/OS secret and reference it with `docker volume create`. The same `token_secret` parameter can be used with other DC/OS and docker volume commands.

First, you need to create a [DC/OS secret](/key-management/dc-os-secrets/) for your auth token(s)

```text
dcos security secrets create --value=<auth-token> pwx/secrets/user1-token
```

Next, pass the secret name in as a parameter or option during volume creation or other operations. This is the same as passing any other parameter or option during Portworx volume creation through DC/OS.

```text
docker volume create -d pxd --name token_secret=pwx/secrets/user1-token,repl=3,name=myvol1
```

### Raw JWT token

Similar to other Portworx volume options, you must pass `token` as an inline parameter:

```text
docker volume create -d pxd --name token=<jwt-auth-token>,repl=3,name=myvol2
```
