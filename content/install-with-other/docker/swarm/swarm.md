---
title: Swarm
---

Identify storage

Portworx pools the storage devices on your server and creates a global capacity for containers.

> **Important:**  
> Back up any data on storage devices that will be pooled. Storage devices will be reformatted!

To view the storage devices on your server, use the `lsblk` command.

For example:

```text
lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    xvda                      202:0    0     8G  0 disk
    └─xvda1                   202:1    0     8G  0 part /
    xvdb                      202:16   0    64G  0 disk
    xvdc                      202:32   0    64G  0 disk
```

Note that devices without the partition are shown under the **TYPE** column as **part**. This example has two non-root storage devices \(/dev/xvdb, /dev/xvdc\) that are candidates for storage devices.

Identify the storage devices you will be allocating to PX. PX can run in a heterogeneous environment, so you can mix and match drives of different types. Different servers in the cluster can also have different drive configurations.

### Install {#install}

PX runs as a container directly via OCI runC. This ensures that there are no cyclical dependencies between Docker and PX.

On each swarm node, perform the following steps to install PX.

**Step 1: Install the PX OCI bundle**

Portworx provides a Docker based installation utility to help deploy the PX OCI bundle. This bundle can be installed by running the following Docker container on your host system:

**To get the 1.4 tech preview release**

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com/1.4/?type=dock&stork=false' | awk '/image: / {print $2}')

# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

**To get the 1.3 stable release**

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com/1.3/?type=dock&stork=false' | awk '/image: / {print $2}')

# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

**To get the 1.2 stable release**

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com/1.2/?type=dock&stork=false' | awk '/image: / {print $2}')

# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

> **Note:**  
> Running the PX OCI bundle does not require Docker, but Docker will still be required to _install_ the PX OCI bundle. If you do not have Docker installed on your target hosts, you can download this Docker package and extract it to a root tar ball and manually install the OCI bundle.

**Step 2: Configure PX under runC**

Now that you have downloaded and installed the PX OCI bundle, you can use the the `px-runc install` command from the bundle to configure systemd to start PX runC.

The _px-runc_ command is a helper-tool that does the following:

1. prepares the OCI directory for runC
2. prepares the runC configuration for PX
3. used by systemd to start the PX OCI bundle

Installation example:

```text
#  Basic installation

sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb -s /dev/xvdc -x swarm
```

**Command-line arguments**

 **Options**

```text
-c                        [REQUIRED] Specifies the cluster ID that this PX instance is to join
-k                        [REQUIRED] Points to your key value database, such as an etcd cluster or a consul cluster
-s                        [REQUIRED unless -a is used] Specifies the various drives that PX should use for storing the data
-e key=value              [OPTIONAL] Specify extra environment variables
-v <dir:dir[:shared,ro]>  [OPTIONAL] Specify extra mounts
-d <ethX>                 [OPTIONAL] Specify the data network interface
-m <ethX>                 [OPTIONAL] Specify the management network interface
-z                        [OPTIONAL] Instructs PX to run in zero storage mode
-f                        [OPTIONAL] Instructs PX to use an unmounted drive even if it has a filesystem on it
-a                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives
-A                        [OPTIONAL] Instructs PX to use any available, unused and unmounted drives or partitions
-j                        [OPTIONAL] Specifies a journal device for PX
-x <swarm|kubernetes>     [OPTIONAL] Specify scheduler being used in the environment
-r <portnumber>           [OPTIONAL] Specifies the portnumber from which PX will start consuming. Ex: 9001 means 9001-9020
```

* additional PX-OCI -specific options:

```text
-oci <dir>                [OPTIONAL] Specify OCI directory (default: /opt/pwx/oci)
-sysd <file>              [OPTIONAL] Specify SystemD service file (default: /etc/systemd/system/portworx.service)
```

**KVDB options**

```text
-userpwd <user:passwd>    [OPTIONAL] Username and password for ETCD authentication
-ca <file>                [OPTIONAL] Specify location of CA file for ETCD authentication
-cert <file>              [OPTIONAL] Specify location of certificate for ETCD authentication
-key <file>               [OPTIONAL] Specify location of certificate key for ETCD authentication
-acltoken <token>         [OPTIONAL] ACL token value used for Consul authentication
```

**Secrets options**

```text
-secret_type <aws|kvdb|vault>   [OPTIONAL] Specify the secret type to be used by Portworx for cloudsnap and encryption features.
-cluster_secret_key <id>        [OPTIONAL] Specify the cluster wide secret key to be used when using AWS KMS or Vault for volume encryption.
```

 **Environment variables**

```text
PX_HTTP_PROXY         [OPTIONAL] If running behind an HTTP proxy, set the PX_HTTP_PROXY variables to your HTTP proxy.
PX_HTTPS_PROXY        [OPTIONAL] If running behind an HTTPS proxy, set the PX_HTTPS_PROXY variables to your HTTPS proxy.
PX_ENABLE_CACHE_FLUSH [OPTIONAL] Enable cache flush deamon. Set PX_ENABLE_CACHE_FLUSH=true.
PX_ENABLE_NFS         [OPTIONAL] Enable the PX NFS daemon. Set PX_ENABLE_NFS=true.
```

NOTE: Setting environment variables can be done using the `-e` option, during [PX-OCI](https://docs.portworx.com/runc/#step-2-configure-px-under-runc) or [PX Docker Container](https://docs.portworx.com/scheduler/docker/docker-container.html) command line install \(e.g. add `-e VAR=VALUE` option\).

```text
# Example PX-OCI config with extra "PX_ENABLE_CACHE_FLUSH" environment variable
sudo /opt/pwx/bin/px-runc install -e PX_ENABLE_CACHE_FLUSH=yes \
    -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb
```

**Examples**

Using etcd:

```text
px-runc install -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 -x swarm
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 -x swarm
```

Using consul:

```text
px-runc install -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 -x swarm
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 -x swarm
```

**Modifying the PX configuration**

After the initial installation, you can modify the PX configuration file at `/etc/pwx/config.json` \(see [details](https://docs.portworx.com/control/config-json.html)\) and restart Portworx using `systemctl restart portworx`.

**Step 3: Starting PX runC**

Once you install the PX OCI bundle and systemd configuration from the steps above, you can start and control PX runC directly via systemd:

```text
# Reload systemd configurations, enable and start Portworx service
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```

> **Note:** If you have previously installed Portworx as a Docker container \(as “legacy plugin system”, or v1 plugin\), and already have PX-volumes allocated and in use by other Docker containers/applications, read [instructions here](https://docs.portworx.com/runc/#upgrading-from-px-containers-to-px-oci)

### Adding Nodes {#adding-nodes}

To add nodes to increase capacity and enable high availability, simply repeat these steps on other servers. As long as PX is started with the same cluster ID, they will form a cluster.

### Access the pxctl CLI {#access-the-pxctl-cli}

After Portworx is running, you can create and delete storage volumes through the Docker volume commands or the **pxctl** command line tool.

With **pxctl**, you can also inspect volumes, the volume relationships with containers, and nodes. For more on using **pxctl**, see the [CLI Reference](https://docs.portworx.com/control/status.html).

To view the global storage capacity, run:

```text
sudo /opt/pwx/bin/pxctl status
```

The following sample output of `pxctl status` shows that the global capacity for Docker containers is 128 GB.

```text
/opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: 0a0f1f22-374c-4082-8040-5528686b42be
	IP: 172.31.50.10
 	Local Storage Pool: 2 pools
	POOL	IO_PRIORITY	SIZE	USED	STATUS	ZONE	REGION
	0	LOW		64 GiB	1.1 GiB	Online	b	us-east-1
	1	LOW		128 GiB	1.1 GiB	Online	b	us-east-1
	Local Storage Devices: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/xvdf	STORAGE_MEDIUM_SSD	64 GiB		10 Dec 16 20:07 UTC
	1:1	/dev/xvdi	STORAGE_MEDIUM_SSD	128 GiB		10 Dec 16 20:07 UTC
	total			-			192 GiB
Cluster Summary
	Cluster ID: 55f8a8c6-3883-4797-8c34-0cfe783d9890
	IP		ID					Used	Capacity	Status
	172.31.50.10	0a0f1f22-374c-4082-8040-5528686b42be	2.2 GiB	192 GiB		Online (This node)
Global Storage Pool
	Total Used    	:  2.2 GiB
	Total Capacity	:  192 GiB
```

