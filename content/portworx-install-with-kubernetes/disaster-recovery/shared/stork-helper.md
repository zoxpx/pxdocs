The following steps can be used to download `storkctl`:

* Linux:

    ```bash
    curl http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/2.0.0/linux/storkctl -o storkctl &&
    sudo mv storkctl /usr/local/bin &&
    sudo chmod +x /usr/local/bin/storkctl
    ```
* OS X:

    ```bash
    curl http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/2.0.0/darwin/storkctl -o storkctl &&
    sudo mv storkctl /usr/local/bin &&
    sudo chmod +x /usr/local/bin/storkctl
    ```

* Windows:
    * Download [storkctl.exe](http://openstorage-stork.s3-website-us-east-1.amazonaws.com/storkctl/2.0.0/windows/storkctl.exe)
    * Move `storkctl.exe` to a directory in your PATH
