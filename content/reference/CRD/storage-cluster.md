---
title: StorageCluster
description: Explanation of Portworx Enterprise Operator and fields in StorageCluster object
keywords: portworx, operator, storagecluster
weight: 1
---

The Portworx cluster configuration is specified by a Kubernetes CRD (CustomResourceDefinition) called StorageCluster. The StorageCluster object acts as the definition of the Portworx Cluster.

The `StorageCluster` object provides a Kubernetes native experience. You can manage your Portworx cluster just like any other application running on Kubernetes. That is, if you create or edit the `StorageCluster` object, the operator will create or edit the Portworx cluster in the background.

To generate a `StorageCluster` spec customized for your environment, point your browser to  [PX-Central](https://central.portworx.com), and click "Install and Run" to start the Portworx spec generator. Then, the wizard will walk you through all the necessary steps to create a `StorageCluster` spec customized for your environment.

Note that using the Portworx spec generator is the recommended way of generating a `StorageCluster` spec. However, if you want to generate the `StorageCluster` spec manually, you can refer to the [StorageCluster Examples](#storagecluster-examples) and [StorageCluster Schema](#storagecluster-schema) sections.

## StorageCluster Examples

This section provides a few examples of common Portworx configurations you can use for manually configuring your Portworx cluster. Update the default values in these files to match your environment.

* Portworx with internal KVdb, configured to use all unused devices on the system.

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

* Portworx with external ETCD, Stork, and Lighthouse.

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
    args:
      health-monitor-interval: "100"
  userInterface:
    enabled: true
```

* Portworx with update and delete strategies, and placement rules.

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
    tolerations:
    - key: infra/node
      operator: Equal
      value: "true"
      effect: NoExecute
```

* Portworx with custom image registry, network interfaces, and miscellaneous options

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

This section explains the fields used to configure the `StorageCluster` object.

| Field | Description |Type| Default |
| --- | --- | --- | --- |
| spec.<br> image| Specifies the Portworx monitor image. | `string` | None |
| spec.<br> imagePullPolicy | Specifies the image pull policy for all the images deployed by the operator. It can take one of the following values: `Always` or `IfNotPresent` | `string` | `Always` |
| spec.<br>imagePullSecret | If Portworx pulls images from a secure repository, you can use this field to pass it the name of the secret. Note that the secret should be in the same namespace as the `StorageCluster` object. | `string` | None |
| spec.<br>customImageRegistry | The custom container registry server Portworx uses to fetch the Docker images. You may include the repository as well. | `string` | None |
| spec.<br>secretsProvider | The name of the secrets provider Portworx uses to store your credentials. To use features like cloud snapshots or volume encryption, you must configure a secret store provider. Refer to the [Secret store management page](/key-management/) page for more details. | `string` |  None |
| spec.<br>runtimeOptions | A collection of key-value pairs that overwrites the runtime options. | `map[string]string` | None |
| spec.<br>featureGates | A collection of key-value pairs specifying which Portworx features should be enabled or disabled. [^1] | `map[string]string` | None |
| spec.<br>env[] | A list of [Kubernetes like environment variables](https://github.com/kubernetes/api/blob/master/core/v1/types.go#L1826). Similar to how environment variables are provided in Kubernetes, you can directly provide values to Portworx or import them from a source like a `Secret`, `ConfigMap`, etc. | `[]object` | None |

[^1]: As an example, here's how you can enable the `CSI` feature.
    ```text
    spec:
      featureGates:
        CSI: "true"
    ```
    Please note that you can also use `CSI: "True"` or `CSI: "1"`.

### KVdb configuration

This section explains the fields used to configure Portworx with a KVdb. Note that, if you don't specify the endpoints, the operator starts Portworx with the internal KVdb.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>kvdb.<br>internal | Specifies if Portworx starts with the [internal KVdb](/concepts/internal-kvdb). | `boolean` | `true` |
| spec.<br>kvdb.endpoints[]<br> | A list of endpoints for your external key-value database like ETCD or Consul. This field takes precedence over the `spec.kvdb.internal` field. That is, if you specify the endpoints, Portworx ignores the `spec.kvdb.internal` field and it uses the external KVdb. | `[]string` | None |
| spec.<br>kvdb.<br>authSecret | Indicates the name of the secret Portworx uses to authenticate against your KVdb. The secret must be placed in the same namespace as the `StorageCluster` object. The secret should provide the following information: <br> -  The username and password stored under the `username` and `password` keys, if you're using a username/password authentication schema. <br> - The CA certificate stored under the `kvdb-ca.crt` key and the certificate key stored under the `kvdb.key`, if you're using certificates for authentication. <br> - The ACL token stored under the `acl-token` key, if you're using ACL tokens for authentication. | string | None |

### Storage configuration

This section provides details about the fields used to configure the storage for your Portworx cluster. If you don't specify a device, the operator sets the `spec.storage.useAll` field to `true`.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>storage.<br>useAll | If set to `true`, Portworx uses all available, unformatted, and unpartitioned devices. [^2] | `boolean` | `true` |
| spec.<br>storage.<br>useAllWithPartitions | If  set to `true`, Portworx uses all the available and unformatted devices. [^2] | `boolean` |  `false` |
| spec.<br>storage.<br>forceUseDisks | If set to `true`, Portworx uses a device even if there's a file system on it. Note that Portworx may wipe the drive before using it. | `boolean` | `false` |
| spec.<br>storage.<br>devices[] | Specifies the list of devices Portworx should use. | `[]string` | None |
| spec.<br>storage.<br>journalDevice | Specifies the device Portworx uses for journaling. | `string` | None |
| spec.<br>storage.<br>systemMetadataDevice | Indicates the device Portworx uses to store metadata. For better performance, specify a system metadata device when using Powrtworx with the internal KVdb. | `string` | None |
| spec.<br>storage.<br>kvdbDevice | Specifies the device Portworx uses to store internal KVDB data. | `string` | None |

[^2]: Note that Portworx ignores this filed if you specify the storage devices using the `spec.storage.devices` field.

### Cloud storage configuration

This section explains the fields used to configure Portworx with cloud storage. Once the cloud storage is configured, Portworx manages the cloud disks automatically based on the provided specs. Note that the `spec.storage` fields take precedence over the fields presented in this section. Make sure the `spec.storage` fields are empty when configuring Portworx with cloud storage.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>cloudStorage.<br>deviceSpecs[] | A list of the specs for your cloud storage devices. Portworx creates a cloud disk for every device. | `[]string` | None |
| spec.<br>cloudStorage.<br>journalDeviceSpec | Specifies the cloud device Portworx uses for journaling. | `string` | None |
| spec.<br>cloudStorage.<br>systemMetadataDeviceSpec | Indicates the cloud device Portworx uses for metadata. For performance, specify a system metadata device when using Portworx with the internal KVdb. | `string` | None |
| spec.<br>cloudStorage.<br>kvdbDeviceSpec | Specifies the cloud device Portworx uses for an internal KVDB. | `string` | None |
| spec.<br>cloudStorage.<br>maxStorageNodesPerZone | Indicates the maximum number of storage nodes per zone. If this number is reached, and a new node is added to the zone, Portworx doesn't provision drives for the new node. Instead, Portworx starts the node as a compute-only node. | `uint32` | None |
| spec.<br>cloudStorage.<br>maxStorageNodes | Specifies the maximum number of storage nodes. If this number is reached, and a new node is added, Portworx doesn't provision drives for the new node. Instead, Portworx starts the node as a compute-only node. As a best practice, it is recommended to use the `maxStorageNodesPerZone` field. | `uint32` | None |

### Network configuration

This section describes the fields used to configure the network settings. If these fields are not specified, Portworx auto-detects the network interfaces.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>network.<br>dataInterface | Specifies the network interface Portworx uses for data traffic. | `string` | None |
| spec.<br>network.<br>mgmtInterface| Indicates the network interface Portworx uses for control plane traffic. | `string` | None |


### Placement rules

You can use the placement rules to specify where Portworx should be deployed. By default, the operator deploys Portworx on all worker nodes.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>placement.<br>nodeAffinity | Use this field to restrict Portwox on certain nodes. It works similarly to the [Kubernetes node affinity](https://github.com/kubernetes/api/blob/master/core/v1/types.go#L2692) feature. | `object` | None |
| spec.<br>placement.<br>tolerations[] | Specifies a list of tolerations that will be applied to Portworx pods so that they can run on nodes with matching taints.| `[]object` | None |


### Update strategy

This section provides details on how to specify an update strategy.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>updateStrategy.<br>type | Indicates the update strategy. Currently, Portworx supports the following update strategies- `RollingUpdate` and `OnDelete`. | `object` | `RollingUpdate` |
| spec.<br>updateStrategy.<br>rollingUpdate.<br>maxUnavailable | Similarly to how Kubernetes rolling update strategies work, this field specifies how many nodes can be down at any given time. Note that you can specify this as a number or percentage. | `int` or `string` | `1` |

### Delete/Uninstall strategy

This section provides details on how to specify an uninstall strategy for your Portworx cluster.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>deleteStrategy.<br>type | Indicates what happens when the Portworx `StorageCluster` object is deleted. By default, there is no delete strategy, which means only the Kubernetes components deployed by the operator are removed.  The Portworx `systemd` service continues to run, and the Kubernetes applications using the Portworx volumes are not affected. Portworx supports the following delete strategies: <br> - `Uninstall` - Removes all Portworx components from the system and leaves the devices and KVdb intact. <br> - `UninstallAndWipe` - Removes all Portworx components from the system and wipes the devices and metadata from KVdb.  | `string`| None |

### Monitoring configuration

This section provides details on how to enable monitoring for Portworx.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>monitoring.<br>prometheus.<br>enabled | Enables or disables a Prometheus cluster. | `boolean` | `false` |
| spec.<br>monitoring.<br>prometheus.<br>exportMetrics | Expose the Portworx metrics to an external or operator deployed Prometheus. | `boolean` | `false` |

### Stork configuration

This section describes the fields used to manage the Stork deployment through the Portworx operator.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>stork.<br>enabled | Enables or disables Stork at any given time. | `boolean` | `true` |
| spec.<br>stork.<br>image | Specifies the Stork image. | `string` | None |
| spec.<br>stork.<br>lockImage | Enables locking Stork to the given image. When set to false, the Portworx Operator will overwrite the Stork image to a recommended image for given Portworx version. | `boolean` | `false` |
| spec.<br>stork.<br>args | A collection of key-value pairs that overrides the default Stork arguments or adds new arguments. | `map[string]string` | None |
| spec.<br>stork.<br>env[] | A list of [Kubernetes like environment variables](https://github.com/kubernetes/api/blob/master/core/v1/types.go#L1826) passed to Stork. | `[]object` | None |


### Lighthouse configuration

This section provides details on how to deploy and manage Lighthouse.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>userInterface.<br>enabled | Enables or disables Lighthouse at any given time. | boolean | `false` |
| spec.<br>userInterface.<br>image | Specifies the Lighthouse image. | `string` | None |
| spec.<br>userInterface.<br>lockImage | Enables locking Lighthouse to the given image. When set to false, the Portworx Operator will overwrite the Lighthouse image to a recommended image for given Portworx version. | `boolean` | `false` |

### Autopilot configuration

This section provides details on how to deploy and manage Autopilot.

| Field | Description | Type | Default |
| --- | --- | --- | --- |
| spec.<br>autopilot.<br>enabled | Enables or disables Autopilot at any given time. | boolean | `false` |
| spec.<br>autopilot.<br>image | Specifies the Autopilot image. | `string` | None |
| spec.<br>autopilot.<br>lockImage | Enables locking Autopilot to the given image. When set to false, the Portworx Operator will overwrite the Autopilot image to a recommended image for given Portworx version. | `boolean` | `false` |
| spec.<br>autopilot.<br>providers | List of data providers for Autopilot. | `[]object` | None |
| spec.<br>autopilot.<br>providers.<br>name | Unique name of the data provider. | `string` | None |
| spec.<br>autopilot.<br>providers.<br>type | Type of the data provider. For instance, `prometheus` | `string` | None |
| spec.<br>autopilot.<br>providers.<br>params | Map of key-value params for the provider. | `map[string]string` | None |
