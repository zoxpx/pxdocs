---
title: Running Portworx in Production with DC/OS
description: Operations guide for running Portworx in Production with DC/OS
keywords: operations guide, run book, disaster recovery, disaster proof, site failure, node failure, power failure
weight: 1
linkTitle: Running Portworx in Production with DC/OS
---

## DAY 1 Operations

### Initial Software Setup for Production

* Deployment - Portworx can be deployed either as a DC/OS framework or as a systemd service directly in the system
  Refer to the install instructions for running PX as a DC/OS framework [page](/install-with-other/dcos). This deploys PX as a OCI container and as a framework in DC/OS

 (OR)

  * Deploy PX directly as [OCI container](/install-with-other/docker/standalone)
  * Ensure all nodes in the cluster have NTP running and the times are synchronized across all the nodes that will
    form the Portworx cluster
  * All nodes in the cluster should have achieved quorum and `pxctl status` should display the cluster as `operational`
  * etcd -  Setup etcd as a 3-node etcd cluster *outside* the  container orchestrator to ensure maximum stability. Refer to the following [page](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd) on how to install etcd and also configure it for maximum stability.

### Configuring the Server or the Compute Infrastructure

* Check and ensure a *minimum* 2 cores and 4GB of RAM are allocated for Portworx.
* The base operating system of the server supports linux kernel 3.10+ . Newer 4.x linux kernels have many performance and stability related fixes and is recommended.

```text
uname -r
```

```output
3.10.0-327.22.2.el7.x86_64
```

### Configuring the Networking Infrastructure

* Make sure the following ports are open in all the servers. 9001-9022

* Configure separate networks for Data and Management networks to isolate the traffic

  * Data network is specified giving the '-d' switch and Management networks with the '-m' switch. Refer to [scheduler guides](./) for specifics to enable it in your scheduler.

  * With multiple NICs, create a bonded ethernet port for data interface for improved availability and performance.

### Configuring and Provisioning Underlying Storage


#### Selecting drives for an installation

* Storage can be provided to Portworx explicitly by passing in a list of block devices. `lsblk -a` will display a list of devices on the system. This is accomplished by the '-s' flag as a runtime parameter. It can also be provided implicity by passing in the '-a' flag. In this mode, Portworx will pick up all the available drives that are not in use. When combined with '-f', Portworx will pick up drives even if they have a filesystem on them (mounted drives are still excluded).  Note that not all nodes need to contribute storage; a node can operate in the storageless mode with the '-z' switch. Refer to [scheduler guides](./) for specifics for your scheduler.

* HW RAID - If there are many drives in a server and drive failure tolerance is required per server, enable HW RAID (if available) and give the block device from a HW RAID volume for Portworx to manage.

* PX classifies drive media into different performance levels and groups them in separate pools for volume data. These levels are called `io_priority` and they offer the levels  `high`, `medium` and `low`

* The `io_priority` of a pool is determined automatically by PX. If the intention is to run low latency transactional workloads like databases on PX, then Portworx recommends having NVMe or other SAS/SATA SSDs in the system. Pool priority can be managed as documented [here](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/maintenance-mode)

* This [page](/concepts/class-of-service) offers more information on different io_prioirty levels


####  Working with drives with AWS Auto scaling group

Portworx supports automatic management of EBS volumes. If you are using AWS ASG to manage PX nodes,then you should to use the ASG [feature](/portworx-install-with-kubernetes/cloud/aws/aws-asg)

### PX Node Topology

PX replicated volumes distributes data across failure domains. For on-premise installations, this ensures that a power failure to a rack does not result in data unavailability. For cloud deployments this ensures data availability across zones.

### Topology in cloud environments

PX auto-detects availabilty zones and regions and provisions replicas across
  different zones. For e.g., see below for the partial output of `pxctl status`:

```text
pxctl status
```

```output
   Status: PX is operational
   License: Trial (expires in 23 days)
   Node ID: a17f382d-b2ef-41b8-81fc-d9b86d56b5d1
	  IP: 172.31.51.89
 	  Local Storage Pool: 2 pools
	  POOL	IO_PRIORITY	RAID_LEVEL	USABLE	USED	STATUS	ZONE	REGION
	  0	LOW		raid0		64 GiB	1.1 GiB	Online	b	us-east-1
	  1	LOW		raid0		128 GiB	65 GiB	Online	b	us-east-1
    ...
    ...
  ```

  This node is in us-east-1. If PX is started in other zones, then when a volume with greater than 1 replication factor
  is created, it will have the replicas automatically created in other nodes in other zones.

### Topology in on-premise deployments

Failure domains in terms of RACK information can be passed in as described [here](/concepts/update-geography-info)


### Volume Management Best Practices

* Volumes - Portworx volumes are thinly provisioned by default. Make sure to monitor for capacity for `VolumeSpaceLow` alerts. These alerts are triggered when the free available space goes below a threshold. See [this page](/install-with-other/operate-and-maintain/monitoring/portworx-alerts) for more details.

* For applications needing node level availability and read parallelism across nodes, it is recommended to set the volumes with replication factor 2 or replication factor 3/

  Here is how one can configure a volume with replication factor 3:

  ```text
  pxctl volume create dbasevol --size=1 --repl=3 --iopriority=high
  ```

* PX makes the best effort to distribute volumes evenly across all nodes and based on the `iopriority` that is requested. When PX cannot find the appropriate media type that is requested to create a given `iopriority` type, it will attempt to create the volume with the next available `iopriority` level.

* Volumes can be created in different availability zones by using the `--zones` option in the `pxctl volume create` command:

  ```text
  pxctl volume create dbasevol --size=1 --repl=3 --iopriority=high --zones=us-east-1,us-east-2,us-east-3
  ```

* Volumes can be created in different racks using `--racks` option and passing the rack labels when creating the volume:

  ```text
  pxctl volume create dbasevol --size=1 --repl=3 --iopriority=high --racks=dcrack1,dcrack2,dcrack3
  ```

  Please ensure the PX containers are started with the corresponding rack parameters.

* If the volumes need to be protected against accidental deletes because of background garbage collecting scripts, then the volumes need to be created with the `--sticky` flag:

  ```text
  pxctl volume create dbasevol --size=1 --repl=3 --iopriority=high --sticky
  ```

* The `--sticky` flag can be turned on and off using the `pxctl volume update` commands:

  ```text
  pxctl volume update dbasevol --sticky=off
  ```

* For applications that require shared access from multiple containers running in different hosts, Portworx recommends running shared volumes. Shared volumes can be configured as follows:

  ```text
  pxctl volume create wordpressvol --shared --size=100 --repl=3
  ```

  This [page](/concepts) gives more details on different volume types, how to create them and update the configuration for the volumes

### Data Protection for Containers

* Snapshots - Follow DR best practices and ensure volume snapshots are scheduled for instantaneous recovery in case of app failures.

* Portworx supports 64 snapshots per volume

* Each snapshot can be taken manually via the `pxctl snap create` command like this:

  ```text
  pxctl snap create --name mysnap --label color=blue,fabric=wool myvol
  ```

  ```output
  Volume successfully snapped: 1152602487227170184
  ```

* Alternatively, snapshots can be scheduled by creating a hourly, daily or weekly schedule. This will enable the snapshots to be automatically created without user intervention:

  ```text
  pxctl volume create --daily @08:00 --daily @18:00 --weekly Friday@23:30 --monthly 1@06:00 myvol
  ```

* Here is more information on how to setup [snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots) in PX-Enterprise.

* For DR, it is recommended to setup cloudsnaps as well. This is covered in detail in the Day 3 - Cloudsnaps section

### Alerts and Monitoring for Production

Portworx recommends setting up monitoring with Prometheus and AlertsManager to ensure monitoring of the data services infrastructure for your containers

While Prometheus can be deployed as a container within the container orchestrator, many of Portworx's production customers deploy Prometheus in a separate cluster that is dedicated for managing and monitoring their large scale container orchestrator infrastructure.

  * Here is how Prometheus can be setup to monitor Portworx [Prometheus](/install-with-other/operate-and-maintain/monitoring/prometheus)
  * Configure Grafana via this [template](/install-with-other/operate-and-maintain/monitoring/grafana)
  * Here is how Alerts Manager can be configured for looking for alerts with [Alerts Manager](/install-with-other/operate-and-maintain/monitoring/alerting)
  * List of Portworx Alerts are documented [here](/install-with-other/operate-and-maintain/monitoring/portworx-alerts)

## Day 2 Operations

### Hung Node Recovery

* A PX node may hang or appear to hang because of the following reasons:
  * Underlying media being too slow to respond and thus PX trying to error recovery of the media
  * Kernel hangs or panics that are impacting overall operations of the system
  * Other applications that are not properly constrainted putting heavy memory pressure on the system
  * Applications consuming a lot of CPU that are not properly constrained.

* Docker Daemon issues where Docker itself has hung and thus resulting on all other containers not responding properly.

* Running PX as a OCI container greatly alleviates any issues introduced by Docker Daemon hanging or not being responsive as PX runs as a OCI container and not as a docker container thus eliminating the docker dependency.

* If PX appears to not respond, a restart of the PX OCI container via `systemctl` would help.

* Any PX restart within 10 mins will ensure that applications continue to run without experiencing volume unmounts/outage.

### Stuck Volume Detection and Resolution

* With DC/OS, it is possible that even after the application container terminates, a volume is left attached. This volume is still available for use in any other node. PX makes sure that if a volume is not in use by an application, it can be attached to any other node in the system.

* With this attach operation, PX will automatically manage the volume attach status with no user intervention required and continue to serve the volume I/Os even a container attaches to the same volume from a different node.

### Scaling out a cluster nodes in the Cloud and On-Prem

#### Scaling out a cluster in cloud

* The best way to scale a cluster is via ASG integration on AWS.
* This feature is called Stateful Autoscaling and is described [here](/portworx-install-with-kubernetes/cloud/aws/aws-asg/#stateful-autoscaling).
  * Perform sizing of your data needs and determine the amount and type of storage (EBS volumes) needed per ECS instance.
  * Create EBS volume [templates](/portworx-install-with-kubernetes/cloud/aws/aws-asg/#create-ebs-volume-templates) to match the number of EBS volumes needed per EC2 instance.
  * Create a [Stateful AMI](/portworx-install-with-kubernetes/cloud/aws/aws-asg/#create-a-stateful-ami) to associate with your auto-scaling group.
  * Once everything is setup, as described in the steps above, then the cluster can be scaled up and down via ASG. Portworx will automatically manage the EBS volume creation and preserve the volumes across the cluster scaling up and down. This [page](/portworx-install-with-kubernetes/cloud/aws/aws-asg/#scaling-the-cluster-up) desribes how PX handles the volume management in a auto-scaling cluster.

#### Scaling out a cluster on-prem

* The best way to scale the cluster on-prem is by having the new nodes join the existing cluster. This [page](/install-with-other/operate-and-maintain/scaling/scale-out) shows how to scale up a existing cluster by adding more nodes.

* Using DC/OS, if PX is installed as a framework, you can also scale a PX cluster by using the DC/OS PX [framework](/install-with-other/dcos/#scaling-up-portworx-nodes).


### Cluster Capacity Expansion

* Cluster storage capacity can be expanded by adding more drives each node.
* Drives with similar capacity (within 1GB capacity difference) will be grouped together as a same pool.
* Drives can be added per node and PX will add that to the closest pool size by drive size.
* Before adding drives to the node, the node will need to be taken into maintenance mode
* Ensure the volumes in the node have replicas in other nodes.
  * If the volumes have replication factor of 1, increase the [replication factor](/reference/cli/updating-volumes).
  * Ensure the services are failed over to a different node when the node is taken into maintenance mode.
* Follow the instructions in this [page](/install-with-other/operate-and-maintain/scaling/scale-up) to add storage each node.

### Server and Networking Replacements and Upgrades

* Servers running PX can be replaced by performing decommissioning of the server to safely remove them from the cluster.
* Ensure that all the volumes in the cluster are replicated before decommissioning the node so that the data is still available for the containers mounting the volumes after the node is decommisioned.
* Use `pxctl cluster delete` command to manually remove the node from the cluster.
* Follow the instructions in this page to [delete](/install-with-other/operate-and-maintain/scaling/scale-down/#prevention-of-data-loss) nodes in the cluster
* Once the node is decommissioned, components like network adapters, storage adapters that need to be replaced can be replaced.
* The server can be replaced as well.
* Once the replacement is done, the node can be joined back to the cluster by going through the steps described in the scaling-out the cluster section.

### Software Upgrades

#### Portworx Software Upgrades

  * Work with Portworx Support before planning major upgrades. Ensure all volumes have the latest snapshots before performing upgrades.
  * Ensure there are [cloudsnaps](/reference/cli/cloud-snaps) that are taken for all the volumes.
  * If you are using the Portworx DC/OS framework for deploying PX and running PX as OCI format container, follow this [link](/install-with-other/dcos/operate-and-maintain/upgrade-oci) to perform the upgrades.
  * If you are running PX as a systemd service, follow this [link](/install-with-other/dcos/operate-and-maintain/upgrade).


#### DC/OS Upgrades

* Work with Portworx Support before planning major upgrades. Ensure all volumes have the latest snapshots before performing upgrade.
* Ensure there are [cloudsnaps](/install-with-other/dcos/operate-and-maintain/upgrade) that are taken.
* Due to a [bug in DCOS](https://jira.mesosphere.com/browse/DCOS_OSS-2103) the Portworx service file will get removed after an upgrade. Please run `dcos portworx plan force-restart deploy portworx-deploy` after the DCOS upgrade to re-deploy the service file.
* After the migration, relaunch PX and ensure that the entire cluster is online by running `pxctl status`.
* Check if the DC/OS services via marathon and any other frameworks can mount the PX volumes from the marathon UI or the DC/OS UI.

#### OS upgrades and Docker Upgrades

* Work with Portworx Support before planning major upgrades. Ensure all volumes have the latest snapshots before performing the upgrade.
* Ensure kernel-devel packages are installed after a OS migration.
* If PX is run as a OCI container, Docker Upgrades and Restarts do not impact PX runtime. So recommend running PX as a OCI container.

## Day 3 Operations

### Handling Lost or Stale Nodes on the Cloud and On-Prem

* Lost or Stale Nodes can be removed from the PX cluster for force-decommissioning the node from the cluster.
* The command used to remove a node is `pxctl cluster delete -f`.
* For e.g., if a specific node is offline but it no longer exists, use ` pxctl cluster delete -f node-id` to remove the node from the cluster.

### Volume Data Recovery

### Disaster Recovery with Cloudsnaps

* It is recommended to setup cloudsnaps for volume backup and recovery to handle DR scenarios.
* Cloudsnaps are also good way to perform cluster to cluster data migration.
* Cloudsnaps can work with Amazon S3, Azure Blob, Google Cloud Storage or any S3 compatible object store.
* Cloudsnaps store the volume snaps in the cloud and on import, can roll up all the snaps and import a point-in-time copy of the volume into the cluster.
* It is recommended to take atleast one cloudsnap a day for each volume in production in the cluster.
* Cloudsnaps can be scheduled via the Portworx CLI for hourly, daily, weekly or monthly snaps.
* Cloudsnaps can also be scheduled to happen at a particular time. It is recommended to schedule cloudsnaps at a time when the application data traffic is light to ensure faster back-ups.
* Follow [DR best practices](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/dr-best-practices) and setup periodic cloudsnaps so in case of a disaster, Portworx volumes can be restored from an offsite backup.

### Drive Replacements

* Any drive in a given node can be replaced by another drive in the same node.
* In order to perform a drive replacement, the PX node must be put into `maintenance mode`.

#### Step 1: Enter Maintenance mode

```text
pxctl service  maintenance --enter
```

```output
This is a disruptive operation, PX will restart in maintenance mode.
Are you sure you want to proceed ? (Y/N): y

PX is not running on this host.
```

#### Step 2: Replace old drive with a new drive

Ensure the replacement drive is already available in the system.

For e.g., replace drive /dev/sde with /dev/sdc:

```text
pxctl service drive replace --source /dev/sde --target /dev/sdc --operation start
```

```output
"Replace operation is in progress"
```

Check the status:

```text
pxctl service drive replace --source /dev/sde --target /dev/sdc --operation status
```

```output
"Started on 16.Dec 22:17:06, finished on 16.Dec 22:17:06, 0 write errs, 0 uncorr. read errs\n"
```


#### Step 3: Exit Maintenance mode

```text
pxctl service  maintenance --exit
```

```output
PX is now operational
```

#### Step 4: Check if the drive has been successfully replaced

```text
pxctl service drive show
```

```output
PX drive configuration:
Pool ID: 0
	IO_Priority: LOW
	Size: 15 TiB
	Status: Online
	Has meta data: No
	Drives:
	1: /dev/sdc, 3.0 GiB allocated of 7.3 TiB, Online
	2: /dev/sdb, 0 B allocated of 7.3 TiB, Online
Pool ID: 1
	IO_Priority: HIGH
	Size: 1.7 TiB
	Status: Online
	Has meta data: Yes
	Drives:
	1: /dev/sdj, 1.0 GiB allocated of 1.7 TiB, Online
```
* If there is no spare drive available in the system, then the following steps need to be performed:
  * Decommission the PX node (Refer to `pxctl cluster delete`).
  * Ensure all volumes have replicas in other nodes if you still need to access the data.
  * Replace the bad drive(s) with new drive(s).
  * Add the node to the cluster as a new node.
     (refer to [adding cluster nodes](/install-with-other/operate-and-maintain/scaling/scale-out)).
  * Ensure the cluster is operational and the new node has been added to the cluster via `pxctl cluster status` and `pxctl cluster list`.
