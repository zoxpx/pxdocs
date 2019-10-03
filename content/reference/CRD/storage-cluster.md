---
title: StorageCluster
description: Explanation of Portworx Enterprise Operator and fields in StorageCluster object
keywords: portworx, operator, storagecluster
weight: 1
---

The Portworx Operator manages the complete lifecycle of a Portworx cluster. It provides easy installation and configuration managment for Portworx.
The Portworx cluster configuration if specified by a Kubernetes CRD (CustomResourceDefinition) called StorageCluster. The StorageCluster object
acts as the definition of the Portworx Cluster.

As shown in the below diagram, it manages the Portworx platform consisting of the Portworx nodes,
STORK, Lighthouse and other components that make running stateful applications seamless for the users.

![Portworx Operator](/img/px-operator-in-kubernetes.jpg)

The StorageCluster provides a Kubernetes native experience to manage a Portworx cluster just like any other application in Kubernetes. Simply creating
or editing a StorageCluster object will result in the Operator creating or updating the Portworx cluster in the background.

It is recommended to use the Portworx Spec Generator in [PX-Central](https://central.portworx.com) to create a StorageCluster spec. The spec generator will
walk you through different options which you select based on your environment to generate a StorageCluster spec.

If you want to generate the StorageCluster spec manually, you can refer to the following [examples](#storagecluster-examples) and the [schema description](#storagecluster-schema) of StorageCluster.

## StorageCluster Examples
Here are some sample Portworx configurations for reference. You can set various fields as per your
environment and cluster requirements.

- Portworx with Internal KVDB and all unused devices on the system

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  image: portworx/oci-monitor:2.1.2
  kvdb:
    internal: true
  storage:
    useAll: true
```

- Portworx with external ETCD, with STORK and Lighthouse enabled.

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  image: portworx/oci-monitor:2.1.2
  kvdb:
    endpoints:
    - etcd:http://etcd-1.net:2379
    - etcd:http://etcd-2.net:2379
    - etcd:http://etcd-3.net:2379
    authSecret: px-etcd-auth
  stork:
    enabled: true
    image: openstorage/stork:2.2.4
    args:
      health-monitor-interval: "100"
  userInterface:
    enabled: true
    image: portworx/px-lighthouse:2.0.4
```

- Portworx with update and delete strategies and placement rules

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  image: portworx/oci-monitor:2.1.2
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 20%
  deleteStrategy:
    type: UninstallAndWipe
  placement:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: px/enabled
            operator: NotIn
            values:
            - "false"
          - key: node-role.kubernetes.io/master
            operator: DoesNotExist
```

- Portworx with custom image registry, network interfaces and misc options

```text
apiVersion: core.libopenstorage.org/v1alpha1
kind: StorageCluster
metadata:
  name: portworx
  namespace: kube-system
spec:
  image: portworx/oci-monitor:2.1.2
  imagePullPolicy: Always
  imagePullSecret: regsecret
  customImageRegistry: docker.private.io/repo
  network:
    dataInterface: eth1
    mgmtInterface: eth1
  secretsProvider: vault
  runtimeOptions:
    num_io_threads: "10"
  env:
  - name: VAULT_ADDRESS
    value: "http://10.0.0.1:8200"
```

## StorageCluster Schema

##### `spec.image` (_string_)
Specify the Portworx monitor image (Example: portworx/oci-monitor:2.1.2)

##### `spec.imagePullPolicy` (_string_)
Image pull policy for all the images deployed by the operator. Default: Always

##### `spec.imagePullSecret` (_string_)
Image pull secret is the name of the secret in the same namespace as the StorageCluster. This is used
for pulling images from a secure registry.

##### `spec.customImageRegistry` (_string_)
Specify a custom container registry server that will be used to Docker images. You may include the
repository as well (Example: myregistry.net:5443, myregistry.net/myrepository)

##### `spec.secretsProvider` (_string_)
Name of the secrets provider that Portworx will connect to for features like volume encryption, cloudsnap, etc. Default: k8s (Kubernetes secrets)

##### `spec.runtimeOptions` (_map[string]string_)
Runtime options is a map string keys and values used to overwrite Portworx runtime options.

##### `spec.featureGates` (_map[string]string_)
Feature gates is a map string key and values to enable/disable Portworx features.

##### `spec.env[]` (_object array_)
Env is a list of [Kubernetes like environment variables](https://github.com/kubernetes/api/blob/master/core/v1/types.go#L1826).
Just like how environment variables are provided in Kubernetes, you can directly give values
or import from a source like Secret, ConfigMap, etc.


### KVDB configuration
This section contains all the details to configure the key-value database used by Portworx. If endpoints
are not specified, the Operator starts Portworx with internal KVDB.

##### `spec.kvdb.internal` (_boolean_)
If you want to use Portworx's [internal kvdb](/concepts/internal-kvdb), you can set this option.

##### `spec.kvdb.endpoints[]` (_string array_)
If using external key-value database like ETCD, Consul, specify the endpoints to connect to it in this list.
If the endpoints are specified, then `spec.kvdb.internal` is ignored and the external KVDB will be used.

##### `spec.kvdb.authSecret` (_string_)
KVDB Auth secret is the name of the secret in the same namespace as StorageCluster. This secret should have
information needed to authenticate with the KVDB. It could username/password for basic authentication or
certificate information or ACL token.

- If using username/password for authentication the secret should have keys called `username` and `password`.
- If using certificates for authentication the secret should have keys called `kvdb-ca.crt`, `kvdb.crt` and `kvdb.key` for CA certificate, certificate and corresponding certificate key respectively.
- If using ACL token for authentication the secret should have key called `acl-token`.


### Storage configuration
This section contains all the details to configure the storage for the Portworx cluster. If no devices are
specified, the Operator starts Portworx with `spec.storage.useAll` set to true.

##### `spec.storage.useAll` (_boolean_)
This tells Portworx to use all available, unformatted, unpartioned devices. It will be ignored if
`spec.storage.devices` is not empty.

##### `spec.storage.useAllWithPartitions` (_boolean_)
This tells Portworx to use all available unformatted devices. It will be ignored if
`spec.storage.devices` is not empty.

##### `spec.storage.forceUseDisks` (_boolean_)
This tells Portworx to use the devices even if there is file system present on it. Note that
the __drives may be wiped__ before using.

##### `spec.storage.devices[]` (_string array_)
Devices is an array of devices that should be used by Portworx.

##### `spec.storage.journalDevice` (_string_)
Device that will be used for journaling by Portworx.

##### `spec.storage.systemMetadataDevice` (_string_)
Device that will be used for storing metadata by Portworx. It is recommended to have a system metadata
device when using internal KVDB for better performance.


### Cloud storage configuration
This section contains all the details to configure the storage in cloud. This enables Portworx
to manage cloud disks automatically for the user based on given specs. `spec.storage` takes precedence
over this section. Make sure `spec.storage` is empty when specifying cloud storage.

##### `spec.cloudStorage.deviceSpecs[]` (_string array_)
Device specs is a list of storage device specs. A cloud disk will be created for every spec in the list.

##### `spec.cloudStorage.journalDeviceSpec` (_string_)
Device spec for device that will be used for journaling by Portworx.

##### `spec.cloudStorage.systemMetadataDeviceSpec` (_string_)
Device spec for device that will be used for storing metadata by Portworx. It is recommended to have
a system metadata device when using internal KVDB for better performance.

##### `spec.cloudStorage.maxStorageNodesPerZone` (_uint32_)
Specify maximum number of storage nodes per zone. Portworx will not provision drives for additional
nodes in the zone and start them as compute only nodes.

##### `spec.cloudStorage.maxStorageNodes` (_uint32_)
Specify maximum number of total storage nodes. Portworx will not provision drives for additional
nodes in the cluster and start them as compute only nodes. It is recommended to use `maxStorageNodesPerZone`
as a best practice.

### Network configuration
This section contains network information needed by Portworx. If nothing is specified, Portworx will
auto detect and choose network interfaces.

##### `spec.network.dataInterface` (_string_)
Data interface allows users to override the auto selected network interace for data traffic.

##### `spec.network.mgmtInterface` (_string_)
Management interface allows users to override the auto selected network interace for control plane traffic.


### Placement Rules
Placement lets your override where Portworx will be deployed. By default Portworx gets deployed on all worker
nodes.

##### `spec.placement.nodeAffinity` (_object_)
[Kubernetes like node affinity](https://github.com/kubernetes/api/blob/master/core/v1/types.go#L2692)
 to restrict Portworx on certain nodes.


### Update Strategy
Similar to Kubernetes DaemonSet, this allows you to specify a update strategy for Portworx updates.

##### `spec.updateStrategy.type` (_object_)
Type of update strategy to use. Currently it supports RollingUpdate and OnDelete. Default: RollingUpdate.

##### `spec.updateStrategy.rollingUpdate.maxUnavailable` (_intOrString_)
Similar to Kubernetes rolling update strategy you can specify this section for rolling updates.
The default value is 1 which means only one node will be down at a given point of time. You can
specify a static number of percentage value. (Example: 3, 30%, etc)


### Delete/Uninstall Strategy
This section contains information on how to uninstall the Portworx cluster.

##### `spec.deleteStrategy.type`
Type of delete strategy to use. Deleting the Portworx StorageCluster object will trigger this delete
strategy. By default there is no delete strategy, which means only the Kubernetes components deployed by
the Operator will be removed leaving the Portworx systemd service running without disturbing the apps
running on it. Currently there are two supported delete strategies:

- Uninstall - Uninstall all Portworx components from the system leaving the devices and KVDB intact.
- UninstallAndWIpe - Uninstall all Portworx components from the system and also wipe the devices and metadata from KVDB.


### Stork configuration
This section contains information to enable and manage stork deployment through the Portworx Operator.

##### `spec.stork.enabled` (_boolean_)
You can enable/disable STORK by toggling this flag at any given time.

##### `spec.stork.image` (_string_)
Specify the STORK image.

##### `spec.stork.args` (_map[string]string_)
A map of string keys and values to override the default STORK arguments or to add new arguments.

##### `spec.stork.env[]` (_object array_)
A list of [Kubernetes like environment variables](https://github.com/kubernetes/api/blob/master/core/v1/types.go#L1826) that need to be passed to STORK.


### Lighthouse configuration
This section contains information to enable and manage Lighthouse deployment through the Portworx Operator.

##### `spec.userInterface.enabled` (_boolean_)
You can enable/disable Lighthouse by toggling this flag at any given time.

##### `spec.userInterface.image` (_string_)
Specify the Lighthouse image.
