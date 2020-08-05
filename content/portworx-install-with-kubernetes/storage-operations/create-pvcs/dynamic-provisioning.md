---
title: Dynamic Provisioning of PVCs
weight: 3
linkTitle: Dynamic Provisioning of PVCs
keywords: dynamic provisioning, PVC, storage class, StatefulSets, Kubernetes, k8s
description: Learn how to use dynamically provisioned Portworx volumes with Kubernetes
series: k8s-vol
---

This document describes how to dynamically provision a volume using Kubernetes and Portworx.

### Using Dynamic Provisioning
Using Dynamic Provisioning and Storage Classes you don't need to create Portworx volumes out of band and they will be created automatically.
Using Storage Classes objects an admin can define the different classes of Portworx Volumes that are offered in a cluster. Following are the different parameters that can be used to define a Portworx Storage Class

| Name              	| Description                                                                                                                                                                                                                                                            	| Example                	|
|-------------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|------------------------	|
| fs                	| Filesystem to be laid out: xfs\|ext4                                                                                                                                                                                                                               	| fs: "ext4"               	|
| block_size        	| Block size                                                                                                                                                                                                                                                             	| block_size: "32k"        	|
| repl              	| Replication factor for the volume: 1\|2\|3                                                                                                                                                                                                                                	| repl: "3"                	|
| shared            	| Flag to create a globally shared namespace volume which can be used by multiple pods                                                                                                                                                                                   	| shared: "true"         	|
| priority_io       	| IO Priority: low\|medium\|high                                                                                                                                                                                                                                           	| priority_io: "high"    	|
| io_profile       	| Overrides the I/O algorithm Portworx uses for a volume. The following values are supported: <ul><li> [db_remote](/install-with-other/operate-and-maintain/performance-and-tuning/tuning#the-db-remote-profile) <li> [sequential](/install-with-other/operate-and-maintain/performance-and-tuning/tuning#the-sequential-profile) <li> [random](/install-with-other/operate-and-maintain/performance-and-tuning/tuning#the-random-profile) <li> [cms](/install-with-other/operate-and-maintain/performance-and-tuning/tuning#cms)<li> [sync_shared](/install-with-other/operate-and-maintain/performance-and-tuning/tuning#the-sync-shared-profile)</ul>                                                                                                                                                                                                                                      	| io_profile: "db_remote"    	|
| group             	| The group a volume should belong too. Portworx will restrict replication sets of volumes of the same group on different nodes. If the force group option 'fg' is set to true, the volume group rule will be strictly enforced. By default, it's not strictly enforced. 	| group: "volgroup1"       	|
| fg                	| This option enforces volume group policy. If a volume belonging to a group cannot find nodes for it's replication sets which don't have other volumes of same group, the volume creation will fail.                                                                    	| fg: "true"             	|
| label             	| List of comma-separated name=value pairs to apply to the Portworx volume                                                                                                                                                                                               	| label: "name=mypxvol"    	|
| nodes             	| Comma-separated Portworx Node ID's to use for replication sets of the volume                                                                                                                                                                                           	| nodes: "minion1,minion2" 	|
| aggregation_level 	| Specifies the number of replication sets the volume can be aggregated from                                                                                                                                                                                             	| aggregation_level: "2"   	|
| snap_schedule     	| Snapshot schedule. Following are the accepted formats:<br><br>periodic=_mins_,_snaps-to-keep_ <br>daily=_hh:mm_,_snaps-to-keep_ <br>weekly=_weekday@hh:mm_,_snaps-to-keep_  <br>monthly=_day@hh:mm_,_snaps-to-keep_<br><br> _snaps-to-keep_ is optional. Periodic, Daily, Weekly and Monthly keep last 5, 7, 5 and 12 snapshots by default respectively.          	| snap_schedule: periodic=60,10<br><br>snap_schedule: daily=12:00,4<br><br>snap_schedule: weekly=sunday@12:00,2<br><br>snap_schedule: monthly=15@12:00     	|
| snap_interval     	| Snapshot interval in minutes. 0 disables snaps. Minimum value: 60. It is recommended to use snap_schedule above.                                                                                                                                                                      	| snap_interval: "120"     	|
| sticky     	| Flag to create sticky volumes that cannot be deleted until the flag is disabled                                                                                                                                                                                                      	| sticky: "true"     	|
| journal     	| Flag to indicate if you want to use journal device for the volume's data. This will use the journal device that you used when installing Portworx. This is useful to absorb frequent syncs from short bursty workloads. Default: false                                                                                                                                                                                             	| journal: "true"     	|
| secure | Flag to create an encrypted volume. For details about how you can create encrypted volumes, see the [Create encrypted PVCs](/portworx-install-with-kubernetes/storage-operations/create-pvcs/create-encrypted-pvcs/) page.| secure: "true" |
| snapshotschedule.<br>stork.<br>libopenstorage.<br>org | Flag to create scheduled snapshots with Stork. For details about how you can create scheduled snapshots with Stork, see the [Scheduled snapshots](/portworx-install-with-kubernetes/storage-operations/create-snapshots/scheduled/) page. | |
| stork.<br>libopenstorage.<br>org/<br>preferLocalNodeOnly | This flag enforces a pod to be scheduled on the same node as a replica. | stork.<br>libopenstorage.<br>org/<br>preferLocalNodeOnly : "true" |

{{<info>}}
**NOTE:** For the list of Kubernetes-specific parameters that you can use with a Portworx Storage class, see the [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) page of the Kubernetes documentation.
{{</info>}}

### Provision volumes
#### Step 1: Create Storage Class.

Create the storageclass:

```text
kubectl create -f examples/volumes/portworx/portworx-sc.yaml
```

Example:

```text
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
```
[Download example](/samples/k8s/portworx-volume-sc.yaml?raw=true)

Verifying storage class is created:

```text
kubectl describe storageclass portworx-sc
```

```output
     Name: 	        	portworx-sc
     IsDefaultClass:	        No
     Annotations:		<none>
     Provisioner:		kubernetes.io/portworx-volume
     Parameters:		repl=1
     No events.
```

#### Step 2: Create Persistent Volume Claim.

Creating the persistent volume claim:

```text
kubectl create -f examples/volumes/portworx/portworx-volume-pvcsc.yaml
```

Example:

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvcsc001
  annotations:
    volume.beta.kubernetes.io/storage-class: portworx-sc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```
[Download example](/samples/k8s/portworx-volume-pvcsc.yaml?raw=true)

Verifying persistent volume claim is created:

```text
kubectl describe pvc pvcsc001
```

```output
Name:	      	pvcsc001
Namespace:      default
StorageClass:   portworx-sc
Status:	      	Bound
Volume:         pvc-e5578707-c626-11e6-baf6-08002729a32b
Labels:	      	<none>
Capacity:	    2Gi
Access Modes:   RWO
No Events.
```
Persistent Volume is automatically created and is bounded to this pvc.

Verifying persistent volume claim is created:

```text
kubectl describe pv pvc-e5578707-c626-11e6-baf6-08002729a32b
```

```output
Name: 	      	pvc-e5578707-c626-11e6-baf6-08002729a32b
Labels:        	<none>
StorageClass:  	portworx-sc
Status:	      	Bound
Claim:	      	default/pvcsc001
Reclaim Policy: 	Delete
Access Modes:   	RWO
Capacity:	        2Gi
Message:
Source:
Type:	      	PortworxVolume (a Portworx Persistent Volume resource)
VolumeID:   	374093969022973811
No events.
```

#### Step 3: Create Pod which uses Persistent Volume Claim with storage class.

Create the pod:

```text
kubectl create -f examples/volumes/portworx/portworx-volume-pvcscpod.yaml
```

Example:

```text
apiVersion: v1
kind: Pod
metadata:
  name: pvpod
spec:
  containers:
  - name: test-container
    image: gcr.io/google_containers/test-webserver
    volumeMounts:
    - name: test-volume
      mountPath: /test-portworx-volume
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: pvcsc001
```
[Download example](/samples/k8s/portworx-volume-pvcscpod.yaml?raw=true)

Verifying pod is created:

```text
kubectl get pod pvpod
```

```output
NAME      READY     STATUS    RESTARTS   AGE
pvpod       1/1     Running   0          48m
```

{{<info>}}To access PV/PVCs with a non-root user refer [here](/portworx-install-with-kubernetes/storage-operations/create-pvcs/access-via-non-root-users)
{{</info>}}

### Delete volumes
For dynamically provisioned volumes using StorageClass and PVC (PersistenVolumeClaim), if a PVC is deleted, the corresponding Portworx volume will also get deleted. This is because Kubernetes, for PVC, creates volumes with a reclaim policy of deletion. So the volumes get deleted on PVC deletion.

To delete the PVC and the volume, you can run `kubectl delete -f <pvc_spec_file.yaml>`
