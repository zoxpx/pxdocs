---
title: Amazon ECS with Portworx
description: Find out how to deploy Portworx on Amazon Elastic Container Service (ECS)
keywords: portworx, amazon, docker, aws, ecs, cloud
weight: 3
linkTitle: Amazon ECS
noicon: true
series: px-other
---

This guide shows you how you can easily deploy Portworx on Amazon Elastic Container Service [**ECS**](https://aws.amazon.com/ecs/)

### Step 1: Create an ECS cluster
In this example, we create an ECS cluster called `ecs-demo1` using default AWS AMI (ami-b2df2ca4) and create two EC2 instances in the US-EAST-1 region.


As of this guide is written, the default ECS AMI uses Docker 1.12.6.
Note that Portworx recommends a minimum cluster size of 3 nodes.

#### Create the cluster in the console
Log into the ECS console and create an ecs cluster called "ecs-demo1".

![ecs-clust-create](/img/aws-ecs-setup_withPX_001y.PNG "ecs-1")


In the above example, the Container Instance IAM role is used by the ECS container agent. This ECS container agent is deployed by default with the EC2 instances from the ECS wizard. Note that this agent makes calls to AWS ECS API actions on your behalf. Thus, these EC2 instances that are running the ECS container agent require an IAM role that has permission to join ECS cluster and launch containers within the cluster.

Create a custom IAM role and Select Role Type "Amazon EC2 Role for Container Service". This is the minimal required permission to launch ECS cluster. And depending on your use case, you may need to set up additional AWS policies for your ECS to access and use other AWS resources. Below is the policy for the "AmazonEC2ContainerServiceRole":

```text
    {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:Describe*",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets"
             ],
            "Resource": "*"
          }
          ]
     }
```

Use the created custom IAM role `ECS` for this ECS cluster and the security group should allow inbound ssh access from your network.

Your EC2 instances must have the correct IAM role set. Follow these [IAM instructions](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html).

After the ECS cluster "ecs-demo1" successfully launches, the corresponding EC2 instances that belong to this ECS cluster can be found under the "ECS instance" tab of ECS console or from AWS EC2 console. Each of this EC2 instances is running with an amazon-ecs-agent in the docker container.

![ecs-clust-create](/img/aws-ecs-setup_withPX_003xx.PNG "ecs-3")

#### Add storage capacity to each EC2 instance
This section explains how to provision storage for these EC2 instances by creating new EBS volumes and attaching them to these EC2 instances. Portworx will be using the EBS volumes to provision storage to your containers. Below, we are creating a 20GB EBS volume in the same region "us-east-1b" of the launched EC2 instances. Ensure all ECS instances are attached with the EBS volumes.

![ecs-clust-create](/img/aws-ecs-setup_withPX_002y.PNG "ecs-2" )

![ecs-clust-create](/img/aws-ecs-setup_withPX_004yy.PNG "ecs-4")

Note that there is no need to format the EBS volumes once they are created and attached to the EC2 instance. Portworx will pick up the available unformatted drives (if you use the -a option as show below in the next step) or you can point to the appropriate block device for the Portworx to pick up by using the -s option when you launch Portworx with the docker run command.


### Step 2: Deploy Portworx

Install PX on each ECS instance. Portworx will use the EBS volumes you provisioned in step 4.

The installation and setup of PX OCI bundle is a 4-step process:

  1. Install the PX OCI bundle
  2. Configure PX under runC
  3. Download and Activate the Portworx service
  4. Enable log rotation

#### Step 2.1: Install the PX OCI bundle

Portworx provides a Docker based installation utility to help deploy the PX OCI
bundle.  This bundle can be installed by running the following Docker container
on your host system:

```text
latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock&stork=false' | awk '/image: / {print $2}')
# Download OCI bits (reminder, you will still need to run `px-runc install ..` after this step)
sudo docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable
```

#### Step 2.2: Configure PX under runC

Now that the PX OCI bundle has been deployed, we have to configure it by running the following:

```text
# Basic installation
sudo /opt/pwx/bin/px-runc install -sysd /dev/null -c MY_CLUSTER_ID \
  -k etcd://myetc.company.com:2379 \
  -s /dev/xvdb -s /dev/xvdc {{ include.sched-flags }}
```

#### Step 2.3: Download and Activate the Portworx service

Since the Amazon ECS systems do not have the `systemd` service available, we will need to start Portworx service via the custom init-script:

```text
sudo curl https://docs.portworx.com/install-with-other/ecs/portworx-sysvinit.sh -o /etc/rc.d/init.d/portworx
sudo chmod 755 /etc/rc.d/init.d/portworx
sudo chkconfig --add portworx
sudo service portworx start
```

#### Step 2.4: Enable log rotation

Finally, since the Portworx service creates some amount of log-files, we need to ensure these logs are recycled on regular basis, using systems' "logrotate" service:

```text
cat > /etc/logrotate.d/portworx << _EOF
/var/log/portworx.log {
  minsize 50M
  daily
  rotate 5
  missingok
  compress
  notifempty
  nocreate
  postrotate
      service portworx restart >/dev/null 2>&1 || true
  endscript
}
_EOF
```

### Step 3: Setup ECS task with PX volume from ECS CLI workstation
From your linux workstation download and setup AWS ECS CLI utilities

  1. Download and install ECS CLI ([detail instructions](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html))

    ```text
    sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
    sudo chmod +x /usr/local/bin/ecs-cli
    ```

  2. Configure AWS ECS CLI on your workstation

    ```text
    export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXX
    export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXX
    ecs-cli configure --region us-east-1 --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --cluster ecs-demo1
    ```

  3. Create a 1GB PX volume using the Docker CLI.  ssh into one of the ECS instances and create this PX volumes.

    ```text
    ssh -i ~/.ssh/id_rsa ec2-user@52.91.191.220
    docker volume create -d pxd --name=demovol --opt size=1 --opt repl=3 --opt shared=true
    ```

    ```output
    demovol
    ```

    ```text
    docker volume ls
    ```

    ```output
    DRIVER              VOLUME NAME
    pxd                 demovol
    ```


  4. From your ECS CLI workstation, which has the ecs-cli command, setup and launch the ECS task definition with previously created PX volume. Create a task definition file "redis.yml" which will launch two containers: redis based on redis image, and web based on binocarlos/moby-counter. Then, use the ecs-cli command to post this task definition and launch it.

    ```text
    cat redis.yml
    ```

    ```output
      web:
      image: binocarlos/moby-counter
      links:
        -  redis:redis
      redis:
      image: redis
      volumes:
        -  demovol:/data
    ```

    ```text
    ecs-cli compose --file redis.yml up
    ```

    ```output
    INFO[0001] Using ECS task definition                     TaskDefinition="ecscompose-root:1"
    INFO[0001] Starting container...                         container="59701c44-c267-4c85-a8c0-ff87910af535/web"
    INFO[0001] Starting container...                         container="59701c44-c267-4c85-a8c0-ff87910af535/redis"
    INFO[0001] Describe ECS container status                 container="59701c44-c267-4c85-a8c0-ff87910af535/redis" desiredStatus=RUNNING lastStatus=PENDING taskDefinition="ecscompose-root:1"
    INFO[0001] Describe ECS container status                 container="59701c44-c267-4c85-a8c0-ff87910af535/web" desiredStatus=RUNNING lastStatus=PENDING taskDefinition="ecscompose-root:1"
    INFO[0013] Started container...                          container="59701c44-c267-4c85-a8c0-ff87910af535/redis" desiredStatus=RUNNING lastStatus=RUNNING taskDefinition="ecscompose-root:1"
    INFO[0013] Started container...                          container="59701c44-c267-4c85-a8c0-ff87910af535/web" desiredStatus=RUNNING lastStatus=RUNNING taskDefinition="ecscompose-root:1"
    ```

    ```text
    ecs-cli ps
    ```

    ```output
    Name                                               State    Ports                                                          TaskDefinition
    59701c44-c267-4c85-a8c0-ff87910af535/redis         RUNNING                                                                 ecscompose-root:1
    59701c44-c267-4c85-a8c0-ff87910af535/web           RUNNING                                                                 ecscompose-root:1
    ```

  5. You can also view the task status in the ECS console.
  ![task](/img/aws-ecs-setup_withPX_003t.PNG "ecs3t")

  6. On the above ECS console, Clusters -> pick your cluster `ecs-demo1` and click on the `Container Instance` ID that corresponding to the running task. This will display the containers' information including where are these containers deployed, into which EC2 instance. Below, we find that the task defined containers are deployed on EC2 instance with public IP address `52.91.191.220`.
  ![task](/img/aws-ecs-setup_withPX_003z.PNG "ecs3z")
  7. From above, ssh into the EC2 instance `52.91.191.220` and verify PX volume is attached to running container.

    ```text
    sudo docker ps -a
    ```

    ```output
    CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                             NAMES
    7ba93d51918b        binocarlos/moby-counter          "node index.js"          12 hours ago        Up 12 hours         80/tcp                                            ecs-ecscompose-root-1-web-c2fbfff3bf92b1dad401
    e25ba9131f9b        redis                            "docker-entrypoint.sh"   12 hours ago        Up 12 hours         6379/tcp                                          ecs-ecscompose-root-1-redis-a6a6a2fcb4a6d188e601
    ```

    ```text
    pxctl v l
    ```

    ```output
    ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
    1061916907972944739     demovol                 1 GiB   3       yes     no              LOW             0       up - attached on 172.31.31.61
    ```
  8. Check the `ecs-ecscompose-root-1-redis-a6a6a2fcb4a6d188e601` redis container  and verify that a 1GB pxfs volume is mounted on /data:

    ```text
    sudo docker exec -it ecs-ecscompose-root-1-redis-a6a6a2fcb4a6d188e601 sh -c 'df -kh'
    ```

    ```output
    Filesystem                                                                                        Size  Used Avail Use% Mounted on
    /dev/mapper/docker-202:1-263203-3f7e353e23d7ba722fc74d1fb7db60e34f98933355ac65f78e6b4f2bcde19778  9.8G  215M  9.0G   3% /
    tmpfs                                                                                             3.9G     0  3.9G   0% /dev
    tmpfs                                                                                             3.9G     0  3.9G   0% /sys/fs/cgroup
    pxfs                                                                                              976M  2.5M  907M   1% /data
    /dev/xvda1                                                                                        7.8G  1.3G  6.5G  16% /etc/hosts
    shm                                                                                                64M     0   64M   0% /dev/shm
  ```


### Step 4: Setup ECS task with PX volume via AWS ECS console
#### Optional: the same process of step3 but do it on AWS GUI

Create a ECS tasks definition directly via the ECS console (GUI) and using PX volume.

  1. ssh into one of the EC2 instance and create a new PX volume using Docker CLI.

    ```text
    docker volume create -d pxd --name=demovol --opt size=1 --opt repl=3 --opt shared=true
    ```

  2. In AWS ECS console, choose the previously created cluster `ecs-demo1`; then create a new task definition.
   ![task](/img/aws-ecs-setup_withPX_005y.PNG)
  3. From the new task definition screen, enter the task definition name `redis-demo` and click `Add volume` near the bottom of the page.
  ![task](/img/aws-ecs-setup_withPX_005yy.PNG)
  4. Enter the `Name` in the Add volume screen, that is just the name for your volume defined in this task definition and no need to be the same as the PX volume name. Then enter the `Source path`, and this is the PX volume name `demovol`.
  ![task](/img/aws-ecs-setup_withPX_005yyx.PNG)
  5. After added the volume, click `Add container` button to define your containers specification.
  ![task](/img/aws-ecs-setup_withPX_006y.PNG)
  6. From the `Add container` screen, enter the `Container name` "redis"  and `Image*` "redis" ; then click the `Add` button.
  ![task](/img/aws-ecs-setup_withPX_006z.PNG)
  7. To add another container, on the same  Create a Task Definition screen, click `Add container` button. On the Add container screen, enter the `Container name` "web" and `Image*` ["binocarlos/moby-counter"](https://hub.docker.com/r/binocarlos/moby-counter/) and on `NETWORK SETTINGS` `Links` enter "redis:redis" ; then on `STORAGE AND LOGGING` `Mount Points` select from drop down "volume0" and enter the `Container path` "/data" ; and then click the `Add` button.
  ![task](/img/aws-ecs-setup_withPX_007y.PNG)
  8. On the same task definition screen, click `create` button at the of the screen.
  ![task](/img/aws-ecs-setup_withPX_008y.PNG)
  9. From the AWS ECS console, Task Definitions, select the definition "redis-demo" and click `Actions` and select `run`
  ![task](/img/aws-ecs-setup_withPX_009y.PNG)
  10. Click `Run Task`
  ![task](/img/aws-ecs-setup_withPX_010y.PNG)
  11. You will see the task is submitted and change status from `PENDING` to `RUNNING`.
  ![task](/img/aws-ecs-setup_withPX_011y.PNG)
  ![task](/img/aws-ecs-setup_withPX_012y.PNG)
