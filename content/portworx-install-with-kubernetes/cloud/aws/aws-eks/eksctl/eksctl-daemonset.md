---
title: Install Portworx on AWS EKS using eksctl and the Daemonset
linkTitle: Install using the Daemonset
keywords: Install, on cloud, EKS, Elastic Kubernetes Service, AWS, Amazon Web Services, Kubernetes, k8s, eksctl
description: Install Portworx on an AWS EKS (Elastic Kubernetes Service) cluster using eksctl.
weight: 3
noicon: true
---

This article provides instructions for installing Portworx on Elastic Kubernetes Service (EKS) using the Weaveworks `eksctl` command-line utility.

{{<info>}}
**NOTE:** You can follow these procedures to deploy Portworx on AWS Outposts.
{{</info>}}

## Prerequisites

Before you can install Portworx on EKS using `pxctl`, you must meet the following prerequisites:

* You must have `eksctl` [downloaded](https://github.com/weaveworks/eksctl/releases) and installed on your local computer

## Grant Portworx the needed AWS permissions

{{% content "shared/portworx-install-with-kubernetes-cloud-aws-1-prepare.md" %}}

### Create a ClusterConfig

The `ClusterConfig` dictates what resources `eksctl` requests from EKS for the purposes of running Portworx. Portworx requires a number of default resources and configurations in order to function, but other areas of your configuration will vary based on your needs.

1. Create a `ClusterConfig` configuration YAML file, specifying your own configuration options for the following:

    * **metadata:**
        * **name:** withe cluster name you desire
        * **region:** with the region you want your eks service to operate from
        * **version:** with a [supported](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) EKS version
    * **managedNodeGroups:**
        * **storage-nodes.instance:** with the instance type appropriate for your workloads
        * **storage-nodes.minSize:** and **storage-nodes.maxSize:** with the number of worker nodes. Both values must be the same, and a minimum of 3.
        * **storage-nodes.ssh.publicKeyPath:** if no path is specified, the default will be `id_rsa`
        * **storage-nodes.iam.attachPolicyARNs:** with the ARN of the IAM policy you created for Portworx in the **Grant Portworx the needed AWS permissions** step
        * **storageless-nodes.instanceType:** with the instance type approprirate for your storageless node workloads
        * **storageless-nodes.minSize:** with the minimum number of storageless nodes that can be active on your cluster at any given time
        * **storageless-nodes.maxSize:** with the maximum number of storageless allowed on your cluster
        * **storageless-nodes.desiredCapacity:** with the ideal number of storageless nodes preferred on your cluster
        * **storageless-nodes.iam.attachPolicyARNs:** with the ARN of the IAM policy you created for Portworx in the **Grant Portworx the needed AWS permissions** step
    * **availabilityZones:** with the availabilty zones applicable to your region

    ```text
    apiVersion: eksctl.io/v1alpha5
    kind: ClusterConfig
    metadata:
      name: px-eksctl
      region: us-east-1
      version: "1.14"
    managedNodeGroups:
      - name: storage-nodes
        instanceType: m4.xlarge
        minSize: 3
        maxSize: 3
        volumeSize: 20
        #ami: auto
        amiFamily: AmazonLinux2
        labels: {role: worker, "portworx.io/node-type": "storage"}
        tags:
          nodegroup-role: worker
        ssh:  
          allow: true
          publicKeyPath: ~/.ssh/aws-vm.pub
        iam:
          attachPolicyARNs:
            - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
            - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
            - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
            - arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess
            - <arn-of-your-portworx-aws-iam-policy>
          withAddonPolicies:
            imageBuilder: true
            autoScaler: true
            ebs: true
            fsx: true
            efs: true
            albIngress: true
            cloudWatch: true
      - name: storageless-nodes
        instanceType: m4.xlarge
        minSize: 3
        maxSize: 6
        desiredCapacity: 4
        volumeSize: 20
        amiFamily: AmazonLinux2
        labels: {role: worker}
        tags:
          nodegroup-role: worker-storageless
        ssh:
          allow: true
          publicKeyPath: ~/.ssh/aws-vm.pub
        iam:
          attachPolicyARNs:
            - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
            - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
            - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
            - arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess
            - <arn-of-your-portworx-aws-iam-policy>
          withAddonPolicies:
            imageBuilder: true
            autoScaler: true
            ebs: true
            fsx: true
            efs: true
            albIngress: true
            cloudWatch: true
    availabilityZones: [ 'us-east-1a', 'us-east-1b', 'us-east-1c' ]
    ```

2. Enter the following `eksctl create cluster` command, specifying the name of the `clusterConfig` file you created in the step above:

    ```text
    eksctl create cluster -f <my-clusterConfig>.yml
    ```

## Generate the spec

To install Portworx with Kubernetes, you must first generate Kubernetes manifests that you will deploy in your cluster:

1. Navigate to <a href="https://central.portworx.com" target="tab">PX-Central</a> and log in or create an account
3. Select **Install and Run** to open the Spec Generator

    ![Screenshot showing install and run](/img/pxcentral-install.png)

4. Select **New Spec**

    ![Screenshot showing new spec button](/img/pxcentral-spec.png)

5. Generate a spec with the following selections:

    * On the **Storage** tab, specify **AWS** and configure your storage devices based on your needs
    * On the **Customize** tab, select the **Amazon Elastic Container Service for Kubernetes (EKS)** option
    * Under the **Environment Variables** dropdown on the **Customize** tab, create an environment variable named `ENABLE_ASG_STORAGE_PARTITIONING` with a value of **true**

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}

## Further reading

* Refer to the [eksctl github](https://github.com/weaveworks/eksctl/tree/master/examples) for more examples of config files which can be used as input to eksctl
* For more information on what `eksctl` is, as well as how it works, refer to the [eksctl documentation](https://eksctl.io/)
