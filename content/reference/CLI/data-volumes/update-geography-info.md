---
title: Update Geography Info
weight: 6
---

Portworx nodes can be made aware of the rack on which they are a placed as well as the zone and region in which they are present. Portworx can use this information to influence the volume replica placement decisions. The way Portworx reacts to rack, zone and region information is different and is explained below.

**Rack**

If Portworx nodes are provided with the information about their racks then they can use this information to honor the rack placement strategy provided during volume creation. If Portworx nodes are aware of their racks, and a volume is instructed to be created on specific racks, Portworx will make a best effort to place the replicas on those racks. The placement is user driven and has to be provided during volume creation.

**Zone**

If Portworx nodes are provided with the information about their zones then they can influence the `default`replica placement. In case of replicated volumes Portworx will always try to keep the replicas of a volume in different zones. This placement is not `strictly` user driven and if zones are provided, Portworx will automatically default to placing replicas in different zones for a volume.

**Region**

If Portworx nodes are provided with the information about their region then they can influence the `default`replica placement. In case of replicated volumes Portworx will always try to keep the replicas of a volume in the same region. This placement is not `strictly` user driven and if regions are provided, Portworx will automatically default to placing replicas in same region for a volume.

### Providing rack info to Portworx {#providing-rack-info-to-portworx}

To update the rack information in Kubernetes using node labels, click the link below.

{% page-ref page="update-geography-info.md" %}

#### Updating rack information through environment variables {#updating-rack-information-through-environment-variables}

> **Note:** This method requires a reboot of the Portworx container

Portworx can be made aware of its rack information through `PWX_RACK` environment variable. This environment variable can be provided through the `/etc/pwx/px_env` file. A sample file looks like this:

```text
# PX Environment File
# Add variables in the following format to automatically export them into PX container
# PWX_EXAMPLE_VAR=foobar
PWX_RACK=rack3
```

Add the `PWX_RACK=<rack-id>` entry to the end of this file and restart Portworx. On every Portworx restart, all the variables defined in `/etc/pwx/px_env` will be exported as environment variables in the Portworx container. Please make sure the label is a string not starting with a special character or a number.

### Providing zone info to Portworx {#providing-zone-info-to-portworx}

#### Updating zone information through environment variables {#updating-zone-information-through-environment-variables}

> **Note:** This method requires a reboot of the Portworx container

Portworx can be made aware of its zone information through `PWX_ZONE` environment variable. This environment variable can be provided through the `/etc/pwx/px_env` file. A sample file looks like this:

```text
# PX Environment File
# Add variables in the following format to automatically export them into PX container
# PWX_EXAMPLE_VAR=foobar
PWX_ZONE=zone1
```

Add the `PWX_ZONE=<zone-id>` entry to the end of this file and restart Portworx. On every Portworx restart, all the variables defined in `/etc/pwx/px_env` will be exported as environment variables in the Portworx container. Please make sure the label is a string not starting with a special character or a number.

### Providing region info to Portworx {#providing-region-info-to-portworx}

#### Updating region information through environment variables {#updating-region-information-through-environment-variables}

> **Note:** This method requires a reboot of the Portworx container

Portworx can be made aware of its region information through `PWX_REGION` environment variable. This environment variable can be provided through the `/etc/pwx/px_env` file. A sample file looks like this:

```text
# PX Environment File
# Add variables in the following format to automatically export them into PX container
# PWX_EXAMPLE_VAR=foobar
PWX_REGION=region2
```

Add the `PWX_REGION=<region-id>` entry to the end of this file and restart the Portworx. On every Portworx restart, all the variables defined in `/etc/pwx/px_env` will be exported as environment variables in the Portworx container. Please make sure the label is a string not starting with a special character or a number.

