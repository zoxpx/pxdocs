---
title: Apache Nifi on Kubernetes and Portworx
linkTitle: Apache Nifi
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, Apache Nifi
description: See how Portworx can be used to deploy a Apache Nifi StatefulSet on top of Kubernetes.
weight: 9
noicon: true
---


Portworx is a software-defined storage overlay that allows you to run highly-available stateful applications. 

This article shows how you can create and run a Apache NiFi production ready cluster on Kubernetes, which stores data on Portworx volumes.

## Prerequisites

* You must have a Kubernetes cluster with a minimum of 3 worker nodes.
* Portworx is installed on your Kubernetes cluster. For more details on how to install Portworx, refer to the instructions from the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page.


## Create a StorageClass for volume provisioning

1. Use the following command to list the nodes in your cluster:

    ```text
    kubectl get nodes -o wide
    ```

    ```output
NAME                                STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION              CONTAINER-RUNTIME
ip-70-0-15-135.brbnca.spcsdns.net   Ready    master   9d    v1.14.1   70.0.15.135   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.3.0
ip-70-0-15-198.brbnca.spcsdns.net   Ready    <none>   9d    v1.14.1   70.0.15.198   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.3.0
ip-70-0-15-199.brbnca.spcsdns.net   Ready    <none>   9d    v1.14.1   70.0.15.199   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.3.0
ip-70-0-15-200.brbnca.spcsdns.net   Ready    <none>   9d    v1.14.1   70.0.15.200   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.3.0
    ```

2. Define the following `portworx-sc.yaml` StorageClass:

    ```text
    apiVersion: storage.k8s.io/v1beta1
    kind: StorageClass
    metadata:
      name: portworx-nifi-sc
    provisioner: kubernetes.io/portworx-volume
    parameters:
      repl: "3"
      priority_io: "high"
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    ```

3. Apply the StorageClass configuration:

    ```text
    kubectl apply -f portworx-sc.yml
    ```

4. To build environment variables it requires vortex:
    
    Download vortex binary available here (https://github.com/portworx/pxdocs/tree/master/static/samples/k8s/apache-nifi/vortex) at location on master node: /usr/local/bin
    ```text
    chmod +x /usr/local/bin/vortex
    ```

## Apache Nifi installation

1. Clone the repoistory which contains all the required specs: 
    ```text
    git clone https://github.com/portworx/pxdocs.git
    ```

    ```text
    cd pxdocs/static/samples/k8s/apache-nifi
    ```
    
2. Deploy zookeeper
    
    From the zookeeper directory run:
    ```text
    ./build_environment.sh small
    kubectl create -f deployment/
    ```

    Check zookeeper pods status:
    ```text
kubectl get po -n zk
    ```

    ```output
NAME       READY   STATUS    RESTARTS   AGE
pod/zk-0   1/1     Running   0          58m
pod/zk-1   1/1     Running   0          58m
pod/zk-2   1/1     Running   0          58m
    ```
    
    Check zookeeper services status:
    ```text
kubectl get svc -n zk
    ```

    ```output
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/zk-cs   ClusterIP   10.104.1.184   <none>        2181/TCP            58m
service/zk-hs   ClusterIP   None           <none>        2888/TCP,3888/TCP   58m    
    ```

    Check zookeeper pvc's are provisioned from `portworx-nifi-sc` storage class:
    ```text
kubectl get pvc -n zk
    ```

    ```output
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
datadir-zk-0   Bound    pvc-933111a7-86f2-11e9-916b-000c29a48cb7   10Gi       RWO            portworx-nifi-sc   63m
datadir-zk-1   Bound    pvc-9332cd05-86f2-11e9-916b-000c29a48cb7   10Gi       RWO            portworx-nifi-sc   63m
datadir-zk-2   Bound    pvc-9335766d-86f2-11e9-916b-000c29a48cb7   10Gi       RWO            portworx-nifi-sc   63m
    ```

    Check zookeeper is operational:
    ```text
kubectl exec zk-0 cat /opt/zookeeper/conf/zoo.cfg --namespace=zk
kubectl exec zk-0 zkCli.sh create /hello tushar  --namespace=zk
kubectl exec zk-0 zkCli.sh get /hello  --namespace=zk
    ```

3. Deploy Nifi cluster
    
    From the apache-nifi directory run:
    ```text
    ./build_environment.sh default
    ```

    Create the nifi namespace:
    ```text
    kubectl create ns nifi
    ```

    Apply the specs which creates pods, services and pvc's:
    ```text
    kubectl create -f deployment/ -n nifi
    ```

    Check the nifi pods,service and pvc status:
    ```text
    kubectl get pods -n nifi 
    ```

    ```output
NAME      READY     STATUS    RESTARTS   AGE
nifi-0    1/1       Running   0          25m
nifi-1    1/1       Running   0          25m
nifi-2    1/1       Running   0          25m
    ```

    ```text
kubectl get svc -n nifi                
    ```

    ```output
NAME        TYPE           CLUSTER-IP     EXTERNAL-IP                          PORT(S)                      AGE
nifi        ClusterIP      None           <none>                               8081/TCP,2881/TCP,2882/TCP   52m
nifi-0      ExternalName   <none>         nifi-0.nifi.nifi.svc.cluster.local   <none>                       52m
nifi-1      ExternalName   <none>         nifi-1.nifi.nifi.svc.cluster.local   <none>                       52m
nifi-2      ExternalName   <none>         nifi-2.nifi.nifi.svc.cluster.local   <none>                       52m
nifi-3      ExternalName   <none>         nifi-3.nifi.nifi.svc.cluster.local   <none>                       52m
nifi-4      ExternalName   <none>         nifi-4.nifi.nifi.svc.cluster.local   <none>                       52m
nifi-http   NodePort       10.107.71.85   <none>                               8080:31638/TCP               52m
    ```

    Check all the pods of nifi cluster are using pvc's provisioned from `portworx-nifi-sc` storage class.
    ```text
kubectl get pvc -n nifi
    ```

    ```output
NAME                          STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
contentrepository-nifi-0      Bound     pvc-c00b39d5-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
contentrepository-nifi-1      Bound     pvc-c0116c25-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
contentrepository-nifi-2      Bound     pvc-c019d7ee-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
databaserepository-nifi-0     Bound     pvc-c00a3682-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
databaserepository-nifi-1     Bound     pvc-c00f87a8-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
databaserepository-nifi-2     Bound     pvc-c017dbe4-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
flowfilerepository-nifi-0     Bound     pvc-c0096aac-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
flowfilerepository-nifi-1     Bound     pvc-c00df6bb-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
flowfilerepository-nifi-2     Bound     pvc-c016020d-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
provenancerepository-nifi-0   Bound     pvc-c008b6bd-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
provenancerepository-nifi-1   Bound     pvc-c0132c86-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
provenancerepository-nifi-2   Bound     pvc-c01aec6b-4710-11e9-b1b0-42010a800055   5Gi        RWO            portworx-nifi-sc       1d
    ```

4. Once the everything is up and running NiFi user interface is accessible here:
    ```text
    http://<ANY_WORKER_NODE_IP>:<NIFI_HTTP_NODE_PORT>/nifi/
    ```
