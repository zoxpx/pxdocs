---
title: Operation control with systemd
keywords: portworx, kubernetes, systemd
description: How to perform systemctl operations using Portworx systemd service.
weight: 9
series: troubleshoot-portworx-on-kubernetes
---

This guide shows how you can perform systemctl operations using _kubectl_ to control the Portworx systemd service. Portworx already manages the lifecycle of the systemd service and hence these operations should not be required in a properly functioning cluster.

{{<info>}}
**Warning:** These operations should be performed only for debugging/troubleshooting purposes.
{{</info>}}

#### Service control

{{<info>}}You should not stop the Portworx systemd service while applications are still using it. Doing so can cause docker and applications to hang on the system. Migrate all application pods using `kubectl drain` from the node before stopping the Portworx systemd service.
{{</info>}}

**stop / start / restart the PX-OCI service**

{{<info>}}
This is the equivalent of running `systemctl stop portworx`, `systemctl start portworx` … on the node.
{{</info>}}

```text
kubectl label nodes minion2 px/service=start
kubectl label nodes minion5 px/service=stop
kubectl label nodes --all px/service=restart
```

**enable / disable the PX-OCI service**

{{<info>}}
This is the equivalent of running `systemctl enable portworx`, `systemctl disable portworx` on the node.
{{</info>}}

```text
kubectl label nodes minion2 minion5 px/service=enable
```
