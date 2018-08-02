---
title: Install
---

Why OCI

Running Portworx as a runC container eliminates any cyclical dependencies between a Docker container consuming storage from the Portworx container. It also enables you to run your Linux containers without a Docker daemon completely, while still getting all of the advantages of a Linux container and cloud native storage from Portworx.

To install and configure PX to run directly with OCI/runC, please use the configuration steps described in this section.

If you are already running PX as a docker container and need to migrate to OCI, following the [migration steps](https://docs.portworx.com/runc#upgrading-from-px-containers-to-px-oci).

> **Note:**  
> It is highly recommended to include the steps outlined in this document in a systemd unit file, so that PX starts up correctly on every reboot of a host. An example unit file is shown below.

### Install {#install}

#### Prerequisites {#prerequisites}

* _SYSTEMD_: The installation below assumes the [systemd](https://en.wikipedia.org/wiki/Systemd) package is installed on your system \(i.e. _systemctl_ command works\).
  * Note, if you are running Ubuntu 16.04, CentoOS 7 or CoreOS v94 \(or newer\) the “systemd” is already installed and no actions will be required.
* _SCHEDULERS_: If you are installing PX into **Kubernetes** or **Mesosphere DC/OS** cluster, we recommend to install the scheduler-specific Portworx package, which provides tighter integration, and better overall user experience.
* _FIREWALL_: Ensure ports 9001-9015 are open between the cluster nodes that will run Portworx.
* _NTP_: Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.
* _KVDB_: Please have a clustered key-value database \(etcd or consul\) installed and ready. For etcd installation instructions refer this [doc](https://docs.portworx.com/maintain/etcd.html).
* _STORAGE_: At least one of the PX-nodes should have extra storage available, in a form of unformatted partition or a disk-drive.  Also please note that storage devices explicitly given to Portworx \(ie. `px-runc ... -s /dev/sdb -s /dev/sdc3`\) will be automatically formatted by PX.

The installation and setup of PX OCI bundle is a 3-step process:

1. Install PX OCI bits
2. Configure PX OCI
3. Enable and start Portworx service

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
    -s /dev/xvdb -s /dev/xvdc 
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
px-runc install -k etcd://my.company.com:2379 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 
px-runc install -k etcd://70.0.1.65:2379 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 
```

Using consul:

```text
px-runc install -k consul://my.company.com:8500 -c MY_CLUSTER_ID -s /dev/sdc -s /dev/sdb2 
px-runc install -k consul://70.0.2.65:8500 -c MY_CLUSTER_ID -s /dev/sdc -d enp0s8 -m enp0s8 
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

**Advanced usage: Interactive/Foreground mode**

Alternatively, one might prefer to first start the PX interactively \(for example, to verify the configuration parameters were OK and the startup was successful\), and then install it as a service:

```text
# Invoke PX interactively, abort with CTRL-C when confirmed it's running:
sudo /opt/pwx/bin/px-runc run -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb

[...]
> time="2017-08-18T20:34:23Z" level=info msg="Cloud backup schedules setup done"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /run/docker/plugins/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="Starting REST service on socket : /var/lib/osd/driver/pxd.sock"
> time="2017-08-18T20:34:23Z" level=info msg="PX is ready on Node: 53f5e87b... CLI accessible at /opt/pwx/bin/pxctl."
[ hit Ctrl-C ]
```

### Upgrading the PX OCI bundle {#upgrading-the-px-oci-bundle}

To upgrade the OCI bundle, simply re-run the [installation Step 1](https://docs.portworx.com/runc/#install_step1) with the `--upgrade` option. After the upgrade, you will need to restart the Portworx service.

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false' | awk '/image: / {print $2}')
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable --upgrade
sudo systemctl restart portworx
```

### Uninstalling the PX OCI bundle {#uninstalling-the-px-oci-bundle}

To uninstall the PX OCI bundle, please run the following:

```text
# 1: Remove systemd service (if any)
sudo systemctl stop portworx
sudo systemctl disable portworx
sudo rm -f /etc/systemd/system/portworx*.service

# NOTE: if the steps below fail, please reboot the node, and repeat the steps 2..5

# 2: Unmount oci (if required)
grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci

# 3: Remove binary files
sudo rm -fr /opt/pwx

# 4: [OPTIONAL] Remove configuration files. Doing this means UNRECOVERABLE DATA LOSS.
sudo rm -fr /etc/pwx
```

### Migrating from PX-Containers to PX-OCI {#migrating-from-px-containers-to-px-oci}

If you already had PX running as a Docker container and now want to upgrade to runC, follow these instructions:

Step 1: Download and deploy the PX OCI bundle

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false' | awk '/image: / {print $2}')

sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

Step 2: Inspect your existing PX-Containers, record arguments and any custom mounts:

Inspect the mounts so these can be provided to the runC installer.

> **Note:**  
> Mounts for `/dev`, `/proc`, `/sys`, `/etc/pwx`, `/opt/pwx`, `/run/docker/plugins`, `/usr/src`, `/var/cores`, `/var/lib/osd`, `/var/run/docker.sock` can be safely ignored \(omitted\).  
> Custom mounts will need to be passed to PX-OCI in the next step, using the following notation:  
> `px-runc install -v <Source1>:<Destination1>[:<Propagation1 if shared,ro>] ...`

```text
# Inspect Arguments
sudo docker inspect --format '{{.Args}}' px-enterprise 
[ -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb ]

# Inspect Mounts
sudo docker inspect --format '{{json .Mounts}}' px-enterprise | python -mjson.tool 
[...]
    {
        "Destination": "/var/lib/kubelet",
        "Mode": "shared",
        "Propagation": "shared",
        "RW": true,
        "Source": "/var/lib/kubelet",
        "Type": "bind"
    },
```

Step 3: Install the PX OCI bundle

Remember to use the arguments from your PX Docker installation.

```text
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb
```

Step 4: Stop PX-Container and start PX runC

```text
# Disable and stop PX Docker container

sudo docker update --restart=no px-enterprise
sudo docker stop px-enterprise

# Set up and start PX OCI as systemd service

sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```

Once you confirm the PX Container -&gt; PX runC upgrade worked, you can permanently delete the `px-enterprise` docker container.

#### Logging and Log files {#logging-and-log-files}

The [systemd\(1\)](https://en.wikipedia.org/wiki/Systemd) uses a very flexible logging mechanism, where logs can be viewed using the `journalctl` command.

For example:

```text
# Monitor the Portworx logs
sudo journalctl -f -u portworx

# Get a slice of Portworx logs
sudo journalctl -u portworx --since 09:00 --until "1 hour ago"
```

However, if you prefer to capture Portworx service logs in a separate log file, you will need to modify your host system as follows:

```text
# Create a rsyslogd(8) rule to separate out the PX logs:
sudo cat > /etc/rsyslog.d/23-px-runc.conf << _EOF
:programname, isequal, "px-runc" /var/log/portworx.log
& stop
_EOF

# Create logrotate(8) configuration to periodically rotate the logs:
sudo cat > /etc/logrotate.d/portworx << _EOF
/var/log/portworx.log {
    daily
    rotate 7
    compress
    notifempty
    missingok
    postrotate
        /usr/bin/pkill -HUP syslogd 2> /dev/null || true
    endscript
}
_EOF

# Signal syslogd to reload the configurations:
sudo pkill -HUP syslogd
```

