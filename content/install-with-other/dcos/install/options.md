---
title: Options
weight: 3
linkTitle: 2. Options
---

## Portworx Options

Specify your kvdb \(consul or etcd\) server if you don’t want to use the etcd cluster with this service. If the etcd cluster is enabled this config value will be ignored. If you have been given access to the Enterprise version of PX you can replace px-dev:latest with px-enterprise:latest. With PX Enterprise you can increase the number of nodes in the PX Cluster to a value greater than 3.

{{<info>}}
**Note:**<br/>If you are trying to use block devices that already have a filesystem on them, either add the `-f` option
to `portworx options` to force Portworx to use these disks or wipe the filesystem using wipefs command before installing.
{{</info>}}

![Portworx Install options](/img/dcos-px-install-options.png)

{{<info>}}
**Note:**  
For a full list of installtion options, please look [here](/install-with-other/docker/standalone/standalone-oci).
{{</info>}}

## Secrets Options

To use DC/OS secrets for Volume Encryption and storing Cloud Credentials, [click here](/key-management/portworx-with-dc-os-secrets).

## Etcd Options

By default a 3 node etcd cluster will be created with 5GB of local persistent storage. The size of the persistent disks can be changed during install. This can not be updated once the service has been started so please make sure you have enough storage resources available in your DCOS cluster before starting the install. ![Portworx ETCD Install options](/img/dcos-px-etcd-options.png)

## Lighthouse options

Lighthouse will not be installed by default. If you want to access the Lighthouse UI, you will have to enable it.

By default Lighthouse will run on a public agent in your cluster. If you do not have a public agent, you should
uncheck the `public agent` option. Once deployed, DCOS does not allow moving between public and private agents.
 You can enter the `admin username` to be used for creating the Lighthouse account. This can be used to login to
Lighthouse after install in complete. The default password is `Password1` which can be changed after login.

![Portworx Lighthouse Install options](/img/dcos-px-lighthouse-options.png)

Once you have configured the service, click on `Review and Install` and then `Run Service` to start the installation
of the service.
