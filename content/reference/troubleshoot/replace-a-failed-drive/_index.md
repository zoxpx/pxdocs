---
title: Replace a failed drive
description: How to replace a failed drive 
keywords: Portworx, troubleshoot
series: troubleshoot-portworx
---

This document walks you through the process of replacing a failing drive.
It's important to  note the following:

- in a RAID 0 configuration, it's not possible to recover a completely failed drive.
- this procedure can only be applied to recover volumes with a replication factor greater than 1. Refer to the [updating volumes](/reference/cli/updating-volumes#update-a-volume-s-replication-factor) page for more details on how to increase the replication factor of a volume.

Execute the following steps to replace a failed drive:


1. Retrieve the ID of the node by running the following command:

	```text
	pxctl cluster list
	```


2. To retrieve the ID(s) of the affected volume(s), run the `pxctl cluster inspect` command with the ID of the node as a parameter :

	```text
	pxctl cluster inspect <node-id>
	```

3. Remove the node from the cluster by entering the `pxctl cluster delete` command and passing it the ID of the node:

	```text
	pxctl cluster delete <node-id> 
	```

4. Decrease the number of replicas for each affected volume. Note that the maximum number of replicas is 3. The following example reduces the number of replicas to 2:

	```text
	pxctl volume ha-update --repl 2 <volume> --node <node-id>
```

	Note that you must repeat this step for each affected volume.

5. Replace the drive by following the steps from the [maintenance mode](/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/maintenance-mode#replace-a-drive-that-is-already-part-of-the-portworx-cluster) page.

	//TODO: @sen Added this step because I think it makes sense to replace the physical drive. I can easily remove it though.

6. Once you replaced the failing drive, reinitialize the node and add it back to the cluster. Refer to the instructions from the [scaling out an existing Portworx Cluster](/install-with-other/operate-and-maintain/scaling/scale-out) page for more details.


	//TODO: @sen You suggested this link: https://docs.portworx.com/install-with-other/docker/standalone/#why-oci. However, it doesn't explain how to add the node back to the cluster. I suspect this is something the user should do. Thus, I replaced it with the `scale-out` page. Speaking of which, there are two issues:
	
	- incorrect formatting and 
	- the instructions are a bit of confusing. This comes out of nowhere:


	```
	Provide cluster token token-bb4bcf4b-d394-11e6-afae-0242ac110002 that has a token- prefix to the cluster ID
		to which we want to add the new node
	* Use the same CLUSTER_ID as the ID of the cluster which you want the node to join for the -c parameter
	```


7. For each affected drive, increase the replication factor and specify the node on which to place the replicas. Run the `pxctl volume ha-update` command and pass it the following arguments:

	- `--repl` with the new number of replicas
	- the ID of the volume
	- `--node` the new ID of the node

	The following example increases the number of replicas to 3:

	```text
	pxctl volume ha-update --repl 3 <volume> --node <new-node-id>
	```