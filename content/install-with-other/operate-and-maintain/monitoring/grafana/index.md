---
title: "Grafana with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
meta-description: Find templates for displaying Portworx cluster information within Grafana.
---

{{<info>}}
This document presents the **non-Kubernetes** method of monitoring your Portworx cluster with Grafana. Please refer to the [Prometheus and Grafana](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) page if you are running Portworx on Kubernetes.
{{</info>}}


## Configure Grafana

Start grafana with the follwing docker run command

```text
docker run --restart=always --name grafana -d -p 3000:3000 grafana/grafana
```

Login to this grafana at http://&lt;IP_ADDRESS&gt;:3000 in your browser. Default grafana login is admin/admin.

Here, it will ask you to configure your datastore. We are going to be using prometheus that we configured earlier. To use the templates that are provided later, name your datastore 'prometheus'.

In the screen below:
1) Choose 'Prometheus' from the 'Type' dropdown.
2) Name datastore 'prometheus'
3) Add URL of your prometheus UI under Http settings -&gt; Url

Click on 'Save & Test'

![Grafana data store File](/img/grafana_datastore.png "Grafana data store File")

Next step would be to import Portworx provided [Cluster](https://github.com/portworx/px-docs/blob/gh-pages/maintain/monitoring/grafana/Cluster_Template.json) and [Volume](https://github.com/portworx/px-docs/blob/gh-pages/maintain/monitoring/grafana/Volume_Template.json) grafana templates.
If using PX 1.2.11, use [Volume 1.2.11](https://github.com/portworx/px-docs/blob/gh-pages/maintain/monitoring/Portworx%20Volume%20Status_V2_Nov_2.json) grafana template.

From the dropdown on left in your grafana dashboard, go to Dashboards -&gt; Import, and add cluster and volume template.

Your dashboard should look like the following.

![Grafana Cluster Status File](/img/grafana_cluster_status.png "Grafana Cluster Status File")


![Grafana Volume Status File](/img/grafana_volume_status.png "Grafana Volume Status File")

## Cluster Template for Grafana
Use [this template](Cluster_Template.json) to display Portworx cluster details in Grafana

## Volume Template for Grafana
Use [this template](Volume_Template.json) to display Portworx volume details in Grafana
