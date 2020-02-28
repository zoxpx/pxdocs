---
title: Portworx integration with Prometheus
keywords: monitoring, prometheus, graph, stats
meta-description: Looking to integrate Portworx with Prometheus? Learn to integrate Portworx storage with Prometheus for monitoring today!
---
{{<info>}}
This document presents the **non-Kubernetes** method of monitoring your Portworx cluster with Prometheus. Please refer to the [Prometheus and Grafana](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) page if you are running Portworx on Kubernetes.
{{</info>}}


Portworx storage and network stats can easily be integrated with [**prometheus**](https://prometheus.io) or similar applications.
These stats are exported at port 9001; your application can poll http://&lt;IP_ADDRESS&gt;:9001/metrics to get their runtime values.

## Integration with Prometheus

### Step 1: Configuring Prometheus to watch px node
Add your px node as a target in Prometheus config file:

![Prometheus Config File](/img/prometheus-config.png "Prometheus Config File")

In the example above, our node has IP address of 54.173.138.1, so Prometheus is watching 54.173.138.1:9001 as its target. This can be any node in the Portworx cluster.

### Step 2: Portworx metrics to watch and building graphs with Prometheus

Once Prometheus starts watching your Portworx node, you will be able to see new Portworx related metrics added to Prometheus.

![Portworx Metrics in Prometheus](/img/px-metrics-in-prometheus.png "PX Metrics in Prometheus")

You can now build graphs:

![Building a Graph with Prometheus](/img/building-a-graph-with-prometheus.png "Building a Graph with Prometheus")

**Note**

A curl request on port 9001 also shows the stats:

![Curl Request on 9001](/img/curl-request-on-9001.png "Curl Request on 9001")

## Related topics

For information on the available Portworx metrics, refer to the [Portworx metrics for monitoring reference](/reference/metrics/). 
