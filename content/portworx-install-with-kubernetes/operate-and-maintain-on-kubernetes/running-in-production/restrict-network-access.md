---
title: Restrict network access
keywords: portworx, Kubernetes, network policy
description: Securing Portworx API endpoints with Kubernetes Network Policies
weight: 5
noicon: true
hidden: true
---

This document has instructions on restricting network access to the Portworx API in a Kubernetes cluster.

The document uses [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) and [iptables](https://en.wikipedia.org/wiki/Iptables) as a mechanism to achieve this.

{{<info>}}The network policies take effect only if the CNI network plugin installed in your Kubernetes cluster supports it. [Calico](https://docs.projectcalico.org/v2.0/getting-started/kubernetes/tutorials/simple-policy) was used to test the specs in this doc.{{</info>}}

## Step 1: Setup iptables to restrict host access

Apply the following iptable rules on all your Kubernetes worker nodes.

Replace `70.0.98.11-70.0.98.14` in below example with range of host IPs for your Kubernetes worker nodes.

```text
iptables -A INPUT -p tcp -s 127.0.0.1 --match multiport  --dports 9000:9022 -j ACCEPT
iptables -A INPUT -p tcp -s 70.0.98.11 --match multiport  --dports 9000:9022 -j ACCEPT
iptables -A INPUT -p tcp -s 70.0.98.12 --match multiport  --dports 9000:9022 -j ACCEPT
iptables -A INPUT -p tcp -s 70.0.98.13 --match multiport  --dports 9000:9022 -j ACCEPT
iptables -A INPUT -p tcp -s 70.0.98.14 --match multiport  --dports 9000:9022 -j ACCEPT
iptables -A INPUT -p tcp --match multiport  --dports 9000:9022 -j DROP
```

## Step 2: Setup NetworkPolicy to restrict pod access

Apply the following NetworkPolicy in the `kube-system` namespace. This will block traffic to Portworx ports 9001 to 9022 on the host network from all pods except Stork, Kubernetes controller manager and Ligthouse.

Replace `70.0.0.0/16` with the subnet of your Kubernetes worker nodes.

```text
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-9001-for-non-system-users
  namespace: kube-system
spec:
  podSelector:
    matchExpressions:
    - key: name
      operator: NotIn
      values:
        - scheduler
    - key: component
      operator: NotIn
      values:
        - stork
    - key: tier
      operator: NotIn
      values:
        - control-plane
    - key: k8s-app
      operator: NotIn
      values:
        - kube-controller-manager
    - key: name
      operator: NotIn
      values:
        - portworx-pvc-controller
    - key: tier
      operator: NotIn
      values:
        - px-web-console
  policyTypes:
    - Egress
  egress:
    - to:
      - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 70.0.0.0/16
      ports:
        - protocol: TCP
          port: 8099
        - protocol: TCP
          port: 9001
        - protocol: TCP
          port: 9002
        - protocol: TCP
          port: 9003
        - protocol: TCP
          port: 9004
        - protocol: TCP
          port: 9005
        - protocol: TCP
          port: 9006
        - protocol: TCP
          port: 9007
        - protocol: TCP
          port: 9008
        - protocol: TCP
          port: 9009
        - protocol: TCP
          port: 9010
        - protocol: TCP
          port: 9011
        - protocol: TCP
          port: 9012
        - protocol: TCP
          port: 9013
        - protocol: TCP
          port: 9014
        - protocol: TCP
          port: 9015
        - protocol: TCP
          port: 9015
        - protocol: TCP
          port: 9016
        - protocol: TCP
          port: 9017
        - protocol: TCP
          port: 9018
        - protocol: TCP
          port: 9019
        - protocol: TCP
          port: 9020
        - protocol: TCP
          port: 9021
        - protocol: TCP
          port: 9022
```

Apply the following NetworkPolicy in each namespace you have user pods. This will block traffic to Portworx ports 9001 to 9022 on the host network from all pods in the namespace the policy is applied in.

Replace `70.0.0.0/16` with the subnet of your Kubernetes worker nodes.

```text
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
    name: block-9001-for-non-system-users
    namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
      - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 70.0.0.0/16
      ports:
        - protocol: TCP
          port: 9001
        - protocol: TCP
          port: 9002
        - protocol: TCP
          port: 9003
        - protocol: TCP
          port: 9004
        - protocol: TCP
          port: 9005
        - protocol: TCP
          port: 9006
        - protocol: TCP
          port: 9007
        - protocol: TCP
          port: 9008
        - protocol: TCP
          port: 9009
        - protocol: TCP
          port: 9010
        - protocol: TCP
          port: 9011
        - protocol: TCP
          port: 9012
        - protocol: TCP
          port: 9013
        - protocol: TCP
          port: 9014
        - protocol: TCP
          port: 9015
        - protocol: TCP
          port: 9015
        - protocol: TCP
          port: 9016
        - protocol: TCP
          port: 9017
        - protocol: TCP
          port: 9018
        - protocol: TCP
          port: 9019
        - protocol: TCP
          port: 9020
        - protocol: TCP
          port: 9021
        - protocol: TCP
          port: 9022
```
