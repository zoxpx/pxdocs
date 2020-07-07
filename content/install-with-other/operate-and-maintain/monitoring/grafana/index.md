---
title: Grafana with Portworx
keywords: monitoring, portworx, grafana
meta-description: Find templates for displaying Portworx cluster information within Grafana.
---

{{<info>}}
This document presents the **non-Kubernetes** method of monitoring your Portworx cluster with Grafana. Please refer to the [Prometheus and Grafana](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) page if you are running Portworx on Kubernetes.
{{</info>}}


## Configure Grafana

1. Start grafana with the follwing docker run command

      ```text
      docker run --restart=always --name grafana -d -p 3000:3000 grafana/grafana
      ```

2. Log in to Grafana at `http://your_ip_address:3000` in your browser. The default Grafana login is admin/admin.

3. Here, it will ask you to configure your datastore. Use the prometheus that you configured earlier. To use the templates that are provided later, name your datastore 'prometheus'. In the screen below:

      * Choose 'Prometheus' from the 'Type' dropdown.
      * Name datastore 'prometheus'
      * Add URL of your prometheus UI under Http settings -&gt; Url
      * Select **Save & Test**

      ![Grafana data store File](/img/grafana_datastore.png "Grafana data store File")

4. Import the Portworx provided [Cluster](/samples/k8s/pxc/portworx-cluster-dashboard.json), [Volume](/samples/k8s/pxc/portworx-volume-dashboard.json), and [Node](/samples/k8s/pxc/portworx-node-dashboard.json) Grafana templates: From the dropdown on left in your Grafana dashboard, select **Dashboards** followed by **Import**, and add the cluster, volume, and node templates.

      Once added, you can view your dashboards:

      ![Grafana Cluster Status File](/img/grafanaClusterStatus.png "Grafana Cluster Status File")

      ![Grafana Volume Status File](/img/grafanaVolumeStatus.png "Grafana Volume Status File")

      ![Grafana Node Status File](/img/grafanaVolumeStatus.png "Grafana Volume Status File")

<!--
are these the same as what's linked through GitHub above? If so, we should probably just show them using one method or the other.
[Andrei, 2019-12-17]: Don't know but I'm moving them under the `static` folder
## Cluster Template for Grafana
Use [this template](/samples/non-k8s/grafana/Cluster_Template.json) to display Portworx cluster details in Grafana

## Volume Template for Grafana
Use [this template](/samples/non-k8s/grafana/Volume_Template.json) to display Portworx volume details in Grafana
-->
