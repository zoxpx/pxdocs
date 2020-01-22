---
hidden: true
---

Perform the following steps to download `storkctl` from the Stork pod:

* Linux:

    ```text
    STORK_POD=$(kubectl get pods -n kube-system -l name=stork -o jsonpath='{.items[0].metadata.name}') &&
    kubectl cp -n kube-system $STORK_POD:/storkctl/linux/storkctl ./storkctl
    sudo mv storkctl /usr/local/bin &&
    sudo chmod +x /usr/local/bin/storkctl
    ```
* OS X:

    ```text
    STORK_POD=$(kubectl get pods -n kube-system -l name=stork -o jsonpath='{.items[0].metadata.name}') &&
    kubectl cp -n kube-system $STORK_POD:/storkctl/darwin/storkctl ./storkctl
    sudo mv storkctl /usr/local/bin &&
    sudo chmod +x /usr/local/bin/storkctl
    ```

* Windows:

    1. Copy `storkctl.exe` from the stork pod:

        ```text
        STORK_POD=$(kubectl get pods -n kube-system -l name=stork -o jsonpath='{.items[0].metadata.name}') &&
        kubectl cp -n kube-system $STORK_POD:/storkctl/windows/storkctl.exe ./storkctl.exe
        ```

    2. Move `storkctl.exe` to a directory in your PATH
