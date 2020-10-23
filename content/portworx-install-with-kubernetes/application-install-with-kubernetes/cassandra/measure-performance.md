---
title: Performance
linkTitle: Performance
description: Measure the performance of Cassandra with Portworx on Kubernetes
keywords: portworx, containers, cassandra, storage, performance, stress test
weight: 6
---

<!--Maybe we should move this to the Docker section -->

In this section, you will use Docker containers running directly on EC2 instances. Running Cassandra on Docker is one of the most common use-cases of Portworx. Note that you can choose a different method of installing Cassandra, depending on your orchestration environment.

### Set up the environment

1. Create three Docker containers on three AWS `r4.2xlarge` machines with 60GB of RAM and 120GB of disk space available for Portworx.

2. Create a three-node Portworx cluster. On each container, enter the following command, replacing the following values to match your environment:

  * The address of your etcd endpoint (this example uses ` etcd://172.31.45.219:4001`)
  * The cluster ID (this example uses `PXCassTest001`)
  * The list of storage devices your Portworx node should use (this example uses `/dev/xvdb`)

    ```text
    docker run --restart=always --name px -d --net=host      \
               --privileged=true                             \
               -v /run/docker/plugins:/run/docker/plugins    \
               -v /var/lib/osd:/var/lib/osd:shared           \
               -v /dev:/dev                                  \
               -v /etc/pwx:/etc/pwx                          \
               -v /opt/pwx/bin:/export_bin:shared            \
               -v /var/run/docker.sock:/var/run/docker.sock  \
               -v /var/cores:/var/cores                      \
               -v /usr/src:/usr/src                          \
               --ipc=host                                    \
               portworx/px-enterprise -daemon -k etcd://172.31.45.219:4001 -c PXCassTest001 -s /dev/xvdb
    ```

3. Create three Portworx volumes. Enter the following `pxctl volume create` command specifying the following:

  * The name of your volume (this example uses "CVOL-`hostname`")
  * The `--size` flag with the size of your disk (this example creates 60GB disks)
  * The `--nodes` flag as `LocalNode`

    ```text
    pxctl volume create CVOL-`hostname` --size 60 --nodes LocalNode
    ```

4. List your volumes:

    ```text
    pxctl volume list
    ```

    ```output
    ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
    999260470129557090      CVOL-ip-172-31-32-188   60 GiB  1       no      no              LOW             1       up - detached
    973892635505817385      CVOL-ip-172-31-45-219   60 GiB  1       no      no              LOW             1       up - detached
    446982770798983273      CVOL-ip-172-31-47-121   60 GiB  1       no      no              LOW             1       up - detached
    ```

5. Create three Cassandra containers that are using the new Portworx volumes. <!-- We should provide the commands -->
    {{<info>}}
**NOTE:** Portworx uses port 7000, which is Cassandra's default data and storage port. To avoid a conflict, you must edit your `cassandra.yaml` file manually, or download this [`cassandra_conf.tar` file](https://s3.amazonaws.com/rlui-dcos-hadoop/cassandra_conf.tar) and extract it in the `/etc` folder. This step is not required if you are running on Kubernetes or Mesosphere.
  {{</info>}}

6. On each node, set the following environment variables that are pointing to the IP addresses of your nodes:

    ```text
    NODE_1_IP=<IP-OF-THE-FIRST-NODE>
    NODE_2_IP=<IP-OF-THE-SECOND-NODE>
    NODE_3_IP=<IP-OF-THE-THIRD-NODE>
    ```

7. Use the `docker run` command to launch your Cassandra containers:

  * On the first node:

    ```text
    docker run  --name cass-`hostname` -e CASSANDRA_BROADCAST_ADDRESS=`hostname -i`      \
              -p 17000:17000 -p 7001:7001 -p 9042:9042 -p 9160:9160 -p 7199:7199       \
              -v /etc/cassandra:/etc/cassandra                                         \
              -v CVOL-`hostname`:/var/lib/cassandra                                    \
              -d cassandra:latest
    ```
  * On the second node:

    ```text
    docker run  --name cass-`hostname` -e CASSANDRA_BROADCAST_ADDRESS=`hostname -i`      \
              -e CASSANDRA_SEEDS=${NODE_1_IP}                                          \
              -p 17000:17000 -p 7001:7001 -p 9042:9042 -p 9160:9160 -p 7199:7199       \
              -v /etc/cassandra:/etc/cassandra                                         \
              -v CVOL-`hostname`:/var/lib/cassandra                                    \
              -d cassandra:latest
    ```

  * On the third node:

    ```text
    docker run  --name cass-`hostname` -e CASSANDRA_BROADCAST_ADDRESS=`hostname -i`      \
              -e CASSANDRA_SEEDS=${NODE_1_IP},${NODE_2_IP}                             \
              -p 17000:17000 -p 7001:7001 -p 9042:9042 -p 9160:9160 -p 7199:7199       \
              -v /etc/cassandra:/etc/cassandra                                         \
              -v CVOL-`hostname`:/var/lib/cassandra                                    \
              -d cassandra:latest
    ```

3. Verify your installation. Use the following `docker exec` command to run the `nodetool status` command on one of your Cassandra containers, replacing the IP address of the Cassandra container to match your environment.

    ```text
    docker exec -it cass-ip-<IP-ADDRESS> sh -c 'nodetool status'
    ```

    ```output
      Datacenter: datacenter1
      =======================
      Status=Up/Down
      |/ State=Normal/Leaving/Joining/Moving
      --  Address        Load       Tokens       Owns (effective)   Host ID                               Rack
      UN  172.31.32.188  108.65 KiB  256          65.7%             7aa8a83e-1378-4aa1-b9d2-3008b3550b69  rack1
      UN  172.31.45.219  84.33 KiB  256           66.0%             b455c82e-9649-4724-adf1-dae09ec2c616  rack1
      UN  172.31.47.121  108.29 KiB  256          68.3%             26ffac02-2975-4921-b5d0-54f3274bfe84  rack1
      ```

### Run the performance test

1. Simultaneously execute the `cassandra-stress` command on each node. The following example command performs a stress test that starts four threads and inserts 10.000 objects in the `TestKEYSPACE` keyspace:

  * On the first node

    ```text
    docker exec -it cass-`hostname` cassandra-stress write n=10000                 \
      cl=quorum -mode native cql3 -rate threads=4 -schema keyspace="TestKEYSPACE01"  \
      "replication(factor=2)" -pop seq=1..10000 -log file=~/Test_10Kwrite_001.log    \
      -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
    ```

    ```output
      ******************** Stress Settings ********************
      Command:
      Type: write
      Count: 10,000
      No Warmup: false
      Consistency Level: QUORUM
      Target Uncertainty: not applicable
      Key Size (bytes): 10
      Counter Increment Distibution: add=fixed(1)
      Rate:
        Auto: false
        Thread Count: 4
        OpsPer Sec: 0
      Population:
      Sequence: 1..10000
      Order: ARBITRARY
      Wrap: true
      Insert:
        Revisits: Uniform:  min=1,max=1000000
        Visits: Fixed:  key=1
        Row Population Ratio: Ratio: divisor=1.000000;delegate=Fixed:  key=1
        Batch Type: not batching
      Columns:
        Max Columns Per Key: 5
        Column Names: [C0, C1, C2, C3, C4]
        Comparator: AsciiType
        Timestamp: null
        Variable Column Count: false
        Slice: false
        Size Distribution: Fixed:  key=34
      Count Distribution: Fixed:  key=5
      Errors:
        Ignore: false
        Tries: 10
      Log:
        No Summary: false
        No Settings: false
        File: /root/Test_10Kwrite_001.log
        Interval Millis: 1000
    Level: NORMAL
    Mode:
        API: JAVA_DRIVER_NATIVE
        Connection Style: CQL_PREPARED
        CQL Version: CQL3
        Protocol Version: V4
        Username: null
        Password: null
        Auth Provide Class: null
        Max Pending Per Connection: 128
        Connections Per Host: 8
        Compression: NONE
    Node:
        Nodes: [172.31.32.188, 172.31.45.219, 172.31.47.121]
    Is White List: false
    Datacenter: null
    Schema:
        Keyspace: TestKEYSPACE
        Replication Strategy: org.apache.cassandra.locator.SimpleStrategy
        Replication Strategy Pptions: {replication_factor=2}
        Table Compression: null
        Table Compaction Strategy: null
        Table Compaction Strategy Options: {}
    Transport:
    factory=org.apache.cassandra.thrift.TFramedTransportFactory; truststore=null; truststore-password=null; keystore=null; keystore-password=null; ssl-protocol=TLS; ssl-alg=SunX509; store-type=JKS; ssl-ciphers=TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA;
    Port:
      Native Port: 9042
      Thrift Port: 9160
      JMX Port: 7199
    Send To Daemon:
      *not set*
    Graph:
      File: null
      Revision: unknown
      Title: null
      Operation: WRITE
      TokenRange:
      Wrap: false
      Split Factor: 1

    Connected to cluster: Test Cluster, max pending requests per connection 128, max connections per host 8
    Datatacenter: datacenter1; Host: /172.31.32.188; Rack: rack1
    Datatacenter: datacenter1; Host: /172.31.45.219; Rack: rack1
    Datatacenter: datacenter1; Host: /172.31.47.121; Rack: rack1
    Created keyspaces. Sleeping 3s for propagation.
    Sleeping 2s...
    Warming up WRITE with 7500 iterations...
    Failed to connect over JMX; not collecting these stats
    Running WRITE with 4 threads for 10000 iteration
    Failed to connect over JMX; not collecting these stats
    type       total ops,    op/s,    pk/s,   row/s,    mean,     med,     .95,     .99,    .999,     max,   time,   stderr, errors,  gc: #,  max ms,  sum ms,  sdv ms,      mb
    total,          1303,    1303,    1303,    1303,     1.8,     1.2,     4.9,    11.0,    17.0,    21.7,    1.0,  0.00000,      0,      0,       0,       0,       0,       0
    total,          4324,    3021,    3021,    3021,     1.3,     1.1,     2.3,     6.1,    12.8,    14.9,    2.0,  0.27888,      0,      0,       0,       0,       0,       0
    total,          7819,    3495,    3495,    3495,     1.1,     1.1,     1.3,     2.0,    11.0,    16.7,    3.0,  0.20770,      0,      0,       0,       0,       0,       0
    total,         10000,    2692,    2692,    2692,     1.5,     1.1,     3.3,     9.2,    12.1,    13.5,    3.8,  0.15468,      0,      0,       0,       0,       0,       0


    Results:
    Op rate                   :    2,624 op/s  [WRITE: 2,624 op/s]
    Partition rate            :    2,624 pk/s  [WRITE: 2,624 pk/s]
    Row rate                  :    2,624 row/s [WRITE: 2,624 row/s]
    Latency mean              :    1.3 ms [WRITE: 1.3 ms]
    Latency median            :    1.1 ms [WRITE: 1.1 ms]
    Latency 95th percentile   :    2.2 ms [WRITE: 2.2 ms]
    Latency 99th percentile   :    7.5 ms [WRITE: 7.5 ms]
    Latency 99.9th percentile :   12.9 ms [WRITE: 12.9 ms]
    Latency max               :   21.7 ms [WRITE: 21.7 ms]
    Total partitions          :     10,000 [WRITE: 10,000]
    Total errors              :          0 [WRITE: 0]
    Total GC count            : 0
    Total GC memory           : 0.000 KiB
    Total GC time             :    0.0 seconds
    Avg GC time               :    NaN ms
    StdDev GC time            :    0.0 ms
    Total operation time      : 00:00:03

    END
  ```


* On the second node:

    ```text
    docker exec -it cass-`hostname` cassandra-stress write n=10000                  \
      cl=quorum -mode native cql3 -rate threads=4 -schema keyspace="TestKEYSPACE01"   \
      "replication(factor=2)" -pop seq=10001..20000 -log file=~/Test_10Kwrite_002.log \
      -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
    ```

* On the third node:

    ```text
    docker exec -it cass-`hostname` cassandra-stress write n=10000                   \
      cl=quorum -mode native cql3 -rate threads\>=72 -schema keyspace="TestKEYSPACE01" \
      "replication(factor=2)" -pop seq=20001..30000 -log file=~/Test_10Kwrite_003.log  \
      -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
    ```

<!--
What do we want to say?

If the above Cassandra test passes without any issue, the number of inserted objects and threads can be adjusted in such a way to produce a more accurate result.
-->

<!--
I think we can drop this section

Below is an example to insert 10 million objects into the target keyspace with threads `>= 72`. When using threads `>=72`, Cassandra Stress will run several cycles in threads `72, 108, 162, 243, 364, 546 and 819`

```text
docker exec -it cass-`hostname` cassandra-stress write n=10000000                 \
  cl=quorum -mode native cql3 -rate threads\>=72 -schema keyspace="TestKEYSPACE01"  \
  "replication(factor=2)" -pop seq=1..10000000 -log file=~/Test_10Mwrite_001.log    \
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

After a write test, you can do a mixed test which is write/read; however, a write test must be done before any mixed test:

```text
docker exec -it cass-`hostname` cassandra-stress mixed n=10000000                 \
  cl=quorum -mode native cql3 -rate threads\>=72 -schema keyspace="TestKEYSPACE01"  \
  "replication(factor=2)" -pop seq=1..10000000 -log file=~/Test_10Mmixed_001.log    \
  -node ${NODE_1_IP},${NODE_2_IP},${NODE_3_IP}
```

Generally, Cassandra stress test should be run on every Cassandra container about the same time to increase the load. Also, since the test should use the same keyspace on the same test run, it is required to use a different `sequence` to separate between each container's operation on the same keyspace `(e.g. 1..10000 and 10001..20000 and so on)`.
-->