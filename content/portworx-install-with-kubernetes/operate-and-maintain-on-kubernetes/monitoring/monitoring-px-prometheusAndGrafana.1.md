---
title: Prometheus and Grafana
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, monitoring, prometheus, alertmanager, servicemonitor, grafana
description: How to use Prometheus and Grafana for monitoring Portworx on Kubernetes
---

## About Prometheus
Prometheus is an opensource monitoring and alerting toolkit. Prometheus consists of several components some of which are listed below.
- The Prometheus server which scrapes(collects) and stores time series data based on a pull mechanism.
- A rules engine which allows generation of Alerts based on the scraped metrices.
- An alertmanager for handling alerts.
- Multiple integrations for graphing and dashboarding.

In this document we would explore the monitoring of Portworx via Prometheus. The integration is natively supported by Portworx since portworx stands up metrics on a REST endpoint which can readily be scraped by Prometheus.

The following instructions allows you to monitor Portworx via Prometheus and allow the Alertmanager to provide alerts based on configured rules.

The Prometheus [Operator](https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html) creates, configures and manages a prometheus cluster.

The prometheus operator manages 3 customer resource definitions namely:
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
```

Next, apply the spec:

```text
kubectl apply -f <service-monitor.yaml>
```

### Install the Alertmanager
Create a file named `alertmanager.yaml` with the following contents and create a secret from it.
Make sure you add the relevant email addresses in the below config.
```text
global:
  # The smarthost and SMTP sender used for mail notifications.
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: '<sender-email-address>'
  smtp_auth_username: "<sender-email-address>"
  smtp_auth_password: '<sender-email-password>'
route:
  group_by: [Alertname]
  # Send all notifications to me.
  receiver: email-me
receivers:
- name: email-me
  email_configs:
  - to: <receiver-email-address>
    from: <sender-email-address>
    smarthost: smtp.gmail.com:587
    auth_username: "<sender-email-address>"
    auth_identity: "<sender-email-address>"
    auth_password: "<sender-email-password>"
## Edit the file and create a secret with it using the following command
```

```text
kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system
```


Create a file named `alertmanager-cluster.yaml` with the below contents:

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

Now, apply the spec on your cluster:

```text
kubectl apply -f alertmanager-cluster.yaml
```


Create a file named `alertmanager-service.yaml` with the following contents:

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

Apply the spec:

```text
kubectl apply -f alertmanager-service.yaml
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

Download {{< direct-download url="/samples/k8s/grafana/grafana-deployment.yaml" name="grafana-deployment.yaml" >}} and apply it:


```text
kubectl apply -f grafana-deployment.yaml
```

#### Grafana access details

Grafana can be be accessed using a NodePort service.

First get the node port that grafana is using

  ```text
  kubectl get svc -n kube-system grafana
  ```

Access the Grafana dashboard by navigating to `http://<master_ip>:<service_nodeport>`. You would need to create a datasource for the Portworx grafana dashboard metrics to be populated.
Navigate to Configurations --> Datasources.
Create a datasource named `prometheus`. Enter the Prometheus endpoint as obtained in the install verification step for Prometheus from the above section.

![grafanadatasource](/img/datasource-creation-grafana.png)

### Post install verification

Select the Portworx volume metrics dashboard on Grafana to view the Portworx metrics.
![grafanadashboard](/img/grafana-portworx-dashboard.png)
