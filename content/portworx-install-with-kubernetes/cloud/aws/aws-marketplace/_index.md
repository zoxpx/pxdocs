---
title: AWS Marketplace
keywords: Install, on cloud, EKS, Marketplace, Elastic Kubernetes Service, AWS, Amazon Web Services, Kubernetes, k8s
description: Install Portworx on an AWS EKS (Elastic Kubernetes Service) cluster via the Amazon Marketplace.
weight: 2
noicon: true
series: px-k8s
---

This topic provides instructions for installing Portworx via the Amazon Marketplace on EKS (Elastic Kubernetes Service). Follow the steps in this topic in order.

## Prepare your EKS Cluster

Before you can install Portworx, you must configure AWS permissions:

### Grant Portworx the needed AWS permissions

{{% content "shared/portworx-install-with-kubernetes-cloud-aws-1-prepare.md" %}}

### Configure IAM permissions
You can configure the IAM permissions in multiple ways. Follow the steps most appropriate for you:

#### Configure with eksctl
If you created your cluster with `eksctl` this would be your best option. If you did not check out
the section about configuring your cluster with `AWS CLI` or `AWS Console`

1. Before you can create an IAMServiceAccount for Portworx, you must enable the IAM OIDC Provider for your EKS cluster.
Make sure to replace `<clustername>` with your EKS cluster and change the `region` if you are not running in us-east-1

    ```text
    eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=<clustername> --approve
    ```

2. Now you can create the IAMServiceAccount with the appropriate permissions. (you need these permissions to send metering data to AWS)
Make sure to change the namespace if you are not deploying in `kube-system` and make sure to replace `<clustername>` with your EKS cluster

    ```text
    eksctl create iamserviceaccount --name portworx-aws --namespace kube-system --cluster <clustername> --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage --approve --override-existing-serviceaccounts
    ```

This will create an `IAMServiceAccount` on the [AWS Console] (https://console.aws.amazon.com/iam/home?#/roles) and
will create a `ServiceAcccount` in the requested namespace, which we will pass to our helmchart in the next section

#### Configure with AWS CLI or AWS Console
You can configure IAM permissions through the `AWS CLI` or `AWS Console`.
For instructions  on configuring these permissions, refer to the Amazon documentation:

* for AWS CLI go here: [AWS CLI] (https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html#aws-cli)
* for AWS Console go here: [AWS Console] (https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html#aws-management-console)

Use the correct `namespace` and `serviceaccount` you defined in the steps above.

## Install

Once you've prepared your EKS cluster, you can install Portworx. 

{{<info>}}
**NOTE:** If you are not using instance privileges, you must also specify AWS environment variables in the Helm install parameters. Specify the following environment variables:

`--set env="AWS_ACCESS_KEY_ID=<id>\,AWS_SECRET_ACCESS_KEY=<key>"`
{{</info>}}

### Add the Helm repository
Add the Portworx AWS Helm repository by running the following `helm` command:
```text
helm repo add portworx https://raw.githubusercontent.com/portworx/aws-helm/master/stable
```

### Install the helm chart from the repository
To install the chart with the release name `my-release` run the following commands substituting relevant values for your setup. Refer to the [Helm chart configuration reference](#helm-chart-configuration-reference) for information about the configurable parameters:

```text
helm install my-release portworx/portworx --set storage.drives="type=gp2\,size=1000" --set serviceAccount="portworx-aws"
```

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

{{<info>}}
**NOTE**:

* `clusterName` should be a unique name identifying your Portworx cluster. The default value is `mycluster`, but it is suggested to update it with your naming scheme.
* `storage.drives` has been set to 1 TB, if you wish to have smaller storage drives please change that setting.
{{</info>}}

## Upgrade or reconfigure Portworx
When Portworx releases new versions, you can upgrade it through Helm. You can also reconfigure Portworx through Helm by peforming upgrade operations, even if there is no new version to upgrade to. Perform the following steps to upgrade or reconfigure Portworx:

1. Upgrade the Helm repository to make sure you have the latest version of the Helm chart by running the following `helm` command:

    ```text
    helm repo update
    ```

2. Upgrade or reconfigure Portworx by running the `upgrade` command and
specifying the same options you used when you installed Portworx, or new options if you want to reconfigure Portworx. For Example:

    ```text
    helm upgrade my-release portworx/portworx --set storage.drives="type=gp2\,size=1000" --set serviceAccount="portworx-aws"
    ```

## Uninstall Portworx
Perform the following steps to uninstall Portworx:

1. Edit the storage cluster.
```text
kubectl -n <namespace> edit storagecluster <yourclustername>
```

2. Add the following lines to your YAML `spec` section:

    ```text
    deleteStrategy:
      type: UninstallAndWipe
    ```

3. Save the spec and exit out.
4. Delete the storagecluster

    ```text
    kubectl -n <namespace> delete storagecluster <yourclustername>
    ```

5. Once all the portworx related pods are gone,
uninstall/delete the `my-release` deployment:

    ```text
    helm delete my-release
    ```
    This command removes all the Kubernetes components associated with the chart and deletes the release.
    
## Helm chart configuration reference
The following tables lists the configurable parameters of the Portworx chart and their default values.

| Parameter | Description |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `awsProduct` | Portworx Product Name, PX-ENTERPRISE or PX-ENTERPRISE-DR (Defaults to PX-ENTERPRISE) |
| `clusterName` | Portworx Cluster Name |
| `namespace` | Namespace in which to deploy portworx (Defaults to kube-system) |
| `storage.usefileSystemDrive` | Should Portworx use an unmounted drive even with a filesystem ? |
| `storage.usedrivesAndPartitions` | Should Portworx use the drives as well as partitions on the disk ? |
| `storage.drives` | Semi-colon seperated list of drives to be used for storage (example: "/dev/sda;/dev/sdb"), to auto generate amazon disks use a list of drive specs (example: "type=gp2\,size=150";type=io1\,size=100\,iops=2000"). Make sure you escape the commas |
| `storage.journalDevice` | Journal device for Portworx metadata |
| `storage.maxStorageNodesPerZone` | Indicates the maximum number of storage nodes per zone. If this number is reached, and a new node is added to the zone, Portworx doesn’t provision drives for the new node. Instead, Portworx starts the node as a compute-only node. |
| `network.dataInterface` | Name of the interface <ethX> |
| `network.managementInterface` | Name of the interface <ethX> |
| `secretType` | Secrets store to be used can be aws-kms/k8s/none defaults to: k8s |
| `envVars` | semi-colon-separated list of environment variables that will be exported to portworx. (example: MYENV1=val1;MYENV2=val2) |
| `serviceAcccount` | Name of the created service account with required IAM permissions |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.
