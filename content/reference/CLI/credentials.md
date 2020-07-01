---
title: Managing cloud credentials using pxctl
keywords: pxctl, command-line tool, cli, reference, cloud credentials, manage credentials, create credentials, list credentials, validate credentials, delete credentials
description: Trying to create, list, validate or delete credentials for cloud providers? Follow this step-by-step tutorial from Portworx!
weight: 6
linkTitle: Cloud Credentials
---

## Prerequisites

This document provides instructions for managing your cloud credentials using `pxctl`.


The cloud provider credentials are stored in an external secret store. Before you use the commands from below, you should configure a secret provider of your choice with Portworx. For more information, head over to the [Key Management](/key-management) page.

## Overview

You can use the `pxctl credentials` command to create, list, validate, or delete your cloud credentials. Then, Portworx will use these credentials, for example, to back up your volumes to the cloud.

Enter the `pxctl credentials --help` command to display the list of subcommands:

```text
/opt/pwx/bin/pxctl credentials --help
```

```output
Manage credentials for cloud providers

Usage:
  pxctl credentials [flags]
  pxctl credentials [command]

Aliases:
  credentials, cred

Available Commands:
  create      Create a credential for cloud providers
  delete      Delete a credential for cloud
  list        List all credentials for cloud
  validate    Validate a credential for cloud

Flags:
  -h, --help   help for credentials

Global Flags:
      --ca string        path to root certificate for ssl usage
      --cert string      path to client certificate for ssl usage
      --color            output with color coding
      --config string    config file (default is $HOME/.pxctl.yaml)
      --context string   context name that overrides the current auth context
  -j, --json             output in json
      --key string       path to client key for ssl usage
      --raw              raw CLI output for instrumentation
      --ssl              ssl enabled for portworx

Use "pxctl credentials [command] --help" for more information about a command.
```

## List credentials

To list all configured credentials, use this command:

```text
pxctl credentials list
```

```output
S3 Credentials
UUID						REGION			ENDPOINT			ACCESS KEY			SSL ENABLED	ENCRYPTION
ffffffff-ffff-ffff-1111-ffffffffffff		us-east-1		s3.amazonaws.com		AAAAAAAAAAAAAAAAAAAA		false		false

Azure Credentials
UUID						ACCOUNT NAME		ENCRYPTION
ffffffff-ffff-ffff-ffff-ffffffffffff		portworxtest		false
```

##  Create and configure credentials

You can create and configure credentials in multiple ways depending on your cloud provider and how you want to manage them.

### Create credentials on AWS by specifying your keys

{{<info>}}
**NOTE:** The `--s3-storage-class` flag requires PX-Enterprise version 2.5.3 or higher
{{</info>}}

Enter the `pxctl credentials create` command, specifying:

* The `--provider` flag with the name of the cloud provider (`s3`).
* The `--s3-access-key` flag with your secret access key
* The `--s3-secret-key` flag with your access key ID
* The `--s3-region` flag with the name of the S3 region (`us-east-1`)
* The `--s3-endpoint` flag with the  name of the endpoint (`s3.amazonaws.com`)
* The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
* The name of your cloud credentials

```text
pxctl credentials create \
  --provider s3 \
  --s3-access-key <YOUR-SECRET-ACCESS-KEY>
  --s3-secret-key <YOUR-ACCESS-KEY-ID> \
  --s3-region us-east-1 \
  --s3-endpoint s3.amazonaws.com \
  --s3-storage-class STANDARD \
  <NAME>
```

```output
Credentials created successfully
```

{{<info>}}
**Note:** This command will create a bucket with the Portworx cluster ID to use for the backups.
{{</info>}}
<!-- 
### Create credentials on AWS by storing keys as environment variables

{{<info>}}
**NOTE:** This feature requires PX-Enterprise version 2.5.1 or higher
{{</info>}}

You can create and configure credentials for AWS by storing your secret access key and access key ID as environment variables. When you run the `pxctl credentials create`, Portworx uses the environment variables to create the credential:

1. Create the following environment variables, adding your own access key ID and secret access key, and provide them to the Portworx container through either daemon set parameters or the `runc install` command:

    ```text
    AWS_SECRET_ACCESS_KEY=xxx
    AWS_ACCESS_KEY_ID=yyy
    ```
2. Enter the `pxctl credentials create` command, specifying:

    * The `--provider` flag with the name of the cloud provider (`s3`).
    * The `--s3-region` flag with the name of the S3 region (`us-east-1`)
    * The `--s3-endpoint` flag with the name of the endpoint (`s3.amazonaws.com`)
    * The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
    * The `use-iam` flag
    * The name of your cloud credentials

    ```text
    ./pxctl credentials create \
    --provider s3 \
    --s3-region us-east-1 \
    --s3-endpoint s3.amazonaws.com \
    --s3-storage-class STANDARD \
    --use-iam \
    <NAME>
    ```
    ```output
    Credentials created successfully, UUID:12345678-a901-2bc3-4d56-7890ef1d23ab
    ``` 
    -->

### Create credentials on AWS using IAM

{{<info>}}
**NOTE:** This feature requires PX-Enterprise versions 2.5.1 or greater
{{</info>}}

Instead of storing your secret access key and access key ID on the host, you can grant Portworx bucket permissions using IAM. You can grant the EC2 instances on which Portworx is running, or you can grant permissions for a specific bucket.

#### Grant IAM permissions for your EC2 instance in general

1. In AWS, grant IAM permissions for an EC2 instance with no bucket:

    ```text
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:ListAllMyBuckets",
                    "s3:CreateBucket",
                    "s3:ListBucket",
                    "s3:DeleteObject",
                    "s3:GetBucketLocation"
                ],
                "Resource": "*"
            }
        ]
    }
    ```


2. Enter the following pxctl credentials create command, specifying the following:

    * The `--provider` flag with the name of the cloud provider (`s3`).
    * The `--s3-region` flag with the the S3 region associated with your account
    * The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
    * The `use-iam` flag
    * The name of your cloud credentials

    ```text
    ./pxctl credentials create \
    --provider s3 \
    --s3-region us-east-1 \
    --s3-storage-class STANDARD \
    --use-iam \
    <NAME>
    ```
    ```output
    Credentials created successfully, UUID:12345678-a901-2bc3-4d56-7890ef1d23ab
    ```

#### Grant IAM permissions for a specific bucket

1. In AWS, grant IAM permissions for a specific bucket:

    ```text
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "s3:ListAllMyBuckets",
                    "s3:GetBucketLocation"
                ],
                "Resource": "*"
            },
            {
                "Sid": "VisualEditor1",
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::<bucket-name>",
                    "arn:aws:s3:::<bucket-name>/*"
                ]
            }
        ]
    }
    ```

2. Enter the following pxctl credentials create command, specifying the following:

    * The `--provider` flag with the name of the cloud provider (`s3`)
    * The `--s3-region` flag with your bucket's s3 region
    * The optional `--s3-storage-class` flag with either the `STANDARD` or `STANDARD-IA` value, depending on which storage class you prefer
    * The `--bucket` flag with your bucket's name
    * The `use-iam` flag 
    * The name of your cloud credentials

    ```text
    ./pxctl credentials create \
    --provider s3 \
    --s3-region <region> \
    --s3-storage-class STANDARD \
    --bucket <bucket-name> \
    --use-iam \
    <NAME>
    ```
    ```output
    Credentials created successfully, UUID:12345678-a901-2bc3-4d56-7890ef1d23ab
    ```

<!-- What is s3cred in these? Is it the access key ID? -->
<!-- disabling, not release ready:
### Create credentials on Azure

1. [Grant your Azure instance](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-linux-vm-access-storage#grant-your-vm-access-to-an-azure-storage-container) the following permissions:

* `Storage Blob Data Reader`
* `Storage Blob Data Contributor`

2. Enter the following pxctl credentials create command, specifying your own Azure account name and credentials:

  ```text
  ./pxctl cred c --provider azure --azure-account-name <account-name> --use-iam azurecred
  ```
  ```output
  Credentials created successfully, UUID: 12345678-a901-2bc3-4d56-7890ef1d23ab
  ```
-->

## Delete existing credentials

To delete a particular set of credentials, you can run `pxctl credentials delete` with the `uuid` or the `name` as parameters like this:

```text
pxctl credentials delete <uuid or name>
```

```output
Credential deleted successfully
```

{{<info>}}
Don't forget to replace `<uuid or name>` with the actual `uuid` or `name` of the credentials you want to delete.
{{</info>}}


## Validate credentials

If you want to validate a set of credentials for a particular cloud provider, run the following:


```text
pxctl credentials validate <uuid or name>
```

```output
Credential validated successfully
```

{{<info>}}
Don't forget to replace `<uuid or name>` with the actual `uuid` or `name` of the credentials you want to delete.
{{</info>}}

## Related topics

* For information about integrating Portworx with Kubernetes Secrets, refer to the [Kubernetes Secrets](/key-management/kubernetes-secrets/) page.
