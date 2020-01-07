---
title: Reactions to etcd recovery
keywords: Troubleshooting, debuggong, etcd disaster recovery, kubernetes, k8s
hidden: true
---

The following table summarizes how Portworx will respond to an etcd disaster and its recovery from a previous snapshot.


| Portworx state when snapshot was taken | Portworx state just before disaster | Portworx state after disaster recovery |
|-----------------|:---------------|:-------------------------------|
| Portworx running with few volumes | No Portworx or application activity    | Portworx is back online. Volumes are intact. No disruption. |
| Portworx running with few volumes | New volumes created | Portworx is back online. New Volumes are lost. |
| Portworx volumes were not in use by application. (Volumes are not attached) | Volumes are now in use by application (Volumes are attached) | Portworx is back online. The volume which was supposed to be attached is in detached state. Application is in CrashLoopBackOff state. Potentially could lead to data loss. |
| Portworx volumes were in use by application | Volume are now not in use by application | Volumes which are not in use by the application still stay attached. No data loss involved. |
| All Portworx nodes are up | No Portworx Activity | All the expected nodes are still Up |
| All Portworx nodes are up | A few nodes go down which have volume replica. Current Set changes. | Potentially could lead to data loss/corruption. Current Set is not in sync with what the storage actually has and when Portworx comes back up it might lead to data corruption |
| A Portworx node with replica is down. The node is not in current set. | The node is now online and in Current Set. | Portworx volume starts with older current set, but eventually gets updated current set. No data loss involved. |
