---
title: Install on Docker Standalone
description: Learn how to run Porworx as a runC container.
keywords: Install, docker, standalone, runc container
noicon: true
weight: 1
series: px-docker-install
---

{{<info>}}
This document presents the **Docker** (or podman) method of installing a Portworx cluster using `runC` containers. Please refer to the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page if you want to install Portworx on Kubernetes.
{{</info>}}

## Why OCI

Running Portworx as a runC container eliminates any cyclical dependencies between the Docker container consuming storage from the Portworx container. It also enables you to run your Linux containers without a Docker daemon completely, while still getting all of the advantages of a Linux container and a cloud-native storage solution provided by Portworx.

## Install

To install and setup the Portworx OCI bundle, perform the following steps:

1. Install the Portworx OCI bundle
2. Configure the Portworx OCI bundle
3. Enable and start the Portworx service

### Prerequisites

* **Systemd**: The installation procedure assumes that the [systemd](https://en.wikipedia.org/wiki/Systemd) package is installed on your system. You can check if `systemd` is installed by entering the following command:

    ```text
    systemctl
    ```

    If you are running Ubuntu 16.04, CentOS 7 or CoreOS v94 or newer, `systemd` is already installed, and no actions are required.

* **Schedulers**: If you are installing Portworx into a Kubernetes or Mesosphere DC/OS cluster, {{<companyName>}} recommends using [Stork](https://github.com/libopenstorage/stork).
* **Firewall**: Ensure ports 9001-9022 are open on the cluster nodes that run Portworx.
* **NTP**: Ensure all nodes running Portworx are time-synchronized by installing and running the NTP service.
* **KVdb**: Portworx requires a key-value database like etcd or consul. {{<companyName>}} recommends a highly available etcd cluster with persistent storage. See the [etcd installation](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd) page for more details.
* **Storage**: At least one Portwox node should have extra storage available, either as an unformatted partition or as a disk-drive. Note that Portworx automatically formats any storage devices you pass as parameters to the `px-runc` installer. The following example command passes the `/dev/sdb` and `/dev/sdc3` storage devices as parameters:

    ```
     px-runc install -name portworx -c doc-cluster -k etcd:http://127.0.0.1:4001 -s /dev/sdb -s /dev/sdc3 -v /mnt:/mnt:shared
     ```


### Step 1: Install the Portworx OCI bundle

{{% content "shared/install-with-other-docker-shared-runc-install-bundle.md" %}}

### Step 2: Configure Portworx under runC

{{% content "shared/install-with-other-docker-runc-configure-portworx.md" %}}

### Step 3: Start Portworx runC

{{% content "shared/install-with-other-docker-shared-runc-enable-portworx.md" %}}

## Upgrade the Portworx OCI bundle

To upgrade the Portworx OCI bundle, simply re-run the [first step](#step-1-install-the-portworx-oci-bundle) from the installation process and pass the `--upgrade` flag to the `docker run` command.

The following coomands upgrade your Portworx OCI bundle to the latest stable:

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false&aut=false' | awk '/image: / {print $2}')
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable --upgrade
sudo systemctl restart portworx
```

Once the update process is finished, you must restart the Portworx service.

{{<info>}}
If you are installing Portworx on RedHat Linux or RedHat CoreOS with [CRI-O container runtime](https://www.redhat.com/en/blog/introducing-cri-o-10), you don't have to install Docker in order to install Portworx.
Instead, simply replace `docker` command with `podman` (e.g. `sudo podman run --entrypoint...`).
{{</info>}}

## Uninstall the Portworx OCI bundle

Run the following commands to uninstall the Portworx OCI bundle:

```text
# 1: Remove systemd service (if any)
sudo systemctl stop portworx
sudo systemctl disable portworx
sudo rm -f /etc/systemd/system/portworx*

# NOTE: if the steps below fail, please reboot the node, and repeat the steps 2..5

# 2: Unmount oci (if required)
grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci

# 3: Remove binary files
sudo rm -fr /opt/pwx

# 4: [OPTIONAL] Remove configuration files. Doing this means UNRECOVERABLE DATA LOSS.
sudo chattr -ie /etc/pwx/.private.json
sudo rm -fr /etc/pwx
```

#### Logging and Log files

The [systemd](https://en.wikipedia.org/wiki/Systemd) software uses a flexible logging mechanism, where logs can be viewed using the `journalctl` command.

For example, the following commands fetch the logs starting from 09:00 `until` 1 hour ago:

```text
# Monitor the Portworx logs
sudo journalctl -f -u portworx

# Get a slice of Portworx logs
sudo journalctl -u portworx --since 09:00 --until "1 hour ago"
```

If you prefer to capture Portworx service logs in a separate log file, you need to modify your host system as follows:

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

