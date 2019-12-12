---
hidden: true
---

Examples:

* `"-s", "type=pd-ssd,size=200", "-max_storage_nodes_per_zone", "1"`

For a cluster of 6 nodes spanning 3 zones (us-east-1a,us-east-1b,us-east-1c), in the above example Portworx will have 3 storage nodes (one in each zone) and 3 storage less nodes. Portworx will create a total 3 disks of size 200 each and attach one disk to each storage node.

* `"-s", "type=pd-standard,size=200", "-s", "type=pd-ssd,size=100", "-max_storage_nodes_per_zone", "2"`

For a cluster of 9 nodes spanning 2 zones (us-east-1a,us-east-1b), in the above example Portworx will have 4 storage nodes and 5 storage less nodes. Portworx will create a total of 8 disks (4 of size 200 and 4 of size 100). Portworx will attach a set of 2 disks (one of size 200 and one of size 100) to each of the 4 storage nodes.
