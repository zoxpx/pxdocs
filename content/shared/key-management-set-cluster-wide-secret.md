---
hidden: true
---

A cluster wide secret key is a common key that can be used to encrypt all your volumes. You can set the cluster secret key using the following command.

```text
pxctl secrets set-cluster-key
```

```output
Enter cluster wide secret key: *****
Successfully set cluster secret key!
```

This command needs to be run just once for the cluster. If you have added the cluster secret key through the config.json, the above command will overwrite it. Even on subsequent Portworx restarts, the cluster secret key in config.json will be ignored for the one set through the CLI.
