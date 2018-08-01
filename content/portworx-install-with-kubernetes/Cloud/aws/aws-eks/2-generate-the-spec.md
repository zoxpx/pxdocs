---
title: 2. Generate the Spec
description: ""
weight: 2
---

{{<info>}}
If you are not using instance privileges, you must also specify AWS environment variables in the DaemonSet spec file. The environment variables to specify \(for the KOPS IAM user\) are:

`AWS_ACCESS_KEY_ID=<id>,AWS_SECRET_ACCESS_KEY=<key>`

If generating the DaemonSet spec via the GUI wizard, specify the AWS environment variables in the **List of environment variables** field. If generating the DaemonSet spec via the command line, specify the AWS environment variables using the `e` parameter.
{{</info>}}

{{<info>}}
You must specify the disk template \(that you previously generated\) in the DaemonSet spec file. If generating the spec via the GUI wizard, specify the disk template in the **List of drives** field. If generating the spec using the command line, specify the disk template using the `s` parameter.
{{</info>}}

{{% content "portworx-install-with-kubernetes/shared/1-generate-the-spec-footer.md" %}}
