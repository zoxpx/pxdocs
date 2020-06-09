---
title: Portworx on Kubernetes
weight: 2
hidesections: true
description: Documentation on using Portworx in Kubernetes environments
series: top
icon: /img/banner__kubernetes.png
keywords: portworx, kubernetes, k8s, container, storage
---

## Try without installing

You can try Portworx in live interactive tutorials before installing it in your environment.

To view the available playgrounds, continue below.
{{< widelink url="/interactive-tutorials" >}}Interactive tutorials{{</widelink>}}

## Before you begin

Before you install Portworx on Kubernetes, ensure that you're using a supported Kubernetes version:

| **Type** | **Supported Kubernetes Version** |
|---|---|
| On-prem Kubernetes | <ul><li>1.11.3</li><li>1.13.7</li><li>1.14.5</li><li>1.15.3</li><li>1.16.3</li><li>1.17.0</li></ul> |
| Managed Kubernetes | <ul><li>**KOPS:** 1.14.10</li><li>**GKE:** 1.15.9</li><li>**AKS:** 1.14.7</li><li>**EKS:** 1.16.8</li><li>**IKS:** 1.15.5</li></ul> |
| Distribution Kubernetes | <ul><li>**Openshift 3.11:** 1.11</li><li>**Openshift 4.2:** 1.14</li><li>**Openshift 4.3:** 1.16</li><li>**RKE:** 1.16.7</li><li>**Anthos** 1.2, 1.3 </li></ul> |

## Installation

Whether you're using Portworx Enterprise or Essentials, you can install Portworx on the cloud or on-premise. Proceed to one of the following sections for install instructions.

{{<homelist series="k8s-install">}}

## Post-installation

If you have an existing Portworx cluster, continue to below sections for using and managing Portworx.

{{<homelist series2="k8s-postinstall">}}
