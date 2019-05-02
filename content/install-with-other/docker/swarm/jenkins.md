---
title: Deploy Jenkins on Swarm with Portworx
keywords: portworx, jenkins
description: Use Portworx to simplify the deployment of Jenkins running as a container. Check out our example to see for yourself!
weight: 3
linkTitle: Jenkins on Swarm with Portworx
---

Portworx can easily be used to simplify the deployment of Jenkins running as a container, as shown by the example below

## Create Portworx Volume
The example below create a 5GB "jenkins_vol1" volume, replicated on 3 different nodes.

```text
docker volume create -d pxd --name jenkins_vol1 --opt size=5 --opt repl=3
```

## Launch Jenkins through Docker
Using the name of the volume previously created, start up Jenkins as a container.

```text
docker run -d -p 49001:8080 -v jenkins_vol1:/var/jenkins_home:z -t jenkins
```

## Provide the Secret Password
Bring up a browser to the host where you launched Jenkins on port 49001.
You should see

![jenkins1](/img/jenkins1.png)

Run "docker ps" to find the CONTAINER ID of the Jenkins container:

```text
[root@mesos2 ~]# docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                                NAMES
9dfa72c4328c        jenkins                  "/bin/tini -- /usr/lo"   29 seconds ago      Up 23 seconds       50000/tcp, 0.0.0.0:49001->8080/tcp   ecstatic_ptolemy
```

Run the following command to extract the secret password (substituting the actual CONTAINER ID):

```text
docker exec -it 9dfa72c4328c cat /var/jenkins_home/secrets/initialAdminPassword
```

## Complete the Installation

Install the Suggested Plugins

![Install Suggested Plugins](/img/jenkins2.png)

Configure the Admin User

![Configure Admin User](/img/jenkins3.png)

Start Using Jenkins

![Start Using Jenkins](/img/jenkins4.png)

## How to speed up Jenkins

Be sure to read [How to speed up Jenkins builds](https://portworx.com/speed-up-jenkins-builds/) on the ways in which Portworx can help improve Jenkins performance and speed up CI/CD workloads.  

## Highly Resilient Jenkins Using Docker Swarm

Be sure to read [Highly Resilient Jenkins Using Docker Swarm](https://portworx.com/jenkins-docker-swarm/) on way to deploy fault-tolerant on Docker Swarm with Portworx
