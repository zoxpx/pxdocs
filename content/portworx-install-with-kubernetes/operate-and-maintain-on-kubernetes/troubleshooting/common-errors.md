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

* Failure to start Portworx service on `Red Hat Enterprise Linux CoreOS 410.8.20190418.1 (Ootpa)`:
  * You may have encountered the following failure to start Portworx service on RHEL/CoreOS platform:

    ```
    @ip-10-0-162-215 systemd[1]: Starting Portworx OCI Container...
    @ip-10-0-162-215 systemd[1]: Started Portworx OCI Container.
    @ip-10-0-162-215 systemd[1]: portworx.service: Main process exited, code=exited, status=203/EXEC
    @ip-10-0-162-215 systemd[1]: portworx.service: Failed with result 'exit-code'.
    ```
    
  * **EXPLANATION**:<br/> This error occurs due to invalid security context on /opt directory on RHEL/CoreOS system (see [case#02375927](https://access.redhat.com/support/cases/#/case/02375927)).  To fix this for Kubernetes installations, please include the "PRE-EXEC" environment variable into your Portworx YAML as seen below.  For standalone Portworx installations, please run the "if grep -q..." command manually on the host-system:

    ```
    env:
    - name: "PRE-EXEC"
      value: "if grep -q 'Red Hat Enterprise Linux CoreOS' /etc/os-release && /bin/ls -dZ /var/opt/ | grep -q :object_r:var_t: ; then semanage fcontext -a -t usr_t '/var/opt(/.*)?' ; restorecon -Rv /var/opt/ ; fi"
    ```
<br/>
