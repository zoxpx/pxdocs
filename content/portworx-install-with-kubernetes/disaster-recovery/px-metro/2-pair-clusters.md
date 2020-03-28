---
title: 2. Pair Clusters
weight: 2
keywords: Asynchronous DR, disaster recovery, kubernetes, k8s, cloud, backup, restore, snapshot, migration
description: Find out how to pair your clusters
---

## Understand cluster pairing

In order to failover an application running on one Kubernetes cluster to another Kubernetes cluster, you need to migrate the resources between them.
On Kubernetes you will define a trust object required to communicate with the other Kubernetes cluster called a ClusterPair. This creates a pairing between the scheduler (Kubernetes) so that all the Kubernetes resources can be migrated between them.
Throughout this section, the notion of source and destination clusters apply only at the Kubernetes level and does not apply to Storage, as you have a single Portworx storage fabric running on both the clusters.
As Portworx is stretched across them, the volumes do not need to be migrated.

For reference:

* **Source Cluster** is the Kubernetes cluster where your applications are running.
* **Destination Cluster** is the Kubernetes cluster where the applications will be failed over, in case of a disaster in the source cluster.

{{% content "shared/portworx-install-with-kubernetes-disaster-recovery-cluster-pair.md" %}}

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
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```

Make the following changes in the `options` section of your `ClusterPair`:

* This example uses a single storage fabric. Thus, you must delete the `<insert_storage_options_here>: ""` line.
* By default, every seventh migration is a full migration. To make every migration incremental, specify `mode: DisasterRecovery` as follows:

      ```
      options:
         mode: DisasterRecovery
      ```

Once you've made the changes, save the resulting spec to a file named `clusterpair.yaml`.

{{<info>}}
**NOTE:**
For an example that uses more than one storage fabric, see the [Asynchronous DR](/portworx-install-with-kubernetes/disaster-recovery/async-dr/#enable-disaster-recovery-mode) page.
{{</info>}}


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
