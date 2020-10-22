---
title: Monitor operator shared content
keywords: 
description: monitor operator shared content
hidden: true
---

### Monitor the Portworx nodes

1. Enter the following kubectl get command, waiting until all Portworx nodes show as ready in the output:

    ```text
    kubectl -n kube-system get storagenodes -l name=portworx
    ```

2. Enter the following kubectl describe command with the NAME of one of the Portworx nodes to show the current installation status for individual nodes:

    ```text
    kubectl -n kube-system describe storagenode <portworx-node-name>
    ```
    ```output
    Events:
    Type     Reason                             Age                     From                  Message
    ----     ------                             ----                    ----                  -------
    Normal   PortworxMonitorImagePullInPrgress  7m48s                   portworx, k8s-node-2  Portworx image portworx/px-enterprise:2.5.0 pull and extraction in progress
    Warning  NodeStateChange                    5m26s                   portworx, k8s-node-2  Node is not in quorum. Waiting to connect to peer nodes on port 9002.
    Normal   NodeStartSuccess                   5m7s                    portworx, k8s-node-2  PX is ready on this node
    ```

    {{<info>}}
**NOTE:** In your output, the image pulled will differ based on your chosen Portworx license type and version.
    {{</info>}}