---
title: "Grafana with Portworx"
keywords: portworx, prometheus, grafana, alertmanager, cluster, storage
meta-description: Find templates for displaying Portworx cluster information within Grafana.
---

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

4. Import the Portworx provided [Cluster](https://github.com/portworx/pxdocs/blob/master/content/install-with-other/operate-and-maintain/monitoring/grafana/Portworx_Cluster_Dashboard_Jan_2019_No_AM.json), [Volume](https://github.com/portworx/pxdocs/blob/master/content/install-with-other/operate-and-maintain/monitoring/grafana/Portworx_Volume_Dashboard_Sep_2018.json ), and [Node](https://github.com/portworx/pxdocs/blob/master/content/install-with-other/operate-and-maintain/monitoring/grafana/Portworx_Node_Dashboard_Sep_2018_No_AM.json ) Grafana templates: From the dropdown on left in your Grafana dashboard, select **Dashboards** followed by **Import**, and add the cluster, volume, and node templates.

      Once added, you can view your dashboards:

      ![Grafana Cluster Status File](/img/grafanaClusterStatus.png "Grafana Cluster Status File")

      ![Grafana Volume Status File](/img/grafanaVolumeStatus.png "Grafana Volume Status File")

      ![Grafana Node Status File](/img/grafanaVolumeStatus.png "Grafana Volume Status File")

<!-- are these the same as what's linked through GitHub above? If so, we should probably just show them using one method or the other.
## Cluster Template for Grafana
Use [this template](Cluster_Template.json) to display Portworx cluster details in Grafana

## Volume Template for Grafana
Use [this template](Volume_Template.json) to display Portworx volume details in Grafana
-->
