---
title: Installing Etcd using CFCR etcd release
keywords: Install, on-premise, PKS, Pivotal Container Service, kubernetes, k8s, air gapped, etcd, bosh, cfcr
hidden: true
---

[CFCR](https://docs-cfcr.cfapps.io/) provides an etcd release which can be deployed in PKS environments.

### 1. Clone the CFCR etcd release repo.

```text
git clone https://github.com/portworx/cfcr-etcd-release.git
cd cfcr-etcd-release
git checkout tags/v1.5.0-px
```

### 2. Deploy etcd

Download the [etcd deployment manifest](/samples/k8s/bosh-etcd-deployment.yaml) and change availibility zones and networks to match your environment. These are fields in the manifest that have a *CHANGEME* comment.

Now use bosh to deploy it.

```text
export BOSH_ENVIRONMENT=pks # CHANGE this to your bosh director environment name
export BOSH_DEPLOYMENT=etcd
bosh deploy bosh-etcd-deployment.yaml
```

If all goes well, you should have 3 etcd instances.

```text
bosh vms
```

This should output something like below.
```text
Deployment 'etcd'

Instance                                   Process State  AZ    IPs           VM CID                                   VM Type  Active
etcd/087aca88-83ab-4d6a-9889-631f861c1032  running        az-1  70.0.255.241  vm-4f7bc18b-4fc0-4580-aa41-e544ed24f3e5  medium   -
etcd/2da63ebd-cd62-49df-910e-3790b6ebaa86  running        az-1  70.0.255.242  vm-44d83e7c-ae35-469e-89d3-d1e9fea2cdaa  medium   -
etcd/77e56a14-02f7-4f49-80f4-8ccb6ceb769a  running        az-2  70.0.255.243  vm-bbdbc0c3-0513-4eae-a542-1709e668a54e  medium   -

3 vms
```

Let's list the etcd cluster members now.

```text
bosh ssh etcd/087aca88-83ab-4d6a-9889-631f861c1032 ETCDCTL_API=3  /var/vcap/jobs/etcd/bin/etcdctl member list
```

This should output:
```text
21ce9f1eea115b88, started, 087aca88-83ab-4d6a-9889-631f861c1032, https://087aca88-83ab-4d6a-9889-631f861c1032.etcd.pks-services.etcd.bosh:2380, https://087aca88-83ab-4d6a-9889-631f861c1032.etcd.pks-services.etcd.bosh:2379
3563446b241ac972, started, 2da63ebd-cd62-49df-910e-3790b6ebaa86, https://2da63ebd-cd62-49df-910e-3790b6ebaa86.etcd.pks-services.etcd.bosh:2380, https://2da63ebd-cd62-49df-910e-3790b6ebaa86.etcd.pks-services.etcd.bosh:2379
46829f944246eaa8, started, 77e56a14-02f7-4f49-80f4-8ccb6ceb769a, https://77e56a14-02f7-4f49-80f4-8ccb6ceb769a.etcd.pks-services.etcd.bosh:2380, https://77e56a14-02f7-4f49-80f4-8ccb6ceb769a.etcd.pks-services.etcd.bosh:2379
```

### 3. Copy out the etcd certs

To allow external clients to access the etcd cluster, we will copy out the certs.

```text
bosh scp etcd/087aca88-83ab-4d6a-9889-631f861c1032:/var/vcap/jobs/etcd/config/etcd* etcd-certs/
ls etcd-certs/
```

### 4. Create a Kubernetes secret with the certs

After the above steps, you should have all the etcd certs in the *etcd-certs* directory. These need to put in a Kubernetes secret so that Portworx can consume it.

```text
kubectl -n kube-system create secret generic px-kvdb-auth --from-file=etcd-certs/
kubectl -n kube-system describe secret px-kvdb-auth
```

This should output the below and shows the etcd certs are present in the secret.

```text
Name:         px-kvdb-auth
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
etcd-ca.crt:      1679 bytes
etcd.crt:  1680 bytes
etcd.key:  414  bytes
```
