---
title: Solr on Kubernetes on Portworx
linkTitle: Solr
keywords: portworx, container, Kubernetes, ,Solr, storage, Docker, k8s, pvc
description: See how stateful Solr can be deployed on Kubernetes using Portworx volumes.
weight: 8
noicon: true
---

The examples provided create a Solr cluster running in Kubernetes, which uses Portworx volumes for zookeeper and Solr data.

## Portworx StorageClass for Volume provisioning
Check your cluster nodes
```text
kubectl get nodes -o wide
```
```output
 NAME                           STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION              CONTAINER-RUNTIME
ravi-blr-dev-dour-shoulder-0   Ready    master   44d   v1.14.1   70.0.87.119   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
ravi-blr-dev-dour-shoulder-1   Ready    <none>   44d   v1.14.1   70.0.87.82    <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
ravi-blr-dev-dour-shoulder-2   Ready    <none>   44d   v1.14.1   70.0.87.118   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
ravi-blr-dev-dour-shoulder-3   Ready    <none>   44d   v1.14.1   70.0.87.120   <none>        CentOS Linux 7 (Core)   3.10.0-862.3.2.el7.x86_64   docker://18.9.6
```
Define StorageClass.
```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "2"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
```
Apply the StorageClass configuration
```text
kubectl apply -f portworx-sc.yml
```

## Install Zookeeper cluster
Zookeeper ensemble is used for managing the confinguration for Solr.
Define config properties for zookeeper configmap zk-config.properties.
```text
zooLogDir=/store/logs
zooDataLogDir=/store/datalog
zooDataDir=/store/data
zooStandaloneEnabled=false
zooServers=server.1=zk-0.zkensemble:2888:3888 server.2=zk-1.zkensemble:2888:3888 server.3=zk-2.zkensemble:2888:3888
```
Create a configmap
```text
kubectl create configmap zookeeper-ensemble-config --from-env-file=zk-config.properties
```
The Spec below deines a headless service, PodDisruptionBudget and zookeeper statefulset.
```text
apiVersion: v1
kind: Service
metadata:
  name: zkensemble
  labels:
    app: zookeeper-app
spec:
  clusterIP: None
  selector:
    app: zookeeper-app
---
apiVersion: v1
kind: Service
metadata:
  name: zk-service
  labels:
    app: zookeeper-app
spec:
  ports:
  - protocol: TCP
    port: 2181
    targetPort: 2181
  type: LoadBalancer
  selector:
    app: zookeeper-app
---
apiVersion: v1
kind: Service
metadata:
  name: zk-headless
  labels:
    app: zk-headless
spec:
  ports:
  - port: 2888
    name: server
  - port: 3888
    name: leader-election
  clusterIP: None
  selector:
    app: zk
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: zk-config
data:
  ensemble: "zk-0;zk-1;zk-2"
  jvm.heap: "2G"
  tick: "2000"
  init: "10"
  sync: "5"
  client.cnxns: "60"
  snap.retain: "3"
  purge.interval: "1"
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: zk-budget
spec:
  selector:
    matchLabels:
      app: zk
  minAvailable: 2
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: zk
spec:
  selector:
    matchLabels:
      app: zk
  serviceName: zk-headless
  replicas: 3
  template:
    metadata:
      labels:
        app: zk
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      # Use the stork scheduler to enable more efficient placement of the pods
      schedulerName: stork
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/enabled
                operator: NotIn
                values:
                - "false"
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "app"
                    operator: In
                    values:
                    - zk-headless
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: k8szk
        imagePullPolicy: Always
        image: gcr.io/google_samples/k8szk:v1
        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
        env:
        - name : ZK_ENSEMBLE
          valueFrom:
            configMapKeyRef:
              name: zk-config
              key: ensemble
        - name : ZK_HEAP_SIZE
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: jvm.heap
        - name : ZK_TICK_TIME
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: tick
        - name : ZK_INIT_LIMIT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: init
        - name : ZK_SYNC_LIMIT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: tick
        - name : ZK_MAX_CLIENT_CNXNS
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: client.cnxns
        - name: ZK_SNAP_RETAIN_COUNT
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: snap.retain
        - name: ZK_PURGE_INTERVAL
          valueFrom:
            configMapKeyRef:
                name: zk-config
                key: purge.interval
        - name: ZK_CLIENT_PORT
          value: "2181"
        - name: ZK_SERVER_PORT
          value: "2888"
        - name: ZK_ELECTION_PORT
          value: "3888"
        command:
        - sh
        - -c
        - zkGenConfig.sh && zkServer.sh start-foreground
        readinessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        volumeMounts:
        - name: datadir
          mountPath: /var/lib/zookeeper
      securityContext:
        runAsUser: 1000
        fsGroup: 1000
  volumeClaimTemplates:
  - metadata:
      name: datadir
      annotations:
        volume.beta.kubernetes.io/storage-class: portworx-sc
    spec:
      storageClassName: portworx-sc
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 2Gi
```
Apply the above configuration
```text
kubectl create -f zookeeper-ensemble.yml
```
## Post Zookeeper install
Verify the zookeeper pods are up and running with Portworx volumes
```text
kubectl get pods
```
```output
NAME       READY   STATUS              RESTARTS   AGE
zk-0       1/1     Running             0          39m
zk-1       1/1     Running             0          6h16m
zk-2       1/1     Running             0          6h15m
```
Check pvc
```text
kubectl get pvc
```
```output
[root@ravi-blr-dev-dour-shoulder-0 ~]# kubectl get pvc
NAME                   STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
datadir-zk-0           Bound         pvc-492cc607-db62-11e9-a83a-000c29886e3e   2Gi        RWO            portworx-sc    6h14m
datadir-zk-1           Bound         pvc-556adfd1-db62-11e9-a83a-000c29886e3e   2Gi        RWO            portworx-sc    6h13m
datadir-zk-2           Bound         pvc-6dca0c3b-db62-11e9-a83a-000c29886e3e   2Gi        RWO            portworx-sc    6h13m
```
Check statefulset
```text
kubectl get sts
```
```output
NAME     READY   AGE
zk       3/3     6h17m
```
Observe that volumes are bound to zookeeper pods.
```text
pxctl volume inspect pvc-492cc607-db62-11e9-a83a-000c29886e3e 
```
```output
Volume	:  534644031852659169
	Name            	 :  pvc-492cc607-db62-11e9-a83a-000c29886e3e
	Size            	 :  2.0 GiB
	Format          	 :  ext4
	HA              	 :  2
	IO Priority     	 :  LOW
	Creation time   	 :  Sep 20 04:51:19 UTC 2019
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: acba9a03-6781-4962-8f7c-3507eafa45ea (70.0.87.118)
	Device Path     	 :  /dev/pxd/pxd534644031852659169
	Labels          	 :  repl=2,namespace=default,pvc=datadir-zk-0
	Reads           	 :  59
	Reads MS        	 :  60
	Bytes Read      	 :  1126400
	Writes          	 :  21
	Writes MS       	 :  103
	Bytes Written   	 :  172032
	IOs in progress 	 :  0
	Bytes used      	 :  896 KiB
	Replica sets on nodes:
		Set 0
		  Node 		 : 70.0.87.120 (Pool 1)
		  Node 		 : 70.0.87.118 (Pool 2)
	Replication Status	 :  Up
	Volume consumers	 : 
		- Name           : zk-0 (787278d3-db91-11e9-a83a-000c29886e3e) (Pod)
		  Namespace      : default
		  Running on     : ravi-blr-dev-dour-shoulder-2
		  Controlled by  : zk (StatefulSet)
```
Verify that zookeeper ensemble is working.
```text
kubectl exec zk-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar
```
```output
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
Created /foo
```
```text
kubectl exec zk-2 -- /opt/zookeeper/bin/zkCli.sh get /foo
```
```output
WATCHER::

WatchedEvent state:SyncConnected type:None path:null
cZxid = 0x200000002
bar
ctime = Thu Sep 19 05:23:10 UTC 2019
mZxid = 0x200000002
mtime = Thu Sep 19 05:23:10 UTC 2019
pZxid = 0x200000002
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```
## Install Solr
Define config properties for solr configmap solr-config.properties.
```text
solrHome=/store/data
solrPort=8983
zkHost=zk-0.zkensemble:2181,zk-1.zkensemble:2181,zk-2.zkensemble:2181
solrLogsDir=/store/logs
solrHeap=1g
```
Create configmap solr-cluster-config.
```text
kubectl create -f configmap solr-cluster-config --from-env-file=solr-config.properties
```
The following spec defines solr service, PodDisruptionBudget, 2 node solr cluster.
```text
apiVersion: v1
kind: Service
metadata:
  name: solrcluster
  labels:
    app: solr-app
spec:
  clusterIP: None
  selector:
    app: solr-app
---
apiVersion: v1
kind: Service
metadata:
  name: solr-service
  labels:
    app: solr-app
spec:
  ports:
  - protocol: TCP
    port: 8983
    targetPort: 8983
  type: LoadBalancer
  selector:
    app: solr-app
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: solr
spec:
  selector:
    matchLabels:
      app: solr-app # has to match .spec.template.metadata.labels
  serviceName: "solrcluster"
  replicas: 2 # by default is 1
  template:
    metadata:
      labels:
        app: solr-app # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      restartPolicy: Always
      containers:
      - name: solr
        image: solr:8.1.1
        imagePullPolicy: IfNotPresent
        readinessProbe:
          tcpSocket:
            port: 8983
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: 8983
          initialDelaySeconds: 15
          periodSeconds: 20
        volumeMounts:
        - name: volsolr
          mountPath: /store
        ports:
        - name: solrport
          containerPort: 8983
        env:
          - name: MY_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MY_POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: MY_POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: SOLR_HOME
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: solrHome
          - name: ZK_HOST
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: zkHost
          - name: POD_HOST_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: SOLR_HOST
            value: "$(POD_HOST_NAME).solrcluster"
          - name: SOLR_LOGS_DIR
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: solrLogsDir
          - name: SOLR_HEAP
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: solrHeap
      initContainers:
      - name: init-solr-data
        image: busybox
        command:
        - "/bin/sh"
        - "-c"
        - "if [ ! -d $SOLR_HOME/lib ] ; then mkdir -p $SOLR_HOME/lib && chown -R 8983:8983 $SOLR_HOME ; else true; fi"
        env:
          - name: SOLR_HOME
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: solrHome
        volumeMounts:
        - name: volsolr
          mountPath: /store
      - name: init-solr-logs
        image: busybox
        command:
        - "/bin/sh"
        - "-c"
        - "if [ ! -d $SOLR_LOGS_DIR ] ; then mkdir -p $SOLR_LOGS_DIR && chown 8983:8983 $SOLR_LOGS_DIR ; else true; fi"
        env:
          - name: SOLR_LOGS_DIR
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: solrLogsDir
        volumeMounts:
        - name: volsolr
          mountPath: /store
      - name: init-solr-xml
        image: solr:8.1.1
        command:
        - "/bin/sh"
        - "-c"
        - "if [ ! -f $SOLR_HOME/solr.xml ] ; then cp /opt/solr/server/solr/solr.xml $SOLR_HOME/solr.xml;\
               sed -i \"s/<solr>/<solr><str name='sharedLib'>\\/store\\/data\\/lib<\\/str>/g\" $SOLR_HOME/solr.xml ; else true; fi "
        env:
          - name: SOLR_HOME
            valueFrom:
              configMapKeyRef:
                name: solr-cluster-config
                key: solrHome
        volumeMounts:
        - name: volsolr
          mountPath: /store
  volumeClaimTemplates:
  - metadata:
      name: volsolr
    spec:
      storageClassName: portworx-sc
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 32Gi
```
Apply above configuration.
```text
kubectl create -f solr-cluster.yml
```
## Post install status - Solr
Verify Solr resources created on the cluster.
```text
kubectl get pods
```
```output
NAME       READY   STATUS              RESTARTS   AGE
solr-0     1/1     Running             0          78m
solr-1     1/1     Running             0          106m
solr-2     1/1     Running             0          105m
zk-0       1/1     Running             0          5h41m
zk-1       1/1     Running             0          5h41m
zk-2       1/1     Running             0          28m
```
```text
kubectl get pvc
```
```output
NAME                   STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
datadir-zk-0           Bound         pvc-492cc607-db62-11e9-a83a-000c29886e3e   2Gi        RWO            portworx-sc    6h25m
datadir-zk-1           Bound         pvc-556adfd1-db62-11e9-a83a-000c29886e3e   2Gi        RWO            portworx-sc    6h25m
datadir-zk-2           Bound         pvc-6dca0c3b-db62-11e9-a83a-000c29886e3e   2Gi        RWO            portworx-sc    6h24m
volsolr-solr-0         Bound         pvc-2d10ff4f-db6c-11e9-a83a-000c29886e3e   32Gi       RWO            portworx-sc    5h14m
volsolr-solr-1         Bound         pvc-506f787d-db6c-11e9-a83a-000c29886e3e   32Gi       RWO            portworx-sc    5h13m
```
```text
pxctl volume list
```
```output
ID			NAME						SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS			SNAP-ENABLED	
865481696383214454	pvc-2d10ff4f-db6c-11e9-a83a-000c29886e3e	32 GiB	2	no	no		LOW		up - attached on 70.0.87.120	no
534644031852659169	pvc-492cc607-db62-11e9-a83a-000c29886e3e	2 GiB	2	no	no		LOW		up - attached on 70.0.87.118	no
416426097321211582	pvc-506f787d-db6c-11e9-a83a-000c29886e3e	32 GiB	2	no	no		LOW		up - attached on 70.0.87.118	no
235013471273806575	pvc-556adfd1-db62-11e9-a83a-000c29886e3e	2 GiB	2	no	no		LOW		up - attached on 70.0.87.118	no
143480503226632164	pvc-6dca0c3b-db62-11e9-a83a-000c29886e3e	2 GiB	2	no	no		LOW		up - attached on 70.0.87.82	no
```
```text
pxctl volume inspect pvc-2d10ff4f-db6c-11e9-a83a-000c29886e3e 
```
```output
Volume	:  865481696383214454
	Name            	 :  pvc-2d10ff4f-db6c-11e9-a83a-000c29886e3e
	Size            	 :  32 GiB
	Format          	 :  ext4
	HA              	 :  2
	IO Priority     	 :  LOW
	Creation time   	 :  Sep 20 06:02:07 UTC 2019
	Shared          	 :  no
	Status          	 :  up
	State           	 :  Attached: fe471f15-d91c-4f94-900e-fdb2c8379541 (70.0.87.120)
	Device Path     	 :  /dev/pxd/pxd865481696383214454
	Labels          	 :  repl=2,volume.beta.kubernetes.io/storage-class=portworx-sc,namespace=default,pvc=volsolr-solr-0
	Reads           	 :  55
	Reads MS        	 :  24
	Bytes Read      	 :  1110016
	Writes          	 :  27
	Writes MS       	 :  241
	Bytes Written   	 :  249856
	IOs in progress 	 :  0
	Bytes used      	 :  4.8 MiB
	Replica sets on nodes:
		Set 0
		  Node 		 : 70.0.87.120 (Pool 2)
		  Node 		 : 70.0.87.118 (Pool 2)
	Replication Status	 :  Up
	Volume consumers	 : 
		- Name           : solr-0 (c49ce09c-db91-11e9-a83a-000c29886e3e) (Pod)
		  Namespace      : default
		  Running on     : ravi-blr-dev-dour-shoulder-3
		  Controlled by  : solr (StatefulSet)
```
## Failover - Replacing lost stateful replicas
### Scenario-1: Node down
We can see below the respective nodes on which solr pods are running and the Stateful Sets.
```text
kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name
```
```output
NODE                           NAME
ravi-blr-dev-dour-shoulder-3   solr-0
ravi-blr-dev-dour-shoulder-2   solr-1
ravi-blr-dev-dour-shoulder-2   zk-0
ravi-blr-dev-dour-shoulder-2   zk-1
ravi-blr-dev-dour-shoulder-1   zk-2
```
Check the stateful set status
```text
kubectl get sts
```
```output
NAME     READY   AGE
solr     2/2     5h19m
zk       3/3     6h30m
```
Now lets bring down the node which is hosting solr-0.
```text
kubectl drain ravi-blr-dev-dour-shoulder-3 --ignore-daemonsets --delete-local-data --force
```
Inspect the Stateful Sets and the pods and observe that solr StatefulSet is 1/2 and solr-0 has moved to node-1.
```text
kubectl get sts
```
```output
NAME     READY   AGE
solr     1/2     5h20m
zk       3/3     6h31m
```output
NAME     READY   AGE
solr     2/2     5h21m
zk       3/3     6h32m
```
```text
kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name
```
```output
NODE                           NAME
ravi-blr-dev-dour-shoulder-1   solr-0
ravi-blr-dev-dour-shoulder-2   solr-1
ravi-blr-dev-dour-shoulder-2   zk-0
ravi-blr-dev-dour-shoulder-2   zk-1
ravi-blr-dev-dour-shoulder-1   zk-2
```
Now lets bring back the node and observe the pod placements
```text
kubectl uncordon ravi-blr-dev-dour-shoulder-3
```
```text 
kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name
```
```output
NODE                           NAME
ravi-blr-dev-dour-shoulder-1   solr-0
ravi-blr-dev-dour-shoulder-2   solr-1
ravi-blr-dev-dour-shoulder-2   zk-0
ravi-blr-dev-dour-shoulder-2   zk-1
ravi-blr-dev-dour-shoulder-1   zk-2
```
### Scenario-2: Pod down
Now lets kill solr-0 and observe that solr-0 will reinitialize on its original node-3
```text
kubectl delete pod solr-0
```
```text 
kubectl get pods -o wide
```
```output
NAME       READY   STATUS              RESTARTS   AGE     IP              NODE                           NOMINATED NODE   READINESS GATES
solr-0     1/1     Running             0          2m17s   10.233.121.52   ravi-blr-dev-dour-shoulder-3   <none>           <none>
solr-1     1/1     Running             0          5h28m   10.233.127.65   ravi-blr-dev-dour-shoulder-2   <none>           <none>
zk-0       1/1     Running             0          62m     10.233.127.66   ravi-blr-dev-dour-shoulder-2   <none>           <none>
zk-1       1/1     Running             0          6h39m   10.233.127.64   ravi-blr-dev-dour-shoulder-2   <none>           <none>
zk-2       1/1     Running             0          6h39m   10.233.76.16    ravi-blr-dev-dour-shoulder-1   <none>           <none>
```
