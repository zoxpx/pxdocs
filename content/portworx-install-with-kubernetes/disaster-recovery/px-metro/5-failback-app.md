---
title: "5. Failback an application"
weight: 5
keywords: cloud, backup, restore, snapshot, DR, migration, px-motion
description: Find out how to failback an application from the backup Kubernetes cluster to the original one.
---

Once your unhealthy Kubernetes cluster is back up and running, the Portworx nodes in that cluster will not immediately rejoin the cluster. They will stay in
`Out of Quorum` state until you explicitly **Activate** this Cluster Domain.

After this domain is marked as **Active** you can failback the applications if you want.

For this section, we will refer to,

* **Source Cluster** as the Kubernetes cluster which is back online and where your applications need to failback to. (In this example: `cluster_domain: us-east-1a`)
* **Destination Cluster** as the Kubernetes cluster where the applications will be failed over. (In this example: `cluster_domain: us-east-1b`)

### Reactivate inactive Cluster Domain

In order to initiate a failback, we need to first mark the source cluster as active.

#### Using storkctl

Run the following storkctl command to activate the source cluster

`storkctl`:

```text
storkctl activate clusterdomain us-east-1a
```

You need to run the above command from the Kubernetes cluster which is **Active**. To validate that the command has succeeded you can do the following checks:

```text
storkctl get clusterdomainsstatus
```

```output
NAME            ACTIVE                    INACTIVE   CREATED
px-dr-cluster   [us-east-1a us-east-1b]   []         09 Apr 19 17:13 PDT
```

#### Using kubectl

If you wish to use `kubectl` instead of `storkctl`, you can create a `ClusterDomainUpdate` object as explained below. If you have already used `storkctl` you can skip this section.

Start by creating a new file named `clusterdomainupdate.yaml`. In this file, let's specify an object called a ClusterDomainUpdate and designate the cluster domain of the source cluster as active:

 ```text
 apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterDomainUpdate
metadata:
 name: activate-us-east-1a
 namespace: kube-system
spec:
  # Name of the metro domain that needs to be activated/deactivated
  clusterdomain: us-east-1a
  # Set to true to activate cluster domain
  # Set to false to deactivate cluster domain
  active: true
 ```

In order to invoke from command-line, you will need to run the following:

```text
kubectl create -f clusterdomainupdate.yaml
```

```output
clusterdomainupdate "activate-us-east-1a" created
```

You can see that the cluster domain `us-east-1a` is now **Active**

### Stop the application on the destination cluster

On the destination cluster, where the applications were failed over in Step 3, you need to stop them so that we can failback to the source cluster.

You can stop the applications from running by changing the replica count of your deployments and statefulsets to 0.

```text
kubectl scale --replicas 0 deployment/mysql -n migrationnamespace
```

### Start back the application on the source cluster
After you have stopped the applications on the destination cluster, let's jump to the source cluster. Here, we would want to start back the applications by editing the replica count.

```text
kubectl scale --replicas 1 deployment/mysql -n migrationnamespace
```

Lastly, let's check that our application is running:

```text
kubectl get pods -n migrationnamespace
```

```output
NAME                     READY     STATUS    RESTARTS   AGE
mysql-5857989b5d-48mwf   1/1       Running   0          3m
```

```text
kubectl scale --replicas 0 deployment/mysql -n migrationnamespace
```

If we had suspended the migration schedule in source cluster during step 4, we now have to unsuspend it.

Apply the below spec. Notice the `suspend: false`.

```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: MigrationSchedule
metadata:
  name: mysqlmigrationschedule
  namespace: migrationnamespace
spec:
  template:
    spec:
      # This should be the name of the cluster pair created above
      clusterPair: remotecluster
      # If set to false this will migrate only the Portworx volumes. No PVCs, apps, etc will be migrated
      includeResources: true
      # If set to false, the deployments and stateful set replicas will be set to 0 on the destination.
      # If set to true, the deployments and stateful sets will start running once the migration is done
      # There will be an annotation with "stork.openstorage.org/migrationReplicas" on the destinationto store the replica count from the source.
      startApplications: false
       # If set to false, the volumes will not be migrated
      includeVolumes: false
      # List of namespaces to migrate
      namespaces:
      - migrationnamespace
  schedulePolicyName: testpolicy
  suspend: false
```

Using storkctl, verify the schedule is unsuspended.

```text
storkctl get migrationschedule -n migrationnamespace
```

```output
NAME                        POLICYNAME   CLUSTERPAIR      SUSPEND   LAST-SUCCESS-TIME     LAST-SUCCESS-DURATION
mysqlmigrationschedule      testpolcy    remotecluster    false      17 Apr 19 17:16 PDT   2m0s
```
