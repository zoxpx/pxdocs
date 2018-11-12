---
title: Lighthouse Create Credentials
keywords: lighthouse
description: Create Credentials lighthouse.
weight: 2
linkTitle: Create Cloud Credentials
---

### Click on Manage Credentials

In the snapshots tab , click on the cloud icon on the right side pane.

![Lighthouse snapshot tab](/img/lighthouse-new-manage-credentials-1.png)

### Create New Cloud Credentials

Click `New` button on the Manage Credentials page. Three cloud providers are supported [Azure, GCP, Amazon S3].
Newly created credentials will be validated before creation.

`Note` You can create multiple credentials with the same set of details, each credential will generate a unique UUID.

![Lighthouse new credentials](/img/lighthouse-new-create-new-credentials-1.png)


### Azure Credentials

Provide the `Account Name` and `Account Key` to create credentals.

![Lighthouse group snapshot](/img/lighthouse-new-azure-credentials.png)

### S3 Credentials

Provide the `Access Key` ,  `Secret Key` , `Region` and `Endpoint`to create S3 credentials.

`Note` You can only create credentials using only one Region per cluster.
`Endpoint` value is of type `s3.<region-name>.amazonaws.com`.

![Lighthouse group snapshot](/img/lighthouse-new-s3-credentials.png)

### Google Credentials

Provide the `Project ID ` and `JSON Key file ` to create credentals.

![Lighthouse group snapshot](/img/lighthouse-new-google-credentials.png)
