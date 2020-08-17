---
title: Shared content for all Kubernetes secrets docs - per volume secret
keywords: Kubernetes Secrets, k8s
description: Shared content for all Kubernetes secret docs - per volume secret
hidden: true
---

For encrypting volumes using specific secret keys, you need to provide that key for every create and attach command.

To create an **encrypted** volume using a specific secret through Portworx CLI, run the following command:

```text
pxctl volume create --secure --secret_key key1 enc_vol
```

```output
Encrypted volume successfully created: 374663852714325215
```

To create a **shared encrypted** volume run the following command:

```text
pxctl volume create --sharedv4 --secret_key key1 --secure --size 10 enc_shared_vol
```

```output
Encrypted Sharedv4 volume successfully created: 77957787758406722
```

To create an **encrypted** volume using a specific secret through docker, run the following command:

```text
docker volume create --volume-driver pxd secret_key=key1,name=enc_vol
```

To create an **encrypted shared** volume using a specific secret through docker, run the following command:

```text
docker volume create --volume-driver pxd shared=true,secret_key=key1,name=enc_shared_vol
```

To attach and mount an encrypted volume through docker, run the following command:

```text
docker run --rm -it -v secure=true,secret_key=key1,name=enc_vol:/mnt busybox
```
