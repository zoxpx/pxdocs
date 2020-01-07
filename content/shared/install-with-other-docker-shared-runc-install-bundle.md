---
title: Install on Docker (shared)
description: Learn how to install Porworx as a runC container
keywords: Install, Docker, PX OCI
hidden: true
---

Portworx provides a Docker based installation utility to help deploy the Portworx OCI
bundle. This bundle can be installed by running the following Docker container
on your host system:

```text
# Uncomment appropriate `REL` below to select desired Portworx release
REL="/2.3"     # 2.3 portworx release
#REL="/2.2"       # 2.2 portworx release

latest_stable=$(curl -fsSL "https://install.portworx.com$REL/?type=dock&stork=false" | awk '/image: / {print $2}')

# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

{{<info>}}Running the Portworx OCI bundle does not require Docker, but Docker will still be required to _install_ the Portworx OCI bundle.  If you do not have Docker installed on your target hosts, you can download this Docker package and extract it to a root tar ball and manually install the OCI bundle.{{</info>}}
