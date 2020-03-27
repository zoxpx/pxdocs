---
title: Install a backup license server
description: CLI reference for lsctl commands
keywords: lsctl, CLI, command line, command line tool, reference
weight: 3
hidden: true
---

After you've created your license server, but before you add licenses, you can create a backup license server. A backup license server synchronizes with your main license server to provide high availability (HA), which protects your Portworx clusters from interruption in the event that your primary server experiences a problem.

## Prerequisites

* The Docker service installed and running
* The `docker-compose` command available
* Your existing license server's credentials; you must use the same credentials for both the main and backup license servers.

## Enable HA

{{<info>}}
**NOTE:** If you downloaded the Portworx license server docker image directly to your license server, pull the Portworx license server from portworx onto a computer that can access the internet and send it to your air-gapped cluster. The following example sends the docker image to the air-gapped cluster over ssh:

```text
sudo docker pull portworx/px-els:1.0.0
sudo docker save portworx/px-els:1.0.0 | ssh root@<air-gapped-address> docker load
```
{{</info>}}

1.  Create and start the following `docker-compose.yml` file, specifying the following:

    * **services.px-els-main.command:** If your cluster is air-gapped, add `--air-gapped` and `--nic` with the network interface your host uses to connect with the rest of the cluster.:

    ```text
    version: '2.2'
    services:
      px-els-main:
        container_name: px-els-backup
        image: portworx/px-els:1.0.0
        # command: -nic eth0 -extl-port 7070
        privileged: true
        network_mode: host
        restart: always
        volumes:
          - /opt/pwx-ls/bin:/export_bin
          - /etc/pwx-ls:/data
          - /proc:/hostproc
        healthcheck:
            test: ["CMD", "curl", "-fI", "http://127.0.0.1:7069/api/1.0/instances/~/health"]
            interval: 2m30s
            timeout: 30s
            retries: 3
    ```

    {{<info>}}
**NOTE:**

* You must use the same credentials for both the main and backup license servers.
* You can change the admin password with the `lsctl users passwd admin` command.
    {{</info>}}

    ```text
    docker-compose up -d
    ```
    ```output
    Creating px-els ... done
    ```

3. Verify the license server's status by entering the `docker-compose logs` command with the `-f` option:

    ```text
    docker-compose logs -f
    ```
    ```output
    Attaching to px-els
    ...
    px-els         | time="2020-02-11T03:45:35Z" level=info msg="License server RUNNING as PxProxyServer{id=0xc0001ee5d0,ver=px-els/1.0.0-34-gc154428,addr=:7070,SSL=false} ..."
    ```
    The message beginning with `License server RUNNING` indicates success.

3. Log in to your main license server and enable high availability (HA). Enter the `lsctl ha conf` command and the `-m` flag with the IP of your main license server and the `-b` flag with the IP of your backup license server:

    ```text
    /opt/pwx-ls/bin/lsctl login -u admin -p password http://<main-host>:<main-port>
    /opt/pwx-ls/bin/lsctl ha conf -m http://<main-host>:<main-port> -b http://<backup-host>:<backup-port>
    ```
    ```output
    WARN[0000] Changed main URL from http://<host>:7070 to http://192.0.2.0:7070/fne/bin/capability
    WARN[0000] Changed backup URL from <host> to http://192.0.2.1:7070/fne/bin/capability
    INFO[0000] Backup license server updated
    INFO[0000] Main license server updated (restarting in 15 seconds)
    > Restarting Main license server: .....................
    INFO[0048] Successfully set up Main/Backup license servers for HA
    ```

4. Verify your HA configuration:

    ```text
    /opt/pwx-ls/bin/lsctl ha info
    ```
    ```output
    High Availability configuration (Main):
                                Main URI : http://70.0.0.129:7070/fne/bin/capability
                              Backup URI : http://70.0.97.67:7070/fne/bin/capability
         Synchronization to Main enabled : false                                          (Mandatory on backup server)
                Synchronization pagesize : 100
                Synchronization interval : 5m
             Synchronization retry count : 1
   Synchronization retry repeat interval : 1m
        Active license server identifier : AC1F6B221662/ETHERNET
        Backup license server identifier : 000C2909B6BD/ETHERNET
    ```

Once you've created and configured your license servers, you can [populate the licenses on the main license server](/reference/cli/lsctl/add-licenses).

<!-- verified -->
