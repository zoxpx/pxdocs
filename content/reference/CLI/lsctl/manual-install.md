---
title: Manually install a Portworx license server
description: CLI reference for lsctl commands
keywords: lsctl, CLI, command line, command line tool, reference
weight: 2
hidden: true
---

Perform the steps in this topic to manually install a Portworx license server.

## Prerequisites

* The Docker service installed and running
* The `docker-compose` command available

## Manually install a Portworx license server

1. Pull the license server from Portworx:

    ```text
    docker pull portworx/px-els:1.0.0
    ```

    {{<info>}}
**NOTE:** If your cluster is air-gapped, you must first pull the Portworx license server Docker images to either your docker registry, or the server itself:

  * If you have a company-wide docker-registry server, pull the Portworx license server from Portworx:

    ```text
    sudo docker pull portworx/px-els:1.0.0
    sudo docker tag portworx/px-els:1.0.0 <company-registry-hostname>:5000/portworx/px-els:1.0.0
    sudo docker push <company-registry-hostname>:5000/portworx/px-els:1.0.0
    ```

  * If you do not have a company-wide docker-registry server, pull the Portworx license server from portworx onto a computer that can access the internet and send it to your air-gapped cluster. The following example sends the docker image to the air-gapped cluster over ssh:

    ```text
    sudo docker pull portworx/px-els:1.0.0
    sudo docker save portworx/px-els:1.0.0 | ssh root@<air-gapped-address> docker load
    ```
    {{</info>}}

2. Create and start the following `docker-compose.yml` file, adding any options to the following **services.px-els-main.command:** line:

    * If your cluster is air-gapped, add `--air-gapped` and `--nic` with the network interface your host uses to connect with the rest of the cluster.
    * If you're using SSL, add `-enable-ssl`. If you're using non-default paths for your SSL certificates, you may need to append the command above with the `-ssl-certs </path/to/server-bundle.pem>` and `-ssl-key /path/to/server-key.pem` flags.

    ```text
    version: '2.2'
    services:
      px-els-main:
        container_name: px-els
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

4. Once the License Server is operational, log in to it by entering the `lstcl login` command, specifying the `-u admin` and `-p 'Adm1n!Ur'` flags and credentials with the url of your license server:

    ```text
    /opt/pwx-ls/bin/lsctl login -u admin -p 'Adm1n!Ur' http://<host>:<port>
    ```

    {{<info>}}
**NOTE:** If you enabled SSL, you must first log in using the `lsctl login -u admin https://...` command before using other lsctl commands.
    {{</info>}}

5. Verify the deployment completed successfully:

    ```text
    /opt/pwx-ls/bin/lsctl info health
    ```
    ```output
    INFO[0000] ELS instanceID TPAXKSG96V6J reports healthy status
    ```

6. Connect your Portworx cluster or clusters to the license server. From one of your Portworx worker nodes, Enter the following `pxctl` command, specifying the `<host>` and `<port>` of your license server:

    ```text
    /opt/pwx/bin/pxctl license setls http://<host>:<port>/fne/bin/capability
    ```
    ```output
    Successfully set license server.
    ```

7. (Recommended) [Create a backup server and enable high availability](/reference/cli/lsctl/install-backup-server/).

    {{<info>}}
**IMPORTANT:** You cannot enable high availability after adding your licenses.

If you _did not_ enable high availability prior to adding your licenses, the `lsctl ha conf` command will fail. If this happens to you, please contact Portworx support to update your license.
    {{</info>}}

Once you've installed your license server and, optionally, your backup license server, you're ready to add your licenses.

<!-- verified -->
