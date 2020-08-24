---
hidden: true
---

## Generate and Apply a ClusterPair Spec

In Kubernetes, you must define a trust object called **ClusterPair**. Portworx requires this object to communicate with the destination cluster. The ClusterPair object pairs the Portworx storage driver with the Kubernetes scheduler, allowing the volumes and resources to be migrated between clusters.

The ClusterPair is generated and used in the following way:

   * The **ClusterPair** spec is generated on the **destination** cluster.
   * The generated spec is then applied on the **source** cluster

Perform the following steps to create a cluster pair:

{{<info>}}
**NOTE:** You must run the `pxctl` commands in this document either on your Portworx nodes directly, or from inside the Portworx containers on your master Kubernetes node. 
{{</info>}}

### Create object store credentials for cloud clusters

If you are running Kubernetes on-premises, you may skip this section. If your Kubernetes clusters are on the cloud, you must create object credentials on both the destination and source clusters before you can create a cluster pair.

The options you use to create your object store credentials differ based on which object store you use:

#### Create Amazon s3 credentials

1. Find the UUID of your destination cluster

2. Enter the `pxctl credentials create` command, specifying the following:

    * The `--provider` flag with the name of the cloud provider (`s3`).
    * The `--s3-access-key` flag with your secret access key
    * The `--s3-secret-key` flag with your access key ID
    * The `--s3-region` flag with the name of the S3 region (`us-east-1`)
    * The `--s3-endpoint` flag with the  name of the endpoint (`s3.amazonaws.com`)
    * The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
    * `clusterPair_` with the UUID of your destination cluster. Enter the following command into your cluster to find its UUID:
      ```text
      PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
      kubectl exec $PX_POD -n kube-system --  /opt/pwx/bin/pxctl status | grep UUID | awk '{print $3}'
      ```

    ```text
    /opt/pwx/bin/pxctl credentials create \
    --provider s3 \
    --s3-access-key <aws_access_key> \
    --s3-secret-key <aws_secret_key> \
    --s3-region us-east-1  \
    --s3-endpoint s3.amazonaws.com \
    --s3-storage-class STANDARD \
    clusterPair_<UUID_of_destination_cluster>
    ```

#### Create Microsoft Azure credentials

1. Find the UUID of your destination cluster

2. Enter the `pxctl credentials create` command, specifying the following:

    * `--provider` as `azure`
    * `--azure-account-name` with the name of your Azure account
    * `--azure-account-key` with your Azure account key
    * `clusterPair_` with the UUID of your destination cluster appended. Enter the following command into your cluster to find its UUID:
      ```text
      PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
      kubectl exec $PX_POD -n kube-system --  /opt/pwx/bin/pxctl status | grep UUID | awk '{print $3}'
      ```

    ```text
    /opt/pwx/bin/pxctl credentials create \
    --provider azure \
    --azure-account-name <your_azure_account_name> \
    --azure-account-key <your_azure_account_key> \
    clusterPair_<UUID_of_destination_cluster>
    ```

#### Create Google Cloud Platform credentials

1. Find the UUID of your destination cluster

2. Enter the `pxctl credentials create` command, specifying the following:

    * `--provider` as `google`
    * `--google-project-id` with the string of your Google project ID
    * `--google-json-key-file` with the filename of your GCP JSON key file
    * `clusterPair_` with the UUID of your destination cluster appended. Enter the following command into your cluster to find its UUID:
      ```text
      PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
      kubectl exec $PX_POD -n kube-system --  /opt/pwx/bin/pxctl status | grep UUID | awk '{print $3}'
      ```

    ```text
    /opt/pwx/bin/pxctl credentials create \
    --provider google \
    --google-project-id <your_google_project_ID> \
    --google-json-key-file <your_GCP_JSON_key_file> \
    clusterPair_<UUID_of_destination_cluster>
    ```

### Generate a ClusterPair on the destination cluster

To generate the **ClusterPair** spec, run the following command on the **destination** cluster:

```text
storkctl generate clusterpair -n migrationnamespace remotecluster
```
Here, the name (remotecluster) is the Kubernetes object that will be created on the **source** cluster representing the pair relationship.

During the actual migration, you will reference this name to identify the destination of your migration.
