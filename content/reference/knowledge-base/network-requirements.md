---
title: Network requirements for Portworx on Kubernetes
linkTitle: Network requirements
keywords: Network, Communication ports, Firewall, Troubleshooting
description: Description on networking ports Portworx requires on Kubernetes for a functioning cluster
series: kb
weight: 5
hidden: true
---

Being a distributed storage system, Portworx requires access to certain ports on the host.

Below diagram captures the ports that are used and the inter-port communication in a Kubernetes environment.

![Portworx networking requirements on Kubernetes](/img/px-k8s-port-connections.png)
