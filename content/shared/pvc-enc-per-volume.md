---
hidden: true
---

1. Create a `StorageClass`, specifying the following fields and values:
  * **metadata.name** with the name of your `StorageClass` (this example uses `px-secure-sc`)
  * **secure:** with the `true` value
  * **repl:** with the desired number of replicas (this example creates 3 replicas)

    ```text
    cat <<EOF | kubectl apply -f -
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: px-secure-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      secure: "true"
      repl: "3"
    EOF
    ```

    With Portworx, you can create two types of encrypted volumes:

    * **Encrypted Volumes**. You can access a regular encrypted volume from a single node.
    * **Encrypted Shared Volumes**. You can access an encrypted shared volume from multiple nodes.

    To create an **encrypted shared volume**, you must specify the `shared: "true"` flag in the `parameters` section of your storage class:

    Example:

    ```text
    parameters:
      secure: "true"
      repl: "3"
      shared: "true"
    ```

2. Create a PVC, specifying the following fields and values:
  * **metadata.name** with the name of your PVC (this example uses `mysql-data`)
  * **metadata.annotations.volume.beta.kubernetes.io/storage-class** with the name of the `StorageClass` you created in the previous step (this example uses `px-secure-sc`).
  * **spec.storageClassName** with the name of the `StorageClass` you created in the previous step (this example uses `px-secure-sc`)

    ```text
    cat <<EOF | kubectl apply -f -
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: mysql-data
      annotations:
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

3. You can verify that your new Portworx volume is encrypted by entering the following commands:

    ```text
    PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
    kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl volume list
    ```

    ```output
    ID                 NAME                                      ...  ENCRYPTED  ...
    10852605918962284  pvc-5a885584-44ca-11e8-a17b-080027ee1df7  ...  yes        ...
    ```