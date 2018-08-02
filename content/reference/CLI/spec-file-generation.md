---
title: Spec File Generation
weight: 10
---

This section explains how to generate the DaemonSet Portworx spec file via the command line.

## Parameters

Below are the parameters you can specify when generating the spec file.

### **Required Parameters**

| Parameter | **Description** | **Example** |
| --- | --- | --- |
| c | Specifies the unique name for the Portworx cluster. | c=test\_cluster |
| k | Your key value database, such as an etcd cluster or a consul cluster.  If using secure `etcd`, specify `https` in the URL and ensure all certificates are in the `/etc/pwx/` directory on each host pointed to by the Portworx container. | k=etcd:[http://etcd.fake.net:2379](http://etcd.fake.net:2379) |

**Optional Parameters**

| Parameter | **Description** | **Example** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| s | Specify comma-separated list of drives. | s=/dev/sdb,/dev/sdc |
| d | Specify data network interface. This is useful if your instances have non-standard network interfaces. | d=eth1 |
| m | Specify management network interface. This is useful if your instances have non-standard network interfaces. | m=eth1 |
| kbver | Specify Kubernetes version \(current default is 1.7\) | kbver=1.8.4 |
| stork | Specify if you want to install STORK | stork=true |
| coreos | REQUIRED if target nodes are running coreos. | coreos=true |
| osft | REQUIRED if installing on Openshift. | osft =true |
| mas | Specify if PX should run on the Kubernetes master node. For Kubernetes 1.6.4 and prior, this needs to be true \(default is false\) | mas=true |
| z | Instructs PX to run in zero storage mode on Kubernetes master. | z=true |
| f | Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted. | f=true |
| st | Select the secrets type \(_aws_, _kvdb_ or _vault_\) | st=vault |
| j | \(PX 1.3 and higher\) Specify a separate block device as a journaling device for px metadata. | j=/dev/sde |

**KVDB Parameters \(All required except** _**e**_**\)**

| Parameter | **Description** | **Example** |
| --- | --- | --- | --- | --- | --- | --- |
| pwd | Username and password for ETCD authentication in the form user:password | pwd=username:password |
| ca | Location of CA file for ETCD authentication. | ca=/path/to/server.ca |
| cert | Location of certificate for ETCD authentication. | cert=/path/to/server.crt |
| key | Location of certificate key for ETCD authentication. | key=/path/to/server.key |
| acl | ACL token value used for Consul authentication. | acl=398073a8-5091-4d9c-871a-bbbeb030d1f6 |
| e | Comma-separated list of environment variables that will be exported to Portworx. For a list of all of these variables, See the _Environment Variables_ section in the notes below. | e=MYENV1=myvalue1,MYENV2=myvalue2 |

### Environment Variables \(_e_ parameter\)

* `PX_HTTP_PROXY`: If running behind an HTTP proxy, set`PX_HTTP_PROXY` to your HTTP proxy.
* `PX_HTTPS_PROXY`: If running behind an HTTPS proxy, set `PX_HTTPS_PROXY` to your HTTPS proxy.
* `PX_ENABLE_CACHE_FLUSH`: To enable the cache flush deamon, set `PX_ENABLE_CACHE_FLUSH=true`.
* `PX_ENABLE_NFS`: To enable the PX NFS daemon, set `PX_ENABLE_NFS=true`.

## Generate the Spec via the command line

You can use `curl` to generate the spec via the command line. An example is given below.

```text
VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
# For the 1.4 tech preview release
curl -L -o px-spec.yaml "https://install.portworx.com/1.4/?c=mycluster&k=etcd://<ETCD_ADDRESS>:<ETCD_PORT>&kbver=$VER"

# For the 1.3 stable release
curl -L -o px-spec.yaml "https://install.portworx.com/1.3/?c=mycluster&k=etcd://<ETCD_ADDRESS>:<ETCD_PORT>&kbver=$VER"

# For the 1.2 stable release
curl -L -o px-spec.yaml "https://install.portworx.com/1.2/?c=mycluster&k=etcd://<ETCD_ADDRESS>:<ETCD_PORT>&kbver=$VER"
```

