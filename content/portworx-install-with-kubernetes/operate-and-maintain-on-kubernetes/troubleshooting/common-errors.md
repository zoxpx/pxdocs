---
title: Common errors
weight: 2
keywords: Troubleshoot, common errors, Kubernetes, k8s
description: Common errors
---

#### Failed to apply spec due Forbidden: may not be used when type is ClusterIP

{{% content "shared/upgrade/upgrade-nodeport-issue.md" %}}

#### Failed DNS resolution:
  * If you encounter the following error:

    ```
    Jan 18 12:48:03 node1 portworx[872]: level=error msg="error in obtaining etcd version: \
      Get http://_some_host:2379/version: dial tcp: lookup _some_host on [::1]:53: dial udp \
      [::1]:53: connect: no route to host"
    ```

  * Please ensure that the `NetworkManager` service has been stopped and disabled on your Linux host system.
  * **EXPLANATION**:<br/> The Portworx processes running inside the OCI container must be able to perform the DNS hostname resolution,
    especially if using hostnames for KVDB configuration, or the [CloudSnap](/reference/cli/cloud-snaps/) feature.
    However, host's `NetworkManager` service can update the DNS configuration (the `/etc/resolv.conf` file) _after_
    the Portworx container has started, and such changes will not propagate from host to container.
<br/>

---

#### Failure to install Portworx on SELinux:
  * You may have experienced the following issue installing Portworx  (e.g. Fedora 28 host)

    ```
    # sudo docker run --entrypoint /runc-entry-point.sh --rm -i --name px-installer --privileged=true \
      -v /etc/pwx:/etc/pwx -v /opt/pwx:/opt/pwx portworx/px-base-enterprise:2.1.2
    docker: Error response from daemon: OCI runtime create failed: container_linux.go:345: starting \
      container process caused "process_linux.go:430: container init caused \
      \"write /proc/self/attr/keycreate: permission denied\"": unknown.
    ```

  * **EXPLANATION**:<br/> This error is caused by a Docker issue (see [moby#39109](https://github.com/moby/moby/issues/39109)),
    which prevents Docker from running even the simplest containers:

    ```
    # sudo docker run --rm -it hello-world
    docker: Error response from daemon: OCI runtime create failed: container_linux.go:345: starting \
      container process caused "process_linux.go:430: container init caused \
      \"write /proc/self/attr/keycreate: permission denied\"": unknown.
    ```

  * To work around this issue, either turn off [SELinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux)
    support, or make sure to use docker-package provided by the host's platform.
<br/>

---

#### Failure to install Portworx on Kubernetes:
  * You may experience the following issue deploying Portworx into Kubernetes:

    ```
    ...level=info msg="Locating my container handler"
    ...level=info msg="> Attempt to use Docker as container handler failed"     \
         error="/var/run/docker.sock not a socket-file"
    ...level=info msg="> Attempt to use ContainerD as container handler failed" \
         error="Could not load container 134*: container \"134*\" in namespace \"k8s.io\": not found"
    ...level=info msg="> Attempt to use k8s-CRI as container handler failed"    \
         error="stat /var/run/crio/crio.sock: no such file or directory"
    ...level=error msg="Could not instantiate container client"                 \
         error="Could not initialize container handler"
    ...level=error msg="Could not talk to Docker/Containerd/CRI - please ensure \
          '/var/run/docker.sock', '/run/containerd/containerd.sock' or          \
          '/var/run/crio/crio.sock' are mounted"
    ```

  * **EXPLANATION**:<br/> In Kubernetes environments, Portworx installation starts by deploying OCI-Monitor Daemonset,
    which monitors and manages the Portworx service.
    In order to download, install and/or validate the Portworx service, the OCI-Monitor connects to the appropriate
    Kubernetes container runtime via socket-files that need to be mounted into the OCI-Monitor's POD.
  * Please inspect the Portworx DaemonSet spec, and ensure the appropriate socket-files/directories are mounted as volumes
    from the host-system into the Portworx POD.
    Alternatively, you can [reinstall Portworx](/portworx-install-with-kubernetes/), or at minimum generate a new
    YAML-spec via the Portworx spec generator page in [PX-Central](https://central.portworx.com), and copy the volume-mounts into your Portworx spec.

    | [Container runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)   | Supported since   | Required volume mounts                 |
