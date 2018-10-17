---
title: Portworx AWS Auto Scaling
weight: 5
linkTitle: Auto Scaling Group (ASG)
---

This document describes how you can easily scale a Portworx cluster up or down on AWS using [**Auto Scaling Groups**](https://aws.amazon.com/autoscaling/)

## About Stateful Auto Scaling
In order to determine if stateful auto scaling is needed in your environment, read [this blog](https://portworx.com/auto-scaling-groups-ebs-docker/) to get an overview of what this feature does.

## Configure the Auto Scaling Group
Use the [AWS tutorial](http://docs.aws.amazon.com/autoscaling/latest/userguide/GettingStartedTutorial.html) to set up an auto scaling group.

## Portworx in an Auto Scaling Group

EC2 instances in an ASG are ephemeral in nature. In such an environment Portworx can create EBS volumes based on an input template whenever a new instance spins up and provision persistent volumes for your applications. Portworx fingerprints the EBS volumes and attaches them to an instance in the autoscaling cluster. In this way an ephemeral instance gets its own identity.  When an instance terminates, the auto scaling group will automatically add a new instance to the cluster. Portworx gracefully handle this scenario by re-attaching the old EBS volumes to it and give a new instance the old identity.  This ensures that the instance's data is retained with zero storage downtime.

## Stateless Autoscaling
When your Portworx instances do not have any local storage, they are called `head-only` or `stateless` nodes.  They still participate in the PX cluster and can provide volumes to any client container on that node.  However, they strictly consume storage from other stateful PX instances.

Automatically scaling these PX instances up or down do not require any special care, since they do not have any local storage.  They can join and leave the cluster without any manual intervention or administrative action.

To have your stateless PX nodes join a cluster, you need to create a master AMI from which you autoscale your instances.

## Create a stateless AMI
You will need to create a master AMI that you will associate with your auto scaling group.  This AMI will be configured with Docker and for PX to start via `systemd`.

1. Select a base AMI from the AWS market place.
2. Launch an instance from this AMI.
3. Configure this instance to run PX in storage-less mode.  Install Docker and follow [these](https://docs.portworx.com/runc/index.html) instructions to configure the image to run the PX runC container.

{{<info>}}
**Note:**<br/>Please **do not start PX** while creating the master AMI.  If you do, then the AMI will have already been initialized as a new PX node.
{{</info>}}

This AMI will ensure that PX is able to launch on startup.  Ensure that the `stateless AMI` specifies the `-z` option so that PX installs as a storage-less node:

```bash
$ sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
       -k etcd://myetc.company.com:2379 -z
```
{{<info>}}
**Note:** The `-z` option instructs PX to come up as a stateless node.
{{</info>}}

At this point, these nodes will be able to join and leave the cluster dynamically.

## Stateful Autoscaling
When your Portworx instances have storage associated with them, they are called `stateful` nodes and extra care must be taken when using `Auto Scaling`.  As instances get allocated, new EBS volumes may need to be allocated.  Similarly as instances as scaled down, care must be taken so that the EBS volumes are not deleted.

This section explains specific functionality that Portworx provides to easily integrate your auto scaling environment with your stateful PX nodes and optimally manage stateful applications across a variable number of nodes in the cluster.

## EBS volume template

You can also reference an existing EBS volume as a template.  Create at least one EBS volume using the AWS console or AWS CLI. This volume (or a set of volumes) will serve as a template EBS volume(s). On every node where PX is brought up as a storage node, a new EBS volume(s) identical to the template volume(s) will be created.

For example, create two volumes as:
```text
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

Record the EBS volume ID (e.g. _vol-04e2283f1925ec9ee_), this will be passed in to PX as a parameter as a storage device.

### Limiting storage nodes.

PX allows you to create a heterogenous cluster where some of the nodes are storage nodes and rest of them are storageless. Based on the PX version follow one of the below procedure.

#### PX Version 1.5

You can specify the number of storage nodes in your cluster by setting the ```max_storage_nodes_per_zone``` input argument.
This instructs PX to limit the number of storage nodes in one zone to the value specified in ```max_storage_nodes_per_zone``` argument. The total number of storage nodes in your cluster will be
```text
Total Storage Nodes = (Num of Zones) * max_storage_nodes_per_zone.
```
While planning capacity for your auto scaling cluster make sure the minimum size of your cluster is equal to the total number of storage nodes in PX. This ensures that when you scale up your cluster, only storage less nodes will be added. While when you scale down the cluster, it will scale to the minimum size which ensures that all PX storage nodes are online and available.

{{<info>}}
**Note:**<br/> You can always ignore the **max_storage_nodes_per_zone** argument. When you scale up the cluster, the new nodes will also be storage nodes but while scaling down you will loose storage nodes causing PX to loose quorum.
{{</info>}}

Examples:
```text
"-s", "type=gp2,size=200", "-max_storage_nodes_per_zone", "1"
```

For a cluster of 6 nodes spanning 3 zones (us-east-1a,us-east-1b,us-east-1c), in the above example PX will have 3 storage nodes (one in each zone) and 3 storage less nodes. PX will create a total 3 EBS volumes of size 200 each and attach one EBS volume to each storage node.

```text
"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_storage_nodes_per_zone", "2"
```

For a cluster of 9 nodes spanning 2 zones (us-east-1a,us-east-1b), in the above example PX will have 4 storage nodes and 5 storage less nodes. PX will create a total of 8 EBS volumes (4 of size 200 and 4 of size 100). PX will attach a set of 2 EBS volumes (one of size 200 and one of size 100) to each of the 4 storage nodes..


#### PX Version 1.4 and older

You can specify the number of storage nodes in your cluster by setting the ```max_drive_set_count``` input argument.
Modify the input arguments to PX as shown in the below examples.

Examples:

```text
"-s", "type=gp2,size=200", "-max_drive_set_count", "3"
```

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total 3 EBS volumes of size 200 each and attach one EBS volume to each storage node.

```text
"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_drive_set_count", "3"
```

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total of 6 EBS volumes (3 of size 200 and 3 of size 100). PX will attach a set of 2 EBS volumes (one of size 200 and one of size 100) to each of the 3 storage nodes..

## Create a stateful AMI
Now you will need to create a master AMI that you will associate with your auto scaling group.  This AMI will be configured with Docker and for PX to start via `systemd`.

The `stateful` PX instances need some additional information to properly operate in an autoscale environment:

1. AWS access credentials
2. EBS template information created above

The PX instance that is launching will use the above information to either allocate an existing EBS volume to the instance, or create a new one based on the template.  The exact procedure for how the PX instance assignes itself an EBS volume is described further below.

1. Select a base AMI from the AWS market place.
2. Launch an instance from this AMI.
3. Configure this instance to run PX in storage mode.  Install Docker and follow [these](https://docs.portworx.com/runc/index.html) instructions to configure the image to run the PX runC container.

{{<info>}}
**Note:**<br/>Please **do not start PX** while creating the master AMI.  If you do, then the AMI will have already been initialized as a new PX node.
{{</info>}}

This AMI will ensure that PX is able to launch on startup.  Ensure that the `storage AMI` specifies the `-s` option with the EBS volume template.  This ensures that PX installs as a storage node:

```bash
$ sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
       -k etcd://myetc.company.com:2379 -z
```

{{<info>}}
**Note:**There are 2 new env variables passed into the ExecStart.  These are AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY used for authentication.
{{</info>}}

{{<info>}}
**Note:** -s vol-0743df7bf5657dad8 and -s vol-0055e5913b79fb49d - you can pass multiple EBS volumes to use as templates. If these volumes are unavailable, then volumes identical to these will be automatically created.
{{</info>}}

{{<info>}}
**Note:** The cluster ID is the same as the ID used for the storage-less nodes.
{{</info>}}

### Cloud-Init
Optionally, EBS template information can be provided by the `user-data` in [cloud-init](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html).

Specify the following information in the `user-data` section of your instance while creating the launch configuration for your auto scaling group:

```bash
#cloud-config
portworx:
  config:
    storage:
      devices:
      - vol-0743df7bf5657dad8
      - vol-0055e5913b79fb49d
```

PX will use the EBS volume IDs as volume template specs.  Each PX instance that is launched will either grab a free EBS volume that matches the template, or create a new one.

Note that even though each instance is launched with the same `user-data` and hence the same EBS volume template, during runtime, each PX instance will figure out which actual EBS volume to use.

### AWS Requirements

As Portworx needs to create and attach EBS volumes, it needs corresponding AWS permissions. Following is a sample policy describing those permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "<stmt-id>",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DescribeTags",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

You can provide these permissions to Portworx in one of following ways:

1. Instance Privileges: Provide above permissions for all the instances in the autoscaling cluster by applying the corresponding IAM role. More info about IAM roles and policies can be found [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)
2. Environment Variables: Create a User with the above policy and provide the security credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) to Portworx.

Following is an example policy that has all the required permissions

## Scaling the Cluster Up
For each instance in the auto scale group, the following process takes place on the first boot (Note that the `user-data` is made available only during the first boot of an instance):

1. When a PX node starts for the first time, it inspects it's config information (passed in via `user-data` or env variables).
2. PX will also use the AWS credentials provided (or instance priviledges) to query the status of the EBS volumes:
   - If there exists an unattached EBS volume that matches the template in the `storage` section of the `user-data`, PX will assign that volume to this instance.
   - If there does not exist an unattached EBS volume, then PX will create one that matches the template, as long as the total number of volumes in this scale group is less than the `max-count` parameter.
   - If there are more than `max-count` EBS volumes, this PX instance will initialize itself as a `storage-less` node.
3. PX will now join the cluster using the following scheme:
   - If PX **created a new** EBS volume, then PX will then use the information provided in the `px-cluster` section of the `user-data` to join the cluster.  PX creates the `/etc/pwx/config.json` cluster config information **directly inside the EBS volume** for subsequent boots.
   - On the other hand, if this PX instance was able to get an **existing** EBS volume, it will look for the PX cluster configuration information and use that to join the cluster as an existing node.

When PX creates an EBS volume, it adds labels on the volume so that the volume is associated with this cluster.  This is how multiple volumes from different clusters are kept seperate.  The labels will look like:
```bash
PWX_CLUSTER_ID=my-px-asg-cluster
PWX_EBS_VOLUME_TEMPLATE=vol-0055e5913b79fb49d
```

If an instance is terminated by EC2 ASG, then the following happens:
1. The EBS volume associated with that instance gets detached.
2. A new EC2 instance from the AMI gets created by ASG and PX will be able to attach to the free EBS volumes and re-join the cluster with the existing information.

If the number of instances are scaled up, then the following happens:
1. PX on the new instance will detect that there are no free EBS volumes.
2. PX will create a new EBS volume.
3. PX will join the cluster as a new node.

## Scaling the Cluster Down
When you scale the cluster down, the EBS volume (if any) associated with this instance simply gets released back into the EBS pool.  Any other PX instance can optionally be instructed to use this volume on another PX node using the [`pxctl service drive add`](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/scale-up) command.

In the case of ASG, if you want to scale down your PX cluster, you will not be able to use methods mentioned in [Scale-Down Nodes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/scale-down#removing-a-functional-node-from-a-cluster). You can still reduce the size of your Auto Scaling Group, while making sure to maintain PX cluster quorum.

## Corelating EBS volumes with Portworx nodes

Portworx when running in ASG mode provides a set of CLI commands to display the information about all EBS volumes
and their attachment information.

{{<info>}}
**Note:** Following commands are only available for PX version > 1.3
{{</info>}}

#### Listing all Cloud Drives

Run the following command to display all the cloud drives being used by Portworx.

```text

# /opt/pwx/bin/pxctl clouddrive list

Cloud Drives Summary
        Number of nodes in the cluster:  3
        Number of drive sets in use:  3
        List of storage nodes:  [ip-172-20-52-178.ec2.internal ip-172-20-53-168.ec2.internal ip-172-20-33-108.ec2.internal]
        List of storage less nodes:  []

Drive Set List
        NodeIndex        NodeID                                InstanceID                Zone                Drive IDs
        0                ip-172-20-53-168.ec2.internal        i-0347f50a091716c66        us-east-1a        vol-0a3ff5863c7b2c2e4, vol-0f821f3e3a884e275
        1                ip-172-20-33-108.ec2.internal        i-089b22fc89bb11a92        us-east-1a        vol-048dd9c1fd5ed421d, vol-012a4ed30013590ef
        2                ip-172-20-52-178.ec2.internal        i-09169ceb37b251bac        us-east-1a        vol-0bd9aaab0fb615351, vol-0c9f027d111844227
```

#### Inspecting Cloud Drives

Run the following command to display more information about the drives attached on a node.

```text

# /opt/pwx/bin/pxctl clouddrive inspect --nodeid ip-172-20-53-168.ec2.internal

Drive Set Configuration
        Number of drives in the Drive Set:  2
        NodeID:  ip-172-20-53-168.ec2.internal
        NodeIndex:  0
        InstanceID:  i-0347f50a091716c66
        Zone:  us-east-1a

        Drive  0
                ID:  vol-0a3ff5863c7b2c2e4
                Type:  io1
                Size:  16 Gi
                Iops:  100
                Path:  /dev/xvdf

        Drive  1
                ID:  vol-0f821f3e3a884e275
                Type:  gp2
                Size:  8 Gi
                Iops:  100
                Path:  /dev/xvdg
```

## Note

1. When starting a PX cluster with AWS Auto Scaling, you will not be able to use this cluster's configuraion on any other nodes which are not started by ASG.
2. If PX is unable to attach an ESB volume, it will retry, during which node index might get increased. This should be okay and should not affect any cluster, volume operations.
