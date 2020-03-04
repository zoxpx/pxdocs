---
title: Add licenses to a license server using lsctl
linkTitle: Add licenses using lsctl
description: CLI reference for lsctl commands
keywords: lsctl, CLI, command line, command line tool, reference
weight: 5
hidden: true
---

The Portworx license server initially contains no licenses. You must add licenses to it before you can associate them with your Portworx cluster. You can activate licenses using `lsctl`; how you do that depends on whether your license server is capable of accessing the internet.

## Prerequisites

License server must be installed before you can add licenses to it.

## Add licenses to a license server using lsctl

Choose one of the following methods for adding licenses depending on whether or not your environment has access to the internet:

### Activate licenses over the internet

If your license server is connected to the internet, you can add licenses by entering the activation ID provided in your onboarding materials.

Enter the `lsctl license activate` command, specifying your `<activation-id>`:

```text
/opt/pwx-ls/bin/lsctl license activate <activation-id>
```
```output
INFO[0013] Successfully activated licenses.
```

<!-- verified -->

### Add licenses using an offline activation file

If your license server is air-gapped or otherwise unable to connect to the internet, you can add licenses by  obtaining an offline activation file from Portworx support and uploading and adding it to your license server:

1. Enter one of the following `lsctl` commands on your main license server, depending on whether or not you're running a standalone license server, or license servers in high availability:

    * If you're running a standalone license server, enter the `lsctl info hostids` command:

        ```text
        /opt/pwx-ls/bin/lsctl info hostids
        ```
    * If you're running license servers in high availability:

        ```text
        /opt/pwx-ls/bin/lsctl ha info
        ```

    Save the output and send it to Portworx Support to obtain an offline activation file.

2. Copy the offline activation file onto your license server.

3. Enter the `lsctl license add` command, specifying your `<license-file>`:

    ```text
    /opt/pwx-ls/bin/lsctl license add license-file.bin
    ```

<!-- not verified -->

## Verify licenses

Once you've added your licenses, verify them by entering the `/opt/pwx-ls/bin/lsctl license ls` command:

```text
/opt/pwx-ls/bin/lsctl license ls
```
```output
NAME                COUNT  USED  EXPIRY
Nodes                   5     2  in 78 days
DisasterRecovery        5     0  in 78 days
EnablePlatformBare      5     0  in 78 days
```

<!-- verified -->
