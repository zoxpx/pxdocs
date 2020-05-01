---
title: Open NFS ports
weight: 4
keywords: sharedv4 volumes, ReadWriteMany, PVC, kubernetes, k8s
description: Open the NFS ports required for sharedv4 volumes to work.
hidden: true
---

SharedV4 volumes require specific open NFS ports to allow for communication between nodes in your cluster. Depending on how your cluster is configured, your firewall may block some of these ports or your NFS ports may differ from the defaults. To solve this, you may need to manually assign NFS ports and ensure your firewall or ACL allows them to communicate. 

This document provides instructions for detecting and opening NFS ports according to various cluster configurations you may have.

## Prerequistes

All of the use-cases in this document require the default Portworx ranges be open between hosts: ports 9001 - 9028 and port 111.
<!-- need to standardize cluster node and host. -->

## Determine which ports to open

Enter the `rpcinfo` command with the `-p` flag to find which ports NFS is using on your node:

    ```text
    rpcinfo -p
    ```

SharedV4 volumes communicate over the following ports:

* portmapper: 111 (default on all linux distributions)
* nfs service: 2049 (default on all linux distributions)
* mountd: 20048 (depends on the linux distribution)

If the default ports your OS uses match these ports, proceed to the **Open NFS ports on most Linux distributions** section.

If the NFS ports on your OS do not match these ports, or your ports are chosen randomly by your OS, proceed to the **Manually assign and open NFS ports** section.

## Open NFS ports on most Linux distributions

If your Linux distribution uses the default ports identified in the section above, you do not need to manually assign any ports for NFS, but you may need to open them.

Ensure your ports are open on any firewalls and your ACL by entering the following `iptables` command:

```text
iptables -I INPUT -p tcp -m tcp --match multiport --dports 111,2049,20048 -j ACCEPT
iptables -I OUTPUT -p tcp -m tcp --match multiport --dports 111,2049,20048 -j ACCEPT
```

Once you've determined your hosts are using the default ports and opened those ports, you can start using sharedV4 volumes.

## Manually assign and open NFS ports

For certain Linux distributions, the OS chooses the `mountd` port randomly every time the node reboots. To solve this, you must manually assign NFS ports, and how you accomplish this depends on your OS.

Only perform the steps in one of the following sections if:

* The `mountd` port is not fixed (and not 20048) and is chosen at random by your Linux distribution.
* You wish to open a contiguous range of ports for Portworx and want to shift the default NFS ports to the Portworx port range.

If you do need to manually assign and open NFS ports, follow the steps in the  section that applies for your OS:

### Assign NFS ports on CentOS and Red Hat Enterprise Linux

1. Modify the `/etc/sysconfig/nfs` file, uncommenting or adding the following fields and assigning the associated values:

    * `LOCKD_TCPPORT=9023`
    * `LOCKD_UDPPORT=9024`
    * `MOUNTD_PORT=9025`
    * `STATD_PORT=9026`

2. Enter the `systemctl restart nfs-server` command to restart the NFS server:

    ```text
    systemctl restart nfs-server
    ```

3. Open the newly assigned NFS ports on your access control list:

    ```text
    iptables -I INPUT -p tcp -m tcp --match multiport --dports 111,2049,9023,9025,9026 -j ACCEPT
    iptables -I OUTPUT -p tcp -m tcp --match multiport --dports 111,2049,9023,9025,9026 -j ACCEPT
    iptables -I INPUT -p udp -m udp --dport 9024  -j ACCEPT
    iptables -I OUTPUT -p udp -m udp --dport 9024  -j ACCEPT
    ```

### Open NFS ports on Debian-based Linux

1. Modify the `/run/sysconfig/nfs-utils` file, uncommenting or adding the following fields and assigning the associated values:

    * `RPCNFSDARGS=" 8 --port 9023"`: append the `--port 9023` option to any existing values.
    * `RPCMOUNTDARGS="--port 9024"`: add the `--port 9024` option.
    * `STATDARGS="--port 9025 --outgoing-port 9026"`: add the `--port 9025` and `--outgoing-port 9026` options.

2. Enter the following commands to restart the NFS server:

    ```text
    systemctl daemon-reload
    systemctl restart rpc-statd
    systemctl restart rpc-mountd
    systemctl restart nfs-server
    ```

3. Open the newly assigned NFS ports on your access control list:

    ```text
    iptables -I INPUT -p tcp -m tcp --match multiport --dports 111,2049,9023,9025,9026 -j ACCEPT
    iptables -I OUTPUT -p tcp -m tcp --match multiport --dports 111,2049,9023,9025,9026 -j ACCEPT
    iptables -I INPUT -p udp -m udp --dport 9024  -j ACCEPT
    iptables -I OUTPUT -p udp -m udp --dport 9024  -j ACCEPT
    ```

### Open NFS ports on CoreOS

The following sharedv4 NFS services run on a node when Portworx is installed with sharedv4 support:

* portmapper
* status
* mountd
* nfs and nfs_acl
* nlockmgr

View these services and the port they are using by entering the `rcpinfo -p` command:

    ```text
    rcpinfo -p
    ```

By default, services like `mountd` and `nlockmgr` run on random ports and must be fixed to a specific port.

#### Configure nfs, nfs_acl, and lockd ports

By default, the `nfs-server.service` configuration file is located under the following directory:

```text
/usr/lib/systemd/system/nfs-server.service
```

1. Check the status of the existing `nfs-server.service`:

    ```text
    systemctl status nfs-server
    ```

2. Copy the systemd unit file from the `usr` directory into the `etc` directory:

    ```text
    cp /usr/lib/systemd/system/nfs-server.service /etc/systemd/system/nfs-server.service
    ```

3. Open `/etc/systemd/system/nfs-server.service` in a text editor and, under the `[Service]` section, add the `--port 9023` value to the `ExecStart=/usr/sbin/rpc.nfsd` key:

    ```text
    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStartPre=/usr/sbin/exportfs -r
    ExecStart=/usr/sbin/rpc.nfsd --port 9023
    ExecStop=/usr/sbin/rpc.nfsd 0
    ExecStopPost=/usr/sbin/exportfs -au
    ExecStopPost=/usr/sbin/exportfs -f
    ```

4. Update the `lockd` ports:

    ```text
    echo 9027 > /proc/sys/fs/nfs/nlm_udpport
    echo 9028 > /proc/sys/fs/nfs/nlm_tcpport
    ```

5. Ensure the `lockd` manager ports persist over node reboots by creating a `100-nfs-ports.conf` file under the `/etc/sysctl.d/` folder and adding the ports to it:

    ```text
    cat /etc/sysctl.d/100-nfs-ports.conf
    fs.nfs.nlm_tcpport = 9027
    fs.nfs.nlm_udpport = 9028
    ```

6. Reload the `systemd` daemon and restart the `nfs-server` service:

    ```text
    systemctl daemon-reload
    systemctl restart nfs-server
    ```

7. Verify that the NFS services are running on the ports you configured by searching the output of `rcpinfo -p`:

    ```text
    rpcinfo -p | grep nfs
    ```
    ```output
    100003    3   tcp   9023  nfs
    100003    4   tcp   9023  nfs
    100227    3   tcp   9023  nfs_acl
    ```

    ```text
    rpcinfo -p | grep nlock
    ```
    ```output
    100021    1   udp   9027  nlockmgr
    100021    3   udp   9027  nlockmgr
    100021    4   udp   9027  nlockmgr
    100021    1   tcp   9028  nlockmgr
    100021    3   tcp   9028  nlockmgr
    100021    4   tcp   9028  nlockmgr
    ```

#### Configure mountd services

1. Check the status of the existing `nfs-server.service`:

    ```text
    systemctl status nfs-mountd
    ```

2. Copy the systemd unit file from the `usr` directory into the `etc` directory:

    ```text
    cp /usr/lib/systemd/system/nfs-mountd.service /etc/systemd/system/nfs-mountd.service
    ```

3. Open `/etc/systemd/system/nfs-mountd.service` in a text editor and, under the `[Service]` section, add the `--port 9024` value to the `ExecStart=/usr/sbin/rpc.mountd` key:

    ```text
    ...

    [Service]
    Type=forking
    ExecStart=/usr/sbin/rpc.mountd --port 9024
    ```

4. Reload the `systemd` daemon and restart the `nfs-server` service:

    ```text
    systemctl daemon-reload
    systemctl restart nfs-server
    ```

5. Verify that the NFS services are running on the ports you configured by searching the output of `rcpinfo -p`:

    ```text
    rpcinfo -p | grep mountd
    ```
    ```output
    100005    1   udp   9024  mountd
    100005    1   tcp   9024  mountd
    100005    2   udp   9024  mountd
    100005    2   tcp   9024  mountd
    100005    3   udp   9024  mountd
    100005    3   tcp   9024  mountd
    ```

#### Configure statd services

1. Check the status of the existing `rpc-statd.service`:

    ```text
    systemctl status rpc-statd
    ```
    <!-- what should users be looking for here? -->

2. Copy the systemd unit file from the `usr` directory into the `etc` directory:

    ```text
    cp /usr/lib/systemd/system/rpc-statd.service /etc/systemd/system/rpc-statd.service
    ```

3. Open `/etc/systemd/system/rpc-statd.service` in a text editor and, under the `[Service]` section, add the `--port 9025` and `--outgoing-port 9026` value to the `ExecStart=/usr/sbin/rpc.statd` key:

    ```text
    ...

    [Service]
    Environment=RPC_STATD_NO_NOTIFY=1
    Type=forking
    PIDFile=/var/run/rpc.statd.pid
    ExecStart=/usr/sbin/rpc.statd --port 9025 --outgoing-port 9026
    ```

4. Reload the `systemd` daemon and restart the `rpc-statd` service:

    ```text
    systemctl daemon-reload
    systemctl restart rpc-statd
    ```

5. Verify that the NFS services are running on the ports you configured by searching the output of `rcpinfo -p`:

    ```text
    rpcinfo -p | grep status
    ```
    ```output
    100024    1   udp   9025  status
    100024    1   tcp   9025  status
    ```
