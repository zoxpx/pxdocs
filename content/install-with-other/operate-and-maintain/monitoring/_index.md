---
title: "Monitoring your cluster"
---

## Using node_exporter and cadvisor alongside Portworx

[Node exporter](https://github.com/prometheus/node_exporter) and [cadvisor with prometheus](https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md) are great tools that export metrics about hardware/OS and containers. In order to provide metrics from the host, both tools require '/' to be exported into the container as '/rootfs'.

Portworx exports mounts to other containers and these in turn also get exported to node_exporter and cadvisor. In order for all mount events to be propagated to these containers, the root fs on the host should be bind mounted as "ro:slave". If this is not done, it is possible that these containers hold on to these volume mounts preventing the portworx volumes from being used on other hosts.

```
# Host root filesystem should be mounted as read-only:slave
-v "/:/rootfs:ro" \
```

## Monitoring Portworx

Portworx exports metrics to Prometheus as are described [here](/install-with-other/operate-and-maintain/prometheus)

Alert manager integration is described [here](/install-with-other/operate-and-maintain/alerting)

Grafana templates are provided [here](/install-with-other/operate-and-maintain/grafana/)




