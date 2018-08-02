---
title: Kafka
---

This guide will help you to install the Kafka service on your DCOS cluster backed by PX volumes for persistent storage.

The source code for these services can be found here: [Portworx DCOS-Commons Frameworks](https://github.com/portworx/dcos-commons)

> **Note:**  
> This framework is only supported directly by Portworx. Please contact support@portworx.com directly for any support issues related with using this framework.

Please make sure you have installed [Portworx on DCOS](https://docs.portworx.com/scheduler/mesosphere-dcos/install.html) before proceeding further.

### Finding the service in the DCOS Universe/Catalog: {#finding-the-service-in-the-dcos-universecatalog}

You should see the Kafka service available in your universe as Portworx-Kafka

![Kafka-PX in DCOS Universe](https://docs.portworx.com/images/dcos-kafka-px-universe.png)

### Installation {#installation}

#### Default Install {#default-install}

If you want to use the defaults, you can now run the dcos command to install the service

```text
 dcos package install --yes portworx-kafka
```

You can also click on the “Install” button on the WebUI next to the service and then click “Install Package”.

#### Advanced Install {#advanced-install}

If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on “Advanced Installation”

Here you have the option to change the service name, volume name, volume size, and provide any additional options that you want to pass to the docker volume driver. You can also configure other Kafka related parameters on this page including the number of broker nodes.

![Kafka-PX install options](https://docs.portworx.com/images/dcos-kafka-px-install-options.png)

Click on “Review and Install” and then “Install” to start the installation of the service.

### Install Status {#install-status}

Once you have started the install you can go to the Services page to monitor the status of the installation.

![Kafka-PX on services page](https://docs.portworx.com/images/dcos-kafka-px-service.png)

If you click on the Kafka service you should be able to look at the status of the nodes being created.

![Kafka-PX install started](https://docs.portworx.com/images/dcos-kafka-px-started-install.png)

When the Scheduler service as well as all the Kafka services are in Running \(green\) status, you should be ready to start using the Kafka service.

![Kafka-PX install finished](https://docs.portworx.com/images/dcos-kafka-px-finished-install.png)

If you check your Portworx cluster, you should see multiple volumes that were automatically created using the options provided during install, one for each of the Brokers.

![Kafka-PX volumes](https://docs.portworx.com/images/dcos-kafka-px-volume-list.png)

If you run the “dcos service” command you should see the portworx-kafka service in ACTIVE state with 3 running tasks

```text
 dcos service
 NAME                           HOST             ACTIVE  TASKS  CPU   MEM      DISK   ID                                         
 portworx-kafka      ip-10-0-3-116.ec2.internal   True     3    3.0  6144.0    0.0    66d598b0-2f90-4d0a-9567-8468a9979190-0038  
 marathon                    10.0.7.49            True     2    2.0  2048.0    0.0    66d598b0-2f90-4d0a-9567-8468a9979190-0001  
 metronome                   10.0.7.49            True     0    0.0   0.0      0.0    66d598b0-2f90-4d0a-9567-8468a9979190-0000  
 portworx            ip-10-0-1-127.ec2.internal   True     4    3.3  4096.0    25.0   66d598b0-2f90-4d0a-9567-8468a9979190-0031  
 portworx            ip-10-0-2-42.ec2.internal    True     3    1.2  3168.0  12288.0  66d598b0-2f90-4d0a-9567-8468a9979190-0032
```

### Verify Setup {#verify-setup}

From the DCOS client; install the new command for portworx-kafka

```text
  dcos package install portworx-kafka --cli
```

Find out all the kafka broker endpoints

```text
  dcos portworx-kafka endpoints broker
  {
   "address": [
    "10.0.2.82:1025",
    "10.0.0.49:1025",
    "10.0.3.101:1029"
   ],
  "dns": [
  "kafka-2-broker.portworx-kafka.mesos:1025",
  "kafka-0-broker.portworx-kafka.mesos:1025",
  "kafka-1-broker.portworx-kafka.mesos:1029"
   ],
  "vip": "broker.portworx-kafka.l4lb.thisdcos.directory:9092"
  }
```

Find out the zookeeper endpoint for the create kafka service

```text
 dcos portworx-kafka endpoints zookeeper
 master.mesos:2181/dcos-service-portworx-kafka
```

Create a topic, from the DCOS client use dcos command to create a test topic `test-one` with replication set to three

```text
dcos portworx-kafka topic create test-one --partitions 1 --replication 3
{
    "message": "Output: Created topic \"test-one\".\n"
}
```

Connect to the master node and launch a kafka client container.

```text
 dcos node ssh --master-proxy --leader

 core@ip-10-0-6-66 ~ $ docker run -it mesosphere/kafka-client
 root@d19258d46fd3:/bin#
```

Produce a message and send to all kafka brokers

```text
 echo "Hello, World." | ./kafka-console-producer.sh --broker-list kafka-2-broker.portworx-kafka.mesos:1025,kafka-0-broker.portworx-kafka.mesos:1025,kafka-1-broker.portworx-kafka.mesos:1029 --topic test-one
```

Consume the message

```text
 ./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-portworx-kafka --topic test-one --from-beginning
 Hello, World.
```

