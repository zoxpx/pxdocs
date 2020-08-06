---
title: Deploy Portworx using the Operator
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Find out how to deploy Portworx using the Operator
weight: 2
aliases:
  - /portworx-install-with-kubernetes/on-premise/openshift/operator/2-deploy-px/
---

The {{< pxEnterprise >}} Operator takes a custom Kubernetes resource called `StorageCluster` as input. The `StorageCluster` is a representation of your Portworx cluster configuration. Once the `StorageCluster` object is created, the Operator will deploy a Portworx cluster corresponding to the specification in the `StorageCluster` object. The Operator will watch for changes on the `StorageCluster` and update your cluster according to the latest specifications.

For more information about the `StorageCluster` object and how the Operator manages changes, refer to the [StorageCluster](/reference/crd/storage-cluster) article.

## Grant the required cloud permissions

{{<info>}}
**NOTE:** If you're installing Portworx on OpenShift on-premises, you may skip this section and go straight to the [install](#install-portworx-using-the-openshift-console) section.
{{</info>}}

If you're installing Portworx on OpenShift on a cloud environment, Portworx requires different user and service permissions from OpenShift. Grant the appropriate permissions for your cloud environment:

### OpenShift on AWS

{{% content "shared/portworx-install-with-kubernetes-cloud-aws-1-prepare.md" %}}

### OpenShift on GCP

{{% content "shared/portworx-install-with-kubernetes-cloud-gcp-service-account.md" %}}

### OpenShift on Azure

{{% content "shared/azure-cloud-user-requirements.md" %}}

## Open ports for worker nodes

Ensure ports 17001-17020 on worker nodes are reachable from master and other worker nodes.

## Create secret for Portworx Essentials

If running a **{{< pxEssentials >}}** cluster, then create the following secret with
your [Essential Entitlement ID](https://central.portworx.com/profile)

```text
kubectl -n kube-system create secret generic px-essential \
  --from-literal=px-essen-user-id=YOUR_ESSENTIAL_ENTITLEMENT_ID \
  --from-literal=px-osb-endpoint='https://pxessentials.portworx.com/osb/billing/v1/register'
```

## Install Portworx using the OpenShift console

To install Portworx with OpenShift, you will first generate `StorageCluster` spec that you will deploy in your cluster.

1. Generate the `StorageCluster` spec with the {{<iframe url="https://openshift4.install.portworx.com" text="Portworx spec generator tool.">}}

2. Within the Portworx Operator page, select **Create Instance** to create a `StorageCluster` object.

      ![Create Storage Cluster](/img/OpenshiftCreateInstance.png)

3. The spec displayed here represents a very basic default spec. Copy the spec you created with the spec generator and paste it over the default spec in the YAML editor on the OpenShift Console. Select **Create** to deploy Portworx.

      ![Storage Cluster Spec](/img/OpenshiftCreateStorageCluster.png)

4. Verify that Portworx has deployed successfully by navigating to the **Storage Cluster** tab of the **Installed Operators** page. Once Portworx has fully deployed, the status will show as **Online**.

      ![Storage Cluster Online](/img/OpenshiftStatusOnline.png)

## Install Portworx using the command line

If you're not using the OpenShift console, you can create the StorageCluster object using the `oc` command:

{{% content "shared/portworx-install-with-kubernetes-on-premise-openshift-apply-the-spec-oc.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}
