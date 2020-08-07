---
title: Portworx command line arguments
description: Command line arguments to the Portworx daemon
keywords: portworx, px-developer, Portworx Enterprise, plugin, install, configure, container, storage, runc, oci
hidden: true
---

Below is the list of arguments you can pass to `px-runc`:

##### General options

```text
-c <id>                   [REQUIRED] Specifies the cluster ID that this PX instance is to join
-k <kvdb://host:port>     [REQUIRED] Points to your key value database, such as an etcd cluster or a consul cluster
-b                        Use in-built kvdb. Provide the kvdb endpoints required for bootstrap with -k option.
-s <device path>          [REQUIRED unless -a/-A are used] Specify storage devices that PX should use for storing the data
-xs <omit device path>    Specify storage devices that PX should NOT use for storing the data (useful with -a/-A)
-T <type>                 Specify backend storage type (<type> is mdraid or lvm)
-cache [<device path>]    Specify storage devices that PX should use for caching
-dedicated_cache          Constrain cache drive assignment from given -cache drives only
-j <device path>          Specify storage device that PX should use for storing the journal data
-metadata <device path>   Specify storage device that PX should use for storing the system meta data
-kvdb_dev <device path>   Specify storage device that PX should use for storing internal kvdb data
-oci <dir>                Specify OCI directory (dfl: /opt/pwx/oci)
-sysd <file>              Specify SystemD service file (dfl: /etc/systemd/system/portworx.service)
-e key=value              Specify extra environment variables
-v <dir:dir[:shared,ro]>  Specify extra mounts
-d <ethX>                 Specify the data network interface
-m <ethX>                 Specify the management network interface
-z                        Instructs PX to run in zero storage mode
-f                        Instructs PX to use an unmounted drive even if it has a filesystem on it
-a                        Instructs PX to use any available, unused and unmounted drives
-A                        Instructs PX to use any available, unused and unmounted drives or partitions
-x <swarm|kubernetes>     Specify scheduler type (if PX running in scheduler environment)
-r <startport>            Start of the portrange Portworx will use for communication (dfl: 9001)
-marketplace_name         [OPTIONAL] pass in the marketplace name if installing via a 3rd party marketplace
```

##### KVDB options

```text
-userpwd <user:passwd>    Username and password for ETCD authentication
-ca <file>                Specify location of CA file for ETCD authentication
-cert <file>              Specify location of certificate for ETCD authentication
-key <file>               Specify location of certificate key for ETCD authentication
-acltoken <token>         Specify ACL token for Consul authentication
+internal-kvdb-options:
-kvdb_cluster_size <#>    Size of the internal kvdb cluster (dfl: 3)
-kvdb_recovery            Starts the nodes in kvdb recovery mode
```

##### Cluster domain options

```text
-cluster_domain <name>    Cluster Domain Name for this cluster
```

##### PX-API options

```text
# px-api-ssl-options:
-apirootca <file>         Specify self-signed root CA certificate file
-apicert <file>           Specify node certificate file
-apikey <file>            Specify node certificate key file
-apidisclientauth         Disable api client authentication
# px-authentication-options:
-oidc_issuer   <URL>          Location of OIDC service (e.g. https://accounts.google.com)
-oidc_client_id <id>          Client id provided by the OIDC
-oidc_custom_claim_namespace  OIDC namespace for custom claims
-jwt_issuer <val>             JSON Web Token issuer (e.g. openstorage.io)
-jwt_rsa_pubkey_file <file>   JSON Web Token RSA Public file path
-jwt_ecds_pubkey_file <file>  JSON Web Token ECDS Public file path
-username_claim <claim>       Claim key from the token to use as the unique id of the user (<claim> is sub, email or name; dfl: sub)
```

##### Volume options

```text
-disable-sharedv4         Disable sharedv4 volume support. When set, NFS dependencies will not be installed.
-raid <0|10>              Specify which RAID-level should PX use with local storage (dfl: 0)
```

{{<info>}}
The `-raid <0|10>` option is different than the volume replication factor.  For example, Portworx nodes using `-raid 10` and hosting volumes with a replication factor of 3, will keep 6 copies of the data.
{{</info>}}

##### CSI options

```text
-csiversion <ver>         Specify which CSI version to use (<ver> is 1.0 or 0.3; dfl: 1.0)
```

##### secrets options

```text
-secret_type <type>       Specify the secrets type (<type> is aws-kms, dcos, docker, ibm-kp, k8s, kvdb, vault, gcloud-kms or azure-kv)
-cluster_secret_key <id>  Specify cluster-wide secret ID
```

##### Auto-scaling group options

```text
-max_drive_set_count <#>         Specify maximum number of drive sets PX can create
-max_storage_nodes_per_zone <#>  Specify the maximum number of storage nodes per zone in PX cluster
-node_pool_label <key>           Specify the scheduler node label key with which nodes are grouped into node pools
```

##### Resource control options

```text
--cpus <#.#>                  Specify maximum number of CPUs Portworx can use (e.g. --cpus=1.5)
--cpu-shares <#>              Specify CPU shares (relative weight)
--cpuset-cpus <val>           Specify CPUs in which to allow execution (<val> is range <#-#>, or sequence <#,#>)
--memory <bytes>              Specify maximum ammount of memory Portworx can use
--memory-reservation <bytes>  Specify memory reservation soft limit (must be smaller than '--memory')
--memory-swap <bytes>         Specify maximum ammount of RAM+SWAP memory Portworx can use
--memory-swappiness <0-100>   Specify percentage of container's anonymous pages host can swap out
```

<a name="env-variables"></a>

##### Environment variables

```text
PX_HTTP_PROXY          If running behind an HTTP proxy, set the PX_HTTP_PROXY variables to your HTTP proxy.
PX_HTTPS_PROXY         If running behind an HTTPS proxy, set the PX_HTTPS_PROXY variables to your HTTPS proxy.
PX_ENABLE_CACHE_FLUSH  To enable cache flush daemon, set PX_ENABLE_CACHE_FLUSH=true.
```

{{<info>}}
You can set the environment variables using the `-e` option.
{{</info>}}

For example, to set the `PX_ENABLE_CACHE_FLUSH` environment variable to `true`, run the following command:

```text
sudo /opt/pwx/bin/px-runc install -e PX_ENABLE_CACHE_FLUSH=yes \
    -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb
```
