---
title: Encryption using StorageClass
hidden: true
---

Using a Storage Class parameter, you can tell Portworx to encrypt all PVCs created using that Storage Class. Portworx uses a cluster wide secret to encrypt all the volumes created using the secure Storage Class.

#### Step 1: Create cluster wide secret key
A cluster wide secret key is a common key that points to a secret value/passphrase which can be used to encrypt all your volumes.

Below are the 2 options for creating the cluster wide secret key:

##### Option 1: Kubernetes Secrets
Create a cluster wide secret in Kubernetes, if not already created:
```text
$ kubectl -n portworx create secret generic px-vol-encryption \
  --from-literal=cluster-wide-secret-key=<value>
```
Note that the cluster wide secret has to reside in the `px-vol-encryption` secret under the `portworx` namespace.

Now you have to give Portworx the cluster wide secret key, that acts as the default encryption key for all volumes.
```bash
$ PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
$ kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets set-cluster-key \
  --secret cluster-wide-secret-key
```

##### Option 2: Other secrets provider
Similar to Kubernetes secrets, you can set the cluster wide secret key in the secrets provider that you have configured. Refer to the 'Setting cluster wide secret key' section under the respective [secrets provider integration](/key-management).

#### Step 2: Create a StorageClass
Create a storage class with `secure` parameter set to `true`.
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: px-secure-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  secure: "true"
  repl: "3"
```

#### Step 3: Create Persistent Volume Claim
Create a PVC that uses the above `px-secure-sc` storage class.
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: secure-pvc
spec:
  storageClassName: px-secure-sc
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

#### Step 4: Verify the volume
Once the PVC has been created, verify the volume created in Portworx is encrypted.
```
# PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
# kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume list
ID                 NAME                                      ...  ENCRYPTED  ...
10852605918962284  pvc-5a885584-44ca-11e8-a17b-080027ee1df7  ...  yes        ...
```
