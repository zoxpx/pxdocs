---
hidden: true
---

The following steps can be used to download `storkctl`:

* Linux:

    ```text
    curl http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/linux/storkctl -o storkctl &&
    sudo mv storkctl /usr/local/bin &&
    sudo chmod +x /usr/local/bin/storkctl
    ```
* OS X:

    ```text
    curl http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/darwin/storkctl -o storkctl &&
    sudo mv storkctl /usr/local/bin &&
    sudo chmod +x /usr/local/bin/storkctl
    ```

* Windows:
    * Download [storkctl.exe](http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/latest/windows/storkctl.exe)
    * Move `storkctl.exe` to a directory in your PATH
