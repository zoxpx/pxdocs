Below steps save all Portworx images into a tarball after which they can be loaded onto nodes individually.

1. Save all Portworx images into a tarball called _px-offline.tar_.

    ```text
    docker save -o px-offline.tar $PX_IMGS $PX_ENT
    ```

2. Load images from tarball

    You can load all images from the tarball on a node using `docker load` command. Below command uses ssh on nodes _node1_, _node2_ and _node3_ to copy the tarball and load it. Change the node names as per your environment.

    ```text
    for no in node1 node2 node3; do
        cat px-offline.tar | ssh $no docker load
    done
    ```