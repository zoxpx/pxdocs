---
title: Shared
hidden: true
---

### Granting Portworx the needed AWS permissions {#aws-requirements}

Portworx creates and attaches EBS volumes. As such, it needs the AWS permissions to do so. Below is a sample policy describing these permissions:

```text
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

You can provide these permissions to Portworx in multiple ways. Click on the link below for more information.

{% page-ref page="key-management/portworx-with-aws-kms.md" %}

### Specify a disk template {#ebs-volume-template}

An EBS volume template defines the EBS volume properties that Portworx will use as a reference. There are two methods you can use to provide this template to Portworx. These are discussed below.

#### Method 1: Create your own template spec

In Portworx 1.3 and higher, you can specify a template spec which will be used by Portworx to create new EBS volumes.

The spec follows this format:

```text
"type=<EBS volume type>,size=<size of EBS volume>,iops=<IOPS value>"
```

* **type**: Following two types are supported
  * _gp2_
  * _io1_ \(For io1 volumes specifying the iops value is mandatory.\)
* **size**: This is the size of the EBS volume in GB
* **iops**: This is the required IOs per second from the EBS volume.

See [EBS details](https://aws.amazon.com/ebs/details/) for more details on above parameters.

Examples:

* `"type=gp2,size=200"`
* `"type=gp2,size=100","type=io1,size=200,iops=1000"`

You will use the template spec later, in the _Install Portworx with Kubernetes_ topic.

#### Method 2: Use existing EBS volumes as templates

You can also reference an existing EBS volume as a template. Create at least one EBS volume using the AWS console or AWS CLI. This volume \(or a set of volumes\) will serve as a template EBS volume\(s\). On every node where Portworx is active, a new EBS volume\(s\) identical to the template volume\(s\) will be created.

For example, create two volumes as:

```text
vol-0743df7bf5657dad8: 1000 GiB provisioned IOPS
vol-0055e5913b79fb49d: 1000 GiB GP2
```

Ensure that these EBS volumes are created in the same region as the auto scaling group.

You will use the EBS volume Id \(e.g. _vol-04e2283f1925ec9ee_\) in the _Install Portworx with Kubernetes_ topic, which is discussed next.
