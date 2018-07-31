# Redis

 This page provides instructions for deploying Redis with Portworx on Kubernetes.

### Create a storage volume for Redis

To create a Portworx storage volume for Redis, use the `docker volume create` command:

```text
docker volume create -d pxd --name=redis_vol --opt \
     	size=4 --opt block_size=64 --opt repl=1 --opt fs=ext4
```

### Start the Redis container {#start-the-redis-container}

To start the Redis container using the `redis_vol` volume created above, run the command below. \(Use the Docker \`-v’ option to attach the Portworx volume to the `/data` directory, which is where Redis stores its data\).

```text
docker run --name some-redis  -v redis_vol:/data --volume-driver=pxd  -d redis redis-server --appendonly yes
```

Your Redis container is now available for use on port 6379.

### Start the redis CLI client container {#start-the-redis-cli-client-container}

```text
docker run -it --link some-redis:redis --rm redis redis-cli -h redis -p 6379
```

### Populate the redis instance with some data {#populate-the-redis-instance-with-some-data}

```text
redis:6379> set foo 100
OK
redis:6379> incr foo
(integer) 101
redis:6379> append foo abcxxx
(integer) 9
redis:6379> get foo
"101abcxxx"
redis:6379>
```

### Kill the "some-redis" instance {#kill-the-some-redis-instance}

```text
docker kill some-redis
```

### Start a new redis-server instance with volume persistance {#start-a-new-redis-server-instance-with-volume-persistance}

Start another redis-server container called `other-redis` using the original `redis_vol` to show data persistance.

```text
docker run --name other-redis  -v redis_vol:/data --volume-driver=pxd  -d redis redis-server --appendonly yes
```

### Start a redis CLI container {#start-a-redis-cli-container}

Connect to the new `other-redis` container with the following command.

```text
docker run -it --link other-redis:redis --rm redis redis-cli -h redis -p 6379
```

### See that the original data has persisted {#see-that-the-original-data-has-persisted}

```text
redis:6379> get foo
"101abcxxx"
```

### Create snapshot of your volume {#create-snapshot-of-your-volume}

You can create container-granular snapshots, by saving just this container’s state. Snapshots are then immedidately available as a volume.

Create a snapshot of the `redis_vol` volume using `pxctl`.

```text
pxctl volume list
ID			NAME		SIZE	HA	STATUS
416765532972737036	redis_vol	2.0 GiB	1	up - attached on 3abe5484-756c-4076-8a80-7b7cd5306b28

pxctl snap create 416765532972737036
Volume successfully snapped:  3291428813175937263
```

### Update the volume with new data {#update-the-volume-with-new-data}

```text
docker run -it --link other-redis:redis --rm redis redis-cli -h redis -p 6379
redis:6379> get foo
"101abcxxx"
redis:6379> set foo foobar
OK
redis:6379> get foo
"foobar"
```

### See that the snapshot volume still contains the original data {#see-that-the-snapshot-volume-still-contains-the-original-data}

```text
docker run --name snap-redis -v 3291428813175937263:/data --volume-driver=pxd -d redis redis-server --appendonly yes
940d2ad6b87df9776e26d29e746eb05fb6081c0e6019d46ba77915d7c8305308

docker run -it --link snap-redis:redis --rm redis redis-cli -h redis -p 6379
redis:6379> get foo
"101abcxxx"
redis:6379>
```

