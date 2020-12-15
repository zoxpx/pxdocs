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
| On-prem Kubernetes | <ul><li>1.11</li><li>1.12</li><li>1.13</li><li>1.14</li><li>1.15</li><li>1.16</li><li>1.17</li><li>1.18</li><li>K3s</li></ul> |
| Managed Kubernetes | <ul><li>**KOPS:** 1.16</li><li>**GKE:** 1.15</li><li>**AKS:** 1.14</li><li>**EKS:** 1.16</li><li>**IKS:** 1.15</li><li>**PKS:** 1.15</li></ul> |
| Distribution Kubernetes | <ul><li>**Openshift 3.11:** 1.11</li><li>**Openshift 4.2:** 1.14</li><li>**Openshift 4.3:** 1.16</li><li>**Openshift 4.4:** 1.17</li><li>**Openshift 4.5:** 1.18</li><li>**Openshift 4.6:** 1.19</li><li>**RKE:** 1.16</li><li>**Anthos** 1.2, 1.3, 1.4 </li></ul> |

{{<info>}}
**K3s users:** You must use CSI integration to generate / use PVCs.
{{</info>}}

## Installation

Whether you're using {{< pxEnterprise >}} or Essentials, you can install Portworx on the cloud or on-premises. Proceed to one of the following sections for install instructions.

{{<homelist series="k8s-install">}}

## Post-installation

If you have an existing Portworx cluster, continue to below sections for using and managing Portworx.

{{<homelist series2="k8s-postinstall">}}
