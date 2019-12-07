---
title: "Autopilot Install and Setup"
linkTitle: "Autopilot Install and Setup"
keywords: install, autopilot
description: Instructions on installation, configuration and upgrade of Autopilot
---

## Installing Autopilot

### Prerequisites

#### Prometheus

Autopilot requires a running Prometheus instance in your cluster. If you don't have Prometheus configured in your cluster, refer to the [Prometheus and Grafana
](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/monitoring/monitoring-px-prometheusandgrafana.1/) to set it up.

Once you have it installed, find the Prometheus service endpoint in your cluster. Depending on how you installed Prometheus, the precise steps to find this may vary. In most clusters, you can find a service named Prometheus:

```text
kubectl get service -n kube-system prometheus
```
```output
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)          AGE
prometheus   LoadBalancer   10.0.201.44   52.175.223.52   9090:30613/TCP   11d
```

In the example above, `http://prometheus:9090` becomes the Prometheus endpoint. Portworx uses this endpoint in the [Autopilot Configuration](#autopilot-configuration) section.


{{<info>}}*Why `http://prometheus:9090`* ?

`prometheus` is the name of the Kubernetes service for Prometheus in the kube-system namespace. Since Autopilot also runs as a pod in the kube-system namespace, it can access Prometheus using it's Kubernetes service name and port.

{{</info>}}

### Configuring the ConfigMap

Replace `http://prometheus:9090` in the following ConfigMap with your Prometheus service endpoint, if it's different. Once replaced, apply this ConfigMap in your cluster:

```text

apiVersion: v1
kind: ConfigMap
metadata:
  name: autopilot-config
  namespace: kube-system
data:
  config.yaml: |-
    providers:
       - name: default
         type: prometheus
         params: url=http://prometheus:9090
    min_poll_interval: 2
```

This ConfigMap serves as a configuration for Autopilot.

### Installing Autopilot

To install Autopilot, apply the following YAML in your cluster:

```text
apiVersion: v1
kind: ServiceAccount
metadata:
  name: autopilot-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: autopilot-role
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: autopilot-role-binding
subjects:
- kind: ServiceAccount
  name: autopilot-account
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: autopilot-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  labels:
    tier: control-plane
  name: autopilot
  namespace: kube-system
  initializers:
    pending: []
spec:
  selector:
    matchLabels:
      tier: control-plane
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 1
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      labels:
        name: autopilot
        tier: control-plane
    spec:
      containers:
      - command:
        - /autopilot
        - -f
        - ./etc/config/config.yaml
        - -log-level
        - debug
        imagePullPolicy: Always
        image: portworx/autopilot:v0.6.0
        resources:
          requests:
            cpu: '0.1'
        securityContext:
          privileged: false
        name: autopilot
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      hostPID: false
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "name"
                    operator: In
                    values:
                    - autopilot
              topologyKey: "kubernetes.io/hostname"
      serviceAccountName: autopilot-account
      volumes:
        - name: config-volume
          configMap:
            name: autopilot-config
            items:
            - key: config.yaml
              path: config.yaml
```

## Upgrading Autopilot

To upgrade Autopilot, change the image tag in the deployment with the `kubectl set image` command. The following example upgrades Autopilot to the v0.6.0 version:

```text
kubectl set image deployment.v1.apps/autopilot -n kube-system autopilot=portworx/autopilot:v0.6.0
```
```output
deployment.apps/autopilot image updated
```
