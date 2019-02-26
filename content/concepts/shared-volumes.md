---
title: Shared and Sharedv4 Volumes
linkTitle: Shared Volumes
description: Explanation on Portworx Shared and Sharedv4 volumes to allow multiple containers access to one volume
keywords: portworx, PX-Developer, container, Shared Volume, Sharedv4 Volume, NFS, storage
weight: 4
series: concepts
---

Through shared and sharedv4 volumes \(also known as a **global namespace**\), a single volume’s filesystem is concurrently available to multiple containers running on multiple hosts.

{{<info>}}
**Note:**  
You do not need to use shared/sharedv4 volumes to have your data accessible on any host in the cluster. Any PX volumes can be exclusively accessed from any host as long as they are not simultaneously accessed. Shared volumes are for providing simultaneous \(concurrent or shared\) access to a volume from multiple hosts at the same time.
{{</info>}}

A typical pattern is for a single container to have one or more volumes. Conversely, many scenarios would benefit from multiple containers being able to access the same volume, possibly from different hosts. Accordingly, the shared volume feature enables a single volume to be read/write accessible by multiple containers. Example use cases include:

* A technical computing workload sourcing its input and writing its output to a shared volume.
* Scaling a number of Wordpress containers based on load while managing a single shared volume.
* Collecting logs to a central location

{{<info>}}
**Note:**  
Usage of shared/sharedv4 volumes for databases is not recommended, since they have a small metadata overhead. Along with that, typical databases do not support concurrent writes to the underlying database at the same time.
{{</info>}}


Difference between shared and sharedv4 volumes, is the underlying protocol that is used to share this global namespace across multiple hosts.