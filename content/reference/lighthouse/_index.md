---
title: Install Lighthouse
keywords: Install, Lighthouse, Manage Portworx, GUI dashboard, monitor Portworx cluster, add Portworx cluster to Lighthouse, Reference
description: Documentation on using Lighthouse to manage Portworx clusters
weight: 8
linkTitle: Lighthouse
series: reference
---

Lighthouse is a GUI dashboard that can be used to monitor multiple Portworx clusters.

Any cluster running Portworx 1.4 or above can be added to Lighthouse.  Lighthouse must have network access on ports 9001 - 9022 to the nodes in the Portworx cluster.

## Start Lighthouse

Lighthouse runs as a Docker container.

```text
sudo docker run --restart=always                            \
       --name px-lighthouse -d                              \
       -p 80:80 -p 443:443                                  \
       -v /etc/pwxlh:/config                                \
       portworx/px-lighthouse:latest
```

Visit *http://{IP_ADDRESS}:login* in the browser and login with `admin/Password1`

## Adding a Portworx cluster

To add a Portworx cluster to Lighthouse, you will need the IP address of any one of the nodes in that cluster.  Lighthouse will connect to that node and configure itself to monitor that cluster.

After your first login, go to 'click here to add a Cluster to Light House' -> Add cluster endpoint -> Verify. This should automatically fill in the cluster name and UUID.  Once verified, click on attach.

**NOTE:** For the cluster endpoint, please provide the loadbalancer IP or the IP address of one of the nodes in the Portworx Cluster.

![Lighthouse add new cluster](/img/lh-new-add-cluster.png)

### Deleting a Portworx cluster
Under the settings icon, click on Manage Clusters.

![Lighthouse menu](/img/lh-new-menu.png)

Click on the trashcan link next to the cluster name in the cluster list.  This will remove this cluster card from lighthouse cluster landing page

![Lighthouse add new cluster](/img/lh-new-delete-cluster.png)

**NOTE:** This will not remove your cluster from your KVDB.  This action just de-registers this cluster from Lighthouse.
