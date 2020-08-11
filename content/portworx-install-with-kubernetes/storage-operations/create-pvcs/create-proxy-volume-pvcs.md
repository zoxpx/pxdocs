---
title: Create proxy volume PVCs
weight: 4
keywords: create proxy volumes, PVC, kubernetes, k8s
description: Proxy an external data source onto a Portworx volume. 
series: k8s-vol
display: hidden
---

{{<info>}}
**NOTE:** This feature is available as a preview in Portworx version 2.6.0-rc4.
{{</info>}}

Portworx proxy volumes proxy an external data source onto a Portworx volume. The actual data for these volumes resides on the external data source and does not consume any storage from the Portworx storage pools.

You can use proxy volumes to proxy an external NFS share onto your volumes. If you have an NFS share residing outside of a Kubernetes cluster and you wish to access it within an application pod, you can create a Portworx proxy volume that points to this external NFS share. Portworx acts as a medium and makes the external NFS data available to the pods running in Kubernetes.

Portworx uses the host’s NFS utilities to mount the external NFS share when a Pod using the proxy-volume PVC gets scheduled on a node. Depending on how you configure it, you can mount an entire NFS share to volumes, or you can mount only portions of the NFS share to volumes by specifying a directory sub-path.

## Access an external NFS share

You can access a full NFS share in Portworx as a proxy volume. Application using this spec will have access to the whole NFS share. If you wish to access only a sub directory within an NFS share, refer to the **Accessing a sub-path of an external NFS share** section. The examples in these instructions create a proxy volume for an nginx container.

1. Create a storage class spec for proxy volumes, specifying your own values for the following:

  * **parameters.proxy_endpoint:** With the endpoint of the external NFS share Portworx is reflecting from. 
    {{<info>}}
**NOTE:** The <!-- optional? --> `nfs:` prefix instructs Portworx to use the NFS protocol for reflecting an external datasource.
    {{</info>}}
  * **parameters.proxy_nfs_exportpath:** With the export path on the NFS server. 

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: portworx-proxy-volume-volume
    provisioner: kubernetes.io/portworx-volume
    parameters:
      proxy_endpoint: "nfs:<nfs-share-endpoint>"
      proxy_nfs_exportpath: "/<mount-path>"
    allowVolumeExpansion: true
    ```

2. Apply the spec:

    ```text
    kubectl create -f <storageclass-name>.yaml
    ```

3. Create the Portworx proxy volume PVC spec, specifying your own values for the following:

  * **spec.accessModes:** With the access mode you want to assign to your volumes.
  * **spec.resources.requests.storage:** With the amount of storage you want to allocate to a created volume.

    ```text
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: nfs-data
      labels:
        app: nginx
    spec:
      storageClassName: portworx-proxy-volume-volume
      accessModes:
        - <access-mode>
      resources:
        requests:
          storage: <storage-amount>
    ```

4. Apply the spec:

    ```text          
    kubectl create -f <pvc-name>.yaml
    ```

5. Create a Deployment spec that uses the proxy-volume PVC:

    ```text
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: bitnami/nginx
            ports:
            - containerPort: 80
            volumeMounts:
            - name: nginx-persistent-storage
              mountPath: /usr/share/nginx/html
          volumes:
          - name: nginx-persistent-storage
            persistentVolumeClaim:
              claimName: nfs-data
    ```

5. Apply the spec:

    ```text 
    kubectl create -f <pod-name>.yaml
    ```

## Accessing a sub-path of an external NFS share

You can associate a sub-path of an NFS share with Portworx as a proxy volume. Under this approach, applications will have access to a specific sub-path within the NFS share. The examples in these instructions create a proxy volume for an nginx container.

1. Create a storage class spec for proxy volumes, specifying your own values for the following:

  * **parameters.proxy_endpoint:** With the endpoint of the external NFS share Portworx is reflecting from. 
    {{<info>}}
**NOTE:** The <!-- optional? --> `nfs:` prefix instructs Portworx to use the NFS protocol for reflecting an external datasource.
    {{</info>}}
  * **parameters.proxy_endpoint:** With the export path on the NFS server. 

    ```text
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: portworx-proxy-volume-volume
    provisioner: kubernetes.io/portworx-volume
    parameters:
      proxy_endpoint: "nfs:<nfs-share-endpoint>"
      proxy_nfs_exportpath: "/<mount-path>"
    allowVolumeExpansion: true
    ```

2. Apply the spec:

    ```text
    kubectl create -f <storageclass-name>.yaml
    ```

3. Create the Portworx proxy volume PVC spec, specifying your own values for the following:

  *  **metadata.annotations.px/proxy-nfs-subpath:** With the path to the sub-path directory. Volumes created from this PVC will only have access the sub-path, and none of the directories above it. If the sub-path does not exist, Portworx will create it in the NFS share.
    {{<info>}}
**NOTE:** From the external NFS share only the sub-path provided as the annotation will be accessible to this PVC. The parent NFS share or any other directories will not be accessible.
    {{</info>}}

  * **spec.accessModes:** With the access mode you want to assign to your volumes.
  * **spec.resources.requests.storage:** With the amount of storage you want to allocate to a created volume.

    ```text
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: nfs-data
      annotations:
        px/proxy-nfs-subpath: "<path>/<sub-path>"
      labels:
        app: nginx
    spec:
      storageClassName: portworx-proxy-volume-volume
      accessModes:
        - <access-mode>
      resources:
        requests:
          storage: <storage-amount>
    ```

    {{<info>}}
**NOTE:** This PVC can only access the `<sub-path>` directory and its contents.
    {{</info>}}
          
4. Apply the spec:

    ```text
    kubectl create -f <pvc-for-sub-path-name>.yaml
    ```

5. Create a Deployment spec that uses the proxy-volume PVC you created in the step above:

    ```text
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: bitnami/nginx
            ports:
            - containerPort: 80
            volumeMounts:
            - name: nginx-persistent-storage
              mountPath: /usr/share/nginx/html
          volumes:
          - name: nginx-persistent-storage
            persistentVolumeClaim:
              claimName: nfs-data
    ```

6. Apply the spec:

    ```text
    kubectl create -f <pod-name>.yaml
    ```

