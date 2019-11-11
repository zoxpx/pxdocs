---
title: RabbitMQ with Portworx on Kubernetes
linkTitle: RabbitMQ
keywords: portworx, container, Kubernetes, rabbitMQ, storage, Docker, k8s, pvc
description: See how RabbitMQ can be deployed on Kubernetes using Portworx volumes.
weight: 2
noicon: true
---

[RabbitMQ](https://www.rabbitmq.com/) is an open-source message broker.  It plays a central role in many distributed systems.  You can configure RabbitMQ to safely pass messages between decoupled systems.

This reference architecture document shows how you can create and run RabbitMQ with Portworx on Kubernetes. This way, Portworx will provide a reliable persistent storage layer, which makes sure no messages are lost.

The RabbitMQ cluster will use [mirrored queues](https://www.rabbitmq.com/ha.html) to persist data and metadata to Portworx volumes. Portworx also replicates the volumes, providing multiple layers of redundancy.

## Prerequisites

* You must have a Kubernetes cluster with a minimum of 3 worker nodes.
* Portworx is installed on your Kubernetes cluster. For more details on how to install Portworx, refer to the instructions from the [Portworx on Kubernetes](/portworx-install-with-kubernetes/) page.
* (Optional) Helm in installed on your Kubernetes cluster. Refer to the [Helm Quickstart Guide](https://helm.sh/docs/using_helm/#quickstart) for details about how to install Helm.

## Create a StorageClass

RabbitMQ will first need a [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) definition that sets the Portworx storage parameters for volume-creation, which are later attached to the pods that will be created.

This _StorageClass_ will be referenced by a [PersistentVolumeClaims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) created later in this document.  The PersistentVolume created by that is then used by the RabbitMQ cluster pods.

1. The spec below creates a `StorageClass` with 3 replicas and uses a high-priority storage pool:

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
...
storageclass.storage.k8s.io/portworx-rabbitmq created
```

For details about the Portworx-specific parameters, refer to the [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) section.

{{<info>}}
If you're using Portworx with CSI, you need to set the value of the `provisioner` parameter to `pxd.portworx.com`.
{{</info>}}

When you install RabbitMQ with Portworx on Kubernetes, you can choose one of the following options:
* Set up RabbitMQ using [Helm](https://helm.sh)]
* Set up RabbitMQ manually

Setup RabbitMQ (using Helm)

### Helm

A complex application like RabbitMQ relies on several YAML files to define its various components. The next chapter will show how you can use Helm to simplify the deployment of RabbitMQ.

The following Helm command uses the [RabbitMQ High Available](https://github.com/helm/charts/tree/master/stable/rabbitmq-ha) Helm chart to create a [release](https://github.com/helm/helm/blob/release-2.14/docs/glossary.md#release) named rmq. This will create a two-member RabbitMQ cluster, and Portworx will mirror queues and messages between the nodes.


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

..to which, after a minute or two, you should get back the a response from Helm confirming success and specifics of the release we created (including details of how it is configured/accessed):

```output
...
Release "rmq" does not exist. Installing it now.

NAME: rmq
LAST DEPLOYED: Mon Oct 14 16:58:20 2019
NAMESPACE: default
STATUS: DEPLOYED
...
```

Other than specifying that this should be a two-replica [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/), it is worth mentioning that it is _here_ we referenced that StorageClass we defined above, and we also have specify a few dummy credentials (which are insecure and should _not_ be used in anything but a testing environment).

Alternatively, the following section describes how to manually do what helm did for us above.

## Setup RabbitMQ manually

In this section we will instead take the classic approach of including here all the various yaml definitions needed to set up RabbitMQ.

{{<info>}}
The contents of the yaml used below, are largely based on what the [RabbitMQ chart](https://github.com/helm/charts/tree/master/stable/rabbitmq-ha) [templates](https://github.com/helm/charts/tree/master/stable/rabbitmq-ha/templates) create when using Helm.
{{</info>}}

### Configuration and credentials

First we will set-up a [ConfigMap and Secret](https://kubernetes.io/blog/2016/04/configuration-management-with-containers/) that will configure how RabbitMQ starts up and "secure" it with the same dummy credentials.

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
...
configmap/rmq-rabbitmq-ha created
secret/rmq-rabbitmq-ha created
```

{{<info>}}
The above credentials are the same dummy (insecure) credentials as mentioned above in the previous approach that utilized helm.
{{</info>}}

### RBAC for RabbitMQ

This section will set up RBAC-related objects for the workloads we'll define in the [next section](#rabbitmq-cluster).

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
...
serviceaccount/rmq-rabbitmq-ha created
role.rbac.authorization.k8s.io/rmq-rabbitmq-ha created
rolebinding.rbac.authorization.k8s.io/rmq-rabbitmq-ha created
```

### RabbitMQ cluster

Here we're finally launching the workload definition, which consists of the StatefulSet and some supporting Services.

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
...
service/rmq-rabbitmq-ha-discovery created
service/rmq-rabbitmq-ha created
statefulset.apps/rmq-rabbitmq-ha created
```

You may have spotted that the last line reference that StorageClass created near the beginning of this document.  As a result of the `volumeClaimTemplate` section, a new PersistentVolumeClaim will also be created automatically by Kubernetes for each replica.

## Post-install validation testing

Regardless of the method we used to setup RabbitMQ in Kubernetes, we should now be able to control and test our RabbitMQ cluster.

We will use [PerfTest](https://rabbitmq.github.io/rabbitmq-perf-test/stable/htmlsingle/), a testing suite bundled with RabbitMQ, to simulate broker use, measure performance of the system and perform failover testing.

### Example RabbitMQ policy for H/A

First we will configure a queue-policy named `perf-test-with-ha` to:

  * match only queues that begin with `perf-test`
  * set the [ha-mode parameter](https://www.rabbitmq.com/ha.html#mirroring-arguments) to be exactly 2
  * locate the [queue-masters](https://www.rabbitmq.com/ha.html#behaviour) on whichever is the least loaded node
  * finally set up these queues to be [_lazy_](https://www.rabbitmq.com/lazy-queues.html), which will make them want to use storage for persistance early/automatically

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
...
}" with priority "0" for vhost "/" ...
```

### Monitoring

RabbitMQ has a wonderful enabled-by-default [plugin for a web-UI](https://www.rabbitmq.com/management.html) that can be accessed by port-forwarding port 15672 to your local system.  It is useful to have this loaded during the testing to monitor the system.

```text
kubectl port-forward rmq-rabbitmq-ha-0 15672:15672
```

```output
Forwarding from 127.0.0.1:15672 -> 15672
...
```

At this point you should be able to hit TCP port 15672 on [_localhost_](http://127.0.0.1:15672) in your web browser, and see the RabbitMQ WebUI.  You can use the credentials referenced [earlier](#launching-rabbitmq-release) in this document to log in, and explore.   If you then visit the [Queue section](http://127.0.0.1:15672/#/queues),  once the performance test starts and the queues are created, you should see the policy we setup be applied as well.

Additionally, one can examine the log-messages of the pod that will survive the failover test:

```text
kubectl logs -f rmq-rabbitmq-ha-0
```

This will show (after the pod has started) the log-messages from the container live.

### Containerized testing environment

Here we spawn a pod with one container which will allow us to run PerfTest in the [_next_ step](#simulate-broker-usage):

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
...
pod/perftest created
```

A pod with a sleeping container is started on one of the _other_ nodes (that _aren't_ running RabbitMQ).  This container runs for an hour (by sleeping 3600 seconds) and always restart when finished.   We also specify a non-root user to run this environment as, since your cluster may have PodSecurityPolicies enabled.  In the next step we will `kubectl exec` into this pod.

### Simulate Broker Usage

Now we're ready to start up the simulated producers/consumers inside the pre-existing pod's container from the [previous step](#containerized-testing-environment).

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

..to which you should get back the output of the utility itself.

The test-suite's parameters themselves do the following:
* run the session for 15 minutes with queues named in the format of `perf-test-` followed by a number (in our case `1` and `2`)
* create threads for 2 producers and 8 consumers (so theoretically each of the two rabbitmq replicas should host 1 queue and get 1 producers and 4 consumers
* set messages to be flagged as persistent (so will always involve IO which should be understood that this trades off performance for reliabilty)
* use the queue with the sample credentials, at the expected address from the previously defined service (and is internal to the kubernetes cluster)

### Failover

Here we can create a scenario for failure, such as killing one of the pods.

```text
kubectl delete pod rmq-rabbitmq-ha-1 --force --grace-period=0
```

```output
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "rmq-rabbitmq-ha-1" force deleted
```

The performance testing session may pause momentarily (and messages in the queue pile up) as the system recovers from the failure, the queue fails-over eventualy resume with no messages being lost (presuming enough time remains during testing, for all the the testing consumers to catch up).

## Cleaning up

If helm was used, cleaning is as easy as first running:

```text
helm delete --purge rmq
```

Otherwise we need to manually delete all the created created resources from our cluster, by running:

```text
kubectl delete sts/rmq-rabbitmq-ha \
  svc/rmq-rabbitmq-ha svc/rmq-rabbitmq-ha-discovery \
  rolebinding/rmq-rabbitmq-ha \
  role/rmq-rabbitmq-ha \
  sa/rmq-rabbitmq-ha \
  secret/rmq-rabbitmq-ha \
  cm/rmq-rabbitmq-ha
```

Finally (regardless of deployment method), we throw away the data-volumes, volume-param definition and perftest pod by running:

```text
kubectl delete pvc/data-rmq-rabbitmq-ha-0 pvc/data-rmq-rabbitmq-ha-1 \
  sc/portworx-rabbitmq \
  po/perftest
```

The above deletes the...

  * workload itself (statefulset/services)
  * RBAC for the workload (rolebinding/role/serviceaccount)
  * configuration (configmap/secret)
  * storage volumes including data (persistentvolumeclaims)
  * volume parameters (storageclass)
  * pod we simulated broker use from (pod)

At this point you could, if you wanted to, start all over from the beginning of this document.

## Summary

Software as critical to distributed systems as RabbitMQ is to many of its users _needs_ to be set up in a reliable way.  Portworx is a key ingredient to achieve that goal, as demonstrated in this document.

{{<info>}}
It should be understood that regardless of which storage solution is used, the goal of reliability  trades off some performance, by necessity of disk-IO being in the critical path of message processing.  While for highest performance messages can be handled entirely inside memory (which admittedly is orders of magnitudes faster), using that approach reliability would be partially sacrificed and limiting as memory is a far more finite resource than disk.
{{</info>}}
