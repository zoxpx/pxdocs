---
title: Install Portworx Universe on DC/OS for air-gapped clusters
description: Find out how to deploy Portworx Universe on DC/OS for air-gapped clusters
keywords: portworx, mesos, mesosphere, air-gapped, local, universe, DCOS, DC/OS
linkTitle: Install Portworx Local Universe
weight: 3
noicon: true
---

This guide will help you install the Portworx Universe for DC/OS which contains the Portworx service as well as other services
inlcuding Hadoop, Cassandra, Elastic Search, Kafka, etc which can utilize Portworx Volumes.

This guide is based on the [DC/OS guide](https://docs.mesosphere.com/1.12/administering-clusters/deploying-a-local-dcos-universe) to install a local universe.

## Download the pre-requisites
First you will need to download 3 files and transfer them to each of you DC/OS Master nodes

* [dcos-local-px-universe-http.service](https://raw.githubusercontent.com/portworx/universe/version-3.x-px-local-universe/docker/local-universe/dcos-local-px-universe-http.service)
* [dcos-local-px-universe-registry.service](https://raw.githubusercontent.com/portworx/universe/version-3.x-px-local-universe/docker/local-universe/dcos-local-px-universe-registry.service)
* [local-universe.tar.gz](https://s3-us-west-1.amazonaws.com/px-dcos/local-universe_1.11.3_05122018_144403_df8e5c8.tar.gz)

## Install the services
On each of your Master nodes run the following steps:

#### Load the universe container into docker
The local universe could be a large file and may take few minutes to load.
```text
docker load < local-universe.tar.gz
```

#### Copy the service files to /etc/systemd/system and start the services
```text
sudo mv dcos-local-px-universe-registry.service /etc/systemd/system/
sudo mv dcos-local-px-universe-http.service /etc/systemd/system/
sudo systemctl daemon-reload
```
```text
sudo systemctl enable dcos-local-px-universe-http
sudo systemctl enable dcos-local-px-universe-registry
```
```text
sudo systemctl start dcos-local-px-universe-http
sudo systemctl start dcos-local-px-universe-registry
```

#### Confirm that the services are up
```text
sudo systemctl status dcos-local-px-universe-http
sudo systemctl status dcos-local-px-universe-registry
```

## Add the Portworx Universe to DC/OS

Run the dcos command to add the newly deployed universe to your DC/OS cluster
```text
dcos package repo add local-universe http://master.mesos:8083/repo --index=0
```

## Add the docker registry as a trusted store on each agent

On each agent node you will need to download the certificate from the newly deployed Docker registry to set is as trusted.
To do this, run the following command on each agent node, including public agents.
```text
sudo mkdir -p /etc/docker/certs.d/master.mesos:5001
sudo curl -o /etc/docker/certs.d/master.mesos:5001/ca.crt http://master.mesos:8083/certs/domain.crt
sudo systemctl restart docker
```
```text
sudo mkdir /var/lib/dcos/pki/tls/certs # Only required on private agents
sudo cp /etc/docker/certs.d/master.mesos:5001/ca.crt /var/lib/dcos/pki/tls/certs/px-docker-registry-ca.crt
```
```text
hash=$(openssl x509 -hash -noout -in /var/lib/dcos/pki/tls/certs/px-docker-registry-ca.crt)
sudo ln -s /var/lib/dcos/pki/tls/certs/px-docker-registry-ca.crt /var/lib/dcos/pki/tls/certs/${hash}.0
```

## Verify local Universe available from DC/OS

To verify that the local Universe has been configured successfully, log in to the DC/OS UI and look at `Catalog` to
see if the packages are available.

## Using docker images from local registry

If you want to use any images from the newly deployed registry, you will need to update the image names to point to it when starting the
 services. For example, if the original Portworx docker image was `portworx/px-enterprise:<tag>`, you would use `master.mesos:5001/portworx/px-enterprise:<tag>`
