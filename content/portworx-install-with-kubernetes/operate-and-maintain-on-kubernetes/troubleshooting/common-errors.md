---
title: Common errors
weight: 2
keywords: portworx, troubleshoot, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, debug
description: Common errors
---

### Common errors {#common-errors}

* Failed DNS resolution:
  * If you encounter the following error:

    ```
    Jan 18 12:48:03 node1 portworx[872]: level=error msg="error in obtaining etcd version: \
      Get http://_some_host:2379/version: dial tcp: lookup _some_host on [::1]:53: dial udp \
      [::1]:53: connect: no route to host"
    ```

  * Please ensure that the `NetworkManager` service has been stopped and disabled on your Linux host system.
  * **EXPLANATION**:<br/> Portworx processes running inside OCI container must be able to perform the DNS hostname resolution,
    especially if using hostnames for KVDB configuration, or the [CloudSnap](/reference/cli/cloud-snaps/) feature.
    However, host's `NetworkManager` service can update the DNS configuration (the `/etc/resolv.conf` file) _after_
    the Portworx container has started, and such changes will not propagate from host to container.
