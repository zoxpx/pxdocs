---
title: Kubernetes Secrets
logo: /logos/other.png
keywords: portworx, containers, storage, kubernetes
description: Instructions on using Kubernetes secrets with Portworx
weight: 4
disableprevnext: true
series: key-management
noicon: true
---

Portworx can integrate with Kubernetes Secrets to store your encryption keys/secrets and credentials. This guide will help configure Portworx with Kubernetes Secrets. Kubernetes Secrets can then be used to store Portworx secrets for Volume Encryption and Cloud Credentials.

## Configuring Kubernetes Secrets with Portworx {#configuring-kubernetes-secrets-with-portworx}

### New installation

When generating the [Portworx Kubernetes spec file](https://install.portworx.com/), select `Kubernetes` from the `Secrets Store Type` list under `Advanced Settings`. For more details on how to generate Portworx spec for Kubernetes, [click here](/portworx-install-with-kubernetes).

### Existing installation

#### Permissions to access secrets

Portworx stores credentials/secrets in a Kubernetes namespace called `portworx`. It needs permissions to access secrets under this namespace. If you have upgraded Portworx as explained in the _Kubernetes_ section under _Upgrades_ in the _Reference_ topic, then you will not have to create the namespace and roles given below. If the following objects are missing, then create it using `kubectl`:

```text
cat <<EOF | kubectl apply -f -
# Namespace to store credentials
apiVersion: v1
kind: Namespace
metadata:
  name: portworx
---
# Role to access secrets under portworx namespace only
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: px-role
  namespace: portworx
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "create", "update", "patch"]
---
# Allow portworx service account to access the secrets under the portworx namespace
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: px-role-binding
  namespace: portworx
subjects:
- kind: ServiceAccount
  name: px-account
  namespace: kube-system
roleRef:
  kind: Role
  name: px-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

#### Edit the Portworx Daemonset

You will have to edit the Portworx daemonset to use Kubernetes secrets, so that all the new Portworx nodes will start using Kubernetes secrets.

```text
kubectl edit daemonset portworx -n kube-system
```

Add the `"-secret_type", "k8s"` arguments to the `portworx` container in the daemonset. It should look something like this:

```text
  containers:
  - args:
    - -c
    - testclusterid
    - -s
    - /dev/sdb
    - -x
    - kubernetes
    - -secret_type
    - k8s
    name: portworx
```

Editing the daemonset will also restart all the Portworx pods.

## Creating secrets with Kubernetes {#creating-secrets-with-kubernetes}

The following section describes the key generation process with Portworx and Kubernetes which can be used for encrypting volumes.

### Setting cluster wide secret key

A cluster wide secret key is a common key that can be used to encrypt all your volumes. First, let us create a cluster wide secret in Kubernetes using `kubectl`:

```text
kubectl -n portworx create secret generic px-vol-encryption \
  --from-literal=cluster-wide-secret-key=<value>
```

Note that the cluster wide secret has to reside in the `px-vol-encryption` secret under the `portworx` namespace.

Now you have to give Portworx the cluster wide secret key, that acts as the default encryption key for all volumes.

```text
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets set-cluster-key \
  --secret cluster-wide-secret-key
```

This command needs to be run just once for the cluster. If you have added the cluster secret key through _config.json_, the above command will overwrite it. Even on subsequent Portworx restarts, the cluster secret key in _config.json_ will be ignored for the one set through the CLI.

### \(Optional\) Authenticating with Kubernetes Secrets using Portworx CLI

If you wish to quickly try Kubernetes secrets, you can authenticate Portworx with Kubernetes Secrets using Portworx CLI. Run the following command:

```text
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets k8s login
```
{{<info>}}
**Important:**
You need to run this command on all Portworx nodes, so that you could create and mount encrypted volumes on all nodes.
{{</info>}}

If the CLI is used to authenticate with Kubernetes Secrets, for every restart of Portworx container it needs to be re-authenticated with Kubernetes Secrets by running the `k8s login` command on that node.


## Using Kubernetes Secrets with Portworx

{{<homelist series="kubernetes-secret-uses">}}