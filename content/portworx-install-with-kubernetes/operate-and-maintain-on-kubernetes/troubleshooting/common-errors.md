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
<br/>

---

* Failure to install Portworx:
  * You may have experienced the following issue installing Portworx  (e.g. Fedora 28 host)

    ```
    # sudo docker run --entrypoint /runc-entry-point.sh --rm -i --name px-installer --privileged=true \
      -v /etc/pwx:/etc/pwx -v /opt/pwx:/opt/pwx portworx/px-base-enterprise:2.1.2
    docker: Error response from daemon: OCI runtime create failed: container_linux.go:345: starting \
      container process caused "process_linux.go:430: container init caused \
      \"write /proc/self/attr/keycreate: permission denied\"": unknown.
    ```
    
  * **EXPLANATION**:<br/> This error is a docker issue (see [moby#39109](https://github.com/moby/moby/issues/39109)), and it prevents running even the simplest containers:

    ```
    # sudo docker run --rm -it hello-world
    docker: Error response from daemon: OCI runtime create failed: container_linux.go:345: starting \
      container process caused "process_linux.go:430: container init caused \
      \"write /proc/self/attr/keycreate: permission denied\"": unknown.
    ```

  * to work around this issue, one should either turn off the [SELinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux) support, or make sure to use docker-package provided by the host's platform.
<br/>
