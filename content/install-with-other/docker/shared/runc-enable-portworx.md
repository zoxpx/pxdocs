---
title: Enable on Docker (shared)
description: Learn how to enable Porworx as a runC container
keywords: portworx, px-developer, px-enterprise, plugin, install, configure, container, storage, runc, oci
---

Once you install the PX OCI bundle and systemd configuration from the steps above, you can start and control PX runC directly via systemd.

Below commands reload systemd configurations, enable and starts the Portworx service.


```text
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```
