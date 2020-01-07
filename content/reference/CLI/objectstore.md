---
title: Objectstore on a Portworx cluster using pxctl
linkTitle: Objectstore
keywords: pxctl, command-line tool, cli, reference, cloud, objectstore
description: Learn how to deploy highly available S3 compliant object storage on Docker with Portworx
hidden: true
---

This document explains how to expose a highly available S3 compliant Objectstore from a Portworx cluster.

The Objectstore module has the following commands:

```text
pxctl objectstore --help
```

```output
Manage the object store

Usage:
  pxctl objectstore [flags]
  pxctl objectstore [command]

Available Commands:
  create      Create an object store
  delete      Delete the object store
  disable     Disable the object store
  enable      Enable the object store
  status      Show the status of the object store

Flags:
  -h, --help   help for objectstore

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

Use "pxctl objectstore [command] --help" for more information about a command.
```

## Creating an Objectstore

To create the volume required to run the object store, type `pxctl objectstore create`. The command takes in the name of the volume to use for objectstore:

```text
pxctl objectstore create --volume myObjectStore
```

```output
Successfully created object store
```

{{<info>}}
The minimum size of a new volume is 10GB.
{{</info>}}

After this step, let's make sure the volume is created:

```text
pxctl volume list
```

```output
ID			NAME									SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS				SNAP-ENABLED
737202856523964661	myObjectStore								10 GiB	1	no	no		LOWup - detached			no
```

## Enabling the objectstore on a node

To enable the object server on a node, run:

```text
pxctl objectstore enable
```

```output
Successfully updated object store
```

The above command attaches the volume to the node where it is run (if the volume is not attached to some other node). Then, it starts the object server on that node. You'll need to run this command from every node that you want to access the object store. On restarting the container, the object store does not restart automatically.

{{<info>}}
You need to run this command as root.
{{</info>}}

At this point, you should be able to access the object browser at http://&lt;node_ip&gt;:9010

## Check the status of the objectstore

To show the status of the server as well as the access key to login to the object server, type the following:

```text
pxctl objectstore status
```

```output
UUID:			494a3a93-26e3-4203-90ac-896d1135931f
Volume:			737202856523964661
State:			Enabled
Endpoints:		70.0.29.70:9010
Current Endpoint:	70.0.29.70:9010
Status:			Running
Access Key:		L3DX6GC0UR4YBMSF4E6L
Secret Key:		/ClJ8pnUOun6+pZnQi3TafKR9jc14BZJ7tWk95fz
Region:			us-east-1
AccessPort:		9010

Please use the following command from a client to connect to this object store
/opt/pwx/bin/pxctl credentials create \
--provider=s3 --s3-disable-ssl --s3-region=us-east-1 \
--s3-access-key=L3DX6GC0UR4YBMSF4E6L \
--s3-secret-key=/ClJ8pnUOun6+pZnQi3TafKR9jc14BZJ7tWk95fz \
--s3-endpoint=70.0.29.70:9010 494a3a93-26e3-4203-90ac-896d1135931f
```

Use these credentials to login to the object browser as well as running any s3 commands.
Currently, the servers are created with the "us-east-1" region.
The objectstore does not have SSL certificates set up, so you'll need to configure your client accordingly.

## Test the objectore from an S3 client

Use the steps below to test the objectstore with the `mc` client utility.

Download the `mc` utility:

```text
wget https://dl.minio.io/client/mc/release/linux-amd64/mc && chmod +x mc
```

Configure the `mc` client to talk to the objectstore by passing it the IP address of the host, the access and secret keys, and the version of the API:

```text
./mc config host add portworxs3 http://70.0.29.70:9010 L3DX6GC0UR4YBMSF4E6L /ClJ8pnUOun6+pZnQi3TafKR9jc14BZJ7tWk95fz --api "s3v2"
```

```output
mc: Configuration written to `/root/.mc/config.json`. Please update your access credentials.
mc: Successfully created `/root/.mc/share`.
mc: Initialized share uploads `/root/.mc/share/uploads.json` file.
mc: Initialized share downloads `/root/.mc/share/downloads.json` file.
Added `portworxs3` successfully.
```

Now let's create a bucket:
```text
./mc mb portworxs3/test
```

```output
Bucket created successfully `portworxs3/test`.
```

Lastly, we want to show the bucket:

```text
./mc ls portworxs3
```

```output
[2019-04-22 08:49:41 PDT]      0B test/
```

## Disabling the objectstore
You can disable the server on each node by running:

```text
pxctl objectstore disable
```

```output
Successfully updated object store
```

If the object server is still running on other nodes you'll get a message saying that the volumes will not be detached since they are being used by the objectstore on the other nodes.

When you stop the server on the last node you'll get the following message:

```
Successfully stopped object store
Unmounted object store volumes
Detached object store volumes
```

At this point, the volume should be in detached state:
```text
pxctl volume list
```

```output
ID			NAME									SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS				SNAP-ENABLED
737202856523964661	myObjectStore								10 GiB	1	no	no		LOWup - detached			no
```

## Delete the objectstore
You can delete the objectstore by running the following command:

```text
pxctl objectstore delete
```

```output
Successfully deleted object store
```

The command fails if the objectstore is still running on any node.
