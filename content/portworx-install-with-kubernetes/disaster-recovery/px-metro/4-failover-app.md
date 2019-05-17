---
title: "4. Failover an application"
weight: 4
keywords: cloud, backup, restore, snapshot, DR, migration, px-motion
description: Find out how to failover an application from one Kubernetes cluster to another.
---

In case of a disaster, where one of your Kubernetes clusters goes down and is inaccessible, you would want to failover the applications running on it to an operational Kubernetes cluster.

For this section, we will refer to,

* **Source Cluster** as the Kubernetes cluster which is down and where your applications were originally running. (In this example: `cluster_domain: us-east-1a`)
* **Destination Cluster** as the Kubernetes cluster where the applications will be failed over. (In this example: `cluster_domain: us-east-1b`)

In order to failover the application, you need to instruct Stork and Portworx that one of your Kubernetes clusters is down and inactive.

### Deactivate failed Cluster Domain

In order to initiate a failover, we need to first mark the source cluster as inactive.

#### Using storkctl

Run the following storkctl command to deactivate the source cluster

`storkctl`:

```text
storkctl deactivate clusterdomain us-east-1a
```

Run the above command on the destination cluster where Portworx is still running. To validate that the command has succeeded you can check the status of all the cluster domains using `storkctl`:

```text
storkctl get clusterdomainsstatus
```

When a domain gets successfully deactivated the above command should return something like this:

```
NAME            ACTIVE         INACTIVE       CREATED
px-dr-cluster   [us-east-1b]   [us-east-1a]   09 Apr 19 17:12 PDT
```

You can see that the cluster domain `us-east-1a` is now **Inactive**

#### Using kubectl

If you wish to use `kubectl` instead of `storkctl`, you can create a `ClusterDomainUpdate` object as explained below. If you have already used `storkctl` you can skip this section.

Let's create a new file named `clusterdomainupdate.yaml` that specifies an object called `ClusterDomainUpdate` and designates the cluster domain of the source cluster as inactive:

 ```text
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ClusterDomainUpdate
metadata:
 name: deactivate-us-east-1a
 namespace: kube-system
spec:
  # Name of the metro domain that needs to be activated/deactivated
  clusterdomain: us-east-1a
  # Set to true to activate cluster domain
  # Set to false to deactivate cluster domain
  active: false
 ```

In order to invoke from command-line, run the following:

```text
kubectl create -f clusterdomainupdate.yaml
```

### Stop the application on the source cluster (if accessible)

If your source Kubernetes cluster is still alive and is accessible, we recommend you to stop the applications before failing them over to the destination cluster.

You can stop the applications from running by changing the replica count of your deployments and statefulsets to 0. In this way, your application resources will persist in Kubernetes, but the actual application would not be running.

```text
kubectl scale --replicas 0 deployment/mysql -n migrationnamespace
```

Since the replicas for the mysql deployment are set to 0, we need to suspend the migration schedule on the source cluster. This is done so that the mysql deployment on the target cluster doesn't get updated to 0 replicas.

Apply the below spec. Notice the `suspend: true`.

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
  suspend: true
```

Using storkctl, verify the schedule is suspended.

```text
storkctl get migrationschedule -n migrationnamespace
```

```output
NAME                        POLICYNAME   CLUSTERPAIR      SUSPEND   LAST-SUCCESS-TIME     LAST-SUCCESS-DURATION
mysqlmigrationschedule      testpolcy    remotecluster     true      17 Apr 19 15:18 PDT   2m0s
```


### Start the application on the destination cluster

In step 2., we migrated the applications to the destination cluster but the replica count was set to 0 for all the deployments and statefulsets, so that they do not run.
You can now scale the applications by setting the replica counts to the desired value.

Each application spec will have the following annotation `stork.openstorage.org/migrationReplicas` indicating what was the replica count for it on the source cluster.

Once the replica count is updated, the application would start running, and the failover will be completed.

You can use the following command to scale the application:

```text
kubectl scale --replicas 1 deployment/mysql -n migrationnamespace
```

You can also use:

```text
storkctl activate migration -n migrationnamespace
```

which will look for that annotation and scale it to the correct number automatically.

Let's make sure our application is up and running. List the pods with:

```text
kubectl get pods -n migrationnamespace
```

```output
NAME                     READY     STATUS    RESTARTS   AGE
mysql-5857989b5d-48mwf   1/1       Running   0          3m
```
