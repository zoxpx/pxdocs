---
title: ActiveMQ with Portworx on Kubernetes
linkTitle: ActiveMQ
keywords: portworx, container, Kubernetes, activemq, storage, Docker, k8s, pvc
description: See how ActiveMQ can be deployed on Kubernetes using Portworx volumes.
weight: 2
noicon: true
---

[ActiveMQ](http://activemq.apache.org/) is an open-source message broker written in Java. It plays a central role in many distributed systems that heavily rely on Java technologies. You can configure ActiveMQ to safely pass messages between decoupled systems.

This reference architecture document shows how you can create and run ActiveMQ with Portworx on Kubernetes. This way, Portworx will provide a reliable persistent storage layer which makes sure no messages are lost.

## Create a StorageClass

Enter the following combined spec and `kubectl` command to create and apply a `StorageClass` with 2 replicas that uses a high io-priority storage pool:

```text
kubectl apply -f - <<'_EOF'
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: px-activemq
parameters:
  io_priority: high
  repl: "2"
  group: "amq_vg"
provisioner: kubernetes.io/portworx-volume
allowVolumeExpansion: true
reclaimPolicy: Delete
_EOF
```
```output
...
storageclass.storage.k8s.io/px-activemq created
```

For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section.

{{<info>}}
If you're using Portworx with CSI, you must set the value of the `provisioner` parameter to `pxd.portworx.com`.
{{</info>}}

## Setup ActiveMQ

### Configuration

Enter the following combined spec and `kubectl` command to set-up a [ConfigMap](https://kubernetes.io/blog/2016/04/configuration-management-with-containers/) that configures how ActiveMQ starts-up:

```
kubectl apply -f - <<'_EOF'
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: active-mq-xml
data:
  activemq.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <!--
        Licensed to the Apache Software Foundation (ASF) under one or more
        contributor license agreements.  See the NOTICE file distributed
        with this work for additional information regarding copyright ownership.
        The ASF licenses this file to You under the Apache License, Version 2.0
        (the "License"); you may not use this file except in compliance with
        the License.  You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software distributed
        under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
        OR CONDITIONS OF ANY KIND, either express or implied.  See the License for
        the specific language governing permissions and limitations under the License.
    -->
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
           http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">
      <!-- Allows us to use system properties as variables in this configuration file -->
      <bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
        <property name="locations">
          <value>file:${activemq.conf}/credentials.properties</value>
        </property>
      </bean>
      <!-- Allows accessing the server log -->
      <bean id="logQuery" class="io.fabric8.insight.log.log4j.Log4jLogQuery" lazy-init="false" scope="singleton" init-method="start" destroy-method="stop" />
      <!--
            The <broker> element is used to configure the ActiveMQ broker.  
      -->
      <broker xmlns="http://activemq.apache.org/schema/core" brokerName="${HOSTNAME}" dataDirectory="${activemq.data}">
        <!-- ##### DESTINATIONS ##### -->
        <destinationPolicy>
          <policyMap>
            <policyEntries>
              <policyEntry queue="&gt;" producerFlowControl="true" memoryLimit="100mb" maxBrowsePageSize="700">
                <!--
                  Allow messages to be replayed back to original broker if there is demand.
                  (replayWhenNoConsumers="true").
                  Due to ENTMQ-444 you also want to configure a replayDelay that is high enough so that
                  any outstanding message acks are passed along the network bridge *before* we start
                  to replay messages (replayDelay="500"). The value of replayDelay is a bit of a guess but
                  on a decently fast network 500 msecs should be enough to pass on and process all message acks.

                  Note: JMS clients that use the failover transport to connect to a broker in the mesh
                  arbitrarily should consider using an initialReconnectDelay on the failover url that is
                  higher than replayDelay configured in the broker. E.g.
                  "failover:(tcp://brokerA:61616,tcp://brokerB:61616)?randomize=true&initialReconnectDelay=700"
                  This ensures that the demand subscription for this reconnecting consumer is only created
                  after replayDelay has elapsed.
                  If its created before, it may lead to the remote broker skipping message dispatch
                  to the remote broker and those message would seem to be stuck on the broker despite a
                  consumer being connected via a networked broker.
                  See ENTMQ-538 for more details.
                -->
                <networkBridgeFilterFactory>
                  <conditionalNetworkBridgeFilterFactory replayWhenNoConsumers="true" replayDelay="500" />
                </networkBridgeFilterFactory>
              </policyEntry>
              <policyEntry topic="&gt;" producerFlowControl="true">
                <!--
                  The constantPendingMessageLimitStrategy is used to prevent
                  slow topic consumers to block producers and affect other consumers
                  by limiting the number of messages that are retained
                  For more information, see:

                  http://activemq.apache.org/slow-consumer-handling.html
                -->
                <pendingMessageLimitStrategy>
                  <constantPendingMessageLimitStrategy limit="1000" />
                </pendingMessageLimitStrategy>
              </policyEntry>
            </policyEntries>
          </policyMap>
        </destinationPolicy>
        <!--
          The managementContext is used to configure how ActiveMQ is exposed in
          JMX. By default, ActiveMQ uses the MBean server that is started by
          the JVM. For more information, see:

          http://activemq.apache.org/jmx.html
        -->
        <managementContext>
          <managementContext createConnector="false" />
        </managementContext>
        <ioExceptionHandler>
          <defaultIOExceptionHandler ignoreNoSpaceErrors="false" />
        </ioExceptionHandler>
        <networkConnectors>
          <!--
            In a full mesh we want messages to travel freely to any broker
            (i.e. messageTTL="-1") but create demand subscription only to the next connected
            broker (i.e. consumerTTL="1"). See AMQ-4607.
          -->
          <!-- ##### MESH_CONFIG ##### -->
          <networkConnector userName="admin" password="admin" uri="dns://px-amq-tcp:61616/?transportType=tcp&amp;queryInterval=30" messageTTL="-1" consumerTTL="1" />
        </networkConnectors>
        <!--
          Configure message persistence for the broker. The default persistence
          mechanism is the KahaDB store (identified by the kahaDB tag).
          For more information, see:

          http://activemq.apache.org/persistence.html
        -->
        <persistenceAdapter>
          <kahaDB enableJournalDiskSyncs="false" directory="${activemq.data}/kahadb" />
        </persistenceAdapter>
        <plugins>
          <jaasAuthenticationPlugin configuration="activemq" />
        </plugins>
        <!--
          The systemUsage controls the maximum amount of space the broker will
          use before disabling caching and/or slowing down producers.
          For more information, see:

          http://activemq.apache.org/producer-flow-control.html
        -->
        <systemUsage>
          <systemUsage>
            <memoryUsage>
              <memoryUsage percentOfJvmHeap="70" />
            </memoryUsage>
            <storeUsage>
              <storeUsage limit="50 gb" />
            </storeUsage>
            <tempUsage>
              <tempUsage limit="50 gb" />
            </tempUsage>
          </systemUsage>
        </systemUsage>
        <!--
          The transport connectors expose ActiveMQ over a given protocol to
          clients and other brokers. For more information, see:

          http://activemq.apache.org/configuring-transports.html
        -->
        <!-- ##### TRANSPORT_CONNECTORS ##### -->
        <transportConnectors>
          <transportConnector name="openwire" uri="tcp://0.0.0.0:61616?maximumConnections=1000&amp;wireFormat.maxFrameSize=104857600" />
        </transportConnectors>
        <!-- ##### SSL_CONTEXT ##### -->
        <!-- destroy the spring context on shutdown to stop jetty -->
        <shutdownHooks>
          <bean xmlns="http://www.springframework.org/schema/beans" class="org.apache.activemq.hooks.SpringContextHook" />
        </shutdownHooks>
      </broker>
      <!--
        Enable web consoles, REST and Ajax APIs and demos
        The web consoles requires by default login, you can disable this in the jetty.xml file

        Take a look at ${ACTIVEMQ_HOME}/conf/jetty.xml for more details
      -->
      <!-- Do not expose the console or other webapps
        <import resource="jetty.xml" />
      -->
    </beans>
_EOF
```
```output
...
configmap/active-mq-xml created
```

### Defining claim for persistent volume

Enter the following combined `kubectl` command and spec to define the request to generate a Portworx-powered persistent volume:

```text
kubectl apply -f - <<'_EOF'
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: px-amq-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 40Gi
  storageClassName: px-activemq
_EOF
```

```output
...
persistentvolumeclaim/px-amq-claim created
```

### Services & Deployment

Enter the following combined `kubectl` command and spec to create the services and the deployment for them:

```text
kubectl apply -f - <<'_EOF'
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    description: The broker's AMQP port.
  labels:
    application: px
  name: px-amq-amqp
spec:
  ports:
  - port: 5672
    targetPort: 5672
  selector:
    deploymentConfig: px-amq
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    description: The broker's MQTT port.
  labels:
    application: px
  name: px-amq-mqtt
spec:
  ports:
  - port: 1883
    targetPort: 1883
  selector:
    deploymentConfig: px-amq
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    description: The broker's STOMP port.
  labels:
    application: px
  name: px-amq-stomp
spec:
  ports:
  - port: 61613
    targetPort: 61613
  selector:
    deploymentConfig: px-amq
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    description: The broker's OpenWire port.
    service.alpha.openshift.io/dependencies: '[{"name": "px-amq-amqp", "kind": "Service"},{"name": "px-amq-mqtt", "kind": "Service"},{"name": "px-amq-stomp", "kind": "Service"}]'
  labels:
    application: px
  name: px-amq-tcp
spec:
  ports:
  - port: 61616
    targetPort: 61616
  selector:
    deploymentConfig: px-amq
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    description: Supports node discovery for mesh formation.
  labels:
    application: px
  name: px-amq-mesh
spec:
  clusterIP: None
  ports:
  - name: mesh
    port: 61616
  selector:
    deploymentConfig: px-amq
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    application: px
  name: px-amq
spec:
  replicas: 1
  template:
    metadata:
      labels:
        application: px
        deploymentConfig: px-amq
      name: px-amq
    spec:
      schedulerName: stork
      securityContext:
        runAsUser: 1000
        fsGroup: 2000
        runAsNonRoot: true
      containers:
      - env:
        - name: AMQ_USER
          value: admin
        - name: AMQ_PASSWORD
          value: admin
        - name: AMQ_TRANSPORTS
          value: openwire
        - name: AMQ_QUEUES
          value: FUSE.TEST.QUEUE
        - name: AMQ_MESH_SERVICE_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: AMQ_STORAGE_USAGE_LIMIT
          value: 50 Gb
        - name: AMQ_QUEUE_MEMORY_LIMIT
          value: 500mb
        image: registry.access.redhat.com/jboss-amq-6/amq63-openshift:1.4-27
        imagePullPolicy: Always
        name: px-amq
        ports:
        - containerPort: 8778
          name: jolokia
          protocol: TCP
        - containerPort: 5672
          name: amqp
          protocol: TCP
        - containerPort: 1883
          name: mqtt
          protocol: TCP
        - containerPort: 61613
          name: stomp
          protocol: TCP
        - containerPort: 61616
          name: tcp
          protocol: TCP
        readinessProbe:
          exec:
            command:
            - /bin/bash
            - -c
            - /opt/amq/bin/readinessProbe.sh
        volumeMounts:
        - mountPath: /opt/amq/data
          name: data-broker-px-amq
        - mountPath: /opt/amq/conf/activemq.xml
          name: config-xml
          subPath: activemq.xml
      terminationGracePeriodSeconds: 60
      volumes:
      - name: config-xml
        configMap:
          name: active-mq-xml
      - name: data-broker-px-amq
        persistentVolumeClaim:
          claimName: px-amq-claim
_EOF
```

```output
...
service/px-amq-amqp created
service/px-amq-mqtt created
service/px-amq-stomp created
service/px-amq-tcp created
service/px-amq-mesh created
deployment.extensions/px-amq created
```

Once you've applied the service and deployment specs, your ActiveMQ deployment is complete.

## Clean up ActiveMQ

To clean up the environment created above, enter the following `kubectl` command to delete all the resources that you created in the steps above:

```text
kubectl delete \
  deploy/px-amq \
  svc/px-amq-amqp \
  svc/px-amq-mqtt \
  svc/px-amq-stomp \
  svc/px-amq-tcp \
  svc/px-amq-mesh \
  cm/active-mq-xml \
  pvc/px-amq-claim \
  sc/px-activemq
```

The command above deletes the following:

  * The workload itself (deployment/pods)
  * Configuration (configmap)
  * Storage volumes including data (persistentvolumeclaim)
  * Volume parameters (storageclass)

#### References

A portion of the setup here of ActiveMQ is based on [work by Francois Martel adapting](https://github.com/fmrtl73/px/tree/master/amq/k8s/jboss-amq) the [OpenShift version of JBoss ActiveMQ 6](https://github.com/jboss-container-images/jboss-amq-6-openshift-image)
