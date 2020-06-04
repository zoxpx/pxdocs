---
title: "Kubemotion with Stork on Kubernetes"
linkTitle: "Kubemotion with stork"
keywords: cloud, backup, restore, snapshot, DR, migration, kubemotion
description: How to migrate stateful applications on Kubernetes
series: kubemotion
noicon: true
aliases:
  - /cloud-references/migration/migration-stork.html
  - /cloud-references/migration/migration-stork
---

This document will walk you through how to migrate your Portworx volumes between clusters with Stork on Kubernetes.


## Prerequisites

Before we begin, please make sure the following prerequisites are met:

* **Version**: The source AND destination clusters need PX-Enterprise v2.0 or later
release. As future releases are made, the two clusters can have different PX-Enterprise versions (e.g. v2.1 and v2.3).

* **Stork v2.0+** is required on the source cluster.

* **Stork helper** : `storkctl` is a command-line tool for interacting with a set of scheduler extensions.
{{% content "shared/portworx-install-with-kubernetes-disaster-recovery-stork-helper.md" %}}


* **Secret Store** : Make sure you have configured a [secret store](/key-management) on both clusters. This will be used to store the credentials for the objectstore.

* **Network Connectivity**: Ports 9001 and 9010 on the destination cluster should be
reachable by the source cluster.

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

## Show your destination cluster token

On the destination cluster, run the following command from one of the Portworx nodes to get the cluster token. You'll need this token in later steps:

```text
pxctl cluster token show
```

#### Update ClusterPair with storage options

Next, let's edit the  **ClusterPair** spec. Under `spec.options`, add  the following Portworx clusterpair information:

   1. **ip**: the IP address of one of the Portworx nodes on the destination cluster
   2. **port**: the port on which the Portworx API server is listening for requests.
      Default is 9001 if not specified
   3. **token**: the cluster token generated in the [previous step](#show-your-destination-cluster-token)

The updated **ClusterPair** should look like this:

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
      ip: "<ip-address-of-node-in-the-destination-cluster>"
      port: "<port_of_remote_px_node_default_9001>"
      token: "<token_generated_from_destination_cluster>"
status:
  remoteStorageId: ""
  schedulerStatus: ""
  storageStatus: ""
```

Instead of the IP address of the node in the destination cluster, you can use the hostname, or any DNS name.

{{<info>}}
In the updated spec, ensure values for all fields under options are quoted.
{{</info>}}

Copy and save this to a file called `clusterpair.yaml` on the source cluster.

### Creating the ClusterPair

#### Apply the generated ClusterPair on the source cluster

On the **source** cluster, create the clusterpair by applying `clusterpair.yaml`:

```text
kubectl apply -f clusterpair.yaml
```
```output
clusterpair.stork.libopenstorage.org/remotecluster created
```

Note that, when the ClusterPair gets created, Portworx also creates a 100 GiB volume called `ObjectstoreVolume`. If you plan to migrate volumes that are significanlty larger than 100GiB, make sure you check out first the [Migrating Large Volumes](#migrating-large-volumes) section.

#### Verifying the Pair status

Once you apply the above spec on the source cluster, you should be able to check the status of the pairing:

```text
storkctl get clusterpair
```
```output
NAME               STORAGE-STATUS   SCHEDULER-STATUS   CREATED
remotecluster      Ready            Ready              26 Oct 18 03:11 UTC
```
On a successful pairing, you should see the "Storage Status" and "Scheduler Status" as "Ready":

If so, you’re all set and ready to [migrate] (#migrating-volumes-and-resources).

#### Troubleshooting

If instead, you see an error, you should get more information by running:

```text
kubectl describe clusterpair remotecluster
```

{{<info>}}
You might need to perform additional steps for [GKE](gke) and [EKS](eks)
{{</info>}}

## Migrating Volumes and Resources

Once the pairing is configured, applications can be migrated repeatedly to the destination cluster.

{{<info>}}
**NOTE:** If your cluster has a DR license applied to it, you can only perform migrations in DR mode; this includes operations involving the `pxctl cluster migrate` command.
{{</info>}}

### Migrating Large Volumes

When the clusterpair gets created, Portworx automatically creates a 100G volume named *ObjectstoreVolume*. If you attempt to migrate a volume significantly larger than 100G, you will find out that the ObjectStore volume doesn't provide sufficient disk space and the migration will fail.

As an example, say you want to migrate a 1 TB volume. If so, you would need to update the size of the *ObjectstoreVolume* by running:


```text
pxctl volume update --size 1005 ObjectstoreVolume
```

{{<info>}}
Kubemotion uses compression when transferring data. So, if the data is easily compressible, a 100G Objectstore could allow you to transfer more than 100G of data. However, there is no way to tell beforehand how much the data will be compressed.
In our example, we migrated a few docker images that were not easily compressible. Thus, reallocating the Objectstore to > 1TB was a safe thing to do.
{{</info>}}

Here's how you can check if a migration failed due to insufficient space:

```text
storkctl -n nexus get migration nexusmigration -o yaml
```

```output
apiVersion: v1
items:
- metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"stork.libopenstorage.org/v1alpha1","kind":"Migration","metadata":{"annotations":{},"name":"nexusmigration","namespace":"nexus"},"spec":{"clusterPair":"remoteclusteroldgreatdanetonewgreatdane","includeResources":true,"namespaces":["nexus"],"startApplications":true}}
    creationTimestamp: "2019-07-02T23:49:13Z"
    generation: 1
    name: nexusmigration
    namespace: nexus
    resourceVersion: "77951964"
    selfLink: /apis/stork.libopenstorage.org/v1alpha1/namespaces/nexus/migrations/nexusmigration
    uid: fec861ca-9d23-11e9-beb8-0cc47ab5f9a2
  spec:
    clusterPair: remoteclusteroldgreatdanetonewgreatdane
    includeResources: true
    namespaces:
    - nexus
    selectors: null
    startApplications: true
  status:
    resources: null
    stage: Final
    status: Failed
    volumes:
    - namespace: nexus
      persistentVolumeClaim: nexus-pvc
      reason: "Migration Backup failed for volume: Backup failed: XMinioStorageFull:
        Storage backend has reached its minimum free disk threshold. Please delete
        a few objects to proceed.\n\tstatus code: 500, request id: 15ADBC3B90C3A97F,
        host id: "
      status: Failed
      volume: pvc-9b776615-3f5e-11e8-83b6-0cc47ab5f9a2
kind: List
metadata: {}
```

If you see an error similar to the one above, you should increase the size of the *ObjectstoreVolume* and restart the migration.

{{<info>}}
Alternatively, you can use your own cloud (S3, Azure, or Google) instead of ObjectStore on the destination cluster. Note that the credentials must be named `clusterPair_<clusterUUID_of_destination>` and you are required to create them on both the source and the destination cluster.
{{</info>}}

### Starting a migration

#### Using a spec file

In order to make the process schedulable and repeatable, you can write a YAML specification.

In that file, you will specify an object called `Migration`. This object will define the scope of the applications to move and decide whether to automatically start the applications.

Paste this to a file named `migration.yaml`.

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: Migration
metadata:
  name: mysqlmigration
  namespace: migrationnamespace
spec:
  # This should be the name of the cluster pair created above
  clusterPair: remotecluster
  # If set to false this will migrate only the Portworx volumes. No PVCs, apps, etc will be migrated
  includeResources: true
  # If set to false, the deployments and stateful set replicas will be set to 0 on the destination.
  # There will be an annotation with "stork.openstorage.org/migrationReplicas" on the destinationto store the replica count from the source.
  startApplications: true
  # List of namespaces to migrate
  namespaces:
  - migrationnamespace
```

Next, you can invoke this migration manually from the command line:

```text
kubectl apply -f migration.yaml
```

```output
Migration mysqlmigration created successfully
```

or automate it through `storkctl`:

```text
storkctl create migration mysqlmigration --clusterPair remotecluster --namespaces migrationnamespace --includeResources --startApplications -n migrationnamespace
```
```output
Migration mysqlmigration created successfully
```

#### Migration scope

Currently, you can only migrate namespaces in which the object is created. You can also designate one namespace as an admin namespace. This will allow an admin who has access to that namespace to migrate any namespace from the source cluster. Instructions for setting this admin namespace to stork can be found [here](cluster-admin-namespace)

### Monitoring a migration

Once the migration has been started using the above commands, you can check the status using `storkctl`:

```text
storkctl get migration -n migrationnamespace
```

First, you should see something like this:

```
NAME            CLUSTERPAIR     STAGE     STATUS       VOLUMES   RESOURCES   CREATED
mysqlmigration  remotecluster   Volumes   InProgress   0/1       0/0         26 Oct 18 20:04 UTC
```

If the migration is successful, the `Stage` will go from Volumes→ Application→Final.

Here is how the output of a successful migration would look like:

```output
NAME            CLUSTERPAIR     STAGE     STATUS       VOLUMES   RESOURCES   CREATED
mysqlmigration  remotecluster   Final     Successful   1/1       3/3         26 Oct 18 20:04 UTC
```

{{% content "shared/portworx-install-with-kubernetes-disaster-recovery-migration-common.md" %}}
