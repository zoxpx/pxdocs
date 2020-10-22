---
title: Install Portworx on AWS EKS using the Operator
linkTitle: Install using the Operator
keywords: Install, on cloud, EKS, Elastic Kubernetes Service, AWS, Amazon Web Services, Kubernetes, k8s
description: Install Portworx on an AWS EKS (Elastic Kubernetes Service) cluster.
weight: 2
noicon: true
---

This topic explains how to install Portworx with EKS (Elastic Kubernetes Service). Follow the steps in this topic in order.

## Prepare

#### Granting Portworx the needed AWS permissions

{{% content "shared/portworx-install-with-kubernetes-cloud-aws-1-prepare.md" %}}

## Install

{{<info>}}
If you are not using instance privileges, you must also specify AWS environment variables in the StorageCluster spec file. The environment variables to specify \(for the KOPS IAM user\) are:

`AWS_ACCESS_KEY_ID=<id>,AWS_SECRET_ACCESS_KEY=<key>`

If generating the StorageCluster spec via the GUI wizard, specify the AWS environment variables in the **List of environment variables** field. If generating the StorageCluster spec via the command line, specify the AWS environment variables using the `e` parameter.
{{</info>}}

{{% content "shared/operator-install.md" %}}

{{% content "shared/portworx-install-with-kubernetes-shared-generate-the-spec-footer-operator.md" %}}

{{% content "shared/operator-apply-the-spec.md" %}}

{{% content "shared/operator-monitor.md" %}}

{{% content "shared/portworx-install-with-kubernetes-post-install.md" %}}
