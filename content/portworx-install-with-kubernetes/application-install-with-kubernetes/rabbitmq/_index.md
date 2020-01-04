---
title: RabbitMQ with Portworx on Kubernetes
linkTitle: RabbitMQ
keywords: portworx, container, Kubernetes, rabbitMQ, storage, Docker, k8s, pvc
description: See how RabbitMQ can be deployed on Kubernetes using Portworx volumes.
weight: 2
noicon: true
---

[RabbitMQ](https://www.rabbitmq.com/) is an open-source message broker. It plays a central role in many distributed systems. You can configure RabbitMQ to safely pass messages between decoupled systems.

This reference architecture document shows how you can create and run RabbitMQ with Portworx on Kubernetes. This way, Portworx will provide a reliable persistent storage layer, which makes sure no messages are lost.

The RabbitMQ cluster will use [mirrored queues](https://www.rabbitmq.com/ha.html) to persist data and metadata to Portworx volumes. Portworx also replicates the volumes, providing multiple layers of redundancy.

## Prerequisites

* You must have a Kubernetes cluster with a minimum of 3 worker nodes.
* Portworx has been installed on your Kubernetes cluster. For more details on how to install Portworx, refer to the instructions from the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page.
* (Optional) Helm must be installed on your Kubernetes cluster if you plan on using it to deploy RabbitMQ. Refer to the [Helm Quickstart Guide](https://helm.sh/docs/using_helm/#quickstart) for details about how to install Helm.

## Create a StorageClass

Enter the following `kubectl apply` command to create a `StorageClass`:

```text
kubectl apply -f - <<'_EOF'
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: portworx-rabbitmq
parameters:
  io_priority: high
  repl: "2"
  group: "rmq_vg"
provisioner: kubernetes.io/portworx-volume
allowVolumeExpansion: true
reclaimPolicy: Delete
_EOF
```

```output
storageclass.storage.k8s.io/portworx-rabbitmq created
```

Note the following about this `StorageClass`:

* The `provisioner` parameter is set to  `kubernetes.io/portworx-volume`. For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section.
* Two replicas of each volume will be created
* A high-priority storage pool will be used
* The `allowVolumeExpansion` parameter is set to `true`
* The `reclaimPolicy` parameter is set to `Delete`. 

You'll be referencing this `StorageClass` later in this tutorial when you'll create a [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). Then, you'll configure the RabbitMQ Pods to use the persistent volumes created by this PVC.

{{<info>}}
If you're using Portworx with CSI, you need to set the value of the `provisioner` parameter to `pxd.portworx.com`.
{{</info>}}

When you install RabbitMQ with Portworx on Kubernetes, you can choose one of the following options:

* Set up RabbitMQ using [Helm](https://helm.sh)
* Set up RabbitMQ manually

## Set up RabbitMQ using Helm

A complex application like RabbitMQ relies on several YAML files to define its various components. This section shows how you can use Helm to simplify the deployment of RabbitMQ.

The following Helm command uses the [RabbitMQ High Available](https://github.com/helm/charts/tree/master/stable/rabbitmq-ha) Helm chart to create a [release](https://github.com/helm/helm/blob/release-2.14/docs/glossary.md#release) named `rmq`. The release creates a two-member RabbitMQ cluster, and Portworx will mirror queues and messages between the nodes.

```text
helm upgrade \
  --install \
  --set replicaCount=2 \
  --set rabbitmqUsername=admin \
  --set rabbitmqPassword=secretpassword \
  --set managementPassword=anothersecretpassword \
  --set rabbitmqErlangCookie=secretcookie  \
  --set persistentVolume.enabled=true \
  --set persistentVolume.storageClass=portworx-rabbitmq \
  --set schedulerName=stork \
rmq stable/rabbitmq-ha
```

```output
Release "rmq" does not exist. Installing it now.

NAME: rmq
LAST DEPLOYED: Mon Oct 14 16:58:20 2019
NAMESPACE: default
STATUS: DEPLOYED
```

Note that the `replicaCount` variable in this example creates a two-replica [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) and the `persistentVolume.storageClass` references the `StorageClass` defined above.

## Set up RabbitMQ manually

In this section, we'll show how you can install RabbitMQ manually.

{{<info>}}
Note that the spec files used in this section are based on these [Helm templates](https://github.com/helm/charts/tree/master/stable/rabbitmq-ha/templates).
{{</info>}}

1. Enter the following command to create a `ConfigMap` and a Kubernetes secret:

    ```text
    kubectl apply -f - <<'_EOF'
    ---
    # Source: rabbitmq-ha/templates/configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: rmq-rabbitmq-ha
      namespace: default
      labels:
        app: rabbitmq-ha
    data:
      enabled_plugins: |
        [
          rabbitmq_shovel,
          rabbitmq_shovel_management,
          rabbitmq_federation,
          rabbitmq_federation_management,
          rabbitmq_consistent_hash_exchange,
          rabbitmq_management,
          rabbitmq_peer_discovery_k8s
        ].
      rabbitmq.conf: |
        ## RabbitMQ configuration
        ## Ref: https://github.com/rabbitmq/rabbitmq-server/blob/master/docs/rabbitmq.conf.example

        ## Authentification

        ## Clustering
        cluster_formation.peer_discovery_backend  = rabbit_peer_discovery_k8s
        cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
        cluster_formation.k8s.address_type = hostname
        cluster_formation.node_cleanup.interval = 10
        # Set to false if automatic cleanup of absent nodes is desired.
        # This can be dangerous, see http://www.rabbitmq.com/cluster-formation.html#node-health-checks-and-cleanup.
        cluster_formation.node_cleanup.only_log_warning = true
        cluster_partition_handling = autoheal

        ## The default "guest" user is only permitted to access the server
        ## via a loopback interface (e.g. localhost)
        loopback_users.guest = false

        management.load_definitions = /etc/definitions/definitions.json

        ## Memory-based Flow Control threshold
        vm_memory_high_watermark.absolute = 256MB

        ## Auth HTTP Backend Plugin

        ## LDAP Plugin

        ## MQTT Plugin

        ## Web MQTT Plugin

        ## STOMP Plugin

        ## Web STOMP Plugin

        ## Prometheus Plugin

        ## AMQPS support
    ---
    # Source: rabbitmq-ha/templates/secret.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: rmq-rabbitmq-ha
      namespace: default
      labels:
        app: rabbitmq-ha
    type: Opaque
    data:
      rabbitmq-username: "YWRtaW4="
      rabbitmq-password: "c2VjcmV0cGFzc3dvcmQ="
      rabbitmq-management-username: "bWFuYWdlbWVudA=="
      rabbitmq-management-password: "YW5vdGhlcnNlY3JldHBhc3N3b3Jk"
      rabbitmq-erlang-cookie: "c2VjcmV0Y29va2ll"
      definitions.json: "ewogICJnbG9iYWxfcGFyYW1ldGVycyI6IFsKICAgIAogIF0sCiAgInVzZXJzIjogWwogICAgewogICAgICAibmFtZSI6ICJtYW5hZ2VtZW50IiwKICAgICAgInBhc3N3b3JkIjogImFub3RoZXJzZWNyZXRwYXNzd29yZCIsCiAgICAgICJ0YWdzIjogIm1hbmFnZW1lbnQiCiAgICB9LAogICAgewogICAgICAibmFtZSI6ICJhZG1pbiIsCiAgICAgICJwYXNzd29yZCI6ICJzZWNyZXRwYXNzd29yZCIsCiAgICAgICJ0YWdzIjogImFkbWluaXN0cmF0b3IiCiAgICB9CiAgXSwKICAidmhvc3RzIjogWwogICAgewogICAgICAibmFtZSI6ICIvIgogICAgfQogIF0sCiAgInBlcm1pc3Npb25zIjogWwogICAgewogICAgICAidXNlciI6ICJhZG1pbiIsCiAgICAgICJ2aG9zdCI6ICIvIiwKICAgICAgImNvbmZpZ3VyZSI6ICIuKiIsCiAgICAgICJyZWFkIjogIi4qIiwKICAgICAgIndyaXRlIjogIi4qIgogICAgfQogIF0sCiAgInBhcmFtZXRlcnMiOiBbCiAgICAKICBdLAogICJwb2xpY2llcyI6IFsKICAgIAogIF0sCiAgInF1ZXVlcyI6IFsKICAgIAogIF0sCiAgImV4Y2hhbmdlcyI6IFsKICAgIAogIF0sCiAgImJpbmRpbmdzIjogWwogICAgCiAgXQp9"
    _EOF
    ```

    ```output
    configmap/rmq-rabbitmq-ha created
    secret/rmq-rabbitmq-ha created
    ```

    Note that we're separating the application code from the configuration. Refer to the [Configuration management with Containers](https://kubernetes.io/blog/2016/04/configuration-management-with-containers/) for more details about the `ConfigMap` resource.

2. To set up RBAC, apply the following spec in your cluster:

      ```text
      kubectl apply -f - <<'_EOF'
      ---
      # Source: rabbitmq-ha/templates/serviceaccount.yaml
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        labels:
          app: rabbitmq-ha
        name: rmq-rabbitmq-ha
        namespace: default
      ---
      # Source: rabbitmq-ha/templates/role.yaml
      apiVersion: rbac.authorization.k8s.io/v1
      kind: Role
      metadata:
        labels:
          app: rabbitmq-ha
        name: rmq-rabbitmq-ha
        namespace: default
      rules:
        - apiGroups: [""]
          resources: ["endpoints"]
          verbs: ["get"]
      ---
      # Source: rabbitmq-ha/templates/rolebinding.yaml
      apiVersion: rbac.authorization.k8s.io/v1
      kind: RoleBinding
      metadata:
        labels:
          app: rabbitmq-ha
        name: rmq-rabbitmq-ha
        namespace: default
      subjects:
        - kind: ServiceAccount
          name: rmq-rabbitmq-ha
          namespace: default
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: Role
        name: rmq-rabbitmq-ha
      _EOF
      ```

      ```output
      serviceaccount/rmq-rabbitmq-ha created
      role.rbac.authorization.k8s.io/rmq-rabbitmq-ha created
      rolebinding.rbac.authorization.k8s.io/rmq-rabbitmq-ha created
      ```

3. Enter the following command to create a `StatefulSet` and the required supporting services:

      ```text
      kubectl apply -f - <<'_EOF'
      ---
      # Source: rabbitmq-ha/templates/service-discovery.yaml
      apiVersion: v1
      kind: Service
      metadata:
        name: rmq-rabbitmq-ha-discovery
        namespace: default
        labels:
          app: rabbitmq-ha
      spec:
        clusterIP: None
        ports:
          - name: http
            protocol: TCP
            port: 15672
            targetPort: http
          - name: amqp
            protocol: TCP
            port: 5672
            targetPort: amqp
          - name: epmd
            protocol: TCP
            port: 4369
            targetPort: epmd
        publishNotReadyAddresses: true
        selector:
          app: rabbitmq-ha
        type: ClusterIP
      ---
      # Source: rabbitmq-ha/templates/service.yaml
      apiVersion: v1
      kind: Service
      metadata:
        name: rmq-rabbitmq-ha
        namespace: default
        labels:
          app: rabbitmq-ha
      spec:
        clusterIP: "None"
        ports:
          - name: http
            protocol: TCP
            port: 15672
            targetPort: http
          - name: amqp
            protocol: TCP
            port: 5672
            targetPort: amqp
          - name: epmd
            protocol: TCP
            port: 4369
            targetPort: epmd
        selector:
          app: rabbitmq-ha
        type: ClusterIP
      ---
      # Source: rabbitmq-ha/templates/statefulset.yaml
      apiVersion: apps/v1
      kind: StatefulSet
      metadata:
        name: rmq-rabbitmq-ha
        namespace: default
        labels:
          app: rabbitmq-ha
      spec:
        podManagementPolicy: OrderedReady
        serviceName: rmq-rabbitmq-ha-discovery
        replicas: 2
        updateStrategy:
          type: OnDelete
        selector:
          matchLabels:
            app: rabbitmq-ha
        template:
          metadata:
            labels:
              app: rabbitmq-ha
            annotations:
              checksum/config: 1b2c44d6700bf1d0c528a1dc3867f71e5a5e7c9099e15d68639ba407205c1d30
          spec:
            terminationGracePeriodSeconds: 10
            schedulerName: stork
            securityContext:
                fsGroup: 101
                runAsGroup: 101
                runAsNonRoot: true
                runAsUser: 100
            serviceAccountName: rmq-rabbitmq-ha
            initContainers:
              - name: bootstrap
                image: busybox:1.30.1
                imagePullPolicy: IfNotPresent
                command: ['sh']
                args:
                - "-c"
                - |
                  set -ex
                  cp /configmap/* /etc/rabbitmq
                  echo "${RABBITMQ_ERLANG_COOKIE}" > /var/lib/rabbitmq/.erlang.cookie
                env:
                - name: POD_NAME
                  valueFrom:
                    fieldRef:
                      apiVersion: v1
                      fieldPath: metadata.name
                - name: RABBITMQ_MNESIA_DIR
                  value: /var/lib/rabbitmq/mnesia/rabbit@$(POD_NAME).rmq-rabbitmq-ha-discovery.default.svc.cluster.local
                - name: RABBITMQ_ERLANG_COOKIE
                  valueFrom:
                    secretKeyRef:
                      name: rmq-rabbitmq-ha
                      key: rabbitmq-erlang-cookie
                volumeMounts:
                  - name: configmap
                    mountPath: /configmap
                  - name: config
                    mountPath: /etc/rabbitmq
                  - name: data
                    mountPath: /var/lib/rabbitmq
            containers:
              - name: rabbitmq-ha
                image: rabbitmq:3.7.19-alpine
                imagePullPolicy: IfNotPresent
                ports:
                  - name: epmd
                    protocol: TCP
                    containerPort: 4369
                  - name: amqp
                    protocol: TCP
                    containerPort: 5672
                  - name: http
                    protocol: TCP
                    containerPort: 15672
                livenessProbe:
                  exec:
                    command:
                    - /bin/sh
                    - -c
                    - 'wget -O - -q --header "Authorization: Basic `echo -n \"$RABBIT_MANAGEMENT_USER:$RABBIT_MANAGEMENT_PASSWORD\"
                      | base64`" http://localhost:15672/api/healthchecks/node | grep -qF "{\"status\":\"ok\"}"'
                  failureThreshold: 6
                  initialDelaySeconds: 120
                  periodSeconds: 10
                  timeoutSeconds: 5
                readinessProbe:
                  exec:
                    command:
                    - /bin/sh
                    - -c
                    - 'wget -O - -q --header "Authorization: Basic `echo -n \"$RABBIT_MANAGEMENT_USER:$RABBIT_MANAGEMENT_PASSWORD\"
                      | base64`" http://localhost:15672/api/healthchecks/node | grep -qF "{\"status\":\"ok\"}"'
                  failureThreshold: 6
                  initialDelaySeconds: 20
                  periodSeconds: 5
                  timeoutSeconds: 3
                env:
                  - name: MY_POD_NAME
                    valueFrom:
                      fieldRef:
                        apiVersion: v1
                        fieldPath: metadata.name
                  - name: RABBITMQ_USE_LONGNAME
                    value: "true"
                  - name: RABBITMQ_NODENAME
                    value: rabbit@$(MY_POD_NAME).rmq-rabbitmq-ha-discovery.default.svc.cluster.local
                  - name: K8S_HOSTNAME_SUFFIX
                    value: .rmq-rabbitmq-ha-discovery.default.svc.cluster.local
                  - name: K8S_SERVICE_NAME
                    value: rmq-rabbitmq-ha-discovery
                  - name: RABBITMQ_ERLANG_COOKIE
                    valueFrom:
                      secretKeyRef:
                        name: rmq-rabbitmq-ha
                        key: rabbitmq-erlang-cookie
                  - name: RABBIT_MANAGEMENT_USER
                    valueFrom:
                      secretKeyRef:
                        name: rmq-rabbitmq-ha
                        key: rabbitmq-management-username
                  - name: RABBIT_MANAGEMENT_PASSWORD
                    valueFrom:
                      secretKeyRef:
                        name: rmq-rabbitmq-ha
                        key: rabbitmq-management-password
                volumeMounts:
                  - name: data
                    mountPath: /var/lib/rabbitmq
                  - name: config
                    mountPath: /etc/rabbitmq
                  - name: definitions
                    mountPath: /etc/definitions
                    readOnly: true
            affinity:
              podAntiAffinity:
                preferredDuringSchedulingIgnoredDuringExecution:
                  - weight: 1
                    podAffinityTerm:
                      topologyKey: "kubernetes.io/hostname"
                      labelSelector:
                        matchLabels:
                          app: rabbitmq-ha
            volumes:
              - name: config
                emptyDir: {}
              - name: configmap
                configMap:
                  name: rmq-rabbitmq-ha
              - name: definitions
                secret:
                  secretName: rmq-rabbitmq-ha
                  items:
                  - key: definitions.json
                    path: definitions.json
        volumeClaimTemplates:
          - metadata:
              name: data
              annotations:
            spec:
              accessModes:
                - "ReadWriteOnce"
              resources:
                requests:
                  storage: "8Gi"
              storageClassName: "portworx-rabbitmq"
      _EOF
      ```

      ```output
      service/rmq-rabbitmq-ha-discovery created
      service/rmq-rabbitmq-ha created
      statefulset.apps/rmq-rabbitmq-ha created
      ```

    Note that the last line of the spec references the `portworx-rabbitmq` storage class defined in the [Create a StorageClass](#create-a-storageclass) section. As a result, Kubernetes will automatically create a new PVC for each replica.

## Validate the cluster functionality

Once you've set up RabbitMQ manually or using Helm, you can test your installation using a tool called [PerfTest](https://rabbitmq.github.io/rabbitmq-perf-test/stable/htmlsingle/). In the next sections, we will use PerfTest to:

* simulate basic workloads
* measure the performance of the system
* introduce a failure and see how the cluster recovers from it.

### Create a RabbitMQ policy for H/A

Configure a policy named `perf-test-with-ha`  with the following settings:

*  The `rabbitmqctl set_policy perf-test-with-ha '^perf-test'` portion of the command only applies these settings to queues that begin with `perf-test`
* Sets the [ha-mode parameter](https://www.rabbitmq.com/ha.html#mirroring-arguments) equal to `2`.
* Places the [queue-masters](https://www.rabbitmq.com/ha.html#behaviour) on the least-loaded node.
* Sets up the queues as [lazy](https://www.rabbitmq.com/lazy-queues.html). RabbitMQ will save the queues to disk as early as possible.

```text
kubectl exec rmq-rabbitmq-ha-0 -- \
  rabbitmqctl set_policy perf-test-with-ha '^perf-test' \
'{
  "ha-mode":"exactly",
  "ha-params":2,
  "ha-sync-mode":"automatic",
  "queue-master-locator":"min-masters",
  "queue-mode":"lazy"
}' --apply-to queues
```

```output
Setting policy "perf-test-with-ha" for pattern "^perf-test" to "{
  "ha-mode":"exactly",
  "ha-params":2,
  "ha-sync-mode":"automatic",
  "queue-master-locator":"min-masters",
  "queue-mode":"lazy"
}" with priority "0" for vhost "/" ...
```

### Set up monitoring

RabbitMQ provides a web-based [user interface](https://www.rabbitmq.com/management.html) that you can use to manage your cluster. To access it, you must forward connections made to a local port to the 15672 port on the `rmq-rabbitmq-ha-0` Pod.

1. Enter the following `kubectl port-forward` command to forward all connections made to `localhost:15672` to `rmq-rabbitmq-ha-0:15672`:

      ```text
      kubectl port-forward rmq-rabbitmq-ha-0 15672:15672
      ```

      ```output
      Forwarding from 127.0.0.1:15672 -> 15672
      ```

2. You can now access the RabbitMQ user interface by pointing your browser to `localhost:1567`. Use the credentials created in the [Set up RabbitMQ using Helm](#set-up-rabbitmq-using-helm) section.

3. Visit the Queue section at your localhost: `http://127.0.0.1:15672/#/queues`, to see that the `perf-test-with-ha` policy is applied.

4. Additionally, you can stream to `stdout` the logs of the Pod that survives the failover test by entering the following command:

      ```text
      kubectl logs -f rmq-rabbitmq-ha-0
      ```

### Create a containerized testing environment

The following `kubectl run` command creates a Pod with a sleeping container that runs for an hour (see the `"args": ["-c", "sleep 3600"]` line). Then, Kubernetes automatically restarts the container (see the `--restart=Always` line).

```text
kubectl run perftest \
  --restart=Always \
  --image dummy-required-param \
  --generator=run-pod/v1 \
  --overrides \
'{
  "spec": {
    "affinity": {
      "podAntiAffinity": {
        "requiredDuringSchedulingIgnoredDuringExecution": [{
          "labelSelector": {
            "matchExpressions": [{
              "key": "app",
              "operator": "In",
              "values": ["rabbitmq-ha"]
            }]
          },
          "topologyKey": "kubernetes.io/hostname"
        }]
      }
    },
    "containers": [{
      "command": ["sh"],
      "image": "pivotalrabbitmq/perf-test:latest",
      "name": "perftest",
      "args": ["-c", "sleep 3600"]
    }],
    "securityContext": {
      "runAsUser": 1000
    }
  }
}'
```

```output
pod/perftest created
```

{{<info>}}
Note that the above command creates a Pod with one sleeping container. The Pod is then scheduled onto a node that doesn't run RabbitMQ. This way, you evenly distribute bandwidth between both RabbitMQ nodes. 
Also note that we use a non-root user to run the commands. This is useful for when you have [`PodSecurityPolicies`](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) enabled.
{{</info>}}

### Simulate basic workloads

To start the simulated producers and consumers, run the `bin/runjava` command in the `perftest` container:

```text
kubectl exec -it perftest -- \
    bin/runjava com.rabbitmq.perf.PerfTest \
      --time 900 \
      --queue-pattern 'perf-test-%d' \
      --queue-pattern-from 1 \
      --queue-pattern-to 2 \
      --producers 2 \
      --consumers 8 \
      --queue-args x-cancel-on-ha-failover=true \
      --flag persistent \
      --uri amqp://admin:secretpassword@rmq-rabbitmq-ha:5672?failover=failover_exchange
```

There are several things to note about this example:

* Runs the session for 15 minutes with queues named in the format of `perf-test-` followed by a number (in our case `1` and `2`)
* Creates threads for 2 producers and 8 consumers (so theoretically each RabbitMQ replica hosts 1 queue and gets 1 producer and 4 consumers
* Trades off performance for reliability, by flagging the messages as persistent

### Failover

Simulate a failure by force deleting the `rmq-rabbitmq-ha-1` Pod:

```text
kubectl delete pod rmq-rabbitmq-ha-1 --force --grace-period=0
```

```output
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "rmq-rabbitmq-ha-1" force deleted
```

As the system recovers from the failure, you will see that the performance testing session will pause for a short period. As a result, the messages will pile up in the queue. After the failover, the cluster resumes normal processing, and no messages are lost. 

## Clean up

If you used Helm to install the RabbitMQ cluster, then enter the following command to remove all the Kubernetes components and delete the release:

```text
helm delete --purge rmq
```

If you installed the RabbitMQ cluster manually, then enter the following command to delete all the associated resources:

```text
kubectl delete sts/rmq-rabbitmq-ha \
  svc/rmq-rabbitmq-ha svc/rmq-rabbitmq-ha-discovery \
  rolebinding/rmq-rabbitmq-ha \
  role/rmq-rabbitmq-ha \
  sa/rmq-rabbitmq-ha \
  secret/rmq-rabbitmq-ha \
  cm/rmq-rabbitmq-ha
```

Finally, regardless of the deployment method, execute the following command:

```text
kubectl delete pvc/data-rmq-rabbitmq-ha-0 pvc/data-rmq-rabbitmq-ha-1 \
  sc/portworx-rabbitmq \
  po/perftest
```

These `kubectl delete` commands remove the following:

 * The workload itself (StatefulSet and the associated services)
 * The RBAC settings for the workload (Rolebinding, Role, and ServiceAccount)
 * The RBAC configuration (ConfigMap and secret)
 * The volumes including data (PersistentVolumeClaims)
 * The volume parameters (StorageClass)
 * The Pod we used for testing


<!--
## Summary

Software as critical to distributed systems as RabbitMQ is to many of its users _needs_ to be set up in a reliable way.  Portworx is a key ingredient to achieve that goal, as demonstrated in this document.

{{<info>}}
It should be understood that regardless of which storage solution is used, the goal of reliability  trades off some performance, by necessity of disk-IO being in the critical path of message processing.  While for highest performance messages can be handled entirely inside memory (which admittedly is orders of magnitudes faster), using that approach reliability would be partially sacrificed and limiting as memory is a far more finite resource than disk.
{{</info>}}

-->
