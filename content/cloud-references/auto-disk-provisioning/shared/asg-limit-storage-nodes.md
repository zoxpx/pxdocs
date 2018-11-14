PX allows you to create a heterogenous cluster where some of the nodes are storage nodes and rest of them are storageless.

You can specify the number of storage nodes in your cluster by setting the ```max_storage_nodes_per_zone``` input argument.
This instructs PX to limit the number of storage nodes in one zone to the value specified in ```max_storage_nodes_per_zone``` argument. The total number of storage nodes in your cluster will be
```
Total Storage Nodes = (Num of Zones) * max_storage_nodes_per_zone.
```

While planning capacity for your auto scaling cluster make sure the minimum size of your cluster is equal to the total number of storage nodes in PX. This ensures that when you scale up your cluster, only storage less nodes will be added. While when you scale down the cluster, it will scale to the minimum size which ensures that all PX storage nodes are online and available.

{{<info>}}You can always ignore the **max_storage_nodes_per_zone** argument. When you scale up the cluster, the new nodes will also be storage nodes but while scaling down you will loose storage nodes causing PX to loose quorum. {{</info>}}

Examples:

* `"-s", "type=gp2,size=200", "-max_storage_nodes_per_zone", "1"`

For a cluster of 6 nodes spanning 3 zones (us-east-1a,us-east-1b,us-east-1c), in the above example PX will have 3 storage nodes (one in each zone) and 3 storage less nodes. PX will create a total 3 disks of size 200 each and attach one disk to each storage node.

* `"-s", "type=gp2,size=200", "-s", "type=io1,size=100,iops=1000", "-max_storage_nodes_per_zone", "2"`

For a cluster of 9 nodes spanning 2 zones (us-east-1a,us-east-1b), in the above example PX will have 4 storage nodes and 5 storage less nodes. PX will create a total of 8 disks (4 of size 200 and 4 of size 100). PX will attach a set of 2 disks (one of size 200 and one of size 100) to each of the 4 storage nodes.