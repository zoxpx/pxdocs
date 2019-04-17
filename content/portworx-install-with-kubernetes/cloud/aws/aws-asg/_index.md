---
title: Auto-Scaling Groups (ASG)
weight: 1
keywords: portworx, AWS, CloudFormation, ASG, Auto Scaling, Kubernetes
description: Install Portworx on an AWS cluster which uses autoscaling groups (ASG).
noicon: true
series: px-k8s
---

This topic explains how to install Portworx with Kubernetes on AWS (Auto-Scaling Groups). Follow the steps in this topic in order.

For more information on using Auto-Scaling groups, go [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html).

## Prepare

{{% content "portworx-install-with-kubernetes/cloud/aws/shared/1-prepare.md" %}}

## Install

{{<info>}}
If you are not using instance privileges, you must also specify AWS environment variables in the DaemonSet spec file. The environment variables to specify \(for the KOPS IAM user\) are:

`AWS_ACCESS_KEY_ID=<id>,AWS_SECRET_ACCESS_KEY=<key>`

If generating the DaemonSet spec via the GUI wizard, specify the AWS environment variables in the **List of environment variables** field. If generating the DaemonSet spec via the command line, specify the AWS environment variables using the `e` parameter.
{{</info>}}

{{% content "portworx-install-with-kubernetes/shared/1-generate-the-spec-footer.md" %}}

{{% content "portworx-install-with-kubernetes/shared/4-apply-the-spec.md" %}}

{{% content "portworx-install-with-kubernetes/shared/post-install.md" %}}
