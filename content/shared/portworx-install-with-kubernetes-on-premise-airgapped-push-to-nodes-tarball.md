---
hidden: true
---

Follow these steps to save the Portworx images into a tarball and then load them onto your nodes indivudally.

1. Save all Portworx images into a tarball called `px-offline.tar` by running:

    ```text
    docker save -o px-offline.tar $PX_IMGS $PX_ENT
    ```

2. Load the images from the tarball

    You can load all images from the tarball on a node using the `docker load` command. The following command uses `ssh` on `node1`, `node2` and `node3` to copy the tarball and load it. Change the names of the nodes to match your environment.

    ```text
    for no in node1 node2 node3; do
        cat px-offline.tar | ssh $no docker load
    done
    ```
