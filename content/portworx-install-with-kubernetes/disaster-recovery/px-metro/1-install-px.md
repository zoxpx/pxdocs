---
title: "1. Prepare your Portworx Cluster"
weight: 1
keywords: cloud, backup, restore, snapshot, DR, migration, px-motion
description: Find out how to install a single stretch Portworx cluster across multiple Kubernetes clusters.
---

The goal of this document is to setup a single Portworx cluster that spans across multiple Kubernetes clusters.

## Pre-requisites

* **Kubernetes Clusters**: You should have at least two Kubernetes clusters which are part of the same metropolitan area network with a maximum network latency of 10ms between them.
* **Version**: A single Portworx cluster of v2.1 or later release needs to be installed on both clusters. This also requires Stork v2.2+ on both the clusters.
* **Network Connectivity**: Ports between 9001 and 9020 should be open between the two Kubernetes clusters.
* **External Kvdb**: A kvdb like etcd or consul setup outside of the Kubernetes clusters.
* **Stork helper**: `storkctl` is a command-line tool for interacting with a set of scheduler extensions.
* **License**: You will need a DR enabled Portworx License to use this feature.
{{% content "portworx-install-with-kubernetes/disaster-recovery/shared/stork-helper.md" %}}

## Installing Portworx
In this mode of operation, a single Portworx cluster will stretch across multiple Kubernetes clusters.

### New Installation

To install Portworx on each of the Kubernetes clusters, you will need to generate a separate Portworx Kubernetes manifest file for each of them using [Portworx Spec Generator](https://install.portworx.com/2.1)

While generating the spec file for each Kubernetes cluster, make sure you provide the same values for the following arguments:

* **Cluster ID** (Portworx install argument: `-c`)
* **Kvdb Endpoints**  (Portworx install argument: `-k`)

Specifying the same **ClusterID** and **Kvdb Endpoints** in each Kubernetes manifest file ensures that a single Portworx cluster will stretch across multiple Kubernetes clusters.

### Existing Installation
If you already have an existing Kubernetes cluster, you can add another Kubernetes cluster and let its nodes join the same Portworx cluster.

To achieve this, make sure you provide the following arguments same as your existing cluster:

* **Cluster ID** (Portworx install argument: `-c`)
* **Kvdb Endpoints**  (Portworx install argument: `-k`)

Specifying the same **ClusterID** and **Kvdb Endpoints** as your existing cluster ensures that a single Portworx cluster will stretch across multiple Kubernetes clusters.

If your Kubernetes clusters have exactly the same configuration, you can use the URL specified by the `portworx.com/install-source` annotation on the existing Portworx DaemonSet to fetch the spec for your new cluster:

```text
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: portworx
  namespace: kube-system
  annotations:
    portworx.com/install-source: "https://install.portworx.com/2.1?mc=false&kbver=1.11.9&k=etcd%3Ahttp%3A%2F%2F100.26.199.167%3A2379&s=%22type%3Dgp2%2Csize%3D150%22&c=px-cluster-2f6d696f-a728-46ec-bfbc-dcece1765579&stork=true&lh=true&st=k8s"
```

Otherwise you can always generate a new spec using [Portworx Spec Generator](https://install.portworx.com/2.1)

{{<info>}}
**Note**: If your existing Kubernetes cluster uses internal kvdb, then you cannot stretch your Portworx clusters across multiple Kubernetes cluster. This mode of deployments requires an external kvdb running outside your Kubernetes cluster
{{</info>}}

### Specifying cluster domain
A cluster domain identifies a subset of nodes from the stretch Portworx cluster that are a part of the same failure domain. In this case, your Kubernetes clusters are separated across a metropolitan area network and we wish to achieve DR across them. So each Kubernetes cluster and its nodes are one cluster domain. This cluster domain
information needs to be explicitly specified to Portworx through the `-cluster_domain` install argument.

Once you have generated the Kubernetes manifest file, add the `cluster_domain` argument in the args section of the daemonset. You can also edit a running Portworx daemon set and add this new field.

```text
      containers:
        - name: portworx
          image: portworx/oci-monitor:2.1
          imagePullPolicy: Always
          args:
            ["-k", "etcd:http://100.26.199.167:2379,etcd:http://100.26.199.168:2379,etcd:http://100.26.199.169:2379", "-c", "px-dr-cluster", "-cluster_domain", "us-east-1a", "-a", "-secret_type", "k8s",
             "-x", "kubernetes"]

```

The value for `cluster_domain` needs to be different for each Kubernetes cluster.

  * You can name your cluster domains with arbitrary names like **datacenter1** and **datacenter2** identifying in which Datacenter your Kubernetes clusters are running.
  * You can name them based on your cloud provider's zone names such as **us-east-1a**, **us-east-1b**.

{{<info>}}
Only deploy Portworx in this mode when your Kubernetes clusters are separated by a metropolitan area network with a maximum latency of 10ms. It is not recommended to run in this mode if your Kubernetes clusters are across regions like AWS regions `us-east` and `us-west`.
{{</info>}}

A cluster domain and, in turn, the set of nodes which are a part of that domain are associated with either of the following states:

* **Active State**: Nodes from an active cluster domain participate in the cluster activities. Applications **can** be scheduled on the nodes which are a part of an active cluster domain.
* **Inactive State**: Nodes from an inactive cluster domain do not participate in the cluster activities. Applications **cannot** be scheduled on such nodes.

Once the Kubernetes manifest is applied on both the clusters, Portworx will form the stretch cluster. You can run the following commands to ensure Portworx is successfully installed in a stretch fashion.

**Kubernetes Cluster 1 running in `us-east-1a`**

```text
kubectl get nodes -o wide
```

```output
ip-172-20-33-100.ec2.internal   Ready     node      3h        v1.11.9   18.205.7.13      Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
ip-172-20-36-212.ec2.internal   Ready     node      3h        v1.11.9   18.213.118.236   Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
ip-172-20-48-24.ec2.internal    Ready     master    3h        v1.11.9   18.215.34.139    Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
ip-172-20-59-248.ec2.internal   Ready     node      3h        v1.11.9   34.200.228.223   Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
```

**Kubernetes Cluster 2 running in `us-east-1b`**

```text
kubectl get nodes -o wide
```

```output
ip-172-40-34-140.ec2.internal   Ready     node      3h        v1.11.9   34.204.2.95     Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
ip-172-40-35-23.ec2.internal    Ready     master    3h        v1.11.9   34.238.44.60    Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
ip-172-40-40-230.ec2.internal   Ready     node      3h        v1.11.9   52.90.187.179   Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
ip-172-40-50-47.ec2.internal    Ready     node      3h        v1.11.9   3.84.27.79      Debian GNU/Linux 9 (stretch)   4.9.0-7-amd64    docker://17.3.2
```

A single Portworx cluster running across both the Kubernetes clusters

```text
kubectl exec -it portworx-d6rk7 -n kube-system /opt/pwx/bin/pxctl status
```

```output
Status: PX is operational
License: Trial (expires in 31 days)
Node ID: 04de0858-4081-47c3-a2ab-f0835b788738
        IP: 172.40.40.230
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE            REGION
        0       LOW             raid0           150 GiB 9.0 GiB Online  us-east-1b      us-east-1
        Local Storage Devices: 1 device
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/xvdf       STORAGE_MEDIUM_SSD      150 GiB         09 Apr 19 22:57 UTC
        total                   -                       150 GiB
        Cache Devices:
        No cache devices
Cluster Summary
        Cluster ID: px-dr-cluster
        Cluster UUID: 27558ed9-7ddd-4424-92d4-5dfe2af572e0
        Scheduler: kubernetes
        Nodes: 6 node(s) with storage (6 online)
        IP              ID                                      SchedulerNodeName               StorageNode     Used    Capacity        Status  StorageStatus   Version         Kernel          OS
        172.20.33.100   c665fe35-57d9-4302-b6f7-a978f17cd020    ip-172-20-33-100.ec2.internal   Yes             0 B     150 GiB         Online  Up              2.1.0.0-cb23fd1 4.9.0-7-amd64   Debian GNU/Linux 9 (stretch)
        172.40.50.47    bbb2f11d-c6ad-46e7-a52f-530f313869f3    ip-172-40-50-47.ec2.internal    Yes             0 B     150 GiB         Online  Up              2.1.0.0-cb23fd1 4.9.0-7-amd64   Debian GNU/Linux 9 (stretch)
        172.40.34.140   a888a08e-0596-43a5-8d02-6faf19e8724c    ip-172-40-34-140.ec2.internal   Yes             0 B     150 GiB         Online  Up              2.1.0.0-cb23fd1 4.9.0-7-amd64   Debian GNU/Linux 9 (stretch)
        172.20.36.212   7a83c652-ffaf-452f-978c-82b0da1d2580    ip-172-20-36-212.ec2.internal   Yes             0 B     150 GiB         Online  Up              2.1.0.0-cb23fd1 4.9.0-7-amd64   Debian GNU/Linux 9 (stretch)
        172.20.59.248   11e0656a-45a5-4a5b-b4e6-51e130959644    ip-172-20-59-248.ec2.internal   Yes             0 B     150 GiB         Online  Up              2.1.0.0-cb23fd1 4.9.0-7-amd64   Debian GNU/Linux 9 (stretch)
        172.40.40.230   04de0858-4081-47c3-a2ab-f0835b788738    ip-172-40-40-230.ec2.internal   Yes             0 B     150 GiB         Online  Up (This node)  2.1.0.0-cb23fd1 4.9.0-7-amd64   Debian GNU/Linux 9 (stretch)
Global Storage Pool
        Total Used      :  0 B
        Total Capacity  :  900 GiB
```

### Cluster Domains Status

When Stork is deployed along with Portworx in this mode it automatically creates a ClusterDomainStatus object. This can be used to find out the current state of all the cluster domains.
Each Kubernetes cluster where Stork is deployed will have this object automatically created. You can use the following commands to get the current status:

```text
storkctl get clusterdomainsstatus
```

```output
NAME            ACTIVE                    INACTIVE   CREATED
px-dr-cluster   [us-east-1a us-east-1b]   []         09 Apr 19 17:12 PDT
```

You can also use `kubectl` to inspect the ClusterDomainsStatus object

```text
kubectl describe clusterdomainsstatus -n kube-system
```

```output
Name:         px-dr-cluster
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  stork.libopenstorage.org/v1alpha1
Kind:         ClusterDomainsStatus
Metadata:
  Creation Timestamp:  2019-04-10T00:12:53Z
  Generation:          1
  Resource Version:    62704
  Self Link:           /apis/stork.libopenstorage.org/v1alpha1/clusterdomainsstatuses/px-dr-cluster
  UID:                 62865df5-5b25-11e9-a3ff-12e335b4e36e
Status:
  Active:
    us-east-1b
    us-east-1a
  Inactive:  <nil>

```

Once your Portworx stretch cluster is installed, you can proceed to next step.
