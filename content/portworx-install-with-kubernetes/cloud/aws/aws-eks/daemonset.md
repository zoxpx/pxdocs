---
title: Install Portworx on AWS EKS using the DaemonSet
linkTitle: Install using the DaemonSet
keywords: Install, on cloud, EKS, Elastic Kubernetes Service, AWS, Amazon Web Services, Kubernetes, k8s
description: Install Portworx on an AWS EKS (Elastic Kubernetes Service) cluster.
weight: 3
noicon: true
---

This topic explains how to install Portworx with EKS (Elastic Kubernetes Service). Follow the steps in this topic in order.

## Prepare

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
