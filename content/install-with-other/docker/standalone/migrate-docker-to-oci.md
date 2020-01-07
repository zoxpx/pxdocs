---
title: Migrate Portworx installed using Docker to OCI/runc
description: Learn how to migrate Portworx installed using Docker to OCI/runc
keywords: Migrate, Docker, OCI, runc
hidden: true
---

If you already had Portworx running as a Docker container and now want to upgrade to runC, follow these instructions:

### Step 1: Download and deploy the Portworx OCI bundle

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false' | awk '/image: / {print $2}')

sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

###  Step 2: Inspect your existing Portworx containers, record arguments and any custom mounts:

Inspect the mounts so these can be provided to the runC installer.

{{<info>}}
**Note:**
Mounts for `/dev`, `/proc`, `/sys`, `/etc/pwx`, `/opt/pwx`, `/run/docker/plugins`, `/usr/src`, `/var/cores`, `/var/lib/osd`, `/var/run/docker.sock` can be safely ignored \(omitted\).
Custom mounts will need to be passed to Portworx OCI in the next step, using the following notation:
`px-runc install -v <Source1>:<Destination1>[:<Propagation1 if shared,ro>] ...`
{{</info>}}

```text
# Inspect Arguments
sudo docker inspect --format '{{.Args}}' px-enterprise
[ -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379 -s /dev/xvdb ]
```


```text
# Inspect Mounts
sudo docker inspect --format '{{json .Mounts}}' px-enterprise | python -mjson.tool
```

```output
[...]
    {
        "Destination": "/var/lib/kubelet",
        "Mode": "shared",
        "Propagation": "shared",
        "RW": true,
        "Source": "/var/lib/kubelet",
        "Type": "bind"
    },
```

```text
# Alternatively, one can use 'jq' and 'egrep' to filter out the "standard" Portworx mounts,
# and leave only your custom mounts (if any)
sudo docker inspect px-enterprise | \
  jq -c '.[].Mounts[]|{s:.Source,d:.Destination,m:.Mode}|join(":")' | \
  egrep -v "/dev:|/proc:|/sys:|/etc/pwx:|:/export_bin|/docker/plugins:|/usr/src:|/lib/modules:|/var/cores:|/var/lib/osd:|/docker.sock:"
```

### Step 3: Install the Portworx OCI bundle

Remember to use the arguments from your Portworx Docker installation.

```text
sudo /opt/pwx/bin/px-runc install -c MY_CLUSTER_ID \
    -k etcd://myetc.company.com:2379 \
    -s /dev/xvdb
```

### Step 4: Stop the Portworx container and start Portworx runC

```text
# Disable and stop PX Docker container

sudo docker update --restart=no px-enterprise
sudo docker stop px-enterprise

# Set up and start PX OCI as systemd service

sudo systemctl daemon-reload
sudo systemctl enable portworx
sudo systemctl start portworx
```

Once you confirm the Portworx container -&gt; Portworx runC upgrade worked, you can permanently delete the `px-enterprise` docker container.
