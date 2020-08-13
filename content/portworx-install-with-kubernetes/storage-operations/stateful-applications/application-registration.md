---
title: ApplicationRegistration
linkTitle: 
keywords: backup, restore, clone, stateful
description: Backup, restore, and clone stateful applications
hidden: false
weight: 2
---

With Stork 2.4.3 and newer, you can back up and restore customer-specific CRDs. Using this method, you create a Stork custom resource, called an ApplicationRegistration, which registers your CRD with Stork, allowing you to perform a migration, backup, and restore of your CRDs specified resources. 

## Prerequisites

* Your Portworx installation must contain the `libopenstorage/stork:2.4.3` image. 

## Fetch default ApplicationRegistrations

By default, Stork supports a number of customer-specific CRDs. List the existing defaults by entering the `storkctl get appreg` command:

```text
storkctl get applicationregistrations
```
```output
NAME        KIND                       CRD-NAME                 VERSION    SUSPEND-OPTIONS                       KEEP-STATUS
cassandra   CassandraDatacenter        cassandra.datastax.com   v1beta1    spec.stopped,bool                     false
couchbase   CouchbaseBucket            couchbase.com            v2                                               false
couchbase   CouchbaseCluster           couchbase.com            v2         spec.paused,bool                      false
couchbase   CouchbaseEphemeralBucket   couchbase.com            v2                                               false
couchbase   CouchbaseMemcachedBucket   couchbase.com            v2                                               false
couchbase   CouchbaseReplication       couchbase.com            v2                                               false
couchbase   CouchbaseUser              couchbase.com            v2                                               false
couchbase   CouchbaseGroup             couchbase.com            v2                                               false
couchbase   CouchbaseRoleBinding       couchbase.com            v2                                               false
couchbase   CouchbaseBackup            couchbase.com            v2                                               false
couchbase   CouchbaseBackupRestore     couchbase.com            v2                                               false
ibm         IBPCA                      ibp.com                  v1alpha1   spec.replicas,int                     false
ibm         IBPConsole                 ibp.com                  v1alpha1   spec.replicas,int                     false
ibm         IBPOrderer                 ibp.com                  v1alpha1   spec.replicas,int                     false
ibm         IBPPeer                    ibp.com                  v1alpha1   spec.replicas,int                     false
redis       RedisEnterpriseCluster     app.redislabs.com        v1                                               false
redis       RedisEnterpriseDatabase    app.redislabs.com        v1                                               false
weblogic    Domain                     weblogic.oracle          v8         spec.serverStartPolicy,string,NEVER   false
```

## Register a new CRD with Stork

To register a new CRD with Stork, perform the following steps: 

1. Create an `applicationregistration` spec, specifying the following:

  * **metadata.name:** With the name of the spec. 
  * **resources.PodsPath:** (Optional) With The path which stores the pods created by the CR. These will be deleted when scaling down the migration.
  * **resources.group:** With the group of the CRD being registered.
  * **resources.version:** With the version of the CRD being registered.
  * **resources.kind:** With the kind of the CRD being registered. 
  * **resources.keepStatus:** (Optional) If you don't want to save the resource's status after migration, set this value to `false`.
  * **resources.suspendOptions.path:** (Optional) With the path in the CRD spec which contains the option to suspend the application.
  * **resources.suspendOptions.type:** (Optional) With the type of the field that is used to suspend the operation. For example, `int`, if the field contains the replica count for the application.

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: ApplicationRegistration
    metadata:
      name: myappname
    resources:
    - PodsPath: <POD_PATH> 
      group: <CRD_GROUP_NAME>
      version: <CRD_VERSION>
      kind: <CR_KIND>
      # to keep status of CR on migration <!-- where does this apply? to keepStatus below it? can you elaborate more on the statement? -->
      keepStatus: false
      # To disable CR on migration, 
      # CR spec path for disable 
      suspendOptions:
        path: <spec_path>
        type: <type_of_value_to_set> (can be "int"/"bool")
    ```

    The following example ApplicationRegistration allows Stork to back-up, restore, or migrate a `datastax/cassandra` operator: 

    ```text
    apiVersion: stork.libopenstorage.org/v1alpha1
    kind: ApplicationRegistration
    metadata:
      name: cassandra
    resources:
    - PodsPath: ""
      group: cassandra.datastax.com
      version: v1beta1
      kind: CassandraDatacenter
      keepStatus: false #cassandra datacenter status will not be migrated
      suspendOptions:
        path: spec.stopped #path to disable cassandra datacenter
        type: bool #type of value to be set for spec.stopped
    ```

2. Apply the spec:

    ```text
    kubectl apply -f <application-registration-spec>.yaml
    ```

Once you've applied the spec, you can verify it by entering the following `storkctl get` command, specifying your own application name:

```text
storkctl get appreg <app-name>
```
```output
NAME        KIND                  CRD-NAME                 VERSION   SUSPEND-OPTIONS     KEEP-STATUS
cassandra   CassandraDatacenter   cassandra.datastax.com   v1beta1   spec.stopped,bool   false
``` 

{{<info>}}
**NOTE:** If you register your CRD with Stork using an applicationRegistration CRD, you do not need to modify the migration, backup, or restore specs.
{{</info>}}