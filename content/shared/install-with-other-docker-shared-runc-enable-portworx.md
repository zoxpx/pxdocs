---
title: Enable on Docker (shared)
description: Learn how to enable Porworx as a runC container
keywords: Install, Docker, start service
hidden: true
---

Once you install the Portworx OCI bundle and systemd configuration from the steps above, you can control Portworx directly via systemd.

Below commands reload systemd configurations, enable and start the Portworx service.


```text
sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```
