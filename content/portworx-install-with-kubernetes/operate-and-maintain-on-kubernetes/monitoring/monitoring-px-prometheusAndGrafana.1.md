---
title: Prometheus and Grafana
keywords: monitoring, prometheus, alertmanager, servicemonitor, grafana, Kubernetes, k8s
description: How to use Prometheus and Grafana for monitoring Portworx on Kubernetes
---

## About Prometheus
Prometheus is an opensource monitoring and alerting toolkit. Prometheus consists of several components some of which are listed below:

- The Prometheus server which scrapes(collects) and stores time series data based on a pull mechanism.
- A rules engine which allows generation of Alerts based on the scraped metrices.
- An alertmanager for handling alerts.
- Multiple integrations for graphing and dashboarding.

This document walks you through the steps required to monitor your Portworx cluster with Prometheus and Grafana. Portworx natively supports Prometheus since it exposes the metrics on a REST endpoint. Then, Prometheus can scrape this endpoint.

The following instructions allows you to monitor Portworx via Prometheus and allow the Alertmanager to provide alerts based on configured rules.

The Prometheus [Operator](https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html) creates, configures and manages a prometheus cluster.

The Prometheus operator manages 3 customer resource definitions namely:

- Prometheus: The Prometheus CRD defines a Prometheus setup to be run on a Kubernetes cluster. The Operator creates a Statefulset for each definition of the Prometheus resource.
- ServiceMonitor: The ServiceMonitor CRD allows the definition of how Kubernetes services could be monitored based on label selectors. The Service abstraction allows Prometheus to in turn monitor underlying Pods.
- Alertmanager: The Alertmanager CRD allows the definition of an Alertmanager instance within the Kubernetes cluster. The alertmanager expects a valid configuration in the form of a `secret` called `alertmanager-name`.

## About Grafana
Grafana is a dashboarding and visualization tool with integrations to several timeseries datasources. It is used to create dashboards for the monitoring data with customizable visualizations. We would use Prometheus as the source of data to view Portworx monitoring metrics.

## Prerequisites
- A running Portworx cluster.

## Installation

### Install the Prometheus Operator
Download {{< direct-download url="/samples/k8s/grafana/prometheus-operator.yaml" name="prometheus-operator.yaml" >}} and apply it:

```text
kubectl apply -f <prometheus-operator.yaml>
```

### Install the Service Monitor

Create a file named `service-monitor.yaml` with the below contents:

```text
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: kube-system
  name: portworx-prometheus-sm
  labels:
    name: portworx-prometheus-sm
spec:
  selector:
    matchLabels:
      name: portworx
  namespaceSelector:
    any: true
  endpoints:
  - port: px-api
    targetPort: 9001
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: autopilot-prometheus-sm
  namespace: kube-system
  labels:
    name: portworx-prometheus-sm
spec:
  selector:
    matchLabels:
      name: autopilot-service
  namespaceSelector:
    any: true
  endpoints:
    - port: autopilot
```

Next, apply the spec:

```text
kubectl apply -f <service-monitor.yaml>
```

### Install and configure Prometheus Alertmanager

1. Specify your alerting rules. Create a file named `alertmanager.yaml`, specifying your configuration options for the following:

    * **email_configs:**
      * **to:** with the address of the recipient
      * **from:** with the address of the sender
      * **smarthost:** with the address of your SMTP server
      * **auth_username:** with your STMP username
      * **auth_identity:** with the address of the sender
      * **auth_password:** with your SMTP password.
      * **text:**  with the  text the notification
    * **slack_configs:**
      * **api_url:** with your Slack API URL. To retrieve your Slack API URL, you must follow the steps in the [Sending messages using Incoming Webhooks](https://api.slack.com/messaging/webhooks) page of the Slack documentation.
      * **channel:** with the Slack channel you want to send notifications to.
      * **text:** with the text of the notification

    ```text
    global:
      # Global variables
    route:
      group_by: [Alertname]
      receiver: email_and_slack
    receivers:
    - name: email_and_slack
      email_configs:
      - to:
        from:
        smarthost:
        auth_username:
        auth_identity:
        auth_password:
        text: |-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}
      slack_configs:
      - api_url:
        channel:
        text: |-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}
    ```

    {{<info>}}
For a description of the properties in this schema, see the [Configuration file](https://prometheus.io/docs/alerting/configuration/#configuration-file) section of the Prometheus documentation.
    {{</info>}}

2. Create a secret from the `alertmanager.yaml` file:

    ```text
    kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system
    ```

    ```
    secret/alertmanager-portworx created
    ```


3. Create a file named `alertmanager-cluster.yaml`, and copy in the following spec:

    ```text
    apiVersion: monitoring.coreos.com/v1
    kind: Alertmanager
    metadata:
      name: portworx #This name is important since the Alertmanager pods wont start unless a secret named alertmanager-${ALERTMANAGER_NAME} is created. in this case if would expect alertmanager-portworx secret in the kube-system namespace
      namespace: kube-system
      labels:
        alertmanager: portworx
    spec:
      replicas: 3
    ```


4. Apply the spec by entering the following command:

    ```text
    kubectl apply -f alertmanager-cluster.yaml
    ```

    ```
    alertmanager.monitoring.coreos.com/portworx created
    ```

5. Create a file named `alertmanager-service.yaml` with the following content:

      ```text
      apiVersion: v1
      kind: Service
      metadata:
        name: alertmanager-portworx
        namespace: kube-system
      spec:
        type: NodePort
        ports:
        - name: web
          port: 9093
          protocol: TCP
          targetPort: web
        selector:
          alertmanager: portworx
      ```

6. Apply the spec by entering the following command:

    ```text
    kubectl apply -f alertmanager-service.yaml
    ```

    ```
    service/alertmanager-portworx created
    ```

### Install Prometheus

Download {{< direct-download url="/samples/k8s/grafana/prometheus-rules.yaml" name="prometheus-rules.yaml" >}} and apply it:

```text
kubectl apply -f prometheus-rules.yaml
```

Download {{< direct-download url="/samples/k8s/grafana/prometheus-cluster.yaml" name="prometheus-cluster.yaml" >}} and apply it:


```text
kubectl apply -f prometheus-cluster.yaml
```

### Post Install verification


#### Prometheus access details

Prometheus can be be accessed using a NodePort service.

First get the node port that prometheus is using

  ```text
  kubectl get svc -n kube-system prometheus
  ```

Navigate to the Prometheus web UI by going to `http://<master_ip>:<service_nodeport>`. You should be able to navigate to the `Targets` and `Rules` section of the Prometheus dashboard which lists the Portworx cluster endpoints as well as the Alerting rules as specified earlier.

### Installing Grafana

1. Download the {{< direct-download url="/samples/k8s/pxc/grafana.yaml" name="grafana.yaml" >}} file and apply it:


    ```text
    kubectl apply -f grafana.yaml
    ```

2. Download and apply the following Grafana templates:

    ```text
    curl https://github.com/portworx/pxdocs/blob/master/static/samples/k8s/pxc/portworx-cluster-dashboard.json -o portworx-cluster-dashboard.json && \
    curl https://github.com/portworx/pxdocs/blob/master/static/samples/k8s/pxc/portworx-node-dashboard.json -o portworx-node-dashboard.json && \
    curl https://github.com/portworx/pxdocs/blob/master/static/samples/k8s/pxc/portworx-volume-dashboard.json -o portworx-volume-dashboard.json && \
    curl https://github.com/portworx/pxdocs/blob/master/static/samples/k8s/pxc/portworx-etcd-dashboard.json -o portworx-etcd-dashboard.json && \
    kubectl -n kube-system create configmap grafana-dashboards --from-file=portworx-cluster-dashboard.json --from-file=portworx-node-dashboard.json --from-file=portworx-volume-dashboard.json --from-file=portworx-etcd-dashboard.json
    ```

#### Grafana access details

Grafana can be be accessed using a NodePort service.

First get the node port that grafana is using

  ```text
  kubectl get svc -n kube-system grafana
  ```

Access the Grafana dashboard by navigating to `http://<master_ip>:<service_nodeport>`. You would need to create a datasource for the Portworx Grafana dashboard metrics to be populated.
Navigate to Configurations --> Datasources.
Create a datasource named `prometheus`. Enter the Prometheus endpoint as obtained in the install verification step for Prometheus from the above section.

![grafanadatasource](/img/datasource-creation-grafana.png)

### Post install verification

Select the Portworx volume metrics dashboard on Grafana to view the Portworx metrics.
![grafanadashboard](/img/grafana-portworx-dashboard.png)

## Related topics

For information on the available Portworx metrics, refer to the [Portworx metrics for monitoring reference](/reference/metrics/).
