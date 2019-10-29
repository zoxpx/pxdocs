---
title: Private or custom registry
hidden: true
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
description: Private or custom registry
---

If you are using your own private or custom registry for your container images, add `&reg=<your-registry-url>` to the URL. Example:

```text
curl -fsL -o lighthouse-spec.yaml "https://install.portworx.com/2.1?comp=lighthouse&reg=artifactory.company.org:6555"
```
