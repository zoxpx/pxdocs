---
title: Dynamic Provisioning of PVCs
weight: 1
linkTitle: Dynamic Provisioning of PVCs
keywords: portworx, storage class, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk,StatefulSets
description: Learn how to use dynamically provisioned Portworx volumes with Kubernetes
series: k8s-vol
---

This document describes how to dynamically provision a volume using Kubernetes and Portworx.

### Using Dynamic Provisioning
Using Dynamic Provisioning and Storage Classes you don't need to create Portworx volumes out of band and they will be created automatically.
Using Storage Classes objects an admin can define the different classes of Portworx Volumes that are offered in a cluster. Following are the different parameters that can be used to define a Portworx Storage Class

{{% content "shared/portworx-install-with-kubernetes-volume-options.md" %}}

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

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: portworx-sc
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "1"
```
[Download example](/samples/k8s/portworx-volume-sc.yaml?raw=true)

Verifying storage class is created:

```
kubectl describe storageclass portworx-sc
     Name: 	        	portworx-sc
     IsDefaultClass:	        No
     Annotations:		<none>
     Provisioner:		kubernetes.io/portworx-volume
     Parameters:		repl=1
     No events.
```

#### Step 2: Create Persistent Volume Claim.

Creating the persistent volume claim:

```
kubectl create -f examples/volumes/portworx/portworx-volume-pvcsc.yaml
```

Example:

```yaml
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

```
kubectl describe pvc pvcsc001
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

```
kubectl describe pv pvc-e5578707-c626-11e6-baf6-08002729a32b
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

```
kubectl create -f examples/volumes/portworx/portworx-volume-pvcscpod.yaml
```

Example:

```yaml
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

```
kubectl get pod pvpod
   NAME      READY     STATUS    RESTARTS   AGE
   pvpod       1/1     Running   0          48m
```

{{<info>}}To access PV/PVCs with a non-root user refer [here](/portworx-install-with-kubernetes/storage-operations/create-pvcs/access-via-non-root-users)
{{</info>}}

### Delete volumes
For dynamically provisioned volumes using StorageClass and PVC (PersistenVolumeClaim), if a PVC is deleted, the corresponding Portworx volume will also get deleted. This is because Kubernetes, for PVC, creates volumes with a reclaim policy of deletion. So the volumes get deleted on PVC deletion.

To delete the PVC and the volume, you can run `kubectl delete -f <pvc_spec_file.yaml>`
