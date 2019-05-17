---
title: "2. Pair Clusters"
weight: 2
keywords: cloud, backup, restore, snapshot, DR, migration, px-motion
description: Find out how to pair your clusters
---

## Pairing clusters
In order to failover an application running on one Kubernetes cluster to another Kubernetes cluster, we need to migrate the resources between them.
On Kubernetes you will define a trust object required to communicate with the other Kubernetes cluster called a ClusterPair. This creates a pairing between the scheduler (Kubernetes) so that all the Kubernetes resources can be migrated between them.
Throughout this section, the notion of source and destination clusters apply only at the Kubernetes level and does not apply to Storage, as you have a single Portworx storage fabric running on both the clusters.
As Portworx is stretched across them, the volumes do not need to be migrated.

For reference,

* **Source Cluster** is the Kubernetes cluster where your applications are running
* **Destination Cluster** is the Kubernetes cluster where the applications will be failed over, in case of a disaster in the source cluster.

{{% content "portworx-install-with-kubernetes/disaster-recovery/shared/cluster-pair.md" %}}

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterPair
metadata:
    creationTimestamp: null
    name: remotecluster
    namespace: migrationnamespace
spec:
   config:
      clusters:
         kubernetes:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            certificate-authority-data: <CA_DATA>
            server: https://192.168.56.74:6443
      contexts:
         kubernetes-admin@kubernetes:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            cluster: kubernetes
            user: kubernetes-admin
      current-context: kubernetes-admin@kubernetes
      preferences: {}
      users:
         kubernetes-admin:
            LocationOfOrigin: /etc/kubernetes/admin.conf
            client-certificate-data: <CLIENT_CERT_DATA>
            client-key-data: <CLIENT_KEY_DATA>
    options:
       <insert_storage_options_here>: ""
       mode: DisasterRecovery
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```

In the generated **ClusterPair** spec, you will need to do the following modifications:

  * You will see an unpopulated *options* section. It expects options that are required to pair Storage. However, as we have a single storage fabric, this section is not needed. You should delete the line `<insert_storage_options_here>`.
  * Under the options section, the mode is set to **DisasterRecovery**, this is required for scheduling periodic migrations. More information about it in the next step.

Once the modifications are done, save it into a file `clusterpair.yaml`

#### Apply the generated ClusterPair on the source cluster

On the **source** cluster create the clusterpair by applying the generated spec.

```text
kubectl create -f clusterpair.yaml
```

### Verify the Pair status
Once you apply the above spec on the source cluster you should be able to check the status of the pairing using storkctl on the source cluster.

```text
storkctl get clusterpair
```

```output
NAME               STORAGE-STATUS   SCHEDULER-STATUS   CREATED
remotecluster      NotProvided      Ready              09 Apr 19 18:16 PDT
```

So, on a successful pairing you should see the "Scheduler Status" as "Ready" and the "Storage Status" as "Not Provided"

Once the pairing is configured, applications can now failover from one cluster to another. In order to achieve that, we need to migrate the Kubernetes resources to the destination cluster. The next step will help your synchronize the Kubernetes resources between your clusters.
