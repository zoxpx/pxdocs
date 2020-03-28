---
title: Kubernetes Operations (KOPS)
keywords: Install, on cloud, KOPS, Kubernetes Operations, AWS, Amazon Web Services, Kubernetes, k8s
description: Install Portworx on a Kubernetes KOPS cluster running on AWS.
weight: 3
noicon: true
series: px-k8s
---

This topic explains how to install Portworx with Kubernetes on AWS (KOPS). Follow the steps in this topic in order.

## Prepare

This article assumes that you are familiar with KOPS. For information about using KOPS, see one of the following pages:

* [Manage Kubernetes Clusters on AWS Using KOPS](https://aws.amazon.com/blogs/compute/kubernetes-clusters-aws-kops/)

* [Getting Started with KOPS on AWS](https://github.com/kubernetes/kops/blob/master/docs/getting_started/aws.md)

#### Granting Portworx the needed AWS permissions

{{% content "shared/portworx-install-with-kubernetes-cloud-aws-1-prepare.md" %}}

## Install

{{<info>}}
If you are not using instance privileges, you must also specify AWS environment variables in the DaemonSet spec file. The environment variables to specify \(for the KOPS IAM user\) are:

`AWS_ACCESS_KEY_ID=<id>,AWS_SECRET_ACCESS_KEY=<key>`

If generating the DaemonSet spec via the GUI wizard, specify the AWS environment variables in the **List of environment variables** field. If generating the DaemonSet spec via the command line, specify the AWS environment variables using the `e` parameter.
{{</info>}}

{{% content "shared/portworx-install-with-kubernetes-shared-1-generate-the-spec-footer.md" %}}

{{% content "shared/portworx-install-with-kubernetes-4-apply-the-spec.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}
