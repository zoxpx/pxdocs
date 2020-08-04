---
hidden: true
---

Set the default cluster wide secret. Any PVC request that references this cluster-wide secret using the `px/secret-name: default` annotation will use this cluster-wide secret as a passphrase to encrypt the volume.

1. Set the cluster-wide secret key. Enter the following `pxctl secrets set-cluster-key` command specifying the `--secret` parameter with your secret passphrase (this example uses `mysecretpassphrase`):

    ```text
    pxctl secrets set-cluster-key --secret mysecretpassphrase
    ```

    ```output
    Successfully set cluster secret key!
    ```
    {{<info>}}
**WARNING:** You must set the cluster-wide secret only once. If you overwrite the cluster-wide secret, the volumes encrypted with the old secret will become unusable.
    {{</info>}}

    If you've specified your cluster wide secret key in the `config.json` file, the `pxctl secrets set-cluster-key` command will overwrite it. Even if you restart your cluster, Powrtworx will use the key you passed as an argument to the `pxctl secrets set-cluster-key` command.

2. Create a `StorageClass`, specifying the following fields and values:
  * **metadata.name** with the name of your `StorageClass` (this example uses `px-secure-sc`)
  * **secure:** with the `true` value
  * **repl:** with the desired number of replicas (this example creates 3 replicas)

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: px-secure-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      secure: "true"
      repl: "3"
    ```

    With Portworx, you can create two types of encrypted volumes:

    * **Encrypted Volumes**. You can access a regular volume from a single node.
    * **Encrypted Shared Volumes**. You can access an encrypted shared volume from multiple nodes.

    To create a **shared encrypted volume**, you must specify the `shared: "true"` flag in the `parameters` section of your storage class:

    Example:

    ```text
    parameters:
      secure: "true"
      repl: "3"
      shared: "true"
    ```

3. Create a PVC, specifying the following fields and values:
  * **metadata.name** with the name of your PVC (this example uses `mysql-data`)
  * **metadata.annotations.px/secret-name** with the `default` value. This annotation specifies that Portworx must use the default secret to encrypt the volume. If the annotation is not provided, then Portworx will use the per volume encryption workflow. See the [Encrypt volumes using per volume secrets](#encrypt-volumes-using-per-volume-secrets) section for details.
  * **metadata.annotations.volume.beta.kubernetes.io/storage-class** with the name of the `StorageClass` you created in the previous step (this example uses `px-secure-sc`).
  * **spec.storageClassName** with the name of the `StorageClass` you created in the previous step (this example uses `px-secure-sc`)

    ```text
    cat <<EOF | kubectl apply -f -
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: mysql-data
      annotations:
        px/secret-name: default
        volume.beta.kubernetes.io/storage-class: px-secure-sc
    spec:
      storageClassName: px-secure-sc
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 2Gi
    EOF
    ```

    If you do not want to specify the `secure: "true"` flag in your storage class, but you want to encrypt the PVC using that storage class, then you must specify the `px/secure: "true"` flag in the `metadata` section of your PVC.

      Example:

      ```text
      cat <<EOF | kubectl apply -f -
      kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
        name: secure-pvc
        annotations:
          px/secret-name: default
          volume.beta.kubernetes.io/storage-class: px-secure-sc
          px/secure: "true"
      spec:
        storageClassName: portworx-sc
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 2Gi
      EOF
      ```

4. You can verify that your new Portworx volume is encrypted by entering the following commands:

    ```text
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume list
    ```

    ```output
    ID                 NAME                                      ...  ENCRYPTED  ...
    10852605918962284  pvc-5a885584-44ca-11e8-a17b-080027ee1df7  ...  yes        ...
    ```

If you want to migrate encrypted volumes created through this method between two different Portworx clusters, then you must:

  1. Create a secret with the same name. You can use the `--secret-id` flag to specify the name of your secret, as shown in step 1.
  2. Make sure you provide the same **passphrase** while generating the secret.
