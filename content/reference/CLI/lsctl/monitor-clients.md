---
title: Monitor clients and licenses
description: CLI reference for lsctl commands
keywords: lsctl, CLI, command line, command line tool, reference
weight: 6
series: reference
hidden: true
---

You can monitor your licenses using the `lsctl` command. The following represent some of the more common monitoring operations you can perform:

* View the nodes using Portworx licenses
* View which individual license features are leased-out to nodes

## View the nodes using Portworx licenses

Enter the `lscstl client ls` command to list all of the Portworx nodes using licenses from the license server:

```text
/opt/pwx-ls/bin/lsctl client ls
```
```output
CLUSTER ID                                       NODE ID                               LEASE EXPIRY
px-cluster-131bc97a-20d2-4f76-b866-9c5413128f51  c95bb1d2-4803-450b-9117-d32e4aa08dae  in 166h52m11s
px-cluster-131bc97a-20d2-4f76-b866-9c5413128f51  84a67421-1123-4046-9c29-838515e01522  in 166h52m11s
```

{{<info>}}
**NOTE:** Backup license servers retrieve lease expiration information from the primary license server every 5 minutes. If the lease interval is set to a short period of time, 15 minutes for example, Portworx will refresh the lease more frequently than the backup license server syncs. In this situation, you will see slightly different lease expiration times depending on which license server you run the `lscstl client ls` command on.
{{</info>}}

## View the which individual licenses are leased-out to nodes

Enter the `lstcl client usage` command to list all of the Portworx nodes using licenses, display what those licenses are, and the number of licenses being consumed by that node:<!-- not sure if this is exactly right-->

```text
/opt/pwx-ls/bin/lsctl client usage
```
```output
CLUSTER ID                                       NODE ID                               LICENSE  COUNT  LEASE EXPIRY
px-cluster-131bc97a-20d2-4f76-b866-9c5413128f51  c95bb1d2-4803-450b-9117-d32e4aa08dae  Nodes    1      in 166h51m43s
px-cluster-131bc97a-20d2-4f76-b866-9c5413128f51  84a67421-1123-4046-9c29-838515e01522  Nodes    1      in 166h51m43s
```

<!-- verified -->
