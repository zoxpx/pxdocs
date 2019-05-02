---
title: Securing Portworx API endpoints with Kubernetes Network Policies
linkTitle: Securing Portworx API
keywords: portworx, Kubernetes, network policy
description: Securing Portworx API endpoints with Kubernetes Network Policies
weight: 5
noicon: true
hidden: true
---

This document has instructions on restricting network access to the Portworx API in a Kubernetes cluster.

The document uses [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) and [iptables](https://en.wikipedia.org/wiki/Iptables) as a mechanism to achieve this.

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

{{<info>}}Replace `70.0.0.0/16` with the subnet of your Kubernetes worker nodes.{{</info>}}

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
```

Apply the following NetworkPolicy in each namespace you have user pods. This will block traffic to Portworx ports 9001 to 9022 on the host network from all pods in the namespace the policy is applied in.

{{<info>}}Replace `70.0.0.0/16` with the subnet of your Kubernetes worker nodes.{{</info>}}

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
```

## Step 3: Allow API server access

So in this model where we’re using network policies to restrict control plane service access, the one service we may want to allow containers to speak to is the Kubernetes API. As the access provided by network policies is cumulative, this is pretty straightforward. Working with the same setup as the previous example, we can just apply something like below.

{{<info>}}Replace `70.0.0.0/16` with the subnet of your Kubernetes worker nodes.{{</info>}}

```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-api
  namespace: default
spec:
  podSelector: {}
  egress:
  - to:
    - ipBlock:
        cidr: 70.0.0.0/16
    ports:
    - protocol: TCP
      port: 6443
  policyTypes:
  - Egress
```
Now we’ll have access to the API service from pods in the default namespace.

## Limitations

1. The `ports` sections in above rukes is a whitelist of ports you want to give access to pods that are not selected by the `podSelector`. Users are expected to add additional ports they wish to grant accesss.
2. The above NetworkPolicies do not apply to user pods running on the host network. Users are expected to use [Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) to prevent pods from running on host network.
3. Policies in Step 3 and 4 only affect to the namespace they are applied in. Apply the network policies in each user namespace to achieve the same effect.
4. The network policies take effect only if the CNI network plugin installed in your Kubernetes cluster supports it. [Calico](https://docs.projectcalico.org/v2.0/getting-started/kubernetes/tutorials/simple-policy) was used to test the specs in this doc.
