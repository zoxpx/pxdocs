---
title: DCOS
weight: 1
hideSections: true
---

[Mesosphere DC/OS](https://mesosphere.com/product/) makes it easy to build and run modern distributed applications in production at scale, by pooling resources across an entire datacenter or
cloud.

While the DC/OS platform works great for stateless applications, many enterprises who have tried to use DC/OS for stateful applications at scale have stumbled when it comes to using the platform for services like databases, queues and key-value stores.

Portworx, which scales up to 1000 nodes per cluster and is used in production by DC/OS users like GE Digital, solves the operational and data management problems enterprises encounter when running stateful applications on DC/OS.

Unlike the default DC/OS volume driver, Portworx lets you:

* dynamically create volumes for tasks at run time, no more submitting tickets for storage provisioning
* dynamically and automatically resize volumes based on demand while task is running
* run tasks on the same hosts that your data is located on for optimum performance
* avoid pinning services to particular hosts, reducing the value of automated scheduling
* avoid fragile block device mount/unmount operations that block or delay failover operations
* encrypt data at rest and in flight at the container level

Read on for how to use Portworx to provide [persistent storage for Mesosphere DC/OS and marathon](https://portworx.com/use-case/persistent-storage-dcos/) and use it with [DC/OS Commons frameworks](https://docs.mesosphere.com/service-docs/) for some of the most popular stateful services.

## Installation

For documentation for installing with Mesosphere/DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/install" >}}Install Mesosphere/DCOS{{</widelink>}}

## Post-installation

For documentation for installing with Azure on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/azure" >}}Install Azure on DCOS{{</widelink>}}

For documentation for installing with Cassandra on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/cassandra" >}}Install Cassandra on DCOS{{</widelink>}}

For documentation for installing with Couchdb on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/couchdb" >}}Install with Couchdb on DCOS {{</widelink>}}

For documentation for installing with Elasticsearch on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/elastic-search-and-kibana" >}}Install Elasticsearch on DCOS{{</widelink>}}

For documentation for installing with Hadoop on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/hadoop-and-hdfs" >}}Install Hadoop on DCOS{{</widelink>}}

For documentation for installing with Kafka on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/kafka" >}}Install Kafka on DCOS{{</widelink>}}

For documentation for installing with Zookeeper on DCOS with Portworx, continue below
{{< widelink url="/install-with-other/dcos/application-installs/zookeeper" >}}Install Zookeeper on DCOS{{</widelink>}}

For documentation on operating and maintaining your Mesoshere/DCOS installation, continue below
{{< widelink url="/install-with-other/dcos/operate-and-maintain" >}}Operate and Maintain{{</widelink>}}
