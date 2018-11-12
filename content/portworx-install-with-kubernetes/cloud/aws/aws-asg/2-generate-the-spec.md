---
title: 2. Generate the Spec
keywords: portworx, AWS, CloudFormation, ASG, Auto Scaling, Kubernetes
description: Learn how to generate your spec.
weight: 2
---

{{<info>}}
If you are not using instance privileges, you must also specify AWS environment variables in the DaemonSet spec file. The environment variables to specify \(for the KOPS IAM user\) are:

`AWS_ACCESS_KEY_ID=<id>,AWS_SECRET_ACCESS_KEY=<key>`

If generating the DaemonSet spec via the GUI wizard, specify the AWS environment variables in the **List of environment variables** field. If generating the DaemonSet spec via the command line, specify the AWS environment variables using the `e` parameter.
{{</info>}}

{{% content "portworx-install-with-kubernetes/shared/1-generate-the-spec-footer.md" %}}
