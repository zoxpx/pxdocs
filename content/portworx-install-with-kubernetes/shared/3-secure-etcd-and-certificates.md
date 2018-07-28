---
title: Shared
hidden: true
---

**Note:** This section only applies if you are using secure etcd.

We recommend that you use Kubernetes Secrets to provide etcd certificates to Portworx. By using Kubernetes Secrets, the certificates will mount automatically when new nodes join the cluster.

Copy all your etcd certificates and key in a folder _etcd-secrets/_ to create a Kubernetes secret from it.

```text
etcd-ca etcd-cert   etcd-key
```

Use `kubectl` to create the secret named `px-etcd-certs` from the above files:

```text
kubectl -n kube-system create secret generic px-etcd-certs --from-file=etcd-secrets/
```

Now edit the Portworx spec file to reference the certificates. Given the names of the files are `etcd-ca`, `etcd-cert` and `etcd-key`, modify the `volumeMounts` and `volumes` sections as follows:

```text
  volumeMounts:
  - mountPath: /etc/pwx/etcdcerts
    name: etcdcerts
```

```text
  volumes:
  - name: etcdcerts
    secret:
      secretName: px-etcd-certs
      items:
      - key: etcd-ca
        path: pwx-etcd-ca.crt
      - key: etcd-cert
        path: pwx-etcd-cert.crt
      - key: etcd-key
        path: pwx-etcd-key.key
```

Now that the certificates are mounted at `/etc/pwx/etcdcerts`, change the Portworx container args to use the correct certificate paths:

```text
  containers:
  - name: portworx
    args:
      ["-c", "test-cluster", "-a", "-f",
      "-ca", "/etc/pwx/etcdcerts/pwx-etcd-ca.crt",
      "-cert", "/etc/pwx/etcdcerts/pwx-etcd-cert.crt",
      "-key", "/etc/pwx/etcdcerts/pwx-etcd-key.key",
      "-x", "kubernetes"]
```

