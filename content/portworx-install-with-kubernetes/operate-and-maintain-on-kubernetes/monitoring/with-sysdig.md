---
title: Monitor Portworx with Sysdig
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, monitoring, prometheus, alertmanager, servicemonitor, grafana, lighthouse, px-central, px-kvdb, sysdig
description: Learn how to monitor portworx with Sysdig
---

Sysdig is a monitoring platform that allows you to monitor your Portworx cluster by running Sysdig agents on each node of your cluster.

![](/img/sysdigIntegration.png)

In order to use Sysdig with Portworx, you must deploy both products onto your Kubernetes node.

## Prerequisites

* You must have a Kubernetes cluster with Portworx installed on it

## Deploy Sysdig on Kubernetes with Portworx

1. Follow the [Kubernetes Agent Installation Steps](https://sysdigdocs.atlassian.net/wiki/spaces/Platform/pages/256475253/Kubernetes+Installation+Steps) in the Sysdig documentation to deploy the following YAML files:

    * sysdig-agent-clusterrole.yaml
    * sysdig-agent-configmap.yaml
    * sysdig-agent-daemonset-v2.yaml

2. The Portworx `px` process sends metrics to port 9001 at the '/metrics' endpoint. Sysdig integrates Prometheus by default, but must be pointed to the endpoint on which the portworx metrics are exposed. Follow the instructions in the [Integrate Prometheus Metrics into Sysdig Monitor UI](https://sysdigdocs.atlassian.net/wiki/spaces/Monitor/pages/204603650/Integrate+Prometheus+Metrics+into+Sysdig+Monitor+UI) section of the Sysdig documentation to integrate Sysdig with Portworx.

3. Once you've deployed Sysdig and integrated Prometheus, you must modify the `px` processes to expose metrics. Do this by adding the following fields to the `Sysdig-agent-configmap.yaml` file:

      ```text
      ...
      prometheus:
        enabled: true
        interval: 1
        process_filter:  
          - include:
            process.cmdline: "px"
            conf:
              port: 9001
              path: "/metrics"
      ...
      ```

## Save and restore Dashboards

You can save and restore your Sysdig dashboards on your Portworx cluster. Follow the steps in the [Save and Restore Dashboards with Scripts](https://sysdigdocs.atlassian.net/wiki/spaces/Monitor/pages/205488166/Dashboards#Dashboards-SaveandRestoreDashboardswithScripts) section of the Sysdig documentation to download the scripts and review instructions for running them.
