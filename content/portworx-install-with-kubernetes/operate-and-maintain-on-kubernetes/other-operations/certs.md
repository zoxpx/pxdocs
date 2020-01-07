---
title: "Certificates as Kubernetes Secrets"
keywords: SSL certificates, certs, kubernetes secrets, k8s
description: Certificates as Kubernetes secrets.
---

Sometimes it is necessary to store an SSL certificate as a Kubernetes secret. The example here is to secure a third-party S3-compatible objectstore for use with Portworx.

### Creating the secret

 * Copy your certificate to somewhere `kubectl` is configured for this Kubernetes cluster. We will call the file `objectstore.pem` and copy it to the `/opt/certs` folder.
 * Create the secret:

```text
kubectl -n kube-system create secret generic objectstore-cert --from-file=/opt/certs/
```

 * Confirm it was created correctly:

```text
kubectl -n kube-system describe secret objectstore-cert
```

 * Update the Portworx DaemonSet to add the mount secret and the environment variable:

```text
kubectl -n kube-system edit ds portworx
```

The `volumeMounts:` section in the daemonset will have:

```text
volumeMounts:
  - mountPath: /etc/pwx/objectstore-cert
    name: objectstore-cert
```

The `volumes:` section in the daemonset will have:

```text
volumes:
  - name: objectstore-cert
    secret:
      secretName: objectstore-cert
      items:
      - key: objectstore.pem
        path: objectstore.pem
```

The `env:` section in the daemonset will have:

```text
env:
  - name: "AWS_CA_BUNDLE"
    value: "/etc/pwx/objectstore-cert/objectstore.pem"
```

 * After saving the modified daemonset, Portworx will restart in a rolling update.
