---
title: Disk Provisioning on AWS
description: Learn to scale a Portworx cluster up or down on AWS with Auto Scaling. Use our tips and tricks to make it simple!
keywords: portworx, AWS, ASG
linkTitle: AWS
weight: 1
noicon: true
---

{{<info>}}If you are running on Kubernetes, visit [Portworx on Kubernetes on AWS](/portworx-install-with-kubernetes/cloud/aws){{</info>}}

Below guide explains how Portworx dynamic disk provisioning works on AWS and the requirements for it. This is typically useful when an autoscaling group (ASG) is managing your AWS instances.

## AWS Requirements

{{% content "portworx-install-with-kubernetes/cloud/aws/shared/1-prepare.md" %}}

## EBS volume template

An EBS volume template defines the EBS volume properties that Portworx will use as a reference. There are 2 ways you can provide this template to Portworx. These templates are given to Portworx during installation.

### 1. Using a template specification

You can specify a template spec which will be used by Portworx to create new EBS volumes.

The spec follows the following format:
```
"type=<EBS volume type>,size=<size of EBS volume>,iops=<IOPS value>,enc=<true/false>,kms=<CMK>"
```

* __type__: Following two types are supported
    * _gp2_
    * _io1_ (For io1 volumes specifying the iops value is mandatory.)
* __size__: This is the size of the EBS volume in GB
* __iops__: This is the required IOs per second from the EBS volume.
* __enc__:  This needs to be set to true if EBS volumes need to be encrypted. Default: false
* __kms__:  This is the Customer Master Key to encrypt the EBS volume. i.e.`<key>` in `arn:aws:kms:us-east-1:<account-id>:key/<key>`

See [EBS details](https://aws.amazon.com/ebs/details/) for more details on above parameters.

Examples

* `"type=gp2,size=200"`
* `"type=gp2,size=100","type=io1,size=200,iops=1000"`
* `"type=gp2,size=100,enc=true,kms=AKXXXXXXXX123","type=io1,size=200,iops=1000,enc=true,kms=AKXXXXXXXXX123"`


### 2. Using existing EBS volumes as templates

You can also reference an existing EBS volume as a template.  Create at least one EBS volume using the AWS console or AWS CLI. This volume (or a set of volumes) will serve as a template EBS volume(s). On every node where PX is brought up as a storage node, a new EBS volume(s) identical to the template volume(s) will be created.

For example, create two volumes as:
```
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

Record the EBS volume ID (e.g. _vol-04e2283f1925ec9ee_), this will be passed in to PX as a parameter as a storage device.

### Limiting storage nodes

{{% content "cloud-references/auto-disk-provisioning/shared/asg-limit-storage-nodes.md" %}}

{{% content "cloud-references/auto-disk-provisioning/shared/asg-examples-aws.md" %}}

## EC2 Instance types
A PX cluster can be deployed with a heterogeneous makeup of EC2 instance types.  Some of your nodes can be used for converged compute and storage, some for compute only and some for storage only.

Follow this guide to select your appropriate [instance type](https://aws.amazon.com/ec2/instance-types/).  Once you create an AMI template for an instance type, you will create multiple instances from that AMI.  Make sure your AMIs are available in each region that you want to run the PX cluster in.

{{<info>}} Since PX is a replicated block device, you can also use instance local store volumes for maximum performance.  However you **must** have PX replication turned on.{{</info>}}

## Multi Zone Availability

Since PX is a replicated storage solution, we recommend using multiple availability zones when creating your EC2 based cluster.  Follow this site for more information on geographical availability of your instances: [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)
