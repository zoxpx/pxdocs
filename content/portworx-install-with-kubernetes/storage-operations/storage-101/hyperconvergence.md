---
title: Hyperconvergence
weight: 4
keywords: portworx, kubernetes, PVCs
description: Learn essential concepts about keeping your applications hyperconverged with their data
series: k8s-101
---

When a pod runs on the same host as its volume, it is known as convergence or hyper-convergence. Because this configuration reduces the network overhead of an application, performance is typically better.

Natively, Kubernetes does not support this. Portworx uses [STORK](https://github.com/libopenstorage/stork) to ensure that the nodes with data for a volume get prioritized when pods are being scheduled. Stork works as a scheduler extender here.

Below is the high-level workflow when a new pod is needed to get scheduled:

1. The default Kubernetes scheduler assigns scores to all nodes in the cluster that are candidates for scheduling the pod. It takes into consideration the usual scheduling parameters like CPU, Memory, Taints, Tolerations, Affinities etc.
2. The default scheduler then makes a request to STORK to filter nodes based on storage characteristics of the volume being used by the Pod. STORK will give higher scores to nodes that have the volume's data bits.
3. The default scheduler than picks the node with the higher score and assigns that to the pod.

[This page](/portworx-install-with-kubernetes/storage-operations/hyperconvergence/) has more details on hyper-convergence with Portworx.