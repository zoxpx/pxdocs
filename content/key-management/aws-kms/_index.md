---
title: AWS KMS
logo: /logos/aws.png
keywords: Portworx, aws, kms, containers, storage, encryption
description: Instructions on using AWS KEM key management with Portworx
disableprevnext: true
weight: 2
series: key-management
noicon: true
---

_Portworx_ can integrate with AWS KMS to generate and use KMS Datakeys. This document will show you how to spin up a _Portworx_ cluster which is connected to an AWS KMS endpoint. The data keys created in KMS can be used to encrypt _Portworx_ volumes.

{{<info>}}
This feature is supported from PX Enterprise 1.4 onwards.
{{</info>}}

## Configuring AWS KMS with Portworx

There are multiple ways in which you can setup _Portworx_ so that it gets authenticated with AWS.

Following are the authentication details required by _Portworx_ to use the AWS KMS service:

- **AWS Access Key [AWS_ACCESS_KEY_ID]** [required]

    AWS Access Key ID of the account which has permissions to access KMS APIs

- **AWS Secret Key [AWS_SECRET_ACCESS_KEY]** [required]

    AWS Secret Access Key of the account which has permissions to access KMS APIs

- **AWS Secret Token Key [AWS_SECRET_TOKEN_KEY]** [optional]

    AWS Secret Token Key (if configured) of the account which has permissions to access KMS APIs

- **AWS Customer Master Key [AWS_CMK]** [required]

    AWS Customer Master Key.
    The CMK can be found out from AWS's resource ARN. Here is an example ARN for CMK:
    ```
        arn:aws:kms:us-east-1::key/<cmk-id>
    ```
    It specifies that the ARN is for the `kms` service for `us-east-1` region.
    The trailing ID at the end of ARN is the actual CMK that needs to be provided to _Portworx_ through the `AWS_CMK` field.

- **AWS Region of the CMK [AWS_REGION]**  [required]

    The AWS region to which the CMK is associated to. CMKs are region specific and cannot be used across regions.

### Using AWS environment variables

_Portworx_ can authenticate with AWS using AWS SDK’s EnvProvider.

Each of the above fields can be provided as is to _Portworx_ as environment variables.

#### Kubernetes users

If you are installing _Portworx_ on Kubernetes, when generating the _Portworx_ Kubernetes spec file on [https://install.portworx.com/](https://install.portworx.com/):

1. Pass in all the above variables as is in the Environment Variables section.
2. Specify the `Secret Store Type` in the Advanced Settings section as `aws`

 More help on generating the _Portworx_ spec for Kubernetes is available [here](/portworx-install-with-kubernetes).


#### Other users

During installation,

1. Use argument `-secret_type aws-kms` when starting _Portworx_ to specify the secret type as AWS KMS.
2. Use `-e` argument to expose the AWS KMS environment variables


### Using AWS EC2 Role Credentials

_Portworx_ can authenticate with AWS using AWS SDK’s EC2RoleCredentials Provider. Follow [these instructions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) to create an EC2 role. Make sure you provide the following access to KMS in your policy associated with EC2 role.

Here is a sample AWS Policy that gives access to KMS:

```text
{
    "Version": "2012-10-17",
    "Statement": [
            {
	                "Sid": "Stmt1490047200000",
            "Effect": "Allow",
            "Action": [
	                    "kms:*"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:<aws-id>:key/<key-id>"
            ]
        }
    ]
}
```

Apply EC2 role to all the AWS instances where _Portworx_ will be running.

Along with the EC2 role you will still need to provide `AWS_CMK` and `AWS_REGION` either through `config.json` or as environment variables. To provide them through `config.json`, add the following section to the `config.json` on all the nodes

```text
cat /etc/pwx/config.json
```
```
{
    "clusterid": "<cluster-id>",
    "secret": {
        "secret_type": "aws-kms",
        "aws": {
               "AWS_CMK": "your-customer-master-key-id",
               "AWS_REGION": "you-aws-region-to-which-this-cmk-belongs"
        },
    }
    ...
}
```

## Using AWS KMS with Portworx

To use AWS KMS with _Portworx_, proceed to one of the below sections.

{{<homelist series="aws-secret-uses">}}
