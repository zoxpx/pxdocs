---
title: Cleaning up frameworks on DC/OS
description: Follow these two steps to clean up the resources in DC/OS after destroying a service. We're cleaning a portworx-cassandra service in this example.
keywords: portworx, container, Mesos, Mesosphere, DCOS, Cassandra
weight: 6
linkTitle: Cleaning up frameworks
---

You will have to run the following steps after destroying a service to clean up all the resources in DC/OS.  We are
going to clean up the `portworx-cassandra` service in this example. These steps can be used to clean up any service
in DC/OS including the Portworx service.

## Shutdown the service

Find the ID of the service that you want to cleanup. The service should be in inactive state, i.e. ACTIVE should be
set to False.
```text
dcos service --inactive
```
```output
NAME                         HOST               ACTIVE  TASKS  CPU    MEM      DISK   ID
portworx-cassandra  ip-10-0-2-15.ec2.internal   False    2    6.7  27530.0  59890.0  cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0051
marathon                  10.0.4.203            True     4    3.1   3200.0    0.0    cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0001
metronome                 10.0.4.203            True     0    0.0    0.0      0.0    cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0000
portworx            ip-10-0-2-15.ec2.internal   True     6    1.8   5632.0  16384.0  cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0050
```

Shutdown the service if you find it in inactive state. If you don't find the service, there is no need to shutdown.
```text
dcos service shutdown cc3a8927-1aec-4a8a-90d6-a9c317f9e8c6-0051
```

## Run janitor script
The janitor script will clean up the reserved resources as well as any state stored in Zookeeper.

```text
SERVICE_NAME=portworx-cassandra
PRE_RESERVED_ROLE="your_pre_reserved_role/" # Set this only if you started the service with a pre-reserved-role
dcos node ssh --master-proxy --leader \
    "docker run mesosphere/janitor /janitor.py -r ${PRE_RESERVED_ROLE}${SERVICE_NAME}-role -p ${SERVICE_NAME}-principal -z dcos-service-${SERVICE_NAME}"
```

## Cleanup Portworx framework

{{<info>}}
This section presents the **DC/OS** method of cleaning up the Portworx framework. Please refer to the [Uninstall on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/uninstall/) page if you are running Portworx on Kubernetes.
{{</info>}}

If you are trying to cleanup _Portworx_ framework, you will have to perform additional steps to cleanup the remnants
from slave nodes. Run the commands below on all the private agents where _Portworx_ was running.

### Stop Portworx service
```text
sudo systemctl stop portworx
sudo docker rm -f portworx.service
```

### Remove Portworx service
```text
sudo rm -f /etc/systemd/system/portworx.service
sudo rm -f /etc/systemd/system/dcos.target.wants/portworx.service
sudo rm -f /etc/systemd/system/multi-user.target.wants/portworx.service
sudo systemctl daemon-reload
```

### Wipe Portworx drives and config
{{<info>}}
**Note:** If you are going to re-install Portworx, you should wipe out the filesystem from the disks so that they
can be picked up by Portworx in the next install. This can be done by running the following pxctl command:
{{</info>}}

```text
# Use with care since this will wipe data from all the disks given to Portworx
sudo /opt/pwx/bin/pxctl service node-wipe --all
```

If you are running Portworx version < 1.3, run the following commands instead of `node-wipe`:

```text
sudo wipefs -a /dev/sda123 # Replace with your disk names
sudo chattr -i /etc/pwx/.private.json
sudo rm -rf /etc/pwx
sudo umount /opt/pwx/oci
sudo rm -rf /opt/pwx
```

### Remove Portworx kernel module

```text
sudo rmmod -f px
```

### Cleanup slaves with script
Alternatively, if you have the DC/OS CLI installed, then you can execute the above steps on all the nodes by running the following script:

```text
ips=(`dcos node --json | jq -r '.[] | select(.type == "agent") | .id'`)
for ip in "${ips[@]}"
do
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo systemctl stop portworx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo docker rm -f portworx.service'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -f /etc/systemd/system/portworx.service'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -f /etc/systemd/system/dcos.target.wants/portworx.service'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -f /etc/systemd/system/multi-user.target.wants/portworx.service'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo systemctl daemon-reload'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo /opt/pwx/bin/pxctl service node-wipe --all'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo chattr -i /etc/pwx/.private.json'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -rf /etc/pwx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo umount /opt/pwx/oci'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -rf /opt/pwx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rmmod -f px'
done
```

### Remove Portworx metadata from Zookeeper
{{<info>}}
**Note:** Only if you were running _Portworx_ with internal kvdb, you will have to cleanup _Portworx_ metadata from DC/OS Zookeeper.
{{</info>}}

In the Exhibitor UI, the metadata should be present under the Zookeeper node `/pwx/<portworx_cluster_id>`.
In the below example it is `/pwx/portworx-dcos`.

![Exhibitor Portworx metadata](/img/dcos-portworx-internal-kvdb-metadata.png)

Select the `/pwx/<portworx_cluster_id>` node and click on `Modify` button at the bottom of the page. In the
`Modify Node` dialog box select the `Type` as `Delete`.

![Exhibitor Portworx delete metadata](/img/dcos-portworx-delete-internal-kvdb-metadata.png)
