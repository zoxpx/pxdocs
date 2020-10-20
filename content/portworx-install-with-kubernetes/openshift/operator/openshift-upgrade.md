---
title: Preparing Portworx to upgrade to OpenShift 4.3 using the Operator
linkTitle: Prepare to upgrade to OpenShift 4.3
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Find out how to upgrade Portworx for OpenShift 4.3 using Operator.
weight: 4
---

Before you can upgrade your OpenShift environment to 4.3, you must upgrade Portworx to 2.3.5 and expose a new port range so that Portworx can continue to operate. Perform the following steps to upgrade Portworx to 2.3.5 in preparation for upgrading your OpenShift environment:

1. From the OpenShift console, upgrade the Portworx Operator to version 1.1.1 newer.

2. [Upgrade Portworx](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/upgrade/upgrade-operator) to 2.3.5.

3. Verify that all of your nodes have upgraded to 2.3.5:

    ```text
    oc get storagenode -n kube-system
    ```
    ```output
    NAME     ID                                     STATUS   VERSION           AGE
    node-1   04904446-781b-4e12-b1ce-753a9e72dd49   Online   2.3.5.0-a5a0ba1   68s
    node-2   b7a9e162-3166-475f-af6b-3860a4dc2b06   Online   2.3.5.0-a5a0ba1   2m
    node-3   8c182888-280a-4738-abf8-3bccaadeb359   Online   2.3.5.0-a5a0ba1   3m
    ```

4. Open the port ranges on your cloud provider and operating system to allow traffic on ports 17001 - 17020.

5. Change your Portworx cluster's start port:

    1. Enter the `oc edit` command to modify your storage cluster:

        ```text
        oc edit -n kube-system <storagecluster_name>
        ```
    2. Change the `startPort` value in your `StorageCluster` spec to `17001`:

        ```text
        apiVersion: core.libopenstorage.org/v1alpha1	      
        kind: StorageCluster	      
        metadata:	      
          name: portworx	        
          namespace: kube-system	        
        spec:	      
          startPort: 17001
        ```

Once Portworx is running on 2.3.5 and you've changed the port range, you may upgrade OpenShift to 4.3.
