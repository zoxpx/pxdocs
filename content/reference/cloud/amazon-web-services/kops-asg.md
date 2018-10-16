---
title: Run Portworx with Kubernetes Operations(KOPS)
weight: 4
linkTitle: KOPS (Kubernetes Operations)
---

This is a guide to setup a production ready Portworx cluster using Kubernetes (KOPS+AWS) environment that allows you to dynamically provision persistent volumes. KOPS helps you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes clusters. Under the hood KOPS uses AWS Autoscaling groups (ASG) to spin up EC2 instances.

## Portworx in an Auto Scaling Group

EC2 instances in an ASG are ephemeral in nature. In such an environment Portworx can create EBS volumes based on an input template whenever a new instance spins up and provision persistent volumes for your applications. Portworx fingerprints the EBS volumes and attaches them to an instance in the autoscaling cluster. In this way an ephemeral instance gets its own identity.  When an instance terminates, the auto scaling group will automatically add a new instance to the cluster. Portworx gracefully handle this scenario by re-attaching the old EBS volumes to it and give a new instance the old identity.  This ensures that the instance's data is retained with zero storage downtime.

## Prerequisites

**Key-value store**

Portworx uses a key-value store for it's clustering metadata. Please have a clustered key-value database (etcd or consul) installed and ready. For etcd installation instructions refer this [doc](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd).

**Firewall**

Ensure ports 9001-9015 are open between the nodes that will run Portworx. Your nodes should also be able to reach the port KVDB is running on (for example etcd usually runs on port 2379).

**NTP**

Ensure all nodes running PX are time-synchronized, and NTP service is configured and running.

{{<info>}}
**Note:**<br/> This deployment model where Portworx provisions storage drives is not supported with internal kvdb.
{{</info>}}

## AWS Requirements

As Portworx needs to create and attach EBS volumes, it needs corresponding AWS permissions. Following is a sample policy describing those permissions:

```
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


## EBS volume template

An EBS volume template defines the EBS volume properties that Portworx will use as a reference. There are 2 ways you can provide this template to Portworx.

**1. Using a template specification**

For PX 1.3 and higher, you can specify a template spec which will be used by Portworx to create new EBS volumes.

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
* __kms__:  This is the Customer Master Key to encrypt the EBS volume.

See [EBS details](https://aws.amazon.com/ebs/details/) for more details on above parameters.

Examples

```
"type=gp2,size=200"
```
```
"type=gp2,size=100","type=io1,size=200,iops=1000"
```
```
"type=gp2,size=100,enc=true,kms=AKXXXXXXXX123","type=io1,size=200,iops=1000,enc=true,kms=AKXXXXXXXXX123"
```

**2. Using existing EBS volumes as templates**

You can also reference an existing EBS volume as a template.  Create at least one EBS volume using the AWS console or AWS CLI. This volume (or a set of volumes) will serve as a template EBS volume(s). On every node where PX is brought up as a storage node, a new EBS volume(s) identical to the template volume(s) will be created.

For example, create two volumes as:
```
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
```
Total Storage Nodes = (Num of Zones) * max_storage_nodes_per_zone.
```
While planning capacity for your auto scaling cluster make sure the minimum size of your cluster is equal to the total number of storage nodes in PX. This ensures that when you scale up your cluster, only storage less nodes will be added. While when you scale down the cluster, it will scale to the minimum size which ensures that all PX storage nodes are online and available.

{{<info>}}
**Note:**<br/> You can always ignore the **max_storage_nodes_per_zone** argument. When you scale up the cluster, the new nodes will also be storage nodes but while scaling down you will loose storage nodes causing PX to loose quorum.
{{</info>}}

Examples:
```
"-s", "type=gp2,size=200", "-max_storage_nodes_per_zone", "1"
```

For a cluster of 6 nodes spanning 3 zones (us-east-1a,us-east-1b,us-east-1c), in the above example PX will have 3 storage nodes (one in each zone) and 3 storage less nodes. PX will create a total 3 EBS volumes of size 200 each and attach one EBS volume to each storage node.

```
"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_storage_nodes_per_zone", "2"
```

For a cluster of 9 nodes spanning 2 zones (us-east-1a,us-east-1b), in the above example PX will have 4 storage nodes and 5 storage less nodes. PX will create a total of 8 EBS volumes (4 of size 200 and 4 of size 100). PX will attach a set of 2 EBS volumes (one of size 200 and one of size 100) to each of the 4 storage nodes..


#### PX Version 1.4 and older

You can specify the number of storage nodes in your cluster by setting the ```max_drive_set_count``` input argument.
Modify the input arguments to PX as shown in the below examples.

Examples:

```
"-s", "type=gp2,size=200", "-max_drive_set_count", "3"
```

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total 3 EBS volumes of size 200 each and attach one EBS volume to each storage node.

```
"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_drive_set_count", "3"
```

For a cluster of 5 nodes, in the above example PX will have 3 storage nodes and 2 storage less nodes. PX will create a total of 6 EBS volumes (3 of size 200 and 3 of size 100). PX will attach a set of 2 EBS volumes (one of size 200 and one of size 100) to each of the 3 storage nodes..


## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Generate the Portworx Spec

When generating the spec, following parameters are important:

1. __AWS environment variables__: In the environment variables option (_e_), specify _AWS\_ACCESS\_KEY\_ID_ and _AWS\_SECRET\_ACCESS\_KEY_ for the IAM user. Example: AWS_ACCESS_KEY_ID=\<id>,AWS_SECRET_ACCESS_KEY=\<key>. If you are using instance privileges you can ignore setting the environment variables.

2. __Volume template__: In the drives option (_s_), specify the EBS volume template that you created in [previous step](#ebs-volume-template). Portworx will dynamically create EBS volumes based on this template.

To generate the spec file, head on to the below URLs for the PX release you wish to use.

* [Default](https://install.portworx.com).
* [1.6 Stable](https://install.portworx.com/1.6/).
* [1.5 Stable](https://install.portworx.com/1.5/).
* [1.4 Stable](https://install.portworx.com/1.4/).

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/portworx-install-with-kubernetes/px-k8s-spec-curl).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

##### Using Kubernetes Secrets to Provision Certificates
Instead of manually copying the certificates on all the nodes, it is recommended to use [Kubernetes Secrets to provide etcd certificates to Portworx](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/etcd-certs-using-secrets). This way, the certificates will be automatically available to new nodes joining the cluster.

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet.

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.

### Apply the spec

Once you have generated the spec file, deploy Portworx.
```bash
kubectl apply -f px-spec.yaml
```

Monitor the portworx pods

```bash
kubectl get pods -o wide -n kube-system -l name=portworx
```

Monitor Portworx cluster status

```bash
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

If you are still experiencing issues, please refer to [Troubleshooting PX on Kubernetes](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/troubleshooting/troubleshoot-and-get-support) and [General FAQs](https://docs.portworx.com/knowledgebase/faqs.html).

### Corelating EBS volumes with Portworx nodes

Portworx when running in ASG mode provides a set of CLI commands to display the information about all EBS volumes
and their attachment information.

{{<info>}}
**Note:** Following commands are only available for PX version > 1.3
{{</info>}}

#### Listing all Cloud Drives

Run the following command to display all the cloud drives being used by Portworx.

```

{{ include.list }}

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

```

{{ include.inspect }}

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

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/portworx-install-with-kubernetes/application-install-with-kubernetes).
